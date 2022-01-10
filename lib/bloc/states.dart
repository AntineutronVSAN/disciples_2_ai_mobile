import 'package:d2_ai_v2/models/unit.dart';

abstract class GameState {

  final List<Unit> units;
  final WarScreenState warScreenState;

  final List<Unit> allUnits;

  final double populationFitness;
  final int currentGeneration;

  final double positionRating;

  GameState({
    required this.units,
    this.warScreenState = WarScreenState.view,
    required this.allUnits,
    this.currentGeneration = 0,
    this.populationFitness = 0.0,
    this.positionRating = 0.5,
  });

  GameState copyWith({
    units,
    warScreenState,
    allUnits,
    currentGeneration,
    populationFitness,
    positionRating,
  });
}

class GameSceneState extends GameState {
  GameSceneState(
    List<Unit> units, {
    WarScreenState warScreenState = WarScreenState.view,
    required List<Unit> allUnits,
    int currentGeneration = 0,
    double populationFitness = 0.0,
        double positionRating = 0.0,
  }) : super(
          units: units,
          warScreenState: warScreenState,
          allUnits: allUnits,
          currentGeneration: currentGeneration,
          populationFitness: populationFitness,
      positionRating: positionRating
        );

  @override
  GameState copyWith({
    units,
    warScreenState,
    allUnits,
    unitsDeltaHp,
    populationFitness,
    currentGeneration,
    positionRating,
  }) {
    return GameSceneState(
      units ?? this.units,
      warScreenState: warScreenState ?? this.warScreenState,
      allUnits: allUnits ?? this.allUnits,
      populationFitness: populationFitness ?? this.populationFitness,
      currentGeneration: currentGeneration ?? this.currentGeneration,
        positionRating: positionRating ?? this.positionRating,
    );
  }
}

enum WarScreenState { view, pvp, pve, eve }
