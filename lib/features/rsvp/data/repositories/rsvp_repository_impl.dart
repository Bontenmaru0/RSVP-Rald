import '../../../../core/network/safe_remote_call.dart';
import '../../domain/entities/admin_guest_record.dart';
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
  Future<List<AdminGuestRecord>> fetchAdminGuests({
    String? passcode,
    String? name,
    int? guestCount,
    String? confirmationStatus,
    DateTime? datetimeSent,
    DateTime? datetimeUpdatedByAdmin,
  }) {
    return safeRemoteCall(
      () => _remoteDataSource.fetchAdminGuests(
        passcode: passcode,
        name: name,
        guestCount: guestCount,
        confirmationStatus: confirmationStatus,
        datetimeSent: datetimeSent,
        datetimeUpdatedByAdmin: datetimeUpdatedByAdmin,
      ),
    );
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
  Future<String> updateAdminGuestCount({
    required String passcode,
    required int guestCount,
  }) {
    return safeRemoteCall(
      () => _remoteDataSource.updateAdminGuestCount(
        passcode: passcode,
        guestCount: guestCount,
      ),
    );
  }

  @override
  Future<String> updateAdminConfirmationStatus({
    required String passcode,
    required String confirmationStatus,
  }) {
    return safeRemoteCall(
      () => _remoteDataSource.updateAdminConfirmationStatus(
        passcode: passcode,
        confirmationStatus: confirmationStatus,
      ),
    );
  }

  @override
  Future<String> deleteAdminGuests(List<String> passcodes) {
    return safeRemoteCall(() => _remoteDataSource.deleteAdminGuests(passcodes));
  }

  @override
  Future<void> submitResponse(RsvpSubmission submission) {
    return safeRemoteCall(() => _remoteDataSource.submitResponse(submission));
  }
}
