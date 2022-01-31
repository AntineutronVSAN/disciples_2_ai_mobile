

import 'package:auto_size_text/auto_size_text.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/utils/svg_picture.dart';
import 'package:flutter/material.dart';

import '../../../styles.dart';

const double smallUnitCellWidth = 100.0;
const double smallUnitActiveCellWidth = 120.0;
const double smallUnitCellHeight = 100.0;
const double smallUnitActiveCellHeight = 120.0;

const double bigUnitCellWidth = 100.0;
const double bigUnitActiveCellWidth = 120.0;
const double bigUnitCellHeight = 200.0;
const double bigUnitActiveCellHeight = 240.0;


class UnitCellWidget extends StatelessWidget {

  final List<Unit> units;
  final int cellNumber;
  final Function()? onTap;
  final Function()? onLongPress;

  const UnitCellWidget({Key? key, required this.units, required this.cellNumber, this.onTap, this.onLongPress}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final double activeCellWidth = units[cellNumber].isBig ? bigUnitActiveCellWidth : smallUnitActiveCellWidth;
    final double activeCellHeight = units[cellNumber].isBig ? bigUnitActiveCellHeight : smallUnitActiveCellHeight;
    final double cellWidth = units[cellNumber].isBig ? bigUnitCellWidth : smallUnitCellWidth;
    final double cellHeight = units[cellNumber].isBig ? bigUnitCellHeight : smallUnitCellHeight;


    final unit = units[cellNumber];
    final maxHp = unit.unitConstParams.maxHp;
    final curHp = unit.currentHp;

    final paralyzed = unit.paralyzed;
    final petrified = unit.petrified;
    final poisoned = unit.poisoned;
    final blistered = unit.blistered;
    final frostbited = unit.frostbited;

    final hasDebuff = unit.damageLower || unit.initLower;
    final busted = unit.damageBusted;

    var scaleFactor = (curHp / maxHp - 1.0) < 0
        ? -(curHp / maxHp - 1.0)
        : (curHp / maxHp - 1.0);

    if (maxHp == 0.0) {
      scaleFactor = 0.0;
    }

    Color damageColor = Colors.red;
    Color unitHpColor = Colors.green;

    if (paralyzed) {
      damageColor = Color.alphaBlend(damageColor.withOpacity(0.5), Colors.grey);
      unitHpColor = Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.grey);
    }
    if (petrified) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.brown);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.brown);
    }
    if (poisoned) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.green[900]!);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.green[900]!);
    }
    if (blistered) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.yellow[900]!);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.yellow[900]!);
    }
    if (frostbited) {
      damageColor =
          Color.alphaBlend(damageColor.withOpacity(0.5), Colors.blue[900]!);
      unitHpColor =
          Color.alphaBlend(unitHpColor.withOpacity(0.5), Colors.blue[900]!);
    }

    const double cellPadding = 3.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: unit.isDead ? 0.1 : 1.0,
            duration: const Duration(milliseconds: 600),
            child: Padding(
              padding: const EdgeInsets.all(cellPadding),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: unit.isEmpty() ? Colors.white : unitHpColor,
                  border: units[cellNumber].isMoving
                      ? Border.all(color: Colors.teal, width: 5)
                      : null,
                ),
                width: unit.isMoving ? activeCellWidth : cellWidth,
                height: unit.isMoving ? activeCellHeight : cellHeight,
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.7,
                child: AnimatedContainer(
                  margin: const EdgeInsets.all(cellPadding),
                  width: unit.isMoving ? activeCellWidth : cellWidth,
                  height: scaleFactor * (unit.isMoving ? activeCellHeight : cellHeight),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: damageColor,
                  ),
                  duration: const Duration(milliseconds: 200),
                ),
              ),
            ),
          ),
          Positioned.fill(
              top: 8.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    unit.unitConstParams.unitName,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    maxLines: 2,
                  ),
                ),
              )),
          Positioned.fill(
            bottom: 15.0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  unit.isProtected
                      ? const SvgIcon(
                    asset: "ic_unit_protect.svg",
                    color: Colors.black,
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.isWaiting
                      ? const SvgIcon(
                    asset: "ic_unit_wait.svg",
                    color: Colors.black,
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.retreat
                      ? const SvgIcon(
                    asset: "ic_unit_retreat.svg",
                    color: Colors.black,
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.paralyzed
                      ? SvgIcon(
                    asset: "ic_unit_paralyze.svg",
                    color: Colors.grey[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.poisoned
                      ? SvgIcon(
                    asset: "ic_unit_poison.svg",
                    color: Colors.green[800],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.blistered
                      ? SvgIcon(
                    asset: "ic_unit_blistered.svg",
                    color: Colors.orange[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.frostbited
                      ? SvgIcon(
                    asset: "ic_unit_frost.svg",
                    color: Colors.blue[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  hasDebuff
                      ? SvgIcon(
                    asset: "ic_unit_down.svg",
                    color: Colors.red[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  unit.petrified
                      ? SvgIcon(
                    asset: "ic_unit_petrify.svg",
                    color: Colors.brown[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                  busted
                      ? SvgIcon(
                    asset: "ic_unit_butsed.svg",
                    color: Colors.green[900],
                    size: 17.0,
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'HP ' +
                        unit.currentHp.toString() +
                        ' / ' +
                        unit.unitConstParams.maxHp.toString(),
                    style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  if (unit.unitAttack.damage > 0)
                    AutoSizeText.rich(
                        TextSpan(children: [
                          if (unit.unitAttack.damage > 0)
                            TextSpan(
                                text: 'DMG ${unit.unitAttack.attackConstParams.firstDamage}',
                                style: GameStyles.getUnitShortDescriptionStyle()),
                          if (unit.unitAttack.attackConstParams.firstDamage -
                              unit.unitAttack.damage !=
                              0)
                            TextSpan(
                                text:
                                ' ${unit.unitAttack.attackConstParams.firstDamage - unit.unitAttack.damage > 0 ? '- ' : '+ '} '
                                    '${((unit.unitAttack.attackConstParams.firstDamage - unit.unitAttack.damage).abs())}',
                                style: GameStyles
                                    .getUnitShortDescriptionDebuffStyle()),
                          if ((unit.unitAttack2?.damage ?? 0) > 0)
                            TextSpan(
                                text: ' / ${(unit.unitAttack2?.attackConstParams.firstDamage ?? '')}',
                                style: GameStyles.getUnitShortDescriptionStyle()),
                        ])),
                  if (unit.unitAttack.attackConstParams.firstInitiative > 0)
                    AutoSizeText.rich(
                        TextSpan(children: [
                          if (unit.unitAttack.attackConstParams.firstInitiative > 0)
                            TextSpan(
                                text: 'INI ${unit.unitAttack.attackConstParams.firstInitiative}',
                                style: GameStyles.getUnitShortDescriptionStyle()),
                          if (unit.unitAttack.attackConstParams.firstInitiative -
                              unit.unitAttack.initiative !=
                              0)
                            TextSpan(
                                text:
                                ' - ${unit.unitAttack.attackConstParams.firstInitiative - unit.unitAttack.initiative}',
                                style: GameStyles
                                    .getUnitShortDescriptionDebuffStyle()),
                        ])),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Center(
                  child: AutoSizeText(
                    unit.uiInfo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



}