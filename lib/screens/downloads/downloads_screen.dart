import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import 'package:cdegad_kp/core/api/api_endpoints.dart';
import 'package:cdegad_kp/core/api/dio_client.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool _isLoading = true;
  bool _isUploading = false;
  String? _loadError;
  List<Map<String, dynamic>> files = [];
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final response = await ref.read(dioClientProvider).get(ApiEndpoints.downloads);
      final data = (response.data is Map && response.data['data'] is List)
          ? response.data['data'] as List
          : <dynamic>[];
      if (!mounted) return;
      setState(() {
        files = data.map((e) {
          final row = (e as Map).cast<String, dynamic>();
          final name = (row['original_name'] ?? row['filename'] ?? 'file').toString();
          return {
            'id': (row['id'] ?? '').toString(),
            'name': name,
            'filename': (row['filename'] ?? '').toString(),
            'type': _extensionOf(name),
            'size': _formatSize((row['size'] ?? 0).toString()),
            'date': _shortDate((row['created_at'] ?? '').toString()),
            'icon': _getFileIcon(_extensionOf(name)),
            'color': _getFileColor(_extensionOf(name)),
          };
        }).toList();
        _isLoading = false;
      });
      _loadingController.stop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
      _loadingController.stop();
    }
  }

  String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1);
  }

  String _formatSize(String bytes) {
    final n = double.tryParse(bytes) ?? 0;
    if (n >= 1024 * 1024) return '${(n / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (n >= 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
    return '$n B';
  }

  String _shortDate(String value) {
    final m = RegExp(r'^(\d{4}-\d{2}-\d{2})').firstMatch(value.trim());
    return m?.group(1) ?? value;
  }

  Future<void> _uploadFile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);
        final file = result.files.single;
        final multipart = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
        await ref.read(dioClientProvider).postMultipart(
              ApiEndpoints.upload,
              fields: const {},
              files: [multipart],
              fileFieldName: 'file',
            );
        if (!mounted) return;
        setState(() => _isUploading = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('${file.name} uploaded successfully')),
        );
        _loadFiles();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.blue;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.purple;
      case 'mp3':
      case 'wav':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Downloading ${file['name']}...'),
          duration: const Duration(seconds: 1),
        ),
      );
      final stored = file['filename'] as String? ?? file['name'];
      final response = await ref
          .read(dioClientProvider)
          .downloadBytes(ApiEndpoints.uploadFile(stored));
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Empty response from server');
      }
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }
      final filePath = '${downloadsDir.path}/${file['name']}';
      final f = File(filePath);
      f.writeAsBytesSync(bytes);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Saved to: $filePath'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _confirmDelete(int index) async {
    final file = files[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete File"),
        content: Text("Are you sure you want to delete '${file['name']}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(dioClientProvider)
            .delete(ApiEndpoints.downloadsById((file['id'] ?? '').toString()));
        if (!mounted) return;
        setState(() {
          files.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFiles = files.where((file) {
      return file['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads - Department Records'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            if (_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _loadingController.value * 2 * 3.14159,
                            child: Icon(
                              Icons.download,
                              size: 80,
                              color: Colors.green.shade700,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading records...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_loadError != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 72, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load records',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _loadError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: _loadFiles,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search records...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredFiles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'No records uploaded yet'
                                        : 'No records found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredFiles.length,
                              itemBuilder: (context, index) {
                                final file = filteredFiles[index];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: file['color'].withOpacity(0.2),
                                      child: Icon(
                                        file['icon'],
                                        color: file['color'],
                                      ),
                                    ),
                                    title: Text(
                                      file['name'],
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text('${file['size']} • ${file['date']}'),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.download, size: 20),
                                              SizedBox(width: 8),
                                              Text('Download'),
                                            ],
                                          ),
                                          onTap: () => _downloadFile(file),
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.delete, size: 20, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                          onTap: () => _confirmDelete(files.indexOf(file)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _uploadFile,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.upload_file),
        label: Text(_isUploading ? 'Uploading...' : 'Upload File'),
      ),
    );
  }
}
