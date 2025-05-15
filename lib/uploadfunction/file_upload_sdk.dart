import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'file_metadata.dart';

class FileUploadSDK {
  static const String _metadataDir = 'uploaded_files_metadata';
  static const String _filesDir = 'uploaded_files';

  Future<Directory> _getMetadataDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final metadataDir = Directory(path.join(appDir.path, _metadataDir));
    if (!await metadataDir.exists()) {
      await metadataDir.create(recursive: true);
    }
    return metadataDir;
  }

  Future<Directory> _getFilesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final filesDir = Directory(path.join(appDir.path, _filesDir));
    if (!await filesDir.exists()) {
      await filesDir.create(recursive: true);
    }
    return filesDir;
  }

  Future<String> uploadFile(File file, FileMetadata metadata) async {
    try {
      final filesDir = await _getFilesDirectory();
      final metadataDir = await _getMetadataDirectory();

      final fileExtension = path.extension(file.path);
      final storedFileName = '${metadata.id}$fileExtension';
      final storedFile = File(path.join(filesDir.path, storedFileName));

      await file.copy(storedFile.path);

      final metadataFile = File(path.join(metadataDir.path, '${metadata.id}.json'));
      await metadataFile.writeAsString(jsonEncode(metadata.toJson()));

      return metadata.id;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<List<FileMetadata>> getUploadedFiles() async {
    try {
      final metadataDir = await _getMetadataDirectory();
      final files = <FileMetadata>[];

      await for (final entity in metadataDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final content = await entity.readAsString();
          final metadata = FileMetadata.fromJson(jsonDecode(content));
          files.add(metadata);
        }
      }

      files.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
      return files;
    } catch (e) {
      throw Exception('Failed to load uploaded files: $e');
    }
  }

  Future<File?> getFile(String fileId) async {
    try {
      final filesDir = await _getFilesDirectory();
      
      await for (final entity in filesDir.list()) {
        if (entity is File && path.basenameWithoutExtension(entity.path) == fileId) {
          return entity;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get file: $e');
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final filesDir = await _getFilesDirectory();
      final metadataDir = await _getMetadataDirectory();

      final metadataFile = File(path.join(metadataDir.path, '$fileId.json'));
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      await for (final entity in filesDir.list()) {
        if (entity is File && path.basenameWithoutExtension(entity.path) == fileId) {
          await entity.delete();
          break;
        }
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
} 