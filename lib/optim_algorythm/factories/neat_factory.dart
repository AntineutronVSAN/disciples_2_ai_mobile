import 'package:d2_ai_v2/optim_algorythm/check_points/neat_checkpoint.dart';
import 'package:d2_ai_v2/optim_algorythm/neat/individ/neat_individ.dart';
import 'package:d2_ai_v2/providers/file_provider_base.dart';

import '../base.dart';
import '../individual_base.dart';


class NeatFactory implements IndividualFactoryBase {

  final int cellsCount;
  final int cellVectorLength;
  final int input;
  final int output;
  final int version;

  NeatFactory({
    required this.cellsCount,
    required this.cellVectorLength,
    required this.input,
    required this.output,
    required this.version,
  });

  @override
  IndividualBase createIndividual() {
    return NeatIndivid(
        initFrom: false,
        fitness: 0.0,
        fitnessHistory: [],
        needCalculate: true,
        input: input,
        output: output,
        cellsCount: cellsCount,
        cellVectorLength: cellVectorLength,
        version: version);
  }

  @override
  IndividualBase individualFromJson(Map<String, dynamic> json) {
    final newInd = NeatIndivid.fromJson(json);
    return newInd;
  }

  @override
  Future<CheckPoint> getCheckpoint(String file, FileProviderBase provider) async {
    final json = await provider.getDataByFileName(file);
    final checkPoint = NeatCheckpoint.fromJson(json);
    return checkPoint;
  }

  @override
  Future<void> saveCheckpoint(String file, FileProviderBase provider, List<IndividualBase> individuals, int generation) async {
    final checkPoint = NeatCheckpoint(
        generation: generation,
        individuals: individuals.map((e) => e as NeatIndivid).toList(),
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