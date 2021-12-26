

abstract class FileProviderBase {

  Future<void> init();
  Future<void> writeFile(String fileName, Map<String, dynamic> data);
  Future<List<String>> getAllFileNames();
  Future<Map<String, dynamic>> getDataByFileName(String fileName);
}