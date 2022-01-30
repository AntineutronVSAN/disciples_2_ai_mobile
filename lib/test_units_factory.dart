

import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';

class TestUnitsFactory {

  static int _testIDCounter = 0;

  static int get _getNextID {
    _testIDCounter++;
    return _testIDCounter;
  }

  static Unit getTestUnit() {
    return Unit(
        isDead: false,
        isMoving: false,
        isProtected: false,
        isWaiting: false,
        currentHp: 100,
        maxHp: 100,
        unitName: 'Test damager',
        unitGameID: 'unitGameID',
        unitWarId: _getNextID.toString(),
        isDoubleAttack: false,

        unitAttack: UnitAttack(
            power: 80,
            heal: 0,
            damage: 25,
            initiative: 50,
            targetsCount: TargetsCount.one,
            attackClass: AttackClass.L_DAMAGE,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: 25,
            level: 0,
            firstInitiative: 50,
            source: 0),

        unitAttack2: null,
        armor: 0,
        attacksMap: {},
        level: 1,
        upgradeArmor: 0,
        upgradeDamage: 0,
        upgradeHeal: 0,
        upgradeInitiative: 0,
        upgradePower: 0,
        upgradeHp: 0,
        classImmune: {},
        sourceImmune: {},
        hasClassImunne: {},
        hasSourceImunne: {});
  }

  /// Тестовый простой дамагер. Одна атака с типом оружие
  static Unit getTestUnitDamager() {
    return Unit(
        isDead: false,
        isMoving: false,
        isProtected: false,
        isWaiting: false,
        currentHp: 100,
        maxHp: 100,
        unitName: 'Test damager',
        unitGameID: 'unitGameID',
        unitWarId: _getNextID.toString(),
        isDoubleAttack: false,

        unitAttack: UnitAttack(
            power: 80,
            heal: 0,
            damage: 25,
            initiative: 50,
            targetsCount: TargetsCount.one,
            attackClass: AttackClass.L_DAMAGE,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: 25,
            level: 0,
            firstInitiative: 50,
            source: 0),

        unitAttack2: null,
        armor: 0,
        attacksMap: {},
        level: 1,
        upgradeArmor: 0,
        upgradeDamage: 0,
        upgradeHeal: 0,
        upgradeInitiative: 0,
        upgradePower: 0,
        upgradeHp: 0,
        classImmune: {},
        sourceImmune: {},
        hasClassImunne: {},
        hasSourceImunne: {});

  }


  /// Тестовый понижатель урона(основная атака) и инициативы
  /// на максимальное значение
  static Unit getTestLowerDamagerAndInitiative() {
    return Unit(
        isDead: false,
        isMoving: false,
        isProtected: false,
        isWaiting: false,
        currentHp: 100,
        maxHp: 100,
        unitName: 'Test lower',
        unitGameID: 'unitGameID',
        unitWarId: _getNextID.toString(),
        isDoubleAttack: false,

        unitAttack: UnitAttack(
            power: 80,
            heal: 0,
            damage: 0,
            initiative: 50,
            targetsCount: TargetsCount.one,
            attackClass: AttackClass.L_LOWER_DAMAGE,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: 0,
            level: 1,
            firstInitiative: 50,
            source: 0),

        unitAttack2: UnitAttack(
            power: 80,
            heal: 0,
            damage: 0,
            initiative: 50,
            targetsCount: TargetsCount.one,
            attackClass: AttackClass.L_LOWER_INITIATIVE,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: 0,
            level: 1,
            firstInitiative: 50,
            source: 0),
        armor: 0,
        attacksMap: {},
        level: 1,
        upgradeArmor: 0,
        upgradeDamage: 0,
        upgradeHeal: 0,
        upgradeInitiative: 0,
        upgradePower: 0,
        upgradeHp: 0,
        classImmune: {},
        sourceImmune: {},
        hasClassImunne: {},
        hasSourceImunne: {});

  }
}