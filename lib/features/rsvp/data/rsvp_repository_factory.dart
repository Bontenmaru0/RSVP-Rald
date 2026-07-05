import '../domain/repositories/rsvp_repository.dart';
import 'datasources/rsvp_supabase_remote_data_source.dart';
import 'repositories/rsvp_repository_impl.dart';

RsvpRepository createRsvpRepository() {
  return RsvpRepositoryImpl(RsvpSupabaseRemoteDataSource());
}
