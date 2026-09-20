class JobMessage {
  const JobMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
}
