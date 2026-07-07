import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/admin_guest_record.dart';
import '../../domain/entities/rsvp_dashboard_summary.dart';
import '../../domain/entities/rsvp_submission.dart';
import '../rsvp_supabase_bootstrap.dart';
import 'rsvp_remote_data_source.dart';

class RsvpSupabaseRemoteDataSource implements RsvpRemoteDataSource {
  RsvpSupabaseRemoteDataSource({
    this.tableName = 'invitation_passcodes',
    this.rpcName = 'insert_invitation_passcode',
    this.statusRpcName = 'get_invitation_by_passcode',
    this.adminStatusRpcName = 'is_admin_passcode',
    this.dashboardSummaryRpcName = 'admin_get_dashboard_summary',
  });

  final String tableName;
  final String rpcName;
  final String statusRpcName;
  final String adminStatusRpcName;
  final String dashboardSummaryRpcName;

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
  Future<List<AdminGuestRecord>> fetchAdminGuests({
    String? passcode,
    String? name,
    int? guestCount,
    String? confirmationStatus,
    DateTime? datetimeSent,
    DateTime? datetimeUpdatedByAdmin,
    String sortDirection = 'ASC',
  }) async {
    final client = await _client();
    try {
      final response = await client.rpc(
        'admin_get_guests',
        params: <String, dynamic>{
          'p_passcode': passcode,
          'p_name': name,
          'p_guests': guestCount,
          'p_confirmation_status': confirmationStatus,
          'p_datetime_sent': datetimeSent?.toIso8601String().split('T').first,
          'p_datetime_updated_by_admin':
              datetimeUpdatedByAdmin?.toIso8601String().split('T').first,
          'p_sort_direction': sortDirection,
        },
      );

      if (response is List) {
        return response
            .whereType<Map<String, dynamic>>()
            .map(_toAdminGuestRecord)
            .toList(growable: false);
      }

      throw const InvalidRemoteResponseException();
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<RsvpDashboardSummary> fetchAdminDashboardSummary() async {
    final client = await _client();
    try {
      final response = await client.rpc(dashboardSummaryRpcName);

      if (response is Map<String, dynamic>) {
        return _toDashboardSummary(response);
      }

      if (response is List && response.isNotEmpty) {
        final first = response.first;
        if (first is Map<String, dynamic>) {
          return _toDashboardSummary(first);
        }
      }

      throw const InvalidRemoteResponseException();
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<RsvpSubmission> fetchResponseByPasscode(String passcode) async {
    final client = await _client();
    try {
      final response = await client.rpc(
        statusRpcName,
        params: <String, dynamic>{
          'p_passcode': passcode,
        },
      );

      if (response is Map<String, dynamic>) {
        return _toSubmission(response);
      }

      if (response is List && response.isNotEmpty) {
        final first = response.first;
        if (first is Map<String, dynamic>) {
          return _toSubmission(first);
        }
      }

      throw const InvalidRemoteResponseException();
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<bool> isAdminPasscode(String passcode) async {
    final client = await _client();
    try {
      final response = await client.rpc(
        adminStatusRpcName,
        params: <String, dynamic>{
          'p_passcode': passcode,
        },
      );

      if (response is bool) {
        return response;
      }

      throw const InvalidRemoteResponseException();
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<String> updateAdminGuestCount({
    required String passcode,
    required int guestCount,
  }) async {
    final client = await _client();
    try {
      final response = await client.rpc(
        'admin_update_guest_count',
        params: <String, dynamic>{
          'p_passcode': passcode,
          'p_guests': guestCount,
        },
      );
      return response?.toString() ?? '';
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<String> updateAdminConfirmationStatus({
    required String passcode,
    required String confirmationStatus,
  }) async {
    final client = await _client();
    try {
      final response = await client.rpc(
        'admin_update_confirmation_status',
        params: <String, dynamic>{
          'p_passcode': passcode,
          'p_status': confirmationStatus,
        },
      );
      return response?.toString() ?? '';
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<String> deleteAdminGuests(List<String> passcodes) async {
    final client = await _client();
    try {
      final response = await client.rpc(
        'admin_delete_guests',
        params: <String, dynamic>{
          'p_passcodes': passcodes,
        },
      );
      return response?.toString() ?? '';
    } on PostgrestException catch (error) {
      throw AppException(error.message);
    }
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
      confirmationStatus: row['confirmation_status']?.toString() ?? '',
      submittedAtIso8601: row['datetime_sent']?.toString() ?? '',
    );
  }

  AdminGuestRecord _toAdminGuestRecord(Map<String, dynamic> row) {
    return AdminGuestRecord(
      id: row['id'] is int ? row['id'] as int : int.tryParse('${row['id']}') ?? 0,
      passcode: row['passcode']?.toString() ?? '',
      fullName: row['name']?.toString() ?? '',
      guestCount: row['guests'] is int
          ? row['guests'] as int
          : int.tryParse(row['guests']?.toString() ?? '') ?? 0,
      confirmationStatus: row['confirmation_status']?.toString() ?? '',
      datetimeSentIso8601: row['datetime_sent']?.toString() ?? '',
      datetimeUpdatedByAdminIso8601:
          row['datetime_updated_by_admin']?.toString() ?? '',
    );
  }

  RsvpDashboardSummary _toDashboardSummary(Map<String, dynamic> row) {
    int parseCount(String key) {
      final value = row[key];
      return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return RsvpDashboardSummary(
      totalInvitations: parseCount('total_invitations'),
      confirmedInvitations: parseCount('confirmed_invitations'),
      declinedInvitations: parseCount('declined_invitations'),
      forConfirmationInvitations: parseCount('for_confirmation_invitations'),
      totalGuests: parseCount('total_guests'),
      confirmedGuests: parseCount('confirmed_guests'),
      declinedGuests: parseCount('declined_guests'),
      forConfirmationGuests: parseCount('for_confirmation_guests'),
    );
  }
}
