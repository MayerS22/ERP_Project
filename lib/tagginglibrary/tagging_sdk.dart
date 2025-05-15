import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'document_metadata.dart';

class TaggingSDK {
  static const String _documentsDir = 'tagged_documents';

  Future<Directory> _getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final documentsDir = Directory(path.join(appDir.path, _documentsDir));
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    return documentsDir;
  }

  Future<String> createDocument(DocumentMetadata metadata) async {
    try {
      final documentsDir = await _getDocumentsDirectory();
      final documentFile = File(path.join(documentsDir.path, '${metadata.id}.json'));
      await documentFile.writeAsString(jsonEncode(metadata.toJson()));
      return metadata.id;
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<List<DocumentMetadata>> getAllDocuments() async {
    try {
      final documentsDir = await _getDocumentsDirectory();
      final documents = <DocumentMetadata>[];

      await for (final entity in documentsDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final content = await entity.readAsString();
          final metadata = DocumentMetadata.fromJson(jsonDecode(content));
          documents.add(metadata);
        }
      }

      documents.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      return documents;
    } catch (e) {
      throw Exception('Failed to load documents: $e');
    }
  }

  Future<DocumentMetadata?> getDocument(String documentId) async {
    try {
      final documentsDir = await _getDocumentsDirectory();
      final documentFile = File(path.join(documentsDir.path, '$documentId.json'));
      
      if (await documentFile.exists()) {
        final content = await documentFile.readAsString();
        return DocumentMetadata.fromJson(jsonDecode(content));
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  Future<void> updateDocument(DocumentMetadata updatedMetadata) async {
    try {
      final documentsDir = await _getDocumentsDirectory();
      final documentFile = File(path.join(documentsDir.path, '${updatedMetadata.id}.json'));
      
      if (await documentFile.exists()) {
        await documentFile.writeAsString(jsonEncode(updatedMetadata.toJson()));
      } else {
        throw Exception('Document not found');
      }
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final documentsDir = await _getDocumentsDirectory();
      final documentFile = File(path.join(documentsDir.path, '$documentId.json'));
      
      if (await documentFile.exists()) {
        await documentFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Future<List<String>> getAllTags() async {
    try {
      final documents = await getAllDocuments();
      final Set<String> allTags = {};
      
      for (final document in documents) {
        allTags.addAll(document.tags);
      }
      
      final tagsList = allTags.toList();
      tagsList.sort();
      return tagsList;
    } catch (e) {
      throw Exception('Failed to get all tags: $e');
    }
  }

  Future<List<DocumentMetadata>> searchDocumentsByTag(String tag) async {
    try {
      final documents = await getAllDocuments();
      return documents.where((doc) => doc.tags.contains(tag)).toList();
    } catch (e) {
      throw Exception('Failed to search documents by tag: $e');
    }
  }
} 