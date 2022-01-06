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

    /// Первоначальный урон. Неизменяемый!
    required this.firstDamage,
    required this.level,
    required this.firstInitiative,
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
      firstInitiative: firstInitiative);
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
      firstDamage: firstDamage,
      level: level ?? this.level,
      firstInitiative: firstInitiative,
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
    );
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





