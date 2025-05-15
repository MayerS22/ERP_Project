class Document {
  final String id;
  final String title;
  final String fileName;
  final DateTime uploadDate;

  Document({
    required this.id,
    required this.title,
    required this.fileName,
    required this.uploadDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'fileName': fileName,
    'uploadDate': uploadDate.toIso8601String(),
  };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'],
    title: json['title'],
    fileName: json['fileName'],
    uploadDate: DateTime.parse(json['uploadDate']),
  );
}

// Mock documents for demonstration purposes
List<Document> getMockDocuments() {
  return [
    Document(
      id: 'doc1',
      title: 'Project Proposal',
      fileName: 'project_proposal.pdf',
      uploadDate: DateTime.now().subtract(Duration(days: 10)),
    ),
    Document(
      id: 'doc2',
      title: 'Financial Report Q1',
      fileName: 'financial_report_q1.xlsx',
      uploadDate: DateTime.now().subtract(Duration(days: 7)),
    ),
    Document(
      id: 'doc3',
      title: 'Technical Specifications',
      fileName: 'tech_specs.docx',
      uploadDate: DateTime.now().subtract(Duration(days: 5)),
    ),
    Document(
      id: 'doc4',
      title: 'Marketing Strategy',
      fileName: 'marketing_strategy.pptx',
      uploadDate: DateTime.now().subtract(Duration(days: 3)),
    ),
    Document(
      id: 'doc5',
      title: 'User Research Results',
      fileName: 'user_research.pdf',
      uploadDate: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];
} 