import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class TextInput extends StatelessWidget {
  final String label;
  final Widget formField;
  // final String hintText;
  const TextInput({
    Key? key,
    // required this.hintText,
    required this.formField,
    required this.label,
  }) : super(key: key);

  /// for container decoration
  final double blur = 2.0;
  final Offset distance = const Offset(1.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade500),

            // boxShadow: [
            //   BoxShadow(
            //     blurRadius: blur,
            //     offset: distance,
            //     color: Theme.of(context).brightness == Brightness.dark
            //         ? Colors.black
            //         : Colors.grey.shade500,
            //   ),
            //   BoxShadow(
            //     blurRadius: blur,
            //     offset: -distance,
            //     color: Theme.of(context).brightness == Brightness.dark
            //         ? Colors.grey.shade700
            //         : Colors.white,
            //   ),
            // ],

            /// BoxShadow for neon glow
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.0),
            // border: Border.all(color: Colors.grey),
          ),
          child: formField,
        ),
      ],
    );
  }
}
