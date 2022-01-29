

import 'package:d2_ai_v2/styles.dart';
import 'package:d2_ai_v2/utils/svg_picture.dart';
import 'package:flutter/material.dart';

class AIMovingWidget extends StatelessWidget {

  final int treeDepth;
  final int nodesPerSecond;
  final double height;

  const AIMovingWidget({Key? key,
    required this.treeDepth,
    required this.nodesPerSecond,
    required this.height,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          SvgIcon(asset: 'ic_robot.svg', color: null, size: height - 20),
          const SizedBox(width: 30,),
          SizedBox(
            height: height - 20,
            width: height - 20,
            child: const CircularProgressIndicator(),
          ),
          const SizedBox(width: 30,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Depth: $treeDepth', style: GameStyles.getUnitDescriptionDebuffStyle(),),
              //const SizedBox(height: 10,),
              Text('${(nodesPerSecond / 1000.0).toStringAsFixed(1)}k noses/s', style: GameStyles.getUnitDescriptionDebuffStyle(),),
            ],
          ),
        ],
      ),
    );
  }



}