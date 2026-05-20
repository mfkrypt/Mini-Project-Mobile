class ExhibitorApplication {
  const ExhibitorApplication({
    this.id,
    required this.eventId,
    required this.exhibitorId,
    required this.companyName,
    required this.companyDescription,
    required this.exhibitDescription,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.status,
    required this.submittedAt,
    required this.totalPrice,
    this.decisionReason,
    this.eventName,
    this.boothLabel,
    this.exhibitorName,
  });

  final int? id;
  final int eventId;
  final int exhibitorId;
  final String companyName;
  final String companyDescription;
  final String exhibitDescription;
  final String eventStartDate;
  final String eventEndDate;
  final String status;
  final String submittedAt;
  final double totalPrice;
  final String? decisionReason;
  final String? eventName;
  final String? boothLabel;
  final String? exhibitorName;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'exhibitor_id': exhibitorId,
      'company_name': companyName,
      'company_desc': companyDescription,
      'exhibit_desc': exhibitDescription,
      'event_start_date': eventStartDate,
      'event_end_date': eventEndDate,
      'status': status,
      'submitted_at': submittedAt,
      'decision_reason': decisionReason,
      'total_price': totalPrice,
    };
  }

  static ExhibitorApplication fromMap(Map<String, Object?> map) {
    return ExhibitorApplication(
      id: map['id'] as int?,
      eventId: map['event_id'] as int,
      exhibitorId: map['exhibitor_id'] as int,
      companyName: map['company_name'] as String,
      companyDescription: map['company_desc'] as String,
      exhibitDescription: map['exhibit_desc'] as String,
      eventStartDate: map['event_start_date'] as String,
      eventEndDate: map['event_end_date'] as String,
      status: map['status'] as String,
      submittedAt: map['submitted_at'] as String,
      decisionReason: map['decision_reason'] as String?,
      totalPrice: (map['total_price'] as num).toDouble(),
      eventName: map['event_name'] as String?,
      boothLabel: map['booth_label'] as String?,
      exhibitorName: map['exhibitor_name'] as String?,
    );
  }
}
