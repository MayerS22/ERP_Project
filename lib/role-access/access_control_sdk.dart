import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'access_control_metadata.dart';

class AccessControlSDK {
  static const String _metadataDir = 'access_control_metadata';

  Future<Directory> _getMetadataDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final metadataDir = Directory(path.join(appDir.path, _metadataDir));
    if (!await metadataDir.exists()) {
      await metadataDir.create(recursive: true);
    }
    return metadataDir;
  }

  Future<String> assignPermission(AccessControlMetadata metadata) async {
    try {
      final metadataDir = await _getMetadataDirectory();
      final metadataFile = File(path.join(metadataDir.path, '${metadata.id}.json'));
      await metadataFile.writeAsString(jsonEncode(metadata.toJson()));
      return metadata.id;
    } catch (e) {
      throw Exception('Failed to assign permission: $e');
    }
  }

  Future<List<AccessControlMetadata>> getAllPermissions() async {
    try {
      final metadataDir = await _getMetadataDirectory();
      final permissions = <AccessControlMetadata>[];

      await for (final entity in metadataDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final content = await entity.readAsString();
          final metadata = AccessControlMetadata.fromJson(jsonDecode(content));
          permissions.add(metadata);
        }
      }

      permissions.sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
      return permissions;
    } catch (e) {
      throw Exception('Failed to load permissions: $e');
    }
  }

  Future<List<AccessControlMetadata>> getPermissionsByDocument(String documentId) async {
    try {
      final allPermissions = await getAllPermissions();
      return allPermissions.where((permission) => permission.documentId == documentId).toList();
    } catch (e) {
      throw Exception('Failed to get permissions for document: $e');
    }
  }

  Future<List<AccessControlMetadata>> getPermissionsByUser(String userId) async {
    try {
      final allPermissions = await getAllPermissions();
      return allPermissions.where((permission) => permission.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get permissions for user: $e');
    }
  }

  Future<void> updatePermission(AccessControlMetadata updatedMetadata) async {
    try {
      final metadataDir = await _getMetadataDirectory();
      final metadataFile = File(path.join(metadataDir.path, '${updatedMetadata.id}.json'));
      
      if (await metadataFile.exists()) {
        await metadataFile.writeAsString(jsonEncode(updatedMetadata.toJson()));
      } else {
        throw Exception('Permission does not exist');
      }
    } catch (e) {
      throw Exception('Failed to update permission: $e');
    }
  }

  Future<void> revokePermission(String permissionId) async {
    try {
      final metadataDir = await _getMetadataDirectory();
      final metadataFile = File(path.join(metadataDir.path, '$permissionId.json'));
      
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to revoke permission: $e');
    }
  }

  Future<void> revokeAllPermissionsForDocument(String documentId) async {
    try {
      final documentPermissions = await getPermissionsByDocument(documentId);
      for (final permission in documentPermissions) {
        await revokePermission(permission.id);
      }
    } catch (e) {
      throw Exception('Failed to revoke all permissions for document: $e');
    }
  }
} 