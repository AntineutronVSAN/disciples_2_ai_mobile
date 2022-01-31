import 'package:d2_ai_v2/bloc_base/stateless_base.dart';
import 'package:d2_ai_v2/models/attack.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/screen/unit/components/unit_avatar_section.dart';
import 'package:d2_ai_v2/screen/unit/components/unit_params_section.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_bloc.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_event.dart';
import 'package:d2_ai_v2/screen/unit/unit_inforamtion/unit_information_state.dart';
import 'package:d2_ai_v2/styles.dart';
import 'package:d2_ai_v2/theme/app_bar.dart';
import 'package:d2_ai_v2/theme/clicable_icon.dart';
import 'package:d2_ai_v2/theme/colors.dart';
import 'package:d2_ai_v2/theme/text.dart';
import 'package:flutter/material.dart';

class UnitInformationScreen extends StatelessWidgetWithBloc<UnitInformationBloc,
    UnitInformationEvent, UnitState> {
  const UnitInformationScreen({Key? key, required UnitInformationBloc bloc})
      : super(bloc: bloc, key: key);

  @override
  Widget onStateLoaded(UnitState? newState) {
    assert(newState != null);

    return UnitInformationScreenBody(unit: newState!.unit);
  }

  @override
  void onListen(UnitState? newState) {
    // TODO: implement onListen
  }
}

class UnitInformationScreenBody extends StatelessWidget {
  final Unit unit;

  const UnitInformationScreenBody({Key? key, required this.unit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    final deltaIni = unit.unitAttack.initiative - unit.unitAttack.attackConstParams.firstInitiative;
    final String sign = deltaIni < 0 ? '-' : '+';

    String immuneString = '';
    String protectString = '';
    for(var i in unit.classImmune.entries) {
      if (i.value == ImunneCategory.once) {
        protectString += '${attackNameFromGameAttackInt(i.key)}, ';
        continue;
      }
      if (i.value == ImunneCategory.always) {
        immuneString += '${attackNameFromGameAttackInt(i.key)}, ';
        continue;
      }
    }
    for(var i in unit.sourceImmune.entries) {
      if (i.value == ImunneCategory.once) {
        protectString += '${attackSourceIntToSting(i.key)}, ';
        continue;
      }
      if (i.value == ImunneCategory.always) {
        immuneString += '${attackSourceIntToSting(i.key)}, ';
        continue;
      }
    }

    return Scaffold(
      appBar: getThemeAppBar(
          title: ThemeAppText(
              text: unit.unitConstParams.unitName, style: GameStyles.getMainAppBarTextStyle()),
          leading: ClickableIcon(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: UIColors.primary,
            ),
            onPress: () {
              Navigator.of(context).maybePop();
            },
          )),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            const UnitAvatarSection(description: 'TODO Описание',),
            Center(child: Text('Характеристики юнита', style: GameStyles.getUnitDescriptionStyle(),),),
            UnitsParamsSection(
              content: 'Здоровье: макс ${unit.unitConstParams.maxHp}, текущее ${unit.currentHp}',
            ),
            UnitsParamsSection(
              content: 'Уровень: ${unit.level}',
            ),
            UnitsParamsSection(
              content: 'Инициатива: ${unit.unitAttack.attackConstParams.firstInitiative}',
              debuffContent: deltaIni == 0 ? null : ' $sign $deltaIni',
            ),
            UnitsParamsSection(
              content: 'Броня: текущая ${unit.armor}',
            ),
            UnitsParamsSection(
              content: 'Двойная атака: ${unit.unitConstParams.isDoubleAttack}',
            ),
            UnitsParamsSection(
              content: 'Иммунитет: $immuneString',
            ),
            UnitsParamsSection(
              content: 'Защита: $protectString',
            ),

            Center(child: Text('Основная атака', style: GameStyles.getUnitDescriptionStyle(),),),
            UnitAttackSection(
              attack: unit.unitAttack,
            ),
            Center(child: Text('Доп атака', style: GameStyles.getUnitDescriptionStyle(),),),
            UnitAttackSection(
              attack: unit.unitAttack2,
            ),

            const SizedBox(height: 300,)

          ],
        ),
      ),
    );
  }
}
