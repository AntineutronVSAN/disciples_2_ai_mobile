

import 'package:flutter/material.dart';

class UnitAvatarSection extends StatelessWidget {

  final String description;

  const UnitAvatarSection({Key? key, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            color: Colors.grey,
            child: const Center(child: Text('TODO Аватака')),
          ),
          const SizedBox(height: 10,),
          Text(description),
        ],
      ),
    );
  }



}