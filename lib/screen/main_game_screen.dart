

import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:d2_ai_v2/models/g_immu/g_immu_provider.dart';
import 'package:d2_ai_v2/models/g_immu_c/g_immu_c_provider.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';
import 'package:d2_ai_v2/utils/math_utils.dart';
import 'package:d2_ai_v2/utils/svg_picture.dart';
import 'package:d2_ai_v2/widgets/clicable_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../styles.dart';

class MainGameScreen extends StatelessWidget {
  const MainGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final repo = GameRepository(
        gimmuCProvider: GimmuCProvider(),
        gimmuProvider: GimmuProvider(),
        gtransfProvider: GtransfProvider(),
        tglobalProvider: TglobalProvider(),
        gattacksProvider: GattacksProvider(),
        gDynUpgrProvider: GDynUpgrProvider(),
        gunitsProvider: GunitsProvider());

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
                  RandomExponentialDistribution()), gameRepository: repo,
            ),
            //aiController: AiController()),
            aiController:
            AlphaBetaPruningController(treeDepth: 11, isTopTeam: true)),
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return MainGameScreenBody();
          },
        ));
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
              if (bloc.state.warScreenState == WarScreenState.eve)
                _getGeneticInformation(bloc),
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
                      _getTeamWidgets(context, true),
                      _getActionsWidget(context),
                      _getTeamWidgets(context, false),
                      //_getTeamItems(topTeam: false),
                    ],
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _getRatingWidget(bloc.state.positionRating))
                  ),
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
          const SizedBox(width: 50,),
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

  Widget _getRatingWidget(double currentPositionRating) {
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
              fontSize: 25,
              color: Colors.blue,
              fontWeight: FontWeight.bold
          ),
        ),
        AnimatedContainer(
          width: 10,
          height: isTopContainer ? topContainerHeight : bottomContainerHeight,
          color: !isTopContainer ? Colors.blue : Colors.blue.withOpacity(0.2),
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

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
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getTextButton(
                text: 'Start PVP',
                onPressed: () => BlocProvider.of<GameBloc>(context)
                    .add(OnPVPStartedEvent())),
            _getTextButton(
                text: 'Start PVE',
                onPressed: () => BlocProvider.of<GameBloc>(context)
                    .add(OnPVEStartedEvent())),
            /*_getTextButton(
                text: 'Start EVE',
                onPressed: () => BlocProvider.of<GameBloc>(context)
                    .add(OnEVEStartedEvent())),*/
            _getTextButton(
                text: 'Reset',
                onPressed: () {
                  BlocProvider.of<GameBloc>(context).add(OnReset());
                }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getTextButton(
                text: 'Load',
                onPressed: () =>
                    BlocProvider.of<GameBloc>(context).add(OnUnitsLoad())),
            _getTextButton(text: 'Save', onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _getTeamWidgets(BuildContext context, bool top) {
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
            _getCell(context, bloc.state, 0 + offset, bloc),
            _getCell(context, bloc.state, 1 + offset, bloc),
            _getCell(context, bloc.state, 2 + offset, bloc),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getCell(context, bloc.state, 3 + offset, bloc),
            _getCell(context, bloc.state, 4 + offset, bloc),
            _getCell(context, bloc.state, 5 + offset, bloc),
          ],
        ),
      ],
    );
  }

  Widget _getTextButton({required String text, Function()? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Widget _getCell(
      BuildContext context, GameState state, int cellNumber, GameBloc bloc) {
    final unit = state.units[cellNumber];

    final maxHp = unit.maxHp;
    final curHp = unit.currentHp;

    final paralyzed = unit.paralyzed;
    final petrified = unit.petrified;
    final poisoned = unit.poisoned;
    final blistered = unit.blistered;
    final frostbited = unit.frostbited;

    final hasDebuff = unit.damageLower || unit.initLower;
    final busted = unit.damageBusted;

    var scaleFactor = (curHp / maxHp - 1.0) < 0
        ? -(curHp / maxHp - 1.0)
        : (curHp / maxHp - 1.0);

    if (maxHp == 0.0) {
      scaleFactor = 0.0;
    }

    //final damageColor = paralyzed ? Colors.red.withOpacity(0.5) : Colors.red;
    //final unitHpColor = paralyzed ? Colors.green.withOpacity(0.5) : Colors.green;

    Color damageColor = Colors.red;
    Color unitHpColor = Colors.green;

    if (paralyzed) {
      damageColor = Color.alphaBlend(damageColor.withOpacity(0.5), Colors.grey);
      unitHpColor = Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.grey);
    }
    if (petrified) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.brown);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.brown);
    }
    if (poisoned) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.green[900]!);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.green[900]!);
    }
    if (blistered) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.yellow[900]!);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.yellow[900]!);
    }
    if (frostbited) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.blue[900]!);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.blue[900]!);
    }

    const double cellPadding = 3.0;

    return GestureDetector(
      onTap: () => _onCellTap(context, state, cellNumber, bloc),
      onLongPress: () => bloc.add(OnCellLongTapEvent(cellNumber: cellNumber)),
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: unit.isDead ? 0.1 : 1.0,
            duration: const Duration(milliseconds: 600),
            child: Padding(
              padding: const EdgeInsets.all(cellPadding),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: unit.isEmpty() ? Colors.white : unitHpColor,
                  border: state.units[cellNumber].isMoving
                      ? Border.all(color: Colors.teal, width: 5)
                      : null,
                ),
                width: unit.isMoving ? 120.0 : 100.0,
                height: unit.isMoving ? 120.0 : 100.0,
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.7,
                child: AnimatedContainer(
                  margin: const EdgeInsets.all(cellPadding),
                  width: unit.isMoving ? 120.0 : 100.0,
                  height: scaleFactor * (unit.isMoving ? 120.0 : 100.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: damageColor,
                  ),
                  duration: const Duration(milliseconds: 200),
                ),
              ),
            ),
          ),
          Positioned.fill(
              top: 8.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    unit.unitName,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    maxLines: 2,
                  ),
                ),
              )),
          Positioned.fill(
            bottom: 15.0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  unit.isProtected
                      ? const SvgIcon(
                    asset: "ic_unit_protect.svg",
                    color: Colors.black,
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.isWaiting
                      ? const SvgIcon(
                    asset: "ic_unit_wait.svg",
                    color: Colors.black,
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.retreat
                      ? const SvgIcon(
                    asset: "ic_unit_retreat.svg",
                    color: Colors.black,
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.paralyzed
                      ? SvgIcon(
                    asset: "ic_unit_paralyze.svg",
                    color: Colors.grey[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.poisoned
                      ? SvgIcon(
                    asset: "ic_unit_poison.svg",
                    color: Colors.green[800],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.blistered
                      ? SvgIcon(
                    asset: "ic_unit_blistered.svg",
                    color: Colors.orange[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.frostbited
                      ? SvgIcon(
                    asset: "ic_unit_frost.svg",
                    color: Colors.blue[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  hasDebuff
                      ? SvgIcon(
                    asset: "ic_unit_down.svg",
                    color: Colors.red[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.petrified
                      ? SvgIcon(
                    asset: "ic_unit_petrify.svg",
                    color: Colors.brown[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  busted
                      ? SvgIcon(
                    asset: "ic_unit_butsed.svg",
                    color: Colors.green[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'HP ' +
                        unit.currentHp.toString() +
                        ' / ' +
                        unit.maxHp.toString(),
                    style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  if (unit.unitAttack.damage > 0)
                    AutoSizeText.rich(
                        TextSpan(children: [
                          if (unit.unitAttack.damage > 0)
                            TextSpan(
                                text: 'DMG ${unit.unitAttack.firstDamage}',
                                style: GameStyles.getUnitShortDescriptionStyle()),
                          if (unit.unitAttack.firstDamage -
                              unit.unitAttack.damage !=
                              0)
                            TextSpan(
                                text:
                                ' ${unit.unitAttack.firstDamage - unit.unitAttack.damage > 0 ? '- ' : '+ '} '
                                    '${((unit.unitAttack.firstDamage - unit.unitAttack.damage).abs())}',
                                style: GameStyles
                                    .getUnitShortDescriptionDebuffStyle()),
                          if ((unit.unitAttack2?.damage ?? 0) > 0)
                            TextSpan(
                                text: ' / ${(unit.unitAttack2?.firstDamage ?? '')}',
                                style: GameStyles.getUnitShortDescriptionStyle()),
                        ])),
                  if (unit.unitAttack.firstInitiative > 0)
                    AutoSizeText.rich(
                        TextSpan(children: [
                          if (unit.unitAttack.firstInitiative > 0)
                            TextSpan(
                                text: 'INI ${unit.unitAttack.firstInitiative}',
                                style: GameStyles.getUnitShortDescriptionStyle()),
                          if (unit.unitAttack.firstInitiative -
                              unit.unitAttack.initiative !=
                              0)
                            TextSpan(
                                text:
                                ' - ${unit.unitAttack.firstInitiative - unit.unitAttack.initiative}',
                                style: GameStyles
                                    .getUnitShortDescriptionDebuffStyle()),
                        ])),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Center(
                  child: AutoSizeText(
                    unit.uiInfo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                                      unitID: state.allUnits[index].unitGameID,
                                      cellNumber: cellNumber));
                                },
                                child: Card(
                                  color: Colors.white54,
                                  elevation: 3,
                                  child: ListTile(
                                    title: Text(state.allUnits[index].unitName),
                                    trailing:
                                    const Icon(Icons.arrow_forward_ios),
                                    leading: Text(
                                      state.allUnits[index].unitName[0],
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
