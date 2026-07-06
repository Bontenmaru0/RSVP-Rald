class AdminGuestRecord {
  const AdminGuestRecord({
    required this.id,
    required this.passcode,
    required this.fullName,
    required this.guestCount,
    required this.confirmationStatus,
    required this.datetimeSentIso8601,
    required this.datetimeUpdatedByAdminIso8601,
  });

  final int id;
  final String passcode;
  final String fullName;
  final int guestCount;
  final String confirmationStatus;
  final String datetimeSentIso8601;
  final String datetimeUpdatedByAdminIso8601;
}
