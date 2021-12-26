

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'file_provider_base.dart';

class FileProvider implements FileProviderBase {

  late Directory directory;
  bool inited = false;

  static final FileProvider _singleton = FileProvider._internal();
  FileProvider._internal();
  factory FileProvider() {
    return _singleton;
  }

  @override
  Future<void> init() async {
    if (inited) return;
    directory = await getApplicationDocumentsDirectory();
    inited = true;
  }

  @override
  Future<void> writeFile(String fileName, Map<String, dynamic> data) async {
    if (!inited) throw Exception();

    final path = directory.path;

    final currentFile = File('$path/$fileName.json');

    currentFile.writeAsString(json.encode(data));

  }

  @override
  Future<List<String>> getAllFileNames() async {
    if (!inited) throw Exception();

    return [];
  }

  @override
  Future<Map<String, dynamic>> getDataByFileName(String fileName) async {

    final path = directory.path;
    final currentFile = File('$path/$fileName.json');

    final data = await currentFile.readAsString();
    final jsonData = json.decode(data);

    return jsonData;

  }

}