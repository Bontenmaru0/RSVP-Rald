import '../../../../core/network/safe_remote_call.dart';
import '../../domain/entities/rsvp_submission.dart';
import '../../domain/repositories/rsvp_repository.dart';
import '../datasources/rsvp_remote_data_source.dart';

class RsvpRepositoryImpl implements RsvpRepository {
  const RsvpRepositoryImpl(this._remoteDataSource);

  final RsvpRemoteDataSource _remoteDataSource;

  @override
  Future<List<RsvpSubmission>> fetchResponses() {
    return safeRemoteCall(_remoteDataSource.fetchResponses);
  }

  @override
  Future<RsvpSubmission> fetchResponseByPasscode(String passcode) {
    return safeRemoteCall(() => _remoteDataSource.fetchResponseByPasscode(passcode));
  }

  @override
  Future<bool> isAdminPasscode(String passcode) {
    return safeRemoteCall(() => _remoteDataSource.isAdminPasscode(passcode));
  }

  @override
  Future<void> submitResponse(RsvpSubmission submission) {
    return safeRemoteCall(() => _remoteDataSource.submitResponse(submission));
  }
}
