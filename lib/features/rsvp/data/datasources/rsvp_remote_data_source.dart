import '../../domain/entities/rsvp_submission.dart';
import '../../domain/entities/admin_guest_record.dart';

abstract class RsvpRemoteDataSource {
  Future<void> submitResponse(RsvpSubmission submission);
  Future<List<RsvpSubmission>> fetchResponses();
  Future<RsvpSubmission> fetchResponseByPasscode(String passcode);
  Future<bool> isAdminPasscode(String passcode);
  Future<List<AdminGuestRecord>> fetchAdminGuests({
    String? passcode,
    String? name,
    int? guestCount,
    String? confirmationStatus,
    DateTime? datetimeSent,
    DateTime? datetimeUpdatedByAdmin,
    String sortDirection,
  });
  Future<String> updateAdminGuestCount({
    required String passcode,
    required int guestCount,
  });
  Future<String> updateAdminConfirmationStatus({
    required String passcode,
    required String confirmationStatus,
  });
  Future<String> deleteAdminGuests(List<String> passcodes);
}
