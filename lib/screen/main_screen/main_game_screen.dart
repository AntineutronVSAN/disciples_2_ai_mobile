
import 'package:d2_ai_v2/ai_controller/ai_controller_ab_pruning.dart';
import 'package:d2_ai_v2/bloc/bloc.dart';
import 'package:d2_ai_v2/bloc/events.dart';
import 'package:d2_ai_v2/bloc/states.dart';
import 'package:d2_ai_v2/controllers/attack_controller/attack_controller.dart';
import 'package:d2_ai_v2/controllers/damage_scatter.dart';
import 'package:d2_ai_v2/controllers/duration_controller.dart';
import 'package:d2_ai_v2/controllers/game_controller/game_controller.dart';
import 'package:d2_ai_v2/controllers/imunne_controller.dart';
import 'package:d2_ai_v2/controllers/initiative_shuffler.dart';
import 'package:d2_ai_v2/controllers/power_controller.dart';
import 'package:d2_ai_v2/d2_entities/unit/unit_provider.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';

import 'package:d2_ai_v2/screen/navigator.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';

import 'package:d2_ai_v2/widgets/clicable_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../const.dart';
import 'components/ai_moving_widget.dart';
import 'components/team_widget.dart';

const int treeDepth = 7;

class MainGameScreen extends StatelessWidget {
  const MainGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = GameRepository(
        gimmuCProvider: DBFObjectsProvider(assetsPath: smnsD2ImmuCProviderAssetPath, idKey: smnsD2ImmuCProviderIDkey),
        gimmuProvider: DBFObjectsProvider(assetsPath: smnsD2ImmuProviderAssetPath, idKey: smnsD2ImmuProviderIDkey),
        gtransfProvider: DBFObjectsProvider(assetsPath: smnsD2TransfProviderAssetPath, idKey: smnsD2TransfProviderIDkey),
        tglobalProvider: DBFObjectsProvider(assetsPath: smnsD2GlobalProviderAssetPath, idKey: smnsD2GlobalProviderIDkey),
        gattacksProvider: DBFObjectsProvider(assetsPath: smnsD2AttacksProviderAssetPath, idKey: smnsD2AttacksProviderIDkey),
        gDynUpgrProvider: DBFObjectsProvider(assetsPath: smnsD2GDynUpgProviderAssetPath, idKey: smnsD2GDynUpgProviderIDkey),
        gunitsProvider: DBFObjectsProvider(assetsPath: smnsD2UnitsProviderAssetPath, idKey: smnsD2UnitsProviderIDkey));

    return BlocProvider<GameBloc>(
        create: (BuildContext context) => GameBloc(
            GameSceneState([], allUnits: []),
            repository: repo,
            controller: GameController(
              attackController: AttackController(
                immuneController: ImmuneController(),
                gameRepository: repo,
                powerController: PowerController(
                  randomExponentialDistribution:
                      RandomExponentialDistribution(),
                ),
                damageScatter: DamageScatter(
                  randomExponentialDistribution:
                      RandomExponentialDistribution(),
                ),
                attackDurationController: AttackDurationController(),
              ),
              initiativeShuffler: InitiativeShuffler(
                  randomExponentialDistribution:
                      RandomExponentialDistribution()),
              gameRepository: repo,
            ),
            //aiController: AiController()),
            aiController:
                AlphaBetaPruningController(treeDepth: treeDepth, isTopTeam: true)),
        child: BlocConsumer<GameBloc, GameState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                duration: const Duration(seconds: 1),
              ));
            }
          },
          builder: (context, state) {
              return MainGameScreenBody();
            }
          ),
        );
  }
}

class MainGameScreenBody extends StatefulWidget {
  const MainGameScreenBody({Key? key}) : super(key: key);

  @override
  State<MainGameScreenBody> createState() => _MainGameScreenBodyState();
}

class _MainGameScreenBodyState extends State<MainGameScreenBody> {
  late final TextEditingController _unitListFilterController;

  @override
  void initState() {
    _unitListFilterController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _unitListFilterController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white10,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getHeader(context),
              //if (bloc.state.warScreenState == WarScreenState.eve)
              //  _getGeneticInformation(bloc),
              const SizedBox(
                height: 30,
              ),
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //_getTeamItems(topTeam: true),
                      //_getTeamWidgets(context, true),
                      MainScreenTeamWidget(
                        onLongPress: (val) {
                          _onCellLongPress(val, bloc.state.units, context);
                        },
                        units: bloc.state.units,
                        top: true,
                        onTap: (val) {
                          _onCellTap(context, bloc.state, val, bloc);
                        },
                      ),
                      if (bloc.state.aiMoving)
                        AIMovingWidget(
                          treeDepth: treeDepth,
                          nodesPerSecond: bloc.state.nodesPerSecond ?? 0, height: 50,),
                      if (!bloc.state.aiMoving)
                        _getActionsWidget(context),

                      MainScreenTeamWidget(
                        onLongPress: (val) {
                          _onCellLongPress(val, bloc.state.units, context);
                        },
                        units: bloc.state.units,
                        top: false,
                        onTap: (val) {
                          _onCellTap(context, bloc.state, val, bloc);
                        },
                      ),
                      //_getTeamWidgets(context, false),
                      //_getTeamItems(topTeam: false),
                    ],
                  ),
                  /*Positioned.fill(
                      child: Align(
                          alignment: Alignment.centerRight,
                          //child: _getRatingWidget(bloc.state.positionRating))),
                        child: RatingWidget(currentPositionRating: bloc.state.positionRating,))),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTeamItems({required bool topTeam}) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Draggable<int>(
            feedback: Container(
              width: 50,
              height: 50,
              color: Colors.green,
            ),
            data: 0,
            child: Container(
              width: 50,
              height: 50,
              color: Colors.green,
            ),
            childWhenDragging: const SizedBox.shrink(),
          ),
          const SizedBox(
            width: 50,
          ),
          Draggable<int>(
            feedback: Container(
              width: 50,
              height: 50,
              color: Colors.green,
            ),
            data: 1,
            child: Container(
              width: 50,
              height: 50,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _getRatingWidget(double currentPositionRating) {
    //assert(currentPositionRating >= 0.0 && currentPositionRating <= 1.0);

    const maxContainerHeight = 100.0;

    var topContainerHeight = currentPositionRating >= 0.0
        //? maxContainerHeight * (currentPositionRating - 0.5)
        ? maxContainerHeight * (currentPositionRating)
        : 1.0;
    var bottomContainerHeight = currentPositionRating < 0.0
        //? maxContainerHeight * (0.5 - currentPositionRating)
        ? maxContainerHeight * (-currentPositionRating)
        : 1.0;

    if (topContainerHeight > maxContainerHeight) {
      topContainerHeight = maxContainerHeight;
    }

    if (bottomContainerHeight > maxContainerHeight) {
      bottomContainerHeight = maxContainerHeight;
    }

    final isTopContainer = topContainerHeight > bottomContainerHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          width: 10,
          height: isTopContainer ? topContainerHeight : bottomContainerHeight,
          color: isTopContainer ? Colors.blue : Colors.blue.withOpacity(0.2),
          duration: const Duration(milliseconds: 200),
        ),
        Text(
          currentPositionRating.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 25, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        AnimatedContainer(
          width: 10,
          height: isTopContainer ? topContainerHeight : bottomContainerHeight,
          color: !isTopContainer ? Colors.blue : Colors.blue.withOpacity(0.2),
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }*/

  Widget _getGeneticInformation(GameBloc bloc) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              'Fitness - ${bloc.state.populationFitness.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              'Generation - ${bloc.state.currentGeneration}',
              style: const TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getHeader(BuildContext context) {

    final bloc = BlocProvider.of<GameBloc>(context);

    final isPvp = bloc.state.warScreenState == WarScreenState.pvp;
    final isPve = bloc.state.warScreenState == WarScreenState.pve;

    final isBattle = isPvp || isPve;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isBattle)
              _getTextButton(
                  text: 'Старт',
                  onPressed: () => bloc
                      .add(OnPVPStartedEvent())),
            if (!isBattle)
              _getTextButton(
                  text: 'Страт с ИИ',
                  onPressed: () => bloc
                      .add(OnPVEStartedEvent())),
            /*_getTextButton(
                text: 'Start EVE',
                onPressed: () => BlocProvider.of<GameBloc>(context)
                    .add(OnEVEStartedEvent())),*/
            _getTextButton(
                text: 'Сброс',
                onPressed: () {
                  bloc.add(OnReset());
                }),
          ],
        ),
        if (!isBattle)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getTextButton(
                  text: 'Случайная симметричная расстановка',
                  onPressed: () =>
                      BlocProvider.of<GameBloc>(context).add(OnUnitsLoad())),
              //_getTextButton(text: 'Save', onPressed: () {}),
            ],
          ),
      ],
    );
  }

  /*Widget _getTeamWidgets(BuildContext context, bool top) {
    final offset = top ? 0 : 6;
    final bloc = context.read<GameBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UnitCellWidget(
              units: bloc.state.units,
              cellNumber: 0 + offset,
              onTap: () => _onCellTap(context, bloc.state, 0 + offset, bloc),
              onLongPress: () => _onCellLongPress(0 + offset, bloc.state.units, context),
            ),
            UnitCellWidget(
              units: bloc.state.units,
              cellNumber: 1 + offset,
              onTap: () => _onCellTap(context, bloc.state, 1 + offset, bloc),
              onLongPress: () => _onCellLongPress(1 + offset, bloc.state.units, context),
            ),
            UnitCellWidget(
              units: bloc.state.units,
              cellNumber: 2 + offset,
              onTap: () => _onCellTap(context, bloc.state, 2 + offset, bloc),
              onLongPress: () => _onCellLongPress(2 + offset, bloc.state.units, context),
            ),
            //_getCell(context, bloc.state, 0 + offset, bloc),
            //_getCell(context, bloc.state, 1 + offset, bloc),
            //_getCell(context, bloc.state, 2 + offset, bloc),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UnitCellWidget(
              units: bloc.state.units,
              cellNumber: 3 + offset,
              onTap: () => _onCellTap(context, bloc.state, 3 + offset, bloc),
              onLongPress: () => _onCellLongPress(3 + offset, bloc.state.units, context),
            ),
            UnitCellWidget(
              units: bloc.state.units,
              cellNumber: 4 + offset,
              onTap: () => _onCellTap(context, bloc.state, 4 + offset, bloc),
              onLongPress: () => _onCellLongPress(4 + offset, bloc.state.units, context),
            ),
            UnitCellWidget(
              units: bloc.state.units,
              cellNumber: 5 + offset,
              onTap: () => _onCellTap(context, bloc.state, 5 + offset, bloc),
              onLongPress: () => _onCellLongPress(5 + offset, bloc.state.units, context),
            ),
            //_getCell(context, bloc.state, 3 + offset, bloc),
            //_getCell(context, bloc.state, 4 + offset, bloc),
            //_getCell(context, bloc.state, 5 + offset, bloc),
          ],
        ),
      ],
    );
  }*/

  void _onCellLongPress(int index, List<Unit> cells, BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScreensNavigator.getUnitInfoScreen(unit: cells[index])),
    );
    print(result);
  }

  Widget _getTextButton({required String text, Function()? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, maxLines: 2,),
        style: TextButton.styleFrom(
          primary: Colors.black,
          backgroundColor: Colors.white.withOpacity(0.5)
        ),
      ),
    );
  }

  void _onCellTap(
      BuildContext context, GameState state, int cellNumber, GameBloc bloc) {
    if (state.warScreenState != WarScreenState.view) {
      bloc.add(OnCellTapEvent(cellNumber: cellNumber));
      return;
    }

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return BlocBuilder<GameBloc, GameState>(
            bloc: bloc,
            builder: (BuildContext context, state) {
              return Container(
                  padding: const EdgeInsets.all(15.0),
                  margin: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search),
                          Flexible(
                              child: TextField(
                            controller: _unitListFilterController,
                            onChanged: (value) =>
                                bloc.add(OnUnitsListFilters(unitName: value)),
                          )),
                          const SizedBox(
                            width: 20.0,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.allUnits.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  bloc.add(OnUnitSelected(
                                      unitID: state.allUnits[index].unitConstParams.unitGameID,
                                      cellNumber: cellNumber));
                                },
                                child: Card(
                                  color: Colors.white54,
                                  elevation: 3,
                                  child: ListTile(
                                    title: Text(state.allUnits[index].unitConstParams.unitName),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                    leading: Text(
                                      state.allUnits[index].unitConstParams.unitName[0],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ));
            },
          );
        });
  }

  Widget _getActionsWidget(BuildContext context) {
    final bloc = BlocProvider.of<GameBloc>(context);
    return bloc.state.warScreenState != WarScreenState.view
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ClickableSvg(
                asset: "ic_unit_protect.svg",
                size: 40.0,
                onTap: () {
                  bloc.add(OnUnitProtectClick());
                },
                color: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
              ),
              ClickableSvg(
                asset: "ic_unit_wait.svg",
                size: 40.0,
                onTap: () {
                  bloc.add(OnUnitWaitClick());
                },
                color: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
              ),
              ClickableSvg(
                asset: "ic_unit_retreat.svg",
                size: 40.0,
                onTap: () {
                  bloc.add(OnRetreat());
                },
                color: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
              ),
            ]))
        : const SizedBox.shrink();
  }
}
