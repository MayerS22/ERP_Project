import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'folder_model.dart';

class FolderSDK {
  static const String _foldersDir = 'folder_management';

  Future<Directory> _getFoldersDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final foldersDir = Directory(path.join(appDir.path, _foldersDir));
    if (!await foldersDir.exists()) {
      await foldersDir.create(recursive: true);
      
      // Create root folder on first run
      final rootFolder = Folder(
        id: 'root',
        name: 'Root',
        parentId: null,
        creationDate: DateTime.now(),
        childFolderIds: [],
        fileIds: [],
      );
      
      await _saveFolder(rootFolder);
    }
    return foldersDir;
  }

  Future<void> _saveFolder(Folder folder) async {
    final foldersDir = await _getFoldersDirectory();
    final folderFile = File(path.join(foldersDir.path, '${folder.id}.json'));
    await folderFile.writeAsString(jsonEncode(folder.toJson()));
  }

  Future<Folder> createFolder(String name, String? parentId) async {
    if (name.trim().isEmpty) {
      throw Exception('Folder name cannot be empty');
    }

    // Validate parent folder exists if provided
    if (parentId != null) {
      final parentFolder = await getFolder(parentId);
      if (parentFolder == null) {
        throw Exception('Parent folder not found');
      }
    }

    final id = _generateUniqueId();
    final folder = Folder(
      id: id,
      name: name.trim(),
      parentId: parentId ?? 'root',
      creationDate: DateTime.now(),
      childFolderIds: [],
      fileIds: [],
    );

    await _saveFolder(folder);

    // Update parent folder to include this child
    if (parentId != null) {
      final parentFolder = await getFolder(parentId);
      if (parentFolder != null) {
        final updatedParent = Folder(
          id: parentFolder.id,
          name: parentFolder.name,
          parentId: parentFolder.parentId,
          creationDate: parentFolder.creationDate,
          childFolderIds: [...parentFolder.childFolderIds, id],
          fileIds: parentFolder.fileIds,
        );
        await _saveFolder(updatedParent);
      }
    }

    return folder;
  }

  Future<Folder?> getFolder(String id) async {
    try {
      final foldersDir = await _getFoldersDirectory();
      final folderFile = File(path.join(foldersDir.path, '$id.json'));
      
      if (!await folderFile.exists()) {
        return null;
      }
      
      final content = await folderFile.readAsString();
      return Folder.fromJson(jsonDecode(content));
    } catch (e) {
      print('Error getting folder: $e');
      return null;
    }
  }

  Future<List<Folder>> getFolders({String? parentId}) async {
    try {
      final foldersDir = await _getFoldersDirectory();
      final folders = <Folder>[];

      await for (final entity in foldersDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final content = await entity.readAsString();
          final folder = Folder.fromJson(jsonDecode(content));
          
          // Filter by parentId if specified
          if (parentId == null || folder.parentId == parentId) {
            folders.add(folder);
          }
        }
      }

      folders.sort((a, b) => a.name.compareTo(b.name));
      return folders;
    } catch (e) {
      print('Error listing folders: $e');
      return [];
    }
  }

  Future<bool> updateFolder(String id, String newName) async {
    try {
      final folder = await getFolder(id);
      if (folder == null) {
        return false;
      }

      if (newName.trim().isEmpty) {
        throw Exception('Folder name cannot be empty');
      }

      final updatedFolder = Folder(
        id: folder.id,
        name: newName.trim(),
        parentId: folder.parentId,
        creationDate: folder.creationDate,
        childFolderIds: folder.childFolderIds,
        fileIds: folder.fileIds,
      );

      await _saveFolder(updatedFolder);
      return true;
    } catch (e) {
      print('Error updating folder: $e');
      return false;
    }
  }

  Future<bool> deleteFolder(String id) async {
    try {
      // Don't allow deleting root folder
      if (id == 'root') {
        return false;
      }
      
      final folder = await getFolder(id);
      if (folder == null) {
        return false;
      }

      // Don't allow deleting folders with children
      if (folder.childFolderIds.isNotEmpty || folder.fileIds.isNotEmpty) {
        throw Exception('Cannot delete folder with children or files');
      }

      // Remove this folder from parent's children list
      if (folder.parentId != null) {
        final parentFolder = await getFolder(folder.parentId!);
        if (parentFolder != null) {
          final updatedParent = Folder(
            id: parentFolder.id,
            name: parentFolder.name,
            parentId: parentFolder.parentId,
            creationDate: parentFolder.creationDate,
            childFolderIds: parentFolder.childFolderIds.where((childId) => childId != id).toList(),
            fileIds: parentFolder.fileIds,
          );
          await _saveFolder(updatedParent);
        }
      }

      // Delete folder file
      final foldersDir = await _getFoldersDirectory();
      final folderFile = File(path.join(foldersDir.path, '$id.json'));
      if (await folderFile.exists()) {
        await folderFile.delete();
      }
      
      return true;
    } catch (e) {
      print('Error deleting folder: $e');
      return false;
    }
  }

  Future<List<Folder>> getBreadcrumbPath(String folderId) async {
    final List<Folder> path = [];
    String? currentId = folderId;
    
    while (currentId != null) {
      final folder = await getFolder(currentId);
      if (folder == null) break;
      
      path.insert(0, folder);
      currentId = folder.parentId;
    }
    
    return path;
  }

  String _generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(10000);
    return 'folder_${timestamp}_$randomNumber';
  }
} 