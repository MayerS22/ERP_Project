class AccessControlMetadata {
  final String id;
  final String documentId;
  final String userId;
  final String userName;
  final String permissionLevel; // "view", "edit", "download"
  final DateTime assignedDate;

  AccessControlMetadata({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.userName,
    required this.permissionLevel,
    required this.assignedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'documentId': documentId,
    'userId': userId,
    'userName': userName,
    'permissionLevel': permissionLevel,
    'assignedDate': assignedDate.toIso8601String(),
  };

  factory AccessControlMetadata.fromJson(Map<String, dynamic> json) => AccessControlMetadata(
    id: json['id'],
    documentId: json['documentId'],
    userId: json['userId'],
    userName: json['userName'],
    permissionLevel: json['permissionLevel'],
    assignedDate: DateTime.parse(json['assignedDate']),
  );
} 