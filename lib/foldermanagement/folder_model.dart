class Folder {
  final String id;
  final String name;
  final String? parentId;
  final DateTime creationDate;
  final List<String> childFolderIds;
  final List<String> fileIds;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.creationDate,
    required this.childFolderIds,
    required this.fileIds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parentId': parentId,
    'creationDate': creationDate.toIso8601String(),
    'childFolderIds': childFolderIds,
    'fileIds': fileIds,
  };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    id: json['id'],
    name: json['name'],
    parentId: json['parentId'],
    creationDate: DateTime.parse(json['creationDate']),
    childFolderIds: List<String>.from(json['childFolderIds']),
    fileIds: List<String>.from(json['fileIds']),
  );
} 