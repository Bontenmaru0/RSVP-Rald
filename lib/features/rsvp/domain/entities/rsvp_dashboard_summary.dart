class RsvpDashboardSummary {
  const RsvpDashboardSummary({
    required this.totalInvitations,
    required this.confirmedInvitations,
    required this.declinedInvitations,
    required this.forConfirmationInvitations,
    required this.totalGuests,
    required this.confirmedGuests,
    required this.declinedGuests,
    required this.forConfirmationGuests,
  });

  final int totalInvitations;
  final int confirmedInvitations;
  final int declinedInvitations;
  final int forConfirmationInvitations;
  final int totalGuests;
  final int confirmedGuests;
  final int declinedGuests;
  final int forConfirmationGuests;
}
