

/*case 1:
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
  }*/

const List<List<double>> attacksCombinationCoeff = [
  //           DMG,  DRN,  PAR,  HL,  FEAR,  B_DMG,  PET,  L_DMG,  L_INI,  POIS,  FROS,  REV,  DR_OVER,  CURE,  SUMM,  DR_LVL,  G_AT,  DOPP,  TR_S,  TR_O,  BLI,  WARD,  SHAT
  /*DMG*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*DRN*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*PAR*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*HL*/    [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
/*FEAR*/    [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
/*B_DMG*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*PET*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
/*L_DMG*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
/*L_INI*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
/*POIS*/    [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
/*FROS*/    [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*REV*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
/*DR_OVER*/ [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*CURE*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*SUMM*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*DR_LVL*/[  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*G_AT*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*DOPP*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*TR_S*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*TR_O*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*BLI*/   [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*WARD*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],
  /*SHAT*/  [  1.0,  1.0,  1.0,  1.0, 1.0,   1.0,    1.0,  1.0,    1.0,    1.0,   1.0,   1.0,  1.0,      1.0,   1.0,   1.0,     1.0,   1.0,   1.0,   1.0,   1.0,  1.0,   1.0, ],


];