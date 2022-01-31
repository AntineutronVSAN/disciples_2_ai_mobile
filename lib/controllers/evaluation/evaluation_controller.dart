

import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/cell_utils.dart';

/*

Что учитывается:

  * Ценность юнитов
  * Ценность комбинации юнитов
  * Расположение юнитов на поле боя

 */

/// Класс предназначен для оценки игровой позиции
class EvaluationController {

  /// Коэффициент ценности атаки
  static const unitAttacksCoeff = 1.0;
  /// Коэффициент ценности параметров юнита
  static const unitParamsCoeff = 1.0;

  /// Коэффициент ценности юнита и его атаки в контексте своей команды
  static const unitTeamEval = 1.0;
  /// Коэффициент ценности юнита и его атаки в контексте чужой команды
  static const unitEnemyTeamEval = 1.0;

  static const double targetsCountOneCoeff = 1.0;
  static const double targetsCountAnyCoeff = 2.0;
  static const double targetsCountAllCoeff = 3.0;

  /* DAMAGE */
  static const damageInfiniteDotCoeff = 1.2;
  /* END */

  double getEvaluation({
    required List<Unit> units,
  }) {
    var sfr = 0.0;
    double aiTeamEval = 0.0;
    double enemyTeamEval = 0.0;
    List<GameEvaluation> evaluations = [];
    var index=0;
    for (var u in units) {
      final newEval = GameEvaluation();
      if (checkIsTopTeam(index)) {
        // Свои
        //final currentUnitEval = evaluationController.getUnitEvaluation(u);
        //aiTeamEval += currentUnitEval.getEval();
        getUnitEvaluation(u, newEval);
        aiTeamEval += newEval.getEval();
      } else {
        // Враги
        //final currentUnitEval = evaluationController.getUnitEvaluation(u);
        //enemyTeamEval += currentUnitEval.getEval();
        getUnitEvaluation(u, newEval);
        enemyTeamEval += newEval.getEval();
      }
      evaluations.add(newEval);
      index++;
    }
    sfr += aiTeamEval;
    sfr -= enemyTeamEval;
    return sfr;
  }

  /// Получить ценность юнита с учётом атак
  void getUnitEvaluation(Unit u, GameEvaluation eval) {
    //print('----------------- Ценность юнита ${u.unitName} --------------------');
    double value = 0.0;
    // Мертвый/пустой юнит не имеет ценности
    if (u.isDead || u.isEmpty()) {
      eval.onlyUnitEval = 0.0;
      eval.attacksEval = 0.0;
      return;
    }
    // Юнит, который не может атаковать ценности не имеет
    if (u.retreat) {
      eval.onlyUnitEval = 0.0;
      eval.attacksEval = 0.0;
      return;
    }

    var canMove = true;
    if (u.paralyzed || u.petrified) {
      canMove = false;
    }

    var onlyUnitEval = _onlyUnitEval(u) * unitParamsCoeff;
    //print('Оценка юнита - $onlyUnitEval');
    var unitAtcksEval = getAttackCombinationEvaluation(u.unitAttack, u.unitAttack2) * unitAttacksCoeff;

    if (u.unitConstParams.isDoubleAttack) {
      unitAtcksEval *= 1.5;
    }

    //value += onlyUnitEval * (u.currentHp / u.maxHp);
    //value += unitAtcksEval;

    //print('Оценка атаки с коэффициентами $unitAtcksEval');
    //print('Оценка юнита ${u.unitName} результат - $value');

    eval.attacksEval = canMove ? unitAtcksEval : 0.0;
    eval.onlyUnitEval = onlyUnitEval * (u.currentHp / u.unitConstParams.maxHp);

    return;

    /*return UnitEvaluation(
        attacksEval: canMove ? unitAtcksEval : 0.0,
        onlyUnitEval: onlyUnitEval * (u.currentHp / u.maxHp)
    );*/
  }

  /* TEAM EVAL START */
  /// Коэффициент для оценки юнита в контексте своей команды
  double _unitEvalCoeffTeam(Unit u, List<Unit> units, GameEvaluation eval) {
    var result = 1.0;
    return result;
  }

  /// Коэффициент для оценки юнита в контексте чужой команды
  double _unitEvalEnemyTeam(Unit u, List<Unit> units, GameEvaluation eval) {
    var result = 1.0;
    return result;
  }
  /* TEAM EVAL END */

  double _onlyUnitEval(Unit u) {
    double value = 0.0;

    value += u.unitConstParams.maxHp / 1000.0;
    value += u.armor / 90.0 / 2.0;

    return value;
  }

  /// Ценность атаки
  double getAttackEvaluation(UnitAttack a) {
    double value = 0.0;

    switch(a.attackConstParams.attackClass) {
      case AttackClass.L_DAMAGE:
        value += _handleDamage(a) * 1.0 / 300.0;
        break;
      case AttackClass.L_DRAIN:
        value += _handleDrain(a) * 0.01;
        break;
      case AttackClass.L_PARALYZE:
        value += _handleParalyze(a) * 2.0;
        break;
      case AttackClass.L_HEAL:
        value += _handleHeal(a) * 1.0 / 300.0;
        break;
      case AttackClass.L_FEAR:
        value += _handleFear(a) * 2.0;
        break;
      case AttackClass.L_BOOST_DAMAGE:
        value += _handleBoostDamage(a) * 0.1;
        break;
      case AttackClass.L_PETRIFY:
        value += _handlePetrify(a) * 2.0;
        break;
      case AttackClass.L_LOWER_DAMAGE:
        value += _handleLowerDamage(a) * 0.1;
        break;
      case AttackClass.L_LOWER_INITIATIVE:
        value += _handleLowerInitiative(a) * 0.1;
        break;
      case AttackClass.L_POISON:
        value += _handlePoison(a) * 1.0;
        break;
      case AttackClass.L_FROSTBITE:
        value += _handleFrostbite(a) * 1.0;
        break;
      case AttackClass.L_REVIVE:
        value += _handleRevive(a) * 1.0;
        break;
      case AttackClass.L_DRAIN_OVERFLOW:
        value += _handleDrainOverflow(a) * 0.01;
        break;
      case AttackClass.L_CURE:
        value += _handleCure(a) * 0.25;
        break;
      case AttackClass.L_SUMMON:
        value += _handleSummon(a) * 1.0;
        break;
      case AttackClass.L_DRAIN_LEVEL:
        value += _handleDrainLevel(a) * 1.0;
        break;
      case AttackClass.L_GIVE_ATTACK:
        value += _handleGiveAttack(a) * 1.0;
        break;
      case AttackClass.L_DOPPELGANGER:
        value += _handleDoppel(a) * 1.0;
        break;
      case AttackClass.L_TRANSFORM_SELF:
        value += _handleTransformSelf(a) * 1.0;
        break;
      case AttackClass.L_TRANSFORM_OTHER:
        value += _handleTransformOther(a) * 1.0;
        break;
      case AttackClass.L_BLISTER:
        value += _handleBlister(a) * 1.0;
        break;
      case AttackClass.L_BESTOW_WARDS:
        value += _handleBestowWards(a) * 1.0;
        break;
      case AttackClass.L_SHATTER:
        value += _handleShatter(a) * 1.0 / 90.0 / 1.5;
        break;
    }

    value += a.initiative / 90.0;

    return value;
  }



  /// Ценность комбинации атак
  /// Для рассчёта ценности используется матрица коэффициентов

  double getAttackCombinationEvaluation(UnitAttack a1, UnitAttack? a2) {
    final a1Eval = getAttackEvaluation(a1);
    //print('Оенка атаки 1 - $a1Eval');

    if (a2 == null) {
      return getAttackEvaluation(a1);
    }
    double value = 0.0;


    final a2Eval = getAttackEvaluation(a2);
    //print('Оенка атаки 2 - $a2Eval');

    value += a1Eval;
    value += a2Eval;

    return value;
  }

  /// Ценность команды юнитов [units]
  /// [indexes] положения юнитов
  /// [isTopTeam] оценить верхнюю команду
  double getUnitsTeamEvaluation(List<Unit> units, List<int> indexes, bool isTopTeam) {
    assert(units.length == 12);
    double value = 0.0;

    return value;
  }

  double _targetsCountEvaluation(TargetsCount tc) {
    switch (tc) {
      case TargetsCount.one:
        return targetsCountOneCoeff;
      case TargetsCount.all:
        return targetsCountAllCoeff;
      case TargetsCount.any:
        return targetsCountAnyCoeff;
    }
  }

  double _handleDamage(UnitAttack a) {
    var result = 0.0;

    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    final expectedValue = a.damage * (a.power / 100.0);
    result += expectedValue;

    for(var i in coeffs) {
      result *= i;
    }

    return result;
  }

  double _handleDrain(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    final expectedValue = a.damage * (a.power / 100.0);
    result += expectedValue;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleParalyze(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
      a.attackConstParams.infinite ? 1.5 : 1.0,
    ];

    final expectedValue = a.power / 100.0;
    result += expectedValue;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleHeal(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    final val = a.attackConstParams.heal;
    result += val;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleFear(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    final expectedValue = a.power / 100.0;
    result += expectedValue;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleBoostDamage(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    final val = a.attackConstParams.level * 1.0;
    result += val;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handlePetrify(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
      a.attackConstParams.infinite ? 1.5 : 1.0,
    ];

    final expectedValue = a.power / 100.0;
    result += expectedValue;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleLowerDamage(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    result += a.attackConstParams.level == 1 ? 1.0 : 0.77;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleLowerInitiative(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    result += a.attackConstParams.level == 1 ? 1.0 : 0.77;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handlePoison(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
      a.attackConstParams.infinite ? 1.2 : 1.0,
    ];

    result += a.power / 100.0 / 300.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleFrostbite(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
      a.attackConstParams.infinite ? 1.2 : 1.0,
    ];

    result += a.power / 100.0 / 300.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleRevive(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    result += 1.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleDrainOverflow(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    final expectedValue = a.damage * (a.power / 100.0);
    result += expectedValue;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleCure(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    result += 1.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleSummon(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [

    ];
    // Тут рассчёт
    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleDrainLevel(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      //_targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleGiveAttack(UnitAttack a) {
    var result = 0.0;

    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    result += 1.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleDoppel(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [

    ];
    // Тут рассчёт
    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleTransformSelf(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [

    ];
    // Тут рассчёт
    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleTransformOther(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    result += a.power / 100.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleBlister(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
      a.attackConstParams.infinite ? 1.2 : 1.0,
    ];

    result += a.power / 100.0 / 300.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleBestowWards(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [

    ];
    // Тут рассчёт
    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

  double _handleShatter(UnitAttack a) {
    var result = 0.0;
    final List<double> coeffs = [
      _targetsCountEvaluation(a.attackConstParams.targetsCount),
    ];

    result += a.damage * a.power / 100.0;

    for(var i in coeffs) {
      result *= i;
    }
    return result;
  }

}

class GameEvaluation {
  double onlyUnitEval = 0.0;
  double attacksEval = 0.0;

  double getEval() {
    return onlyUnitEval + attacksEval;
  }

}




