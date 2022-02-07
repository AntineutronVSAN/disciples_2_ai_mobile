import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../styles.dart';

class UnitsParamsSection extends StatelessWidget {
  final String content;
  final String? debuffContent;

  const UnitsParamsSection(
      {Key? key, required this.content, this.debuffContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0, left: 8.0, right: 8.0),
      child: Card(
        elevation: 1,
        child: Row(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  maxLines: 5,
                  text: TextSpan(children: [
                    TextSpan(
                        text: content, style: GameStyles.getUnitDescriptionStyle()),
                    TextSpan(
                        text: debuffContent,
                        style: GameStyles.getUnitDescriptionDebuffStyle())
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UnitAttackSection extends StatelessWidget {

  final UnitAttack? attack;

  const UnitAttackSection({Key? key, required this.attack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (attack == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 1.0, left: 8.0, right: 8.0),
      child: Card(
        color: UIColors.attackInfoSectionColor,
        elevation: 1,
        child: Column(children: [
          UnitsParamsSection(content: 'Класс: ${gameAttackNameFromClass(attack?.attackConstParams.attackClass)}',),
          UnitsParamsSection(content: 'Источник: ${attackSourceIntToSting(attack?.attackConstParams.source)}',),
          UnitsParamsSection(content: 'Число целей: ${attack?.attackConstParams.targetsCount}',),
          UnitsParamsSection(content: 'Точность: ${attack?.power}',),
          UnitsParamsSection(content: 'Дамаг: ${attack?.attackConstParams.firstDamage}',),
          UnitsParamsSection(content: 'Хил: ${attack?.attackConstParams.heal}',),
          UnitsParamsSection(content: 'Длительная: ${attack?.attackConstParams.infinite}',),
          UnitsParamsSection(content: 'Уровень: ${attack?.attackConstParams.level}',),
        ],),
      ),
    );

  }

}