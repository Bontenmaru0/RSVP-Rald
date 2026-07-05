import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/rsvp_submission.dart';
import '../rsvp_supabase_bootstrap.dart';
import 'rsvp_remote_data_source.dart';

class RsvpSupabaseRemoteDataSource implements RsvpRemoteDataSource {
  RsvpSupabaseRemoteDataSource({
    this.tableName = 'invitation_passcodes',
    this.rpcName = 'insert_invitation_passcode',
  });

  final String tableName;
  final String rpcName;

  Future<SupabaseClient> _client() async {
    final initialized = await RsvpSupabaseBootstrap.ensureInitialized();
    if (!initialized) {
      throw const RemoteServiceUnavailableException();
    }

    return Supabase.instance.client;
  }

  @override
  Future<List<RsvpSubmission>> fetchResponses() async {
    final client = await _client();
    final response = await client.from(tableName).select();
    
    return response
        .whereType<Map<String, dynamic>>()
        .map(_toSubmission)
        .toList(growable: false);
  }

  @override
  Future<void> submitResponse(RsvpSubmission submission) async {
    final client = await _client();
    try {
      await client.rpc(
        rpcName,
        params: <String, dynamic>{
          'p_passcode': submission.passcode,
          'p_name': submission.fullName.isEmpty ? null : submission.fullName,
          'p_guests': submission.guestCount,
        },
      );
    } on PostgrestException catch (error) {
      final message = error.message.toLowerCase();
      if (error.code == '23505' ||
          message.contains('already exists') ||
          message.contains('duplicate key value')) {
        throw const DuplicatePasscodeException();
      }
      throw AppException(error.message);
    }
  }

  RsvpSubmission _toSubmission(Map<String, dynamic> row) {
    return RsvpSubmission(
      passcode: row['passcode']?.toString() ?? '',
      fullName: row['name']?.toString() ?? '',
      guestCount: row['guests'] is int
          ? row['guests'] as int
          : int.tryParse(row['guests']?.toString() ?? '') ?? 0,
      isAttending: row['confirmation_status']?.toString() == 'Confirmed',
    );
  }
}
