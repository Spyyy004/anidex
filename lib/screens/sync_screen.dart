import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../models/animal_info.dart';
import '../utils.dart';
import 'animal_info.dart';

class LocalScanItem {
  final String imagePath;
  bool isSubmitted;

  LocalScanItem({required this.imagePath, this.isSubmitted = false});
}

class SyncDataPage extends StatefulWidget {
  @override
  _SyncDataPageState createState() => _SyncDataPageState();
}

class _SyncDataPageState extends State<SyncDataPage> {
  late List<LocalScanItem> localScans = [];

  @override
  void initState() {
    super.initState();
    _loadLocalScans();
  }

  Future<void> _loadLocalScans() async {
    try {
      // Get the local app directory path using path_provider
      final directory = await getApplicationDocumentsDirectory();

      // Ensure the directory exists
      if (!await Directory(directory.path).exists()) {
        print('Directory does not exist: ${directory.path}');
        return;
      }

      // Fetch local scans
      List<LocalScanItem> scans = await fetchLocalScans(directory.path);

      // Update the state with the fetched scans
      setState(() {
        localScans = scans;
      });
    } catch (e) {
      print('Error loading local scans: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync Data'),
      ),
      body: localScans.isNotEmpty
          ? FutureBuilder<void>(
        future: _loadLocalScans(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: localScans.length,
            itemBuilder: (context, index) {
              return _buildListItem(localScans[index]);
            },
          );
        },
      )
          : Center(
        child: Text('No local scans found.'),
      ),
    );
  }

  Widget _buildListItem(LocalScanItem scanItem) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: AnimatedOpacity(
        opacity: scanItem.isSubmitted ? 0.5 : 1.0,
        duration: Duration(milliseconds: 500),
        child: ListTile(
          leading: Image.file(File(scanItem.imagePath)),
          title: Text(scanItem.imagePath.split('/').last), // Display file name
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  _submitScan(scanItem);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteScan(scanItem);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<LocalScanItem>> fetchLocalScans(String directoryPath) async {
    List<LocalScanItem> localScans = [];

    try {
      Directory directory = Directory(directoryPath);
      List<FileSystemEntity> files = directory.listSync();

      for (var file in files) {
        if (file is File) {
          localScans.add(LocalScanItem(imagePath: file.path));
        }
      }
    } catch (e) {
      print('Error fetching local scans: $e');
    }

    return localScans;
  }

  void _submitScan(LocalScanItem scanItem) {
    setState(() {
      scanItem.isSubmitted = true;
    });

    print('Submitting scan: ${scanItem.imagePath}');
    // Implement logic to submit scan (e.g., API call)
    // After submission, you might want to delete the local scan
    Fluttertoast.showToast(msg: "Sync in progress. Please wait");

    final prompt = "your_prompt_here"; // Ensure the prompt is defined

    gemini
        .textAndImage(
      text: prompt,
      images: [File(scanItem.imagePath).readAsBytesSync()],
    )
        .then((value) {
      final jsonString = value!.content!.parts!.last.text.toString();
      final animalInfo = AnimalInfoModel.fromJson(jsonDecode(jsonString));

      if (animalInfo.basicInformation!.commonName == "NA") {
        Fluttertoast.showToast(msg: "No animal found");
        _deleteScan(scanItem);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimalInfo(
              capturedImage: scanItem.imagePath,
              animalInfoModel: animalInfo,
              isInfo: false,
            ),
          ),
        );
        _deleteScan(scanItem);
      }
    }).catchError((e) {
      print('textAndImageInput $e');
      Fluttertoast.showToast(msg: "$e");
      setState(() {
        scanItem.isSubmitted = false;
      });
    });
  }

  void _deleteScan(LocalScanItem scanItem) {
    try {
      File(scanItem.imagePath).deleteSync();
      _loadLocalScans(); // Reload the list after deletion
    } catch (e) {
      print('Error deleting scan: $e');
    }
  }
}
