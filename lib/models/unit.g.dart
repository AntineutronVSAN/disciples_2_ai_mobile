// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      isDead: json['isDead'] as bool,
      isMoving: json['isMoving'] as bool,
      isProtected: json['isProtected'] as bool,
      isWaiting: json['isWaiting'] as bool,
      currentHp: json['currentHp'] as int,
      maxHp: json['maxHp'] as int,
      unitName: json['unitName'] as String,
      unitGameID: json['unitGameID'] as String,
      unitWarId: json['unitWarId'] as String,
      isDoubleAttack: json['isDoubleAttack'] as bool,
      currentAttack: json['currentAttack'] as int? ?? 0,
      unitAttack:
          UnitAttack.fromJson(json['unitAttack'] as Map<String, dynamic>),
      unitAttack2: json['unitAttack2'] == null
          ? null
          : UnitAttack.fromJson(json['unitAttack2'] as Map<String, dynamic>),
      uiInfo: json['uiInfo'] as String? ?? '',
      retreat: json['retreat'] as bool? ?? false,
      armor: json['armor'] as int,
      paralyzed: json['paralyzed'] as bool? ?? false,
      attacks: (json['attacks'] as List<dynamic>)
          .map((e) => UnitAttack.fromJson(e as Map<String, dynamic>))
          .toList(),
      attacksMap: (json['attacksMap'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$AttackClassEnumMap, k),
            UnitAttack.fromJson(e as Map<String, dynamic>)),
      ),
      poisoned: json['poisoned'] as bool? ?? false,
      blistered: json['blistered'] as bool? ?? false,
      frostbited: json['frostbited'] as bool? ?? false,
      damageLower: json['damageLower'] as bool? ?? false,
      revived: json['revived'] as bool? ?? false,
      petrified: json['petrified'] as bool? ?? false,
      initLower: json['initLower'] as bool? ?? false,
      damageBusted: json['damageBusted'] as bool? ?? false,
    );

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'isMoving': instance.isMoving,
      'isDead': instance.isDead,
      'isProtected': instance.isProtected,
      'isWaiting': instance.isWaiting,
      'maxHp': instance.maxHp,
      'currentHp': instance.currentHp,
      'unitName': instance.unitName,
      'unitGameID': instance.unitGameID,
      'unitWarId': instance.unitWarId,
      'isDoubleAttack': instance.isDoubleAttack,
      'currentAttack': instance.currentAttack,
      'unitAttack': instance.unitAttack,
      'unitAttack2': instance.unitAttack2,
      'attacks': instance.attacks,
      'attacksMap': instance.attacksMap
          .map((k, e) => MapEntry(_$AttackClassEnumMap[k], e)),
      'uiInfo': instance.uiInfo,
      'retreat': instance.retreat,
      'armor': instance.armor,
      'paralyzed': instance.paralyzed,
      'petrified': instance.petrified,
      'poisoned': instance.poisoned,
      'blistered': instance.blistered,
      'frostbited': instance.frostbited,
      'damageLower': instance.damageLower,
      'initLower': instance.initLower,
      'revived': instance.revived,
      'damageBusted': instance.damageBusted,
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
