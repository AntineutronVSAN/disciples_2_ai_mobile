


import 'package:d2_ai_v2/d2_entities/game_models_provider.dart';
import 'package:d2_ai_v2/utils/dbf_reader/dbf_reader.dart';
import 'package:flutter/services.dart';


class DBFObjectsProvider extends GameObjectsProviderBaseV2 {

  final String assetsPath;

  final String idKey;

  DBFObjectsProvider({required this.assetsPath, required this.idKey});

  @override
  Future<void> init() async {
    var data = await PlatformAssetBundle().load(assetsPath);
    final reader = DBFReader();
    await reader.read(data.buffer.asUint8List());

    for(var i in reader.rows) {
      final obj = i.objectsMap;
      objects.add(obj);
      if (idKey != '') {
        objectsMap[i.objectsMap[idKey]] = obj;
      }

    }
  }

}