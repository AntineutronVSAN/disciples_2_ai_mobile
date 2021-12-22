class Tglobal
{
  String txt_id;
  String text;
  bool? verified;
  String context;

  Tglobal ({
    required this.txt_id,
    required this.text,
    required this.verified,
    required this.context,
  });
}

class Gattacks
{
  String att_id;
  String name_txt;
  String desc_txt;
  int initiative;
  int source;
  int atck_class;
  int power;
  int reach;
  int? qty_heal;
  int? qty_dam;
  int? level;
  String alt_attack;
  bool? infinite;
  int? qty_wards;
  String ward1;
  String ward2;
  String ward3;
  String ward4;
  bool? crit_hit;

  Gattacks ({
    required this.att_id,
    required this.name_txt,
    required this.desc_txt,
    required this.initiative,
    required this.source,
    required this.atck_class,
    required this.power,
    required this.reach,
    required this.qty_heal,
    required this.qty_dam,
    required this.level,
    required this.alt_attack,
    required this.infinite,
    required this.qty_wards,
    required this.ward1,
    required this.ward2,
    required this.ward3,
    required this.ward4,
    required this.crit_hit,
  });
}

class Gunits
{
  String unit_id;
  int unit_cat;
  int level;
  String prev_id;
  String race_id;
  int subrace;
  int branch;
  bool? size_small;
  bool? sex_m;
  String enroll_c;
  String enroll_b;
  String name_txt;
  String desc_txt;
  String abil_txt;
  String attack_id;
  String attack2_id;
  bool? atck_twice;
  int hit_point;
  String base_unit;
  int? armor;
  int regen;
  String revive_c;
  String heal_c;
  String training_c;
  int xp_killed;
  String upgrade_b;
  int xp_next;
  int? move;
  int? scout;
  int? life_time;
  int? leadership;
  int? negotiate;
  int? leader_cat;
  String dyn_upg1;
  int dyn_upg_lv;
  String dyn_upg2;
  bool? water_only;
  int death_anim;

  Gunits ({
    required this.unit_id,
    required this.unit_cat,
    required this.level,
    required this.prev_id,
    required this.race_id,
    required this.subrace,
    required this.branch,
    required this.size_small,
    required this.sex_m,
    required this.enroll_c,
    required this.enroll_b,
    required this.name_txt,
    required this.desc_txt,
    required this.abil_txt,
    required this.attack_id,
    required this.attack2_id,
    required this.atck_twice,
    required this.hit_point,
    required this.base_unit,
    required this.armor,
    required this.regen,
    required this.revive_c,
    required this.heal_c,
    required this.training_c,
    required this.xp_killed,
    required this.upgrade_b,
    required this.xp_next,
    required this.move,
    required this.scout,
    required this.life_time,
    required this.leadership,
    required this.negotiate,
    required this.leader_cat,
    required this.dyn_upg1,
    required this.dyn_upg_lv,
    required this.dyn_upg2,
    required this.water_only,
    required this.death_anim,
  });
}

