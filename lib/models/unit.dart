import 'package:d2_ai_v2/models/attack.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

@JsonSerializable()
class Unit {
  final bool isMoving;
  final bool isDead;
  final bool isProtected;
  final bool isWaiting;

  final int maxHp;
  final int currentHp;

  final String unitName;

  /// id юнита в игре
  final String unitGameID;

  /// id юнита на поле боя
  final String unitWarId;

  final bool isDoubleAttack;
  final int currentAttack;

  final UnitAttack unitAttack;
  final UnitAttack? unitAttack2;

  /// Что висит на юните
  final List<UnitAttack> attacks;
  final Map<AttackClass, UnitAttack> attacksMap;

  /// Что времено отображается на ячейке юнита
  final String uiInfo;

  /// Отступает ли юнит с поля боя
  final bool retreat;

  final int armor;

  final bool paralyzed;
  final bool petrified;

  final bool poisoned;
  final bool blistered;
  final bool frostbited;

  final bool damageLower;
  final bool initLower;

  final bool revived;

  final bool damageBusted;

  /// Юнит превращён в другого
  final bool transformed;


  /* UPGRADE START */
  final int level;

  final int upgradeDamage;
  final int upgradeArmor;
  final int upgradeInitiative;
  final int upgradeHeal;
  final int upgradePower;
  final int upgradeHp;

  final String? nextID;
  final String? prevID;

  final bool overLevel;
  /* UPGRADE END */

  /* IMMUNE START */
  /// Ключ - класс атаки (23), значение - категория
  final Map<int, ImunneCategory> classImmune;
  /// Ключ - источник атаки (7), значение - категория
  final Map<int, ImunneCategory> sourceImmune;

  /// Флаг определяет, есть ли в данный момент защита от
  /// класса атаки (23). Ключ - класс
  final Map<int, bool> hasClassImunne;
  /// Флаг определяет, есть ли в данный момент защита от
  /// источника атаки (7). Ключ - класс
  final Map<int, bool> hasSourceImunne;

  /* IMMUNE END */


  Unit({
    required this.isDead,
    required this.isMoving,
    required this.isProtected,
    required this.isWaiting,
    required this.currentHp,
    required this.maxHp,
    required this.unitName,
    required this.unitGameID,
    required this.unitWarId,
    required this.isDoubleAttack,
    this.currentAttack = 0,
    required this.unitAttack,
    required this.unitAttack2,
    this.uiInfo = '',
    this.retreat = false,
    required this.armor,
    this.paralyzed = false,
    required this.attacks,
    required this.attacksMap,
    this.poisoned = false,
    this.blistered = false,
    this.frostbited = false,
    this.damageLower = false,
    this.revived = false,
    this.petrified = false,
    this.initLower = false,
    this.damageBusted = false,
    this.transformed = false,

    required this.level,
    required this.upgradeArmor,
    required this.upgradeDamage,
    required this.upgradeHeal,
    required this.upgradeInitiative,
    required this.upgradePower,
    required this.upgradeHp,

    this.nextID,
    this.prevID,
    this.overLevel = false,

    required this.classImmune,
    required this.sourceImmune,
    required this.hasClassImunne,
    required this.hasSourceImunne,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);

  Unit deepCopy() {
    return Unit(isDead: isDead,
        isMoving: isMoving,
        isProtected: isProtected,
        isWaiting: isWaiting,
        currentHp: currentHp,
        maxHp: maxHp,
        unitName: unitName,
        unitGameID: unitGameID,
        unitWarId: unitWarId,
        isDoubleAttack: isDoubleAttack,
        unitAttack: unitAttack.deepCopy(),
        unitAttack2: unitAttack2?.deepCopy(),
        armor: armor,
        attacks: attacks.map((e) => e.deepCopy()).toList(),
        attacksMap: attacksMap.map((key, value) => MapEntry(key, value.deepCopy())),

        currentAttack: currentAttack,
        uiInfo: uiInfo,
        retreat: retreat,
        paralyzed: paralyzed,
        poisoned: poisoned,
        blistered: blistered,
        frostbited: frostbited,
        damageLower: damageLower,
        revived: revived,
        petrified: petrified,
        initLower: initLower,
        damageBusted: damageBusted,
        transformed: transformed,

        level: level,
        upgradeArmor: upgradeArmor,
        upgradeDamage: upgradeDamage,
        upgradeHeal: upgradeHeal,
        upgradeInitiative: upgradeInitiative,
        upgradePower: upgradePower,
      upgradeHp: upgradeHp,
      overLevel: overLevel,

      nextID: nextID,
      prevID: prevID,

      classImmune: classImmune.map((key, value) => MapEntry(key, value)),
      sourceImmune: sourceImmune.map((key, value) => MapEntry(key, value)),
      hasClassImunne: hasClassImunne.map((key, value) => MapEntry(key, value)),
      hasSourceImunne: hasSourceImunne.map((key, value) => MapEntry(key, value)),

    );
  }

  /// Скопировать юнита с новыми параметрами.
  /// Важно помнить, что у новой копии по имолчанию параметр [uiInfo]
  /// пустой
  Unit copyWith({isMoving,
    isDead,
    isProtected,
    isWaiting,
    maxHp,
    currentHp,
    unitName,
    unitGameID,
    unitWarId,
    isDoubleAttack,
    currentAttack,
    unitAttack,
    unitAttack2,
    attacks,
    attacksMap,
    uiInfo,
    retreat,
    armor,
    paralyzed,
    poisoned,
    blistered,
    frostbited,
    damageLower,
    revived,
    petrified,
    initLower,
    damageBusted,
    transformed,

    level,
    upgradeArmor,
    upgradeDamage,
    upgradeHeal,
    upgradeInitiative,
    upgradePower,
    upgradeHp,
    overLevel,

    nextID,
    prevID,

    classImmune,
    sourceImmune,
    hasClassImunne,
    hasSourceImunne,
  }) {
    return Unit(
      isMoving: isMoving ?? this.isMoving,
      isDead: isDead ?? this.isDead,
      isProtected: isProtected ?? this.isProtected,
      isWaiting: isWaiting ?? this.isWaiting,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      unitName: unitName ?? this.unitName,
      unitGameID: unitGameID ?? this.unitGameID,
      unitWarId: unitWarId ?? this.unitWarId,
      isDoubleAttack: isDoubleAttack ?? this.isDoubleAttack,
      currentAttack: currentAttack ?? this.currentAttack,
      unitAttack: unitAttack ?? this.unitAttack,
      unitAttack2: unitAttack2 ?? this.unitAttack2,
      attacks: attacks ?? this.attacks,
      attacksMap: attacksMap ?? this.attacksMap,
      uiInfo: (uiInfo is String) ? uiInfo : ((uiInfo != null) ? uiInfo
          .toString() : ""),
      retreat: retreat ?? this.retreat,
      armor: armor ?? this.armor,
      paralyzed: paralyzed ?? this.paralyzed,
      poisoned: poisoned ?? this.poisoned,
      blistered: blistered ?? this.blistered,
      frostbited: frostbited ?? this.frostbited,
      damageLower: damageLower ?? this.damageLower,
      revived: revived ?? this.revived,
      petrified: petrified ?? this.petrified,
      initLower: initLower ?? this.initLower,
      damageBusted: damageBusted ?? this.damageBusted,
      transformed: transformed ?? this.transformed,

      level: level ?? this.level,
      upgradeArmor: upgradeArmor ?? this.upgradeArmor,
      upgradeDamage: upgradeDamage ?? this.upgradeDamage,
      upgradeHeal: upgradeHeal ?? this.upgradeHeal,
      upgradeInitiative: upgradeInitiative ?? this.upgradeInitiative,
      upgradePower: upgradePower ?? this.upgradePower,
      upgradeHp: upgradeHp ?? this.upgradeHp,
      overLevel: overLevel ?? this.overLevel,

      nextID: nextID ?? this.nextID,
      prevID: prevID ?? this.prevID,

      classImmune: classImmune ?? this.classImmune,
      sourceImmune: sourceImmune ?? this.sourceImmune,
      hasSourceImunne: hasSourceImunne ?? this.hasSourceImunne,
      hasClassImunne: hasClassImunne ?? this.hasClassImunne,
    );
  }

  Unit copyWithDead({
    maxHp,
    currentHp,
    unitName,
    unitGameID,
    unitWarId,
    isDoubleAttack,
    unitAttack,
    unitAttack2,
    attacks,
    attacksMap,
    armor,
    revived,
  }) {
    this.attacksMap.clear();
    this.attacks.clear();
    return Unit(
      isMoving: false,
      isDead: true,
      isProtected: false,
      isWaiting: false,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      unitName: unitName ?? this.unitName,
      unitGameID: unitGameID ?? this.unitGameID,
      unitWarId: unitWarId ?? this.unitWarId,
      isDoubleAttack: isDoubleAttack ?? this.isDoubleAttack,
      currentAttack: 0,
      unitAttack: this.unitAttack.copyWith(
        damage: this.unitAttack.firstDamage,
        initiative: this.unitAttack.firstInitiative,
      ),
      unitAttack2: unitAttack2 ?? this.unitAttack2,
      attacks: this.attacks,
      attacksMap: this.attacksMap,
      uiInfo: "Мёртв",
      retreat: false,
      armor: armor ?? this.armor,
      paralyzed: false,
      petrified: false,
      poisoned: false,
      blistered: false,
      frostbited: false,
      damageLower: false,
      initLower: false,
      damageBusted: false,
      revived: revived ?? this.revived,
      transformed: false,

      level: level,
      upgradeArmor: upgradeArmor,
      upgradeDamage: upgradeDamage,
      upgradeHeal: upgradeHeal,
      upgradeInitiative: upgradeInitiative,
      upgradePower: upgradePower,
      upgradeHp: upgradeHp,
      overLevel: overLevel,

      nextID: nextID,
      prevID: prevID,

      hasSourceImunne: hasSourceImunne,
      hasClassImunne: hasClassImunne,
      classImmune: classImmune,
      sourceImmune: sourceImmune,
    );
  }

  static Unit empty() {
    return Unit(
        isMoving: false,
        isDead: false,
        maxHp: 0,
        currentHp: 0,
        unitName: 'Empty',
        unitGameID: "",
        isProtected: false,
        isWaiting: false,
        unitWarId: "",
        isDoubleAttack: false,
        unitAttack: UnitAttack.empty(),
        unitAttack2: null,
        armor: 0,
        attacks: [],
        attacksMap: {},
        level: 0,
        upgradeArmor: 0,
        upgradeDamage: 0,
        upgradeHeal: 0,
        upgradeInitiative: 0,
        upgradePower: 0,
      overLevel: false,
      upgradeHp: 0,
      nextID: null,
      prevID: null,
      classImmune: {},
      sourceImmune: {},
      hasClassImunne: {},
      hasSourceImunne: {},
    );
  }

  bool isEmpty() {
    return unitGameID == "";
  }
}

enum TargetsCount { one, all, any }

enum AttackType {
  weapon,
  fire,
  water,
  air,
  earth,
  life,
  health,
  death,
  intelligence,
}

TargetsCount targetsCountFromReach(int reach) {
  switch (reach) {
    case 1:
      return TargetsCount.all;
    case 2:
      return TargetsCount.any;
    case 3:
      return TargetsCount.one;
  }
  throw Exception();
}

AttackType? attackTypeFromSource(int? source) {
  if (source == null) {
    return null;
  }

  switch (source) {
    case 0:
      return AttackType.weapon;
    case 1:
      return AttackType.intelligence;
    case 2:
      return AttackType.life;
    case 3:
      return AttackType.death;
    case 4:
      return AttackType.fire;
    case 5:
      return AttackType.water;
    case 6:
      return AttackType.earth;
    case 7:
      return AttackType.air;
  }
  throw Exception("Низвестный источник атаки");
}

enum ImunneCategory {
  no,
  once,
  always
}

ImunneCategory immuneCategoryFromValue(int value) {
  switch (value) {
    case 1:
      return ImunneCategory.no;
    case 2:
      return ImunneCategory.once;
    case 3:
      return ImunneCategory.always;
  }
  throw Exception("Низвестная категория защиты");
}