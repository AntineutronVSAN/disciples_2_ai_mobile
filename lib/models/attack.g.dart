// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitAttack _$UnitAttackFromJson(Map json) => UnitAttack(
      power: json['power'] as int,
      heal: json['heal'] as int,
      damage: json['damage'] as int,
      initiative: json['initiative'] as int,
      targetsCount: $enumDecode(_$TargetsCountEnumMap, json['targetsCount']),
      attackClass: $enumDecode(_$AttackClassEnumMap, json['attackClass']),
      infinite: json['infinite'] as bool,
      attackId: json['attackId'] as String,
      currentDuration: json['currentDuration'] as int? ?? 0,
      firstDamage: json['firstDamage'] as int,
      level: json['level'] as int,
      firstInitiative: json['firstInitiative'] as int,
      source: json['source'] as int,
    );

Map<String, dynamic> _$UnitAttackToJson(UnitAttack instance) =>
    <String, dynamic>{
      'power': instance.power,
      'heal': instance.heal,
      'damage': instance.damage,
      'firstDamage': instance.firstDamage,
      'initiative': instance.initiative,
      'firstInitiative': instance.firstInitiative,
      'targetsCount': _$TargetsCountEnumMap[instance.targetsCount],
      'attackClass': _$AttackClassEnumMap[instance.attackClass],
      'infinite': instance.infinite,
      'attackId': instance.attackId,
      'level': instance.level,
      'source': instance.source,
      'currentDuration': instance.currentDuration,
    };

const _$TargetsCountEnumMap = {
  TargetsCount.one: 'one',
  TargetsCount.all: 'all',
  TargetsCount.any: 'any',
};

const _$AttackClassEnumMap = {
  AttackClass.L_DAMAGE: 'L_DAMAGE',
  AttackClass.L_DRAIN: 'L_DRAIN',
  AttackClass.L_PARALYZE: 'L_PARALYZE',
  AttackClass.L_HEAL: 'L_HEAL',
  AttackClass.L_FEAR: 'L_FEAR',
  AttackClass.L_BOOST_DAMAGE: 'L_BOOST_DAMAGE',
  AttackClass.L_PETRIFY: 'L_PETRIFY',
  AttackClass.L_LOWER_DAMAGE: 'L_LOWER_DAMAGE',
  AttackClass.L_LOWER_INITIATIVE: 'L_LOWER_INITIATIVE',
  AttackClass.L_POISON: 'L_POISON',
  AttackClass.L_FROSTBITE: 'L_FROSTBITE',
  AttackClass.L_REVIVE: 'L_REVIVE',
  AttackClass.L_DRAIN_OVERFLOW: 'L_DRAIN_OVERFLOW',
  AttackClass.L_CURE: 'L_CURE',
  AttackClass.L_SUMMON: 'L_SUMMON',
  AttackClass.L_DRAIN_LEVEL: 'L_DRAIN_LEVEL',
  AttackClass.L_GIVE_ATTACK: 'L_GIVE_ATTACK',
  AttackClass.L_DOPPELGANGER: 'L_DOPPELGANGER',
  AttackClass.L_TRANSFORM_SELF: 'L_TRANSFORM_SELF',
  AttackClass.L_TRANSFORM_OTHER: 'L_TRANSFORM_OTHER',
  AttackClass.L_BLISTER: 'L_BLISTER',
  AttackClass.L_BESTOW_WARDS: 'L_BESTOW_WARDS',
  AttackClass.L_SHATTER: 'L_SHATTER',
};
