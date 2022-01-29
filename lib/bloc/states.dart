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

  final bool aiMoving;
  final int? nodesPerSecond;

  final String? errorMessage;

  GameState({
    required this.units,
    this.warScreenState = WarScreenState.view,
    required this.allUnits,
    this.currentGeneration = 0,
    this.populationFitness = 0.0,
    this.positionRating = 0.0,
    this.topTeamItems,
    this.bottomTeamItems,
    this.aiMoving = false,
    this.nodesPerSecond,
    this.errorMessage,
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
    aiMoving,
    nodesPerSecond,
    errorMessage,
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
    bool aiMoving = false,
    int? nodesPerSecond,
        String? errorMessage,
  }) : super(
          units: units,
          warScreenState: warScreenState,
          allUnits: allUnits,
          currentGeneration: currentGeneration,
          populationFitness: populationFitness,
      positionRating: positionRating,
      topTeamItems: topTeamItems,
    bottomTeamItems: bottomTeamItems,
      aiMoving: aiMoving,
      nodesPerSecond: nodesPerSecond,
      errorMessage: errorMessage,
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
    aiMoving,
    nodesPerSecond,
    errorMessage,
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
        aiMoving: aiMoving ?? this.aiMoving,
        nodesPerSecond: nodesPerSecond ?? this.nodesPerSecond,
        errorMessage: errorMessage,
    );
  }
}

enum WarScreenState { view, pvp, pve, eve }
