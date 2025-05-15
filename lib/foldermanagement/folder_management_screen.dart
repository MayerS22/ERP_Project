import 'package:flutter/material.dart';
import 'folder_model.dart';
import 'folder_sdk.dart';

class FolderManagementScreen extends StatefulWidget {
  @override
  _FolderManagementScreenState createState() => _FolderManagementScreenState();
}

class _FolderManagementScreenState extends State<FolderManagementScreen> {
  final FolderSDK _folderSDK = FolderSDK();
  final TextEditingController _folderNameController = TextEditingController();
  
  List<Folder> _folders = [];
  String _currentFolderId = 'root';
  Folder? _currentFolder;
  List<Folder> _breadcrumbPath = [];
  bool _isLoading = true;
  bool _isCreatingFolder = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentFolder();
  }

  Future<void> _loadCurrentFolder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final folder = await _folderSDK.getFolder(_currentFolderId);
      final folders = await _folderSDK.getFolders(parentId: _currentFolderId);
      final path = await _folderSDK.getBreadcrumbPath(_currentFolderId);
      
      setState(() {
        _currentFolder = folder;
        _folders = folders;
        _breadcrumbPath = path;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading folder: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToFolder(String folderId) {
    setState(() {
      _currentFolderId = folderId;
    });
    _loadCurrentFolder();
  }

  Future<void> _createFolder() async {
    final folderName = _folderNameController.text.trim();
    if (folderName.isEmpty) return;

    setState(() {
      _isCreatingFolder = true;
    });

    try {
      await _folderSDK.createFolder(folderName, _currentFolderId);
      _folderNameController.clear();
      _loadCurrentFolder();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Folder created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating folder: $e')),
      );
    } finally {
      setState(() {
        _isCreatingFolder = false;
      });
    }
  }

  Future<void> _renameFolder(Folder folder) async {
    final TextEditingController controller = TextEditingController(text: folder.name);
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Folder'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Folder Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  
                  try {
                    final success = await _folderSDK.updateFolder(folder.id, newName);
                    if (success) {
                      _loadCurrentFolder();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Folder renamed successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to rename folder')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text('RENAME'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFolder(Folder folder) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure you want to delete "${folder.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                try {
                  final success = await _folderSDK.deleteFolder(folder.id);
                  if (success) {
                    _loadCurrentFolder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Folder deleted successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete folder')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folder Management', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs navigation
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _breadcrumbPath.asMap().entries.map((entry) {
                        final index = entry.key;
                        final folder = entry.value;
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _navigateToFolder(folder.id),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: index == _breadcrumbPath.length - 1
                                      ? Colors.indigo.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  folder.name,
                                  style: TextStyle(
                                    color: Colors.indigo[800],
                                    fontWeight: index == _breadcrumbPath.length - 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            if (index < _breadcrumbPath.length - 1)
                              Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // New folder creation
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _folderNameController,
                          decoration: InputDecoration(
                            labelText: 'New Folder Name',
                            labelStyle: TextStyle(color: Colors.indigo),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isCreatingFolder ? null : _createFolder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isCreatingFolder
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.create_new_folder),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            // Folder list
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _folders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                size: 64,
                                color: Colors.indigo.withOpacity(0.3),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No folders found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create a new folder to get started',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: _folders.length,
                          itemBuilder: (context, index) {
                            final folder = _folders[index];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.folder,
                                  color: Colors.amber[700],
                                  size: 36,
                                ),
                                title: Text(
                                  folder.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${folder.childFolderIds.length} folders, ${folder.fileIds.length} files',
                                  style: TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.indigo),
                                      onPressed: () => _renameFolder(folder),
                                      tooltip: 'Rename',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                                      onPressed: () => _deleteFolder(folder),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                                onTap: () => _navigateToFolder(folder.id),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
} 