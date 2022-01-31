

import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/screen/main_screen/components/unit_cell_widget.dart';
import 'package:flutter/material.dart';

class MainScreenTeamWidget extends StatelessWidget {

  final bool top;
  final Function(int) onTap;
  final Function(int) onLongPress;
  final List<Unit> units;

  const MainScreenTeamWidget({
    Key? key,
    required this.top,
    required this.onTap,
    required this.onLongPress,
  required this.units,
    required
  }) : super(key: key);


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
  Widget build(BuildContext context) {
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

    /*return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UnitCellWidget(
              units: units,
              cellNumber: 0 + offset,
              onTap: () => onTap(0 + offset),
              onLongPress: () => onLongPress(0 + offset),
            ),
            UnitCellWidget(
              units: units,
              cellNumber: 1 + offset,
              onTap: () => onTap(1 + offset),
              onLongPress: () => onLongPress(1 + offset),
            ),
            UnitCellWidget(
              units: units,
              cellNumber: 2 + offset,
              onTap: () => onTap(2 + offset),
              onLongPress: () => onLongPress(2 + offset),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UnitCellWidget(
              units: units,
              cellNumber: 3 + offset,
              onTap: () => onTap(3 + offset),
              onLongPress: () => onLongPress(3 + offset),
            ),
            UnitCellWidget(
              units: units,
              cellNumber: 4 + offset,
              onTap: () => onTap(4 + offset),
              onLongPress: () => onLongPress(4 + offset),
            ),
            UnitCellWidget(
              units: units,
              cellNumber: 5 + offset,
              onTap: () => onTap(5 + offset),
              onLongPress: () => onLongPress(5 + offset),
            ),
            //_getCell(context, bloc.state, 3 + offset, bloc),
            //_getCell(context, bloc.state, 4 + offset, bloc),
            //_getCell(context, bloc.state, 5 + offset, bloc),
          ],
        ),
      ],
    );*/
  }




}