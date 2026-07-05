import '../entities/rsvp_submission.dart';

abstract class RsvpRepository {
  Future<void> submitResponse(RsvpSubmission submission);
  Future<List<RsvpSubmission>> fetchResponses();
  Future<RsvpSubmission> fetchResponseByPasscode(String passcode);
}
