

import 'dart:io';

import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/dbf_reader/dbf_reader.dart';

import 'game_models_provider.dart';


class FileUnitsProvider extends GameObjectsProviderBaseV2<Unit> {

  final String filePath;

  FileUnitsProvider({required this.filePath});

  @override
  Future<void> init() async {
    var bytes = await File('assets/dbf/smns_path_0_999/Globals/Gunits.dbf').readAsBytes();
    //var bytes = await File('assets/dbf/smns_path_0_999/Globals/GimmuC.dbf').readAsBytes();
    //var bytes = await File('assets/dbf/smns_path_0_999/Globals/Tglobal.dbf').readAsBytes();

    final reader = DBFReader();
    reader.read(bytes);



  }

}