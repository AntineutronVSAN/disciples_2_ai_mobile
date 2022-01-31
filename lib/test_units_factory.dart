

import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';

// TODO Все общие с тестами параметрами вынести в константы

const int testUnitHp = 50;
const int testUnitDamage = 10;
const int testUnitInit = 33;

const int testDamagerWithOnceImmuneSelfDamage = 50;
const int testDamagerWithOnceImmuneSelfInitiative = 50;
const int testDamagerWithOnceImmuneSelfHp = 200;
const int testDamagerWithOnceImmuneSelfSource = 0;

class TestUnitsFactory {

  static int _testIDCounter = 0;

  static int get _getNextID {
    _testIDCounter++;
    return _testIDCounter;
  }

  /// Получить юнита-дамагера, который имеет защиту от своей атаки
  static Unit getDamagerWithOnceImmuneSelf({
    int withDamage = testDamagerWithOnceImmuneSelfDamage,
    int withInit = testDamagerWithOnceImmuneSelfInitiative,
    int withHp = testDamagerWithOnceImmuneSelfHp,
  }) {
    return Unit(
        isDead: false,
        isMoving: false,
        isProtected: false,
        isWaiting: false,
        currentHp: withHp,
        maxHp: withHp,
        unitName: 'Test damager',
        unitGameID: 'unitGameID',
        unitWarId: _getNextID.toString(),
        isDoubleAttack: false,

        unitAttack: UnitAttack(
            power: 80,
            heal: 0,
            damage: withDamage,
            initiative: withInit,
            targetsCount: TargetsCount.one,
            attackClass: AttackClass.L_DAMAGE,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: withDamage,
            level: 0,
            firstInitiative: withInit,
            source: testDamagerWithOnceImmuneSelfSource),

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
        classImmune: <int, ImunneCategory>{},
        sourceImmune: <int, ImunneCategory>{testDamagerWithOnceImmuneSelfSource: ImunneCategory.once},
        hasClassImunne: <int, bool>{},
        hasSourceImunne: <int, bool>{testDamagerWithOnceImmuneSelfSource: true});
  }

  /// Получить юнита, который превращает цель в другого юнита на 0 ходов.
  /// Важно отметить, что превращаемый юнит должен быть
  /// тестовым юнитов. Для этого в верхнеуровневые классы
  /// внедряется тестовый репозиторий
  static Unit getUnitTransformer() {

    return Unit(
        isDead: false,
        isMoving: false,
        isProtected: false,
        isWaiting: false,
        currentHp: 255,
        maxHp: 255,
        unitName: 'Test damager',
        unitGameID: 'unitGameID',
        unitWarId: _getNextID.toString(),
        isDoubleAttack: false,

        unitAttack: UnitAttack(
            power: 80,
            heal: 0,
            damage: 0,
            initiative: 80,
            targetsCount: TargetsCount.any,
            attackClass: AttackClass.L_TRANSFORM_OTHER,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: 25,
            level: 3,
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

  /// Бустер урона на 75%
  static Unit getDamageBuster() {
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
            damage: 0,
            initiative: 50,
            targetsCount: TargetsCount.any,
            attackClass: AttackClass.L_BOOST_DAMAGE,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: 25,
            level: 3,
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

  /// Тестовый юнит для тестового репозитория. Тестовый репозиторий
  /// везде возвращает этого юнита
  static Unit getTestUnit() {
    return Unit(
        isDead: false,
        isMoving: false,
        isProtected: false,
        isWaiting: false,
        currentHp: testUnitHp,
        maxHp: testUnitHp,
        unitName: 'Test damager',
        unitGameID: 'unitGameID2',
        unitWarId: _getNextID.toString(),
        isDoubleAttack: false,

        unitAttack: UnitAttack(
            power: 80,
            heal: 0,
            damage: testUnitDamage,
            initiative: testUnitInit,
            targetsCount: TargetsCount.one,
            attackClass: AttackClass.L_DAMAGE,
            infinite: false,
            attackId: _getNextID.toString(),
            firstDamage: testUnitDamage,
            level: 0,
            firstInitiative: testUnitInit,
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