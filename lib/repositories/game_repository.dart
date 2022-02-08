import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/controllers/evaluation/evaluation_controller.dart';
import 'package:d2_ai_v2/d2_entities/game_models_provider.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/g_dyn_upgr.dart';
import 'package:d2_ai_v2/models/g_immu/g_immu_provider.dart';
import 'package:d2_ai_v2/models/g_immu_c/g_immu_c_provider.dart';
import 'package:d2_ai_v2/models/game_models.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/utils/random_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:d2_ai_v2/models/unit.dart';

import 'game_repository_base.dart';

class GameRepository implements GameRepositoryBase {

  final uuid = const Uuid();
  final Random random = Random();

  final GameObjectsProviderBaseV2 gunitsProvider;
  final GameObjectsProviderBaseV2 tglobalProvider;
  final GameObjectsProviderBaseV2 gattacksProvider;
  final GameObjectsProviderBaseV2 gtransfProvider;
  final GameObjectsProviderBaseV2 gDynUpgrProvider;
  final GameObjectsProviderBaseV2 gimmuCProvider;
  final GameObjectsProviderBaseV2 gimmuProvider;

  /// Мапа всех игровых юнитов с ID
  //final Map<String, Gunits> _allGameUnits = {};

  final List<Unit> _units = [];

  final Map<String, Unit> _unitsNamesMap = {};
  final Map<String, Unit> _unitsIdMap = {};

  final EvaluationController evalController = EvaluationController(); // TODO DI

  final Map<String, List<Unit?>> _transfUnitCache = {};

  GameRepository({
    required this.gunitsProvider,
    required this.tglobalProvider,
    required this.gattacksProvider,
    required this.gtransfProvider,
    required this.gDynUpgrProvider,
    required this.gimmuProvider,
    required this.gimmuCProvider,
  });

  @override
  List<Unit> getAllUnits() {
    return List.generate(_units.length, (index) => _units[index].deepCopy());
  }

  /// Получить юнита, в которого превращает атака [attckId]
  @override
  Unit? getTransformUnitByAttackId(String attckId, {bool isBig = false}) {
    final hasCache = _transfUnitCache.containsKey(attckId);

    if (hasCache) {
      return isBig
          ? _transfUnitCache[attckId]![1]?.deepCopy()
          : _transfUnitCache[attckId]![0]!.deepCopy();
    }

    final transfUnitIds = gtransfProvider.objects
        //.where((element) => element.attack_id == attckId)
        .where((element) => element['ATTACK_ID'] == attckId)
        .toList();
    assert(transfUnitIds.length <= 2);

    //final firstUnit = getCopyUnitById(transfUnitIds[0].transf_id).deepCopy();
    final firstUnit = getCopyUnitById(transfUnitIds[0]['TRANSF_ID']).deepCopy();
    final secondUnit = transfUnitIds.length == 2
        //? getCopyUnitById(transfUnitIds[1].transf_id).deepCopy()
        ? getCopyUnitById(transfUnitIds[1]['TRANSF_ID']).deepCopy()
        : null;

    _transfUnitCache[attckId] = [firstUnit.deepCopy(), secondUnit?.deepCopy()];

    return isBig ? secondUnit : firstUnit;

  }

  @override
  void init() async {

    await gunitsProvider.init();
    await gattacksProvider.init();
    await gtransfProvider.init();
    await gimmuCProvider.init();
    await gimmuProvider.init();
    await gDynUpgrProvider.init();
    await tglobalProvider.init();

    final evals = <PairValues<String, double>>[];

    // Достаются юниты
    for (var unit in gunitsProvider.objects) {

      if (unit['HIT_POINT'] == null) {
        print('WARNING: unit ${unit['UNIT_ID']} has not hit points');
        continue;
      }

      Map<String, dynamic> newGameUnitText;
      Map<String, dynamic> dynUpgradeParams;
      try {
        newGameUnitText =
          //tglobalProvider.objects.firstWhere((e) => e.txt_id == unit['NAME_TXT']);
          tglobalProvider.objects.firstWhere((e) => e['TXT_ID'] == unit['NAME_TXT']);

      } catch(e) {
        print('WARNING: Unknown unit name. ID = ${unit['UNIT_ID']}');
        continue;
      }


      final attackID = unit['ATTACK_ID'];
      final attack2ID = unit['ATTACK2_ID'];

      final attack = gattacksProvider.objects
          //.firstWhere((element) => element.att_id == attackID);
          .firstWhere((element) => element['ATT_ID'] == attackID);
      final attack2 = gattacksProvider.objects
          //.firstWhereOrNull((element) => element.att_id == attack2ID);
          .firstWhereOrNull((element) => element['ATT_ID'] == attack2ID);

      //final attackType = attackTypeFromSource(attack.source)!;
      //final attackType2 = attackTypeFromSource(attack2?.source);

      //final unitDynUpgrade = unit.dyn_upg1;
      final unitDynUpgrade = unit['DYN_UPG1'];
      try {
        dynUpgradeParams = gDynUpgrProvider.objects
            //.firstWhere((element) => element.upgrade_id == unitDynUpgrade);
            .firstWhere((element) => element['UPGRADE_ID'] == unitDynUpgrade);
      } catch(e) {
        print('WARNING: Unknown unit DYN_UPG1. ID = ${unit['UNIT_ID']}');
        continue;
        continue;
      }


      /*print('${newGameUnitText.text} '
          '---- ${attack.atck_class} '
          '---- ${attack.alt_attack}'
          '---- ${attack2?.atck_class} '
          '---- ${attack2?.infinite}');*/

      /*print('${newGameUnitText.text} '
          '---- ${unit.level} '
          '---- ${unit.dyn_upg1}'
          '---- ${unit.prev_id} '
          '---- ${unit.upgrade_b}');*/

      /*print('${newGameUnitText.text} '
          '---- ${unit.dyn_upg1} '
          '---- ${unit.dyn_upg_lv} '
          '---- ${unit.level} '
          '---- ${unit.prev_id} '
          '---- ${unit.upgrade_b} '
          '---- ${attack.source} '
          '---- ${dynUpgradeParams.negotiate} ')
      ;*/

      final unitAttack1 = UnitAttack(
          power: attack['POWER'],
          damage: attack['QTY_DAM'] ?? 0,
          initiative: attack['INITIATIVE'],
          attackConstParams: AttackConstParams(
              heal: attack['QTY_HEAL'] ?? 0,
              firstDamage: attack['QTY_DAM'] ?? 0,
              firstInitiative: attack['INITIATIVE'],
              targetsCount: targetsCountFromReach(attack['REACH']),
              attackClass: attackClassFromGameAttack(attack['CLASS']),
              infinite: attack['INFINITE'] ?? false,
              attackId: attack['ATT_ID'],
              level: attack['LEVEL'] ?? 2,
              source: attack['SOURCE']
          ));

      UnitAttack? unitAttack2;

      if (attack2 != null) {
        unitAttack2 = UnitAttack(
            power: attack2['POWER'],
            damage: attack2['QTY_DAM'] ?? 0,
            initiative: attack2['INITIATIVE'],
            attackConstParams: AttackConstParams(
                heal: attack2['QTY_HEAL'] ?? 0,
                firstDamage: attack2['QTY_DAM'] ?? 0,
                firstInitiative: attack2['INITIATIVE'],
                targetsCount: targetsCountFromReach(attack2['REACH']),
                attackClass: attackClassFromGameAttack(attack2['CLASS']),
                infinite: attack2['INFINITE'] ?? false,
                attackId: attack2['ATT_ID'],
                level: attack2['LEVEL'] ?? 2,
                source: attack2['SOURCE']));
      }
      final newMapAtck = <AttackClass, UnitAttack>{};
      final newListAtck = <UnitAttack>[];

      final classImmuneMap = <int, ImunneCategory>{};
      final sourceImmuneMap = <int, ImunneCategory>{};
      final hasClassImmune = <int, bool>{};
      final hasSourceImmune = <int, bool>{};

      final unitClassImmu = gimmuCProvider.objects
          //.where((element) => element.unit_id == unit['UNIT_ID']);
          .where((element) => element['UNIT_ID'] == unit['UNIT_ID']);
      final unitSourceImmu = gimmuProvider.objects
          //.where((element) => element.unit_id == unit['UNIT_ID']);
          .where((element) => element['UNIT_ID'] == unit['UNIT_ID']);

      for (var i in unitClassImmu) {
        //final immuC = i.immunity;
        final immuC = i['IMMUNITY'];
        if (immuC == null) {
          continue;
        }
        //final cat = i.immunecat;
        final cat = i['IMMUNECAT'];
        classImmuneMap[immuC] = immuneCategoryFromValue(cat);
        hasClassImmune[immuC] = true;
      }

      for (var i in unitSourceImmu) {
        //final immuC = i.immunity;
        final immuC = i['IMMUNITY'];
        if (immuC == null) {
          continue;
        }
        //final cat = i.immunecat;
        final cat = i['IMMUNECAT'];
        if (cat == 0 || cat == null) {
          print('WARNING: suorce immune troubles - category = $cat');
          continue;
        }
        sourceImmuneMap[immuC] = immuneCategoryFromValue(cat);
        hasSourceImmune[immuC] = true;
      }

      Unit newUnit = Unit(
        unitConstParams: UnitConstParams(
            maxHp: unit['HIT_POINT'],
            isDoubleAttack: unit['ATCK_TWICE'] ?? false,
            //unitName: newGameUnitText.text,
            unitName: newGameUnitText['TEXT'],
            unitGameID: unit['UNIT_ID'],
            unitWarId: "",
            /*upgradeArmor: dynUpgradeParams.armor ?? 0,
            upgradeDamage: dynUpgradeParams.damage ?? 0,
            upgradeHeal: dynUpgradeParams.heal ?? 0,
            upgradeInitiative: dynUpgradeParams.initiative ?? 0,
            upgradePower: dynUpgradeParams.power ?? 0,
            upgradeHp: dynUpgradeParams.hit_point,*/
            upgradeArmor: dynUpgradeParams['ARMOR'] ?? 0,
            upgradeDamage: dynUpgradeParams['DAMAGE'] ?? 0,
            upgradeHeal: dynUpgradeParams['HEAL'] ?? 0,
            upgradeInitiative: dynUpgradeParams['INITIATIVE'] ?? 0,
            upgradePower: dynUpgradeParams['POWER'] ?? 0,
            upgradeHp: dynUpgradeParams['HIT_POINT'] ?? 0,
            overLevel: false),

        isMoving: false,
        currentHp: unit['HIT_POINT'],
        isDead: false,
        isWaiting: false,
        isProtected: false,
        unitAttack: unitAttack1,
        unitAttack2: unitAttack2,
        armor: unit['ARMOR'] ?? 0,
        attacksMap: newMapAtck,

        level: unit['LEVEL'],

        sourceImmune: sourceImmuneMap,
        hasClassImunne: hasClassImmune,
        hasSourceImunne: hasSourceImmune,
        classImmune: classImmuneMap,
        isBig: !(unit['SIZE_SMALL'] ?? false),
      );

      final eval = GameEvaluation();

      evalController.getUnitEvaluation(newUnit, eval);
      evals.add(PairValues<String, double>(
          first: newUnit.unitConstParams.unitName, end: eval.getEval()));


      _units.add(newUnit);
      _unitsNamesMap[newUnit.unitConstParams.unitName] = newUnit;
      _unitsIdMap[newUnit.unitConstParams.unitGameID] = newUnit;

    }

    evals.sort((a, b) => a.end.compareTo(b.end));
    for (var i in evals) {
      //print('Юнит - ${i.first}. Ценность - ${i.end}');
    }
  }

  @override
  Unit getRandomUnit({RandomUnitOptions? options}) {
    if (options == null) {
      final randomIndex = Random().nextInt(_unitsNamesMap.keys.length);
      final randomName = _unitsNamesMap.keys.toList()[randomIndex];

      return _getCopyUnitWithNewParams(_unitsNamesMap[randomName]!);
    } else {
      if (options.backLine) {
        final isRange = Random().nextInt(100) > 50;

        if (isRange) {
          final units = _units
              .where((element) =>
                  element.unitAttack.attackConstParams.targetsCount ==
                  TargetsCount.any)
              .toList();
          final index = Random().nextInt(units.length);
          return _getCopyUnitWithNewParams(units[index]);
        } else {
          final units = _units
              .where((element) =>
                  element.unitAttack.attackConstParams.targetsCount ==
                  TargetsCount.all)
              .toList();
          final index = Random().nextInt(units.length);
          return _getCopyUnitWithNewParams(units[index]);
        }
      }
      if (options.frontLine) {
        final units = _units
            .where((element) =>
                element.unitAttack.attackConstParams.targetsCount ==
                TargetsCount.one)
            .toList();
        final index = Random().nextInt(units.length);

        return _getCopyUnitWithNewParams(units[index]);
      }

      throw Exception();
    }
  }

  @override
  Unit getCopyUnitByName(String name) {
    final hasUnit = _unitsNamesMap.containsKey(name);
    if (!hasUnit) {
      return GameRepositoryBase.globalEmptyUnit;
    }
    return _getCopyUnitWithNewParams(_unitsNamesMap[name]!);
  }

  /// Получить копию юнита по [id]
  /// TODO метод дико тормознутый
  @override
  Unit getCopyUnitById(String id) {
    Unit? newUnit;
    bool unitFound = false;
    for (var u in _units) {
      if (u.unitConstParams.unitGameID == id) {
        newUnit = _getCopyUnitWithNewParams(u);
        unitFound = true;
        break;
      }
    }
    assert(unitFound);

    return newUnit!;
  }

  Unit _getCopyUnitWithNewParams(Unit u) {
    var newUnit = u.deepCopy();

    newUnit = newUnit.copyWith(
      unitConstParams: newUnit.unitConstParams.copyWith(
        unitWarId: uuid.v1(),
      ),

      attacksMap: <AttackClass, UnitAttack>{},
      attacks: <UnitAttack>[],
      unitAttack: u.unitAttack.deepCopy(),
      unitAttack2: u.unitAttack2?.deepCopy(),

      classImmune: Map<int, ImunneCategory>.from(newUnit.classImmune),
      sourceImmune: Map<int, ImunneCategory>.from(newUnit.sourceImmune),

      hasSourceImunne: Map<int, bool>.from(newUnit.hasSourceImunne),
      hasClassImunne: Map<int, bool>.from(newUnit.hasClassImunne),
    );

    return newUnit;
  }

  @override
  List<String> getAllNames() {
    return gunitsProvider.objects.map((e) => e['NAME_TXT'] as String).toList();
  }

  /*List<String> _getAllGameUnits() {
    return gunitsProvider.objects.map((e) => e['UNIT_ID']).toList();
  }*/
}
