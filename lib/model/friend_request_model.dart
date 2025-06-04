class FriendRequest {
  final int id;
  final int senderUserId;
  final int receiverUserId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String profileUrl;
  final String displayName;

  FriendRequest({
    required this.id,
    required this.senderUserId,
    required this.receiverUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.profileUrl,
    required this.displayName,
  });

  // Factory method to create an instance from JSON
  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      senderUserId: json['senderUserId'],
      receiverUserId: json['receiverUserId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profileUrl: json['profileUrl'],
      displayName: json['displayName'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUserId': senderUserId,
      'receiverUserId': receiverUserId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileUrl': profileUrl,
      'displayName': displayName,
    };
  }
}