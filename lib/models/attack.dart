import 'package:d2_ai_v2/models/unit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attack.g.dart';

@JsonSerializable()
class UnitAttack {
  final int power;
  final int heal;
  final int damage;
  final int firstDamage;
  final int initiative;
  final int firstInitiative;

  final TargetsCount targetsCount;

  final AttackClass attackClass;

  final bool infinite;

  final String attackId;

  final int level;

  final int source;

  /// Така может повеситься на юнита. Это поле покажет, сколько ещё будет
  /// висеть атака на юните
  final int currentDuration;

  UnitAttack({
    required this.power,
    required this.heal,
    required this.damage,
    required this.initiative,
    required this.targetsCount,
    required this.attackClass,
    required this.infinite,
    required this.attackId,
    this.currentDuration = 0,

    required this.firstDamage,
    required this.level,
    required this.firstInitiative,

    required this.source,
  });

  UnitAttack deepCopy() {
    return UnitAttack(
      currentDuration: currentDuration,
      power: power,
      heal: heal,
      damage: damage,
      initiative: initiative,
      targetsCount: targetsCount,
      attackClass: attackClass,
      infinite: infinite,
      attackId: attackId,
      firstDamage: firstDamage,
      level: level,
      firstInitiative: firstInitiative,
      source: source,
    );
  }

  factory UnitAttack.fromJson(Map<String, dynamic> json) =>
      _$UnitAttackFromJson(json);

  Map<String, dynamic> toJson() => _$UnitAttackToJson(this);

  UnitAttack copyWith({
    power,
    heal,
    damage,
    initiative,
    targetsCount,
    attackClass,
    infinite,
    attackId,
    currentDuration,
    level,

    firstDamage,
    firstInitiative,

    source,

  }) {
    return UnitAttack(
      power: power ?? this.power,
      heal: heal ?? this.heal,
      damage: damage ?? this.damage,
      initiative: initiative ?? this.initiative,
      targetsCount: targetsCount ?? this.targetsCount,
      attackClass: attackClass ?? this.attackClass,
      infinite: infinite ?? this.infinite,
      attackId: attackId ?? this.attackId,
      currentDuration: currentDuration ?? this.currentDuration,

      level: level ?? this.level,

      firstDamage: firstDamage ?? this.firstDamage,
      firstInitiative: firstInitiative ?? this.firstInitiative,

        source: source ?? this.source,
    );
  }

  factory UnitAttack.empty() {
    return UnitAttack(
      power: 0,
      heal: 0,
      damage: 0,
      initiative: 0,
      targetsCount: TargetsCount.any,
      attackClass: AttackClass.L_DAMAGE,
      infinite: false,
      attackId: "",
      firstDamage: 0,
      level: 0,
      firstInitiative: 0,
      source: -1,
    );
  }

  bool isHeal() {
    switch (attackClass) {
      case AttackClass.L_DAMAGE:
        return false;
      case AttackClass.L_DRAIN:
        return false;
      case AttackClass.L_PARALYZE:
        return false;
      case AttackClass.L_HEAL:
        return heal > 0;
      case AttackClass.L_FEAR:
        return false;
      case AttackClass.L_BOOST_DAMAGE:
        return false;
      case AttackClass.L_PETRIFY:
        return false;
      case AttackClass.L_LOWER_DAMAGE:
        return false;
      case AttackClass.L_LOWER_INITIATIVE:
        return false;
      case AttackClass.L_POISON:
        return false;
      case AttackClass.L_FROSTBITE:
        return false;
      case AttackClass.L_REVIVE:
        return false;
      case AttackClass.L_DRAIN_OVERFLOW:
        return false;
      case AttackClass.L_CURE:
        return false;
      case AttackClass.L_SUMMON:
        return false;
      case AttackClass.L_DRAIN_LEVEL:
        return false;
      case AttackClass.L_GIVE_ATTACK:
        return false;
      case AttackClass.L_DOPPELGANGER:
        return false;
      case AttackClass.L_TRANSFORM_SELF:
        return false;
      case AttackClass.L_TRANSFORM_OTHER:
        return false;
      case AttackClass.L_BLISTER:
        return false;
      case AttackClass.L_BESTOW_WARDS:
        return false;
      case AttackClass.L_SHATTER:
        return false;
    }
  }

  bool isDamage() {
    switch (attackClass) {
      case AttackClass.L_DAMAGE:
        return true;
      case AttackClass.L_DRAIN:
        return true;
      case AttackClass.L_PARALYZE:
        return false;
      case AttackClass.L_HEAL:
        return false;
      case AttackClass.L_FEAR:
        return false;
      case AttackClass.L_BOOST_DAMAGE:
        return false;
      case AttackClass.L_PETRIFY:
        return false;
      case AttackClass.L_LOWER_DAMAGE:
        return false;
      case AttackClass.L_LOWER_INITIATIVE:
        return false;
      case AttackClass.L_POISON:
        return true;
      case AttackClass.L_FROSTBITE:
        return true;
      case AttackClass.L_REVIVE:
        return false;
      case AttackClass.L_DRAIN_OVERFLOW:
        return true;
      case AttackClass.L_CURE:
        return false;
      case AttackClass.L_SUMMON:
        return false;
      case AttackClass.L_DRAIN_LEVEL:
        return false;
      case AttackClass.L_GIVE_ATTACK:
        return false;
      case AttackClass.L_DOPPELGANGER:
        return false;
      case AttackClass.L_TRANSFORM_SELF:
        return false;
      case AttackClass.L_TRANSFORM_OTHER:
        return false;
      case AttackClass.L_BLISTER:
        return true;
      case AttackClass.L_BESTOW_WARDS:
        return false;
      case AttackClass.L_SHATTER:
        return false;
    }
  }

  bool isDot() {
    switch (attackClass) {
      case AttackClass.L_DAMAGE:
        return false;
      case AttackClass.L_DRAIN:
        return false;
      case AttackClass.L_PARALYZE:
        return false;
      case AttackClass.L_HEAL:
        return false;
      case AttackClass.L_FEAR:
        return false;
      case AttackClass.L_BOOST_DAMAGE:
        return false;
      case AttackClass.L_PETRIFY:
        return false;
      case AttackClass.L_LOWER_DAMAGE:
        return false;
      case AttackClass.L_LOWER_INITIATIVE:
        return false;
      case AttackClass.L_POISON:
        return true;
      case AttackClass.L_FROSTBITE:
        return true;
      case AttackClass.L_REVIVE:
        return false;
      case AttackClass.L_DRAIN_OVERFLOW:
        return false;
      case AttackClass.L_CURE:
        return false;
      case AttackClass.L_SUMMON:
        return false;
      case AttackClass.L_DRAIN_LEVEL:
        return false;
      case AttackClass.L_GIVE_ATTACK:
        return false;
      case AttackClass.L_DOPPELGANGER:
        return false;
      case AttackClass.L_TRANSFORM_SELF:
        return false;
      case AttackClass.L_TRANSFORM_OTHER:
        return false;
      case AttackClass.L_BLISTER:
        return true;
      case AttackClass.L_BESTOW_WARDS:
        return false;
      case AttackClass.L_SHATTER:
        return false;
    }
  }

}

AttackClass attackClassFromGameAttack(int cls) {
  switch (cls) {
    case 1:
      return AttackClass.L_DAMAGE;
    case 2:
      return AttackClass.L_DRAIN;
    case 3:
      return AttackClass.L_PARALYZE;
    case 6:
      return AttackClass.L_HEAL;
    case 7:
      return AttackClass.L_FEAR;
    case 8:
      return AttackClass.L_BOOST_DAMAGE;
    case 9:
      return AttackClass.L_PETRIFY;
    case 10:
      return AttackClass.L_LOWER_DAMAGE;
    case 11:
      return AttackClass.L_LOWER_INITIATIVE;
    case 12:
      return AttackClass.L_POISON;
    case 13:
      return AttackClass.L_FROSTBITE;
    case 14:
      return AttackClass.L_REVIVE;
    case 15:
      return AttackClass.L_DRAIN_OVERFLOW;
    case 16:
      return AttackClass.L_CURE;
    case 17:
      return AttackClass.L_SUMMON;
    case 18:
      return AttackClass.L_DRAIN_LEVEL;
    case 19:
      return AttackClass.L_GIVE_ATTACK;
    case 20:
      return AttackClass.L_DOPPELGANGER;
    case 21:
      return AttackClass.L_TRANSFORM_SELF;
    case 22:
      return AttackClass.L_TRANSFORM_OTHER;
    case 23:
      return AttackClass.L_BLISTER;
    case 24:
      return AttackClass.L_BESTOW_WARDS;
    case 25:
      return AttackClass.L_SHATTER;
  }
  throw Exception();
}

int gameAttackNumberFromClass(AttackClass atck) {
  switch(atck) {

    case AttackClass.L_DAMAGE:
      return 1;
    case AttackClass.L_DRAIN:
      return 2;
    case AttackClass.L_PARALYZE:
      return 3;
    case AttackClass.L_HEAL:
      return 6;
    case AttackClass.L_FEAR:
      return 7;
    case AttackClass.L_BOOST_DAMAGE:
      return 8;
    case AttackClass.L_PETRIFY:
      return 9;
    case AttackClass.L_LOWER_DAMAGE:
      return 10;
    case AttackClass.L_LOWER_INITIATIVE:
      return 11;
    case AttackClass.L_POISON:
      return 12;
    case AttackClass.L_FROSTBITE:
      return 13;
    case AttackClass.L_REVIVE:
      return 14;
    case AttackClass.L_DRAIN_OVERFLOW:
      return 15;
    case AttackClass.L_CURE:
      return 16;
    case AttackClass.L_SUMMON:
      return 17;
    case AttackClass.L_DRAIN_LEVEL:
      return 18;
    case AttackClass.L_GIVE_ATTACK:
      return 19;
    case AttackClass.L_DOPPELGANGER:
      return 20;
    case AttackClass.L_TRANSFORM_SELF:
      return 21;
    case AttackClass.L_TRANSFORM_OTHER:
      return 22;
    case AttackClass.L_BLISTER:
      return 23;
    case AttackClass.L_BESTOW_WARDS:
      return 24;
    case AttackClass.L_SHATTER:
      return 25;
  }

  throw Exception();
}


enum AttackClass {
  /// Простой урон
  L_DAMAGE,

  /// Истощение (вампиризм)
  /// Использует урон [qty_dam] и пополняет здоровье на половину нанесённого урона
  L_DRAIN,

  /// Паралич
  L_PARALYZE,

  /// Исцеление
  L_HEAL,

  /// Страх
  L_FEAR,

  /// Увеличение урона
  /// Если [level] == 1 - +25%
  /// Если [level] == 2 - +50%
  /// Если [level] == 3 - +75%
  /// Если [level] == 4 - +100%
  L_BOOST_DAMAGE,

  /// Окаменение
  L_PETRIFY,

  /// Снижение повреждения
  /// Требует параметра игрового юнита [level]
  /// Если [level] == 1 - снижение 50%
  /// Если [level] == 2 - снижение 33%
  L_LOWER_DAMAGE,

  /// Снижение ини
  L_LOWER_INITIATIVE,

  /// Яд
  L_POISON,

  /// Мороз
  L_FROSTBITE,

  /// Воскрешение
  L_REVIVE,

  /// Выпить жизненную сиду
  L_DRAIN_OVERFLOW,

  /// Лечение (эффектов)
  L_CURE,

  /// Призыв
  L_SUMMON,

  /// Понизить уровень
  L_DRAIN_LEVEL,

  /// Прибавить атаку
  L_GIVE_ATTACK,

  /// Передать жизненную сиду
  L_DOPPELGANGER,

  /// Превраить себя
  L_TRANSFORM_SELF,

  /// Превратить другого
  L_TRANSFORM_OTHER,

  /// Ожёг
  L_BLISTER,

  /// Защита от стихий
  L_BESTOW_WARDS,

  /// Разбить броню
  L_SHATTER,
}