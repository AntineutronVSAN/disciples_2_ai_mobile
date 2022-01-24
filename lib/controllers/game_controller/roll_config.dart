class RollConfig {

  bool topTeamMaxPower;
  bool bottomTeamMaxPower;

  bool topTeamMaxIni;
  bool bottomTeamMaxIni;

  bool topTeamMaxDamage;
  bool bottomTeamMaxDamage;

  RollConfig({
    required this.topTeamMaxPower,
    required this.bottomTeamMaxPower,
    required this.topTeamMaxIni,
    required this.bottomTeamMaxIni,
    required this.bottomTeamMaxDamage,
    required this.topTeamMaxDamage,
  });

  RollConfig deepCopy() {
    return RollConfig(
        topTeamMaxPower: topTeamMaxPower,
        bottomTeamMaxPower: bottomTeamMaxPower,
        topTeamMaxIni: topTeamMaxIni,
        bottomTeamMaxIni: bottomTeamMaxIni,
      topTeamMaxDamage: topTeamMaxDamage,
      bottomTeamMaxDamage: bottomTeamMaxDamage,
    );
  }

}