class FileMetadata {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String originalFileName;
  final DateTime uploadDate;

  FileMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.originalFileName,
    required this.uploadDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'tags': tags,
    'originalFileName': originalFileName,
    'uploadDate': uploadDate.toIso8601String(),
  };

  factory FileMetadata.fromJson(Map<String, dynamic> json) => FileMetadata(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    tags: List<String>.from(json['tags']),
    originalFileName: json['originalFileName'],
    uploadDate: DateTime.parse(json['uploadDate']),
  );
} 