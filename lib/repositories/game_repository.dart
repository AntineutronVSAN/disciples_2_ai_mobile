import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/game_models.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:uuid/uuid.dart';
import 'package:d2_ai_v2/models/unit.dart';

class GameRepository {
  // TODO Провайдеры из сгенерированного файла
  final uuid = Uuid();
  final Random random = Random();

  final GunitsProvider gunitsProvider;
  final TglobalProvider tglobalProvider;
  final GattacksProvider gattacksProvider;

  /// Мапа всех игровых юнитов с ID
  final Map<String, Gunits> _allGameUnits = {};

  final List<Unit> _units = [];

  final Map<String, Unit> _unitsNamesMap = {};

  GameRepository({
    required this.gunitsProvider,
    required this.tglobalProvider,
    required this.gattacksProvider,
  });

  List<Unit> getAllUnits() {
    return List.generate(_units.length, (index) => _units[index].copyWith());
  }

  void init() {
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

      print('${newGameUnitText.text} '
          '---- ${attack.atck_class} '
          '---- ${attack.qty_dam}'
          '---- ${attack2?.atck_class} '
          '---- ${attack2?.qty_dam}');

      final unitAttack1 = UnitAttack(
        attackId: attack.att_id,
        power: attack.power,
        heal: attack.qty_heal ?? 0,
        damage: attack.qty_dam ?? 0,
        initiative: attack.initiative,
        firstInitiative: attack.initiative,
        targetsCount: targetsCountFromReach(attack.reach),
        attackClass: attackClassFromGameAttack(attack.atck_class),
        infinite: attack.infinite ?? false,
        firstDamage: attack.qty_dam ?? 0,
        level: attack.level ?? 2,
      );

      UnitAttack? unitAttack2;

      if (attack2 != null) {
        unitAttack2 = UnitAttack(
          attackId: attack2.att_id,
          power: attack2.power,
          heal: attack2.qty_heal ?? 0,
          damage: attack2.qty_dam ?? 0,
          initiative: attack2.initiative,
          firstInitiative: attack2.initiative,
          targetsCount: targetsCountFromReach(attack2.reach),
          attackClass: attackClassFromGameAttack(attack2.atck_class),
          infinite: attack2.infinite ?? false,
          firstDamage: attack2.qty_dam ?? 0,
          level: attack2.level ?? 2,
        );
      }
      final newMapAtck = <AttackClass, UnitAttack>{};
      final newListAtck = <UnitAttack>[];

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
        attacks: newListAtck,
        attacksMap: newMapAtck,
      );

      // todo Пока не поддерживаются двуклеточники
      if ((unit.size_small ?? false) || true) {
        _units.add(newUnit);
        _unitsNamesMap[newUnit.unitName] = newUnit;
      }
    }
  }

  Unit getCopyUnitByName(String name) {
    final hasUnit = _unitsNamesMap.containsKey(name);
    if (!hasUnit) {
      return Unit.empty();
    }
    return _unitsNamesMap[name]!.copyWith(
      unitWarId: uuid.v1(),
      attacksMap: <AttackClass, UnitAttack>{},
      attacks: <UnitAttack>[],
      unitAttack: _unitsNamesMap[name]!.unitAttack.copyWith(),
      unitAttack2: _unitsNamesMap[name]!.unitAttack2?.copyWith(),
    );
  }

  List<String> getAllNames() {
    return gunitsProvider.objects.map((e) => e.name_txt).toList();
  }

  List<String> _getAllGameUnits() {
    return gunitsProvider.objects.map((e) => e.unit_id).toList();
  }
}
