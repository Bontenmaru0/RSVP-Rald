class RsvpSubmission {
  const RsvpSubmission({
    required this.fullName,
    required this.isAttending,
    required this.message,
    required this.submittedAtIso8601,
  });

  final String fullName;
  final bool isAttending;
  final String message;
  final String submittedAtIso8601;
}
