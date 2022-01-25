class GDynUpgr
{
  String upgrade_id;
  String enroll_c;
  int hit_point;
  int? armor;
  int? regen;
  String revive_c;
  String heal_c;
  String training_c;
  int xp_killed;
  int? xp_next;
  int? move;
  int? negotiate;
  int? damage;
  int? heal;
  int? initiative;
  int? power;

  GDynUpgr ({
    required this.upgrade_id,
    required this.enroll_c,
    required this.hit_point,
    required this.armor,
    required this.regen,
    required this.revive_c,
    required this.heal_c,
    required this.training_c,
    required this.xp_killed,
    required this.xp_next,
    required this.move,
    required this.negotiate,
    required this.damage,
    required this.heal,
    required this.initiative,
    required this.power,
  });
}

