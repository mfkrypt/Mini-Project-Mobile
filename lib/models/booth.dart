class Booth {
  Booth({
    required this.id,
    required this.status,
    required this.price,
    required this.typeName,
    required this.sizeLabel,
    required this.eventId,
    required this.eventName,
  });

  String id;
  String status;
  double price;
  String typeName;
  String sizeLabel;
  int eventId;
  String eventName;
}