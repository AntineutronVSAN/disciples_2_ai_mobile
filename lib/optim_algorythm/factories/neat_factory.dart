import 'package:d2_ai_v2/providers/file_provider_base.dart';

import '../base.dart';
import '../individual_base.dart';


class NeatFactory implements IndividualFactoryBase {

  @override
  IndividualBase createIndividual() {
    // TODO: implement createIndividual
    throw UnimplementedError();
  }

  @override
  IndividualBase individualFromJson(Map<String, dynamic> json) {
    // TODO: implement individualFromJson
    throw UnimplementedError();
  }

  @override
  Future<CheckPoint> getCheckpoint(String file, FileProviderBase provider) {
    // TODO: implement getCheckpoint
    throw UnimplementedError();
  }

  @override
  Future<void> saveCheckpoint(String file, FileProviderBase provider, List<IndividualBase> individuals, int generation) {
    // TODO: implement saveCheckpoint
    throw UnimplementedError();
  }


}