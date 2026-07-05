class RsvpSubmission {
  const RsvpSubmission({
    required this.passcode,
    required this.fullName,
    required this.guestCount,
    required this.isAttending,
    this.submittedAtIso8601 = '',
    this.confirmationStatus = '',
  });

  final String passcode;
  final String fullName;
  final int guestCount;
  final bool isAttending;
  final String submittedAtIso8601;
  final String confirmationStatus;
}
