

import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';


abstract class AiAlgorithm {
  List<double> forward(List<double> input);
}


abstract class IndividualFactoryBase {

  IndividualBase createIndividual();
  IndividualBase individualFromJson(Map<String, dynamic> json);

  Future<CheckPoint> getCheckpoint(String file, FileProviderBase provider);

  Future<void> saveCheckpoint(String file, FileProviderBase provider, List<IndividualBase> individuals, int generation);

  IndividualFactoryBase copyWith();

}

abstract class CheckPoint {

  int getGeneration();
  List<IndividualBase> getIndividuals();

}