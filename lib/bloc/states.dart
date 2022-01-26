import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/models/war_items.dart';

abstract class GameState {

  final List<Unit> units;
  final WarScreenState warScreenState;

  final List<Unit> allUnits;

  final double populationFitness;
  final int currentGeneration;

  final double positionRating;

  final List<WarItem>? topTeamItems;
  final List<WarItem>? bottomTeamItems;

  GameState({
    required this.units,
    this.warScreenState = WarScreenState.view,
    required this.allUnits,
    this.currentGeneration = 0,
    this.populationFitness = 0.0,
    this.positionRating = 0.0,
    this.topTeamItems,
    this.bottomTeamItems,
  });

  GameState copyWith({
    units,
    warScreenState,
    allUnits,
    currentGeneration,
    populationFitness,
    positionRating,
    topTeamItems,
    bottomTeamItems,
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
    List<WarItem>? topTeamItems,
    List<WarItem>? bottomTeamItems,
  }) : super(
          units: units,
          warScreenState: warScreenState,
          allUnits: allUnits,
          currentGeneration: currentGeneration,
          populationFitness: populationFitness,
      positionRating: positionRating,
      topTeamItems: topTeamItems,
    bottomTeamItems: bottomTeamItems,
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
    topTeamItems,
    bottomTeamItems,
  }) {
    return GameSceneState(
      units ?? this.units,
      warScreenState: warScreenState ?? this.warScreenState,
      allUnits: allUnits ?? this.allUnits,
      populationFitness: populationFitness ?? this.populationFitness,
      currentGeneration: currentGeneration ?? this.currentGeneration,
      positionRating: positionRating ?? this.positionRating,
      topTeamItems: topTeamItems ?? this.topTeamItems,
      bottomTeamItems: bottomTeamItems ?? this.bottomTeamItems,
    );
  }
}

enum WarScreenState { view, pvp, pve, eve }
