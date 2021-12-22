import 'package:d2_ai_v2/models/unit.dart';

abstract class GameState {

  final List<Unit> units;
  final WarScreenState warScreenState;

  final List<Unit> allUnits;

  final double populationFitness;
  final int currentGeneration;

  GameState({
    required this.units,
    this.warScreenState = WarScreenState.view,
    required this.allUnits,
    this.currentGeneration = 0,
    this.populationFitness = 0.0,
  });

  GameState copyWith({
    units,
    warScreenState,
    allUnits,
    currentGeneration,
    populationFitness,
  });
}

class GameSceneState extends GameState {
  GameSceneState(
    List<Unit> units, {
    WarScreenState warScreenState = WarScreenState.view,
    required List<Unit> allUnits,
    int currentGeneration = 0,
    double populationFitness = 0.0,
  }) : super(
          units: units,
          warScreenState: warScreenState,
          allUnits: allUnits,
          currentGeneration: currentGeneration,
          populationFitness: populationFitness,
        );

  @override
  GameState copyWith({
    units,
    warScreenState,
    allUnits,
    unitsDeltaHp,
    populationFitness,
    currentGeneration,
  }) {
    return GameSceneState(
      units ?? this.units,
      warScreenState: warScreenState ?? this.warScreenState,
      allUnits: allUnits ?? this.allUnits,
      populationFitness: populationFitness ?? this.populationFitness,
      currentGeneration: currentGeneration ?? this.currentGeneration,
    );
  }
}

enum WarScreenState { view, pvp, pve, eve }
