import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'file_provider_base.dart';

class DartFileProvider extends FileProviderBase {
  @override
  Future<List<String>> getAllFileNames() {
    // TODO: implement getAllFileNames
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getDataByFileName(String fileName) async {
    final file = File('$fileName.json');
    return json.decode(file.readAsStringSync());
  }

  @override
  Future<void> init() async {
    //final file = File('file.txt');
  }

  @override
  Future<void> writeFile(String fileName, Map<String, dynamic> data) async {
    var file = File('$fileName.json');
    final stringData = json.encode(data);
    file.writeAsStringSync(stringData);
  }

}