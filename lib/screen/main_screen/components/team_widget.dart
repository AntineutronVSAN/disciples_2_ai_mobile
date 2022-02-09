

import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/screen/main_screen/components/unit_cell_widget.dart';
import 'package:flutter/material.dart';

import '../../../bloc_base/downloadable_stateless.dart';

const teamWidgetSkeletonOptions = SkeletonOptions(
    estimatedWidth: 300.0,
    estimatedHeight: 200.0,
    skeletonColor: Colors.white10,
    padding: EdgeInsets.all(5.0),
    info: 'Загружаем файлы, пожалуйста, подождите ...',
    infoStyle: TextStyle(color: Colors.white, fontSize: 15.0),
);

class MainScreenTeamWidget extends DowloadableStateless {

  final bool top;
  final Function(int) onTap;
  final Function(int) onLongPress;
  final List<Unit> units;

  const MainScreenTeamWidget({
    Key? key,
    required this.top,
    required this.onTap,
    required this.onLongPress,
    required bool loading,
  required this.units,
    required
  }) : super(key: key, options: teamWidgetSkeletonOptions, loading: loading);


  Widget _getUnitsSection({
    required List<Unit> units,
    required int u1,
    required int u2,
  }) {

    assert(u2 - u1 == 3);

    final unit1 = units[u1];
    final unit2 = units[u2];

    final List<Widget> children = [];

    final curIsBig = top ? unit2.isBig : unit1.isBig;

    if (curIsBig) {
      children.add(UnitCellWidget(
        units: units,
        cellNumber: top ? u2 : u1,
        onTap: () => onTap(top ? u2 : u1),
        onLongPress: () => onLongPress(top ? u2 : u1),
      ));
    } else {
      children.add(UnitCellWidget(
        units: units,
        cellNumber: u1,
        onTap: () => onTap(u1),
        onLongPress: () => onLongPress(u1),
      ));
      children.add(UnitCellWidget(
        units: units,
        cellNumber: u2,
        onTap: () => onTap(u2),
        onLongPress: () => onLongPress(u2),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

  }

  @override
  Widget buildBody(BuildContext context) {
    final offset = top ? 0 : 6;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _getUnitsSection(units: units, u1: offset + 0, u2: offset + 3),
        _getUnitsSection(units: units, u1: offset + 1, u2: offset + 4),
        _getUnitsSection(units: units, u1: offset + 2, u2: offset + 5),
      ],
    );
  }




}