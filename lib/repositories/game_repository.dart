import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/controllers/evaluation/evaluation_controller.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/g_immu/g_immu_provider.dart';
import 'package:d2_ai_v2/models/g_immu_c/g_immu_c_provider.dart';
import 'package:d2_ai_v2/models/game_models.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/utils/random_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:d2_ai_v2/models/unit.dart';

import 'game_repository_base.dart';

class GameRepository implements GameRepositoryBase {
  // TODO Провайдеры из сгенерированного файла
  final uuid = const Uuid();
  final Random random = Random();

  final GunitsProvider gunitsProvider;
  final TglobalProvider tglobalProvider;
  final GattacksProvider gattacksProvider;
  final GtransfProvider gtransfProvider;
  final GDynUpgrProvider gDynUpgrProvider;
  final GimmuCProvider gimmuCProvider;
  final GimmuProvider gimmuProvider;

  /// Мапа всех игровых юнитов с ID
  final Map<String, Gunits> _allGameUnits = {};

  final List<Unit> _units = [];

  final Map<String, Unit> _unitsNamesMap = {};
  final Map<String, Unit> _unitsIdMap = {};

  final EvaluationController evalController = EvaluationController(); // TODO DI

  final Map<String, List<Unit>> _transfUnitCache = {};

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
  Unit getTransformUnitByAttackId(String attckId, {bool isBig = false}) {
    final hasCache = _transfUnitCache.containsKey(attckId);

    if (hasCache) {
      return _transfUnitCache[attckId]![0].deepCopy();
    }

    final transfUnitIds = gtransfProvider.objects
        .where((element) => element.attack_id == attckId)
        .toList();
    assert(transfUnitIds.length <= 2);

    final firstUnit = getCopyUnitById(transfUnitIds[0].transf_id).deepCopy();

    _transfUnitCache[attckId] = [firstUnit];

    return firstUnit;

    /*final transfUnitIds = gtransfProvider.objects.where((element) => element.attack_id == attckId).toList();
    assert(transfUnitIds.length <= 2);

    final firstUnit = getCopyUnitById(transfUnitIds[0].transf_id).deepCopy();
    //final secondUnit = getCopyUnitById(transfUnitIds[1].transf_id).deepCopy();

    if (isBig) {
      //todo
    }
    return firstUnit;*/
  }

  @override
  void init() {
    final evals = <PairValues<String, double>>[];

    // Достаются юниты
    for (var unit in gunitsProvider.objects) {
      final newGameUnitText =
          tglobalProvider.objects.firstWhere((e) => e.txt_id == unit.name_txt);

      final attackID = unit.attack_id;
      final attack2ID = unit.attack2_id;

      final attack = gattacksProvider.objects
          .firstWhere((element) => element.att_id == attackID);
      final attack2 = gattacksProvider.objects
          .firstWhereOrNull((element) => element.att_id == attack2ID);

      //final attackType = attackTypeFromSource(attack.source)!;
      //final attackType2 = attackTypeFromSource(attack2?.source);

      final unitDynUpgrade = unit.dyn_upg1;

      final dynUpgradeParams = gDynUpgrProvider.objects
          .firstWhere((element) => element.upgrade_id == unitDynUpgrade);

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
          //attackId: attack.att_id,
          power: attack.power,
          //heal: attack.qty_heal ?? 0,
          damage: attack.qty_dam ?? 0,
          initiative: attack.initiative,
          //firstInitiative: attack.initiative,
          //targetsCount: targetsCountFromReach(attack.reach),
          //attackClass: attackClassFromGameAttack(attack.atck_class),
          //infinite: attack.infinite ?? false,
          //firstDamage: attack.qty_dam ?? 0,
          //level: attack.level ?? 2,
          //source: attack.source,
          attackConstParams: AttackConstParams(
              heal: attack.qty_heal ?? 0,
              firstDamage: attack.qty_dam ?? 0,
              firstInitiative: attack.initiative,
              targetsCount: targetsCountFromReach(attack.reach),
              attackClass: attackClassFromGameAttack(attack.atck_class),
              infinite: attack.infinite ?? false,
              attackId: attack.att_id,
              level:attack.level ?? 2,
              source: attack.source)
      );

      UnitAttack? unitAttack2;

      if (attack2 != null) {
        unitAttack2 = UnitAttack(
          //attackId: attack2.att_id,
          power: attack2.power,
          //heal: attack2.qty_heal ?? 0,
          damage: attack2.qty_dam ?? 0,
          initiative: attack2.initiative,
          //firstInitiative: attack2.initiative,
          //targetsCount: targetsCountFromReach(attack2.reach),
          //attackClass: attackClassFromGameAttack(attack2.atck_class),
          //infinite: attack2.infinite ?? false,
          //firstDamage: attack2.qty_dam ?? 0,
          //level: attack2.level ?? 2,
          //source: attack2.source,
            attackConstParams: AttackConstParams(
                heal: attack2.qty_heal ?? 0,
                firstDamage: attack2.qty_dam ?? 0,
                firstInitiative: attack2.initiative,
                targetsCount: targetsCountFromReach(attack2.reach),
                attackClass: attackClassFromGameAttack(attack2.atck_class),
                infinite: attack2.infinite ?? false,
                attackId: attack2.att_id,
                level:attack2.level ?? 2,
                source: attack2.source)
        );
      }
      final newMapAtck = <AttackClass, UnitAttack>{};
      final newListAtck = <UnitAttack>[];

      final classImmuneMap = <int, ImunneCategory>{};
      final sourceImmuneMap = <int, ImunneCategory>{};
      final hasClassImmune = <int, bool>{};
      final hasSourceImmune = <int, bool>{};

      final unitClassImmu = gimmuCProvider.objects
          .where((element) => element.unit_id == unit.unit_id);
      final unitSourceImmu = gimmuProvider.objects
          .where((element) => element.unit_id == unit.unit_id);

      for (var i in unitClassImmu) {
        final immuC = i.immunity;
        final cat = i.immunecat;
        classImmuneMap[immuC] = immuneCategoryFromValue(cat);
        hasClassImmune[immuC] = true;
      }

      for (var i in unitSourceImmu) {
        final immuC = i.immunity;
        final cat = i.immunecat;
        sourceImmuneMap[immuC] = immuneCategoryFromValue(cat);
        hasSourceImmune[immuC] = true;
      }

      Unit newUnit = Unit(
        isMoving: false,
        unitGameID: unit.unit_id,
        currentHp: unit.hit_point,
        isDead: false,
        maxHp: unit.hit_point,
        unitName: newGameUnitText.text,
        isWaiting: false,
        isProtected: false,
        unitWarId: "",
        isDoubleAttack: unit.atck_twice ?? false,
        unitAttack: unitAttack1,
        unitAttack2: unitAttack2,
        armor: unit.armor ?? 0,
        //attacks: newListAtck,
        attacksMap: newMapAtck,

        level: unit.level,
        upgradeArmor: dynUpgradeParams.armor ?? 0,
        upgradeDamage: dynUpgradeParams.damage ?? 0,
        upgradeHeal: dynUpgradeParams.heal ?? 0,
        upgradeInitiative: dynUpgradeParams.initiative ?? 0,
        upgradePower: dynUpgradeParams.power ?? 0,
        upgradeHp: dynUpgradeParams.hit_point,

        sourceImmune: sourceImmuneMap,
        hasClassImunne: hasClassImmune,
        hasSourceImunne: hasSourceImmune,
        classImmune: classImmuneMap,
        isBig: !(unit.size_small ?? false),
      );

      final eval = GameEvaluation();

      evalController.getUnitEvaluation(newUnit, eval);
      evals.add(PairValues<String, double>(
          first: newUnit.unitName, end: eval.getEval()));

      // todo Пока не поддерживаются двуклеточники
      if ((unit.size_small ?? false) || true) {
        _units.add(newUnit);
        _unitsNamesMap[newUnit.unitName] = newUnit;
        _unitsIdMap[newUnit.unitGameID] = newUnit;
      }
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
      return _unitsNamesMap[randomName]!.copyWith(
        unitWarId: uuid.v1(),
        attacksMap: <AttackClass, UnitAttack>{},
        attacks: <UnitAttack>[],
        unitAttack: _unitsNamesMap[randomName]!.unitAttack.copyWith(),
        unitAttack2: _unitsNamesMap[randomName]!.unitAttack2?.copyWith(),
      );
    } else {
      if (options.backLine) {
        final isRange = Random().nextInt(100) > 50;

        if (isRange) {
          final units = _units
              .where((element) =>
                  element.unitAttack.attackConstParams.targetsCount == TargetsCount.any)
              .toList();
          final index = Random().nextInt(units.length);
          return _getCopyUnitWithNewParams(units[index]);
          /*return units[index].copyWith(
            unitWarId: uuid.v1(),
            attacksMap: <AttackClass, UnitAttack>{},
            attacks: <UnitAttack>[],
            unitAttack: units[index].unitAttack.copyWith(),
            unitAttack2: units[index].unitAttack2?.copyWith(),
          );*/
        } else {
          final units = _units
              .where((element) =>
                  element.unitAttack.attackConstParams.targetsCount == TargetsCount.all)
              .toList();
          final index = Random().nextInt(units.length);
          return _getCopyUnitWithNewParams(units[index]);
          /*return units[index].copyWith(
            unitWarId: uuid.v1(),
            attacksMap: <AttackClass, UnitAttack>{},
            attacks: <UnitAttack>[],
            unitAttack: units[index].unitAttack.copyWith(),
            unitAttack2: units[index].unitAttack2?.copyWith(),
          );*/
        }
      }
      if (options.frontLine) {
        final units = _units
            .where((element) =>
                element.unitAttack.attackConstParams.targetsCount == TargetsCount.one)
            .toList();
        final index = Random().nextInt(units.length);

        return _getCopyUnitWithNewParams(units[index]);
        /*return units[index].copyWith(
          unitWarId: uuid.v1(),
          attacksMap: <AttackClass, UnitAttack>{},
          attacks: <UnitAttack>[],
          unitAttack: units[index].unitAttack.copyWith(),
          unitAttack2: units[index].unitAttack2?.copyWith(),
        );*/
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
    /*return _unitsNamesMap[name]!.copyWith(
      unitWarId: uuid.v1(),
      attacksMap: <AttackClass, UnitAttack>{},
      attacks: <UnitAttack>[],
      unitAttack: _unitsNamesMap[name]!.unitAttack.copyWith(),
      unitAttack2: _unitsNamesMap[name]!.unitAttack2?.copyWith(),
    );*/
  }

  /// Получить копию юнита по [id]
  /// TODO метод дико тормознутый
  @override
  Unit getCopyUnitById(String id) {
    Unit? newUnit;
    bool unitFound = false;
    for (var u in _units) {
      if (u.unitGameID == id) {
        newUnit = _getCopyUnitWithNewParams(u);
        /*newUnit = u.copyWith(
          unitWarId: uuid.v1(),
          attacksMap: <AttackClass, UnitAttack>{},
          attacks: <UnitAttack>[],
          unitAttack: u.unitAttack.copyWith(),
          unitAttack2: u.unitAttack2?.copyWith(),
        );*/
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
      unitWarId: uuid.v1(),
      attacksMap: <AttackClass, UnitAttack>{},
      attacks: <UnitAttack>[],
      unitAttack: u.unitAttack.deepCopy(),
      unitAttack2: u.unitAttack2?.deepCopy(),

      //classImmune: <int, ImunneCategory>{},
      //sourceImmune: <int, ImunneCategory>{},

      //hasSourceImunne: <int, bool>{},
      //hasClassImunne: <int, bool>{},
    );

    return newUnit;
  }

  @override
  List<String> getAllNames() {
    return gunitsProvider.objects.map((e) => e.name_txt).toList();
  }

  List<String> _getAllGameUnits() {
    return gunitsProvider.objects.map((e) => e.unit_id).toList();
  }
}
