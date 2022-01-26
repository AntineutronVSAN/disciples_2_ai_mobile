import 'dart:async';
import 'dart:isolate';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/optim_algorythm/genetic/individs/genetic_individ.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_worker.g.dart';


class GeneticControllerWorker {

  void calculateFitnesses({required int timeSeconds}) async {
    print('Запуск, время - $timeSeconds');
    await Future.delayed(Duration(seconds: timeSeconds));
    print('Стоп, время - $timeSeconds');
    return;
  }

  static void startGeneticControllerWorker(SendPort sendPort) {
    /*print('ЗАПУСК ИЗОЛЯТА');
    ReceivePort newIsolateReceivePort = ReceivePort();
    // Инициализирующее сообщение
    sendPort.send('data');
    newIsolateReceivePort.listen((message) async {
      print('Изолят принял сообщение - $message');
      sendPort.send(MessageContext<String>(
        data: 'Второй привет, main изолят!',
        sendPort: newIsolateReceivePort.sendPort,
      ));
    });
    print('КОНЕЦ ИЗОЛЯТА');*/
  }
}

@JsonSerializable()
class GeneticWorkerMessage {
  /// Начальные юниты на поле боя
  final List<Unit> units;

  final List<GeneticIndivid> individs;

  final int input;
  final int output;
  final int hidden;
  final int layers;

  GeneticWorkerMessage(
      {required this.units,
      required this.input,
      required this.output,
      required this.hidden,
      required this.layers,
      required this.individs});

  factory GeneticWorkerMessage.fromJson(Map<String, dynamic> json) =>
      _$GeneticWorkerMessageFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticWorkerMessageToJson(this);
}

@JsonSerializable()
class GeneticWorkerResponse {
  final List<double> fitness;

  GeneticWorkerResponse({required this.fitness});

  factory GeneticWorkerResponse.fromJson(Map<String, dynamic> json) =>
      _$GeneticWorkerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticWorkerResponseToJson(this);
}
