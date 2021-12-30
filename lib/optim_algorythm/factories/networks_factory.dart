


import 'package:d2_ai_v2/optim_algorythm/check_points/nn_checkpoint.dart';
import 'package:d2_ai_v2/optim_algorythm/genetic/individs/genetic_individ.dart';
import 'package:d2_ai_v2/optim_algorythm/individual_base.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';

import '../base.dart';

class NetworksFactory implements IndividualFactoryBase {

  final List<int> layers;
  final List<int> unitLayers;
  final int cellsCount;
  final int cellVectorLength;
  final int input;
  final int output;
  final int networkVersion;

  NetworksFactory({
    required this.unitLayers,
    required this.layers,
    required this.cellsCount,
    required this.cellVectorLength,
    required this.input,
    required this.output,
    required this.networkVersion,
  });

  @override
  IndividualBase createIndividual() {
    return GeneticIndivid(
        networkVersion: networkVersion,
        input: input,
        output: output,
        layers: layers,
        unitLayers: unitLayers,
        cellsCount: cellsCount,
        unitVectorLength: cellVectorLength,
        initFrom: false,
        fitnessHistory: []);
  }

  @override
  IndividualBase individualFromJson(Map<String, dynamic> json) {
    return GeneticIndivid.fromJson(json);
  }

  @override
  Future<CheckPoint> getCheckpoint(String file, FileProviderBase provider) async {

    final json = await provider.getDataByFileName(file);
    final checkPoint = NnCheckpoint.fromJson(json);
    return checkPoint;
  }

  @override
  Future<void> saveCheckpoint(String file, FileProviderBase provider, List<IndividualBase> individuals, int generation) async {

    final checkPoint = NnCheckpoint(
        layers: layers,
        unitLayers: unitLayers,
        generation: generation,
        individuals: individuals.map((e) => e as GeneticIndivid).toList(),
        cellsCount: cellsCount,
        cellVectorLength: cellVectorLength,
        input: input,
        output: output).toJson();

    await provider.writeFile(file, checkPoint);
  }

  @override
  IndividualFactoryBase copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }


}