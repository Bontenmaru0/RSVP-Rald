import '../../domain/entities/rsvp_submission.dart';
import '../../domain/repositories/rsvp_repository.dart';
import '../datasources/rsvp_remote_data_source.dart';

class RsvpRepositoryImpl implements RsvpRepository {
  const RsvpRepositoryImpl(this._remoteDataSource);

  final RsvpRemoteDataSource _remoteDataSource;

  @override
  Future<List<RsvpSubmission>> fetchResponses() {
    return _remoteDataSource.fetchResponses();
  }

  @override
  Future<void> submitResponse(RsvpSubmission submission) {
    return _remoteDataSource.submitResponse(submission);
  }
}
