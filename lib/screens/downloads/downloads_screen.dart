import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool _isLoading = true;
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
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      files = [
        {
          "name": "Annual Report 2024.pdf",
          "type": "pdf",
          "size": "2.5 MB",
          "date": "2024-12-15",
          "icon": Icons.picture_as_pdf,
          "color": Colors.red,
        },
        {
          "name": "Forest Coverage Map.jpg",
          "type": "image",
          "size": "1.8 MB",
          "date": "2024-11-20",
          "icon": Icons.image,
          "color": Colors.blue,
        },
        {
          "name": "Tree Plantation Video.mp4",
          "type": "video",
          "size": "15.2 MB",
          "date": "2024-10-10",
          "icon": Icons.videocam,
          "color": Colors.purple,
        },
        {
          "name": "Budget Document 2025.docx",
          "type": "doc",
          "size": "850 KB",
          "date": "2025-01-05",
          "icon": Icons.description,
          "color": Colors.blue,
        },
      ];
      _isLoading = false;
    });
    _loadingController.stop();
  }

  Future<void> _uploadFile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          files.add({
            "name": file.name,
            "type": file.extension ?? "file",
            "size": "${(file.size / 1024).toStringAsFixed(2)} KB",
            "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
            "icon": _getFileIcon(file.extension ?? ""),
            "color": _getFileColor(file.extension ?? ""),
          });
        });

        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('${file.name} uploaded successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${file['name']}...')),
    );
  }

  Future<void> _deleteFile(int index) async {
    setState(() {
      files.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File deleted successfully')),
    );
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
                                          onTap: () => _deleteFile(files.indexOf(file)),
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
        onPressed: _uploadFile,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload File'),
      ),
    );
  }
}
