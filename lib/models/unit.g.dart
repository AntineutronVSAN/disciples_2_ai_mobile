// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitConstParams _$UnitConstParamsFromJson(Map json) => UnitConstParams(
      maxHp: json['maxHp'] as int,
      isDoubleAttack: json['isDoubleAttack'] as bool,
      unitName: json['unitName'] as String,
      unitGameID: json['unitGameID'] as String,
      unitWarId: json['unitWarId'] as String,
      upgradeDamage: json['upgradeDamage'] as int,
      upgradePower: json['upgradePower'] as int,
      upgradeHeal: json['upgradeHeal'] as int,
      upgradeInitiative: json['upgradeInitiative'] as int,
      upgradeHp: json['upgradeHp'] as int,
      upgradeArmor: json['upgradeArmor'] as int,
      overLevel: json['overLevel'] as bool,
    );

Map<String, dynamic> _$UnitConstParamsToJson(UnitConstParams instance) =>
    <String, dynamic>{
      'maxHp': instance.maxHp,
      'unitName': instance.unitName,
      'unitGameID': instance.unitGameID,
      'unitWarId': instance.unitWarId,
      'isDoubleAttack': instance.isDoubleAttack,
      'upgradeDamage': instance.upgradeDamage,
      'upgradeArmor': instance.upgradeArmor,
      'upgradeInitiative': instance.upgradeInitiative,
      'upgradeHeal': instance.upgradeHeal,
      'upgradePower': instance.upgradePower,
      'upgradeHp': instance.upgradeHp,
      'overLevel': instance.overLevel,
    };

Unit _$UnitFromJson(Map json) => Unit(
      unitConstParams: UnitConstParams.fromJson(
          Map<String, dynamic>.from(json['unitConstParams'] as Map)),
      isDead: json['isDead'] as bool,
      isMoving: json['isMoving'] as bool,
      isProtected: json['isProtected'] as bool,
      isWaiting: json['isWaiting'] as bool,
      currentHp: json['currentHp'] as int,
      currentAttack: json['currentAttack'] as int? ?? 0,
      unitAttack: UnitAttack.fromJson(
          Map<String, dynamic>.from(json['unitAttack'] as Map)),
      unitAttack2: json['unitAttack2'] == null
          ? null
          : UnitAttack.fromJson(
              Map<String, dynamic>.from(json['unitAttack2'] as Map)),
      uiInfo: json['uiInfo'] as String? ?? '',
      retreat: json['retreat'] as bool? ?? false,
      armor: json['armor'] as int,
      paralyzed: json['paralyzed'] as bool? ?? false,
      attacksMap: (json['attacksMap'] as Map).map(
        (k, e) => MapEntry($enumDecode(_$AttackClassEnumMap, k),
            UnitAttack.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      poisoned: json['poisoned'] as bool? ?? false,
      blistered: json['blistered'] as bool? ?? false,
      frostbited: json['frostbited'] as bool? ?? false,
      damageLower: json['damageLower'] as bool? ?? false,
      revived: json['revived'] as bool? ?? false,
      petrified: json['petrified'] as bool? ?? false,
      initLower: json['initLower'] as bool? ?? false,
      damageBusted: json['damageBusted'] as bool? ?? false,
      transformed: json['transformed'] as bool? ?? false,
      level: json['level'] as int,
      classImmune: (json['classImmune'] as Map).map(
        (k, e) => MapEntry(
            int.parse(k as String), $enumDecode(_$ImunneCategoryEnumMap, e)),
      ),
      sourceImmune: (json['sourceImmune'] as Map).map(
        (k, e) => MapEntry(
            int.parse(k as String), $enumDecode(_$ImunneCategoryEnumMap, e)),
      ),
      hasClassImunne: (json['hasClassImunne'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String), e as bool),
      ),
      hasSourceImunne: (json['hasSourceImunne'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String), e as bool),
      ),
      isBig: json['isBig'] as bool,
    );

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'isMoving': instance.isMoving,
      'isDead': instance.isDead,
      'isProtected': instance.isProtected,
      'isWaiting': instance.isWaiting,
      'isBig': instance.isBig,
      'unitConstParams': instance.unitConstParams.toJson(),
      'currentHp': instance.currentHp,
      'currentAttack': instance.currentAttack,
      'unitAttack': instance.unitAttack.toJson(),
      'unitAttack2': instance.unitAttack2?.toJson(),
      'attacksMap': instance.attacksMap
          .map((k, e) => MapEntry(_$AttackClassEnumMap[k], e.toJson())),
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
      'transformed': instance.transformed,
      'level': instance.level,
      'classImmune': instance.classImmune
          .map((k, e) => MapEntry(k.toString(), _$ImunneCategoryEnumMap[e])),
      'sourceImmune': instance.sourceImmune
          .map((k, e) => MapEntry(k.toString(), _$ImunneCategoryEnumMap[e])),
      'hasClassImunne':
          instance.hasClassImunne.map((k, e) => MapEntry(k.toString(), e)),
      'hasSourceImunne':
          instance.hasSourceImunne.map((k, e) => MapEntry(k.toString(), e)),
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

const _$ImunneCategoryEnumMap = {
  ImunneCategory.no: 'no',
  ImunneCategory.once: 'once',
  ImunneCategory.always: 'always',
};
