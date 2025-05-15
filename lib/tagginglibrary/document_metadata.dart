class DocumentMetadata {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final DateTime creationDate;
  final DateTime lastUpdated;

  DocumentMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.creationDate,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'tags': tags,
    'creationDate': creationDate.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) => DocumentMetadata(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    tags: List<String>.from(json['tags']),
    creationDate: DateTime.parse(json['creationDate']),
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );

  DocumentMetadata copyWith({
    String? title,
    String? description,
    List<String>? tags,
    DateTime? lastUpdated,
  }) {
    return DocumentMetadata(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      creationDate: this.creationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
} 