import '../../domain/entities/rsvp_submission.dart';

abstract class RsvpRemoteDataSource {
  Future<void> submitResponse(RsvpSubmission submission);
  Future<List<RsvpSubmission>> fetchResponses();
}
