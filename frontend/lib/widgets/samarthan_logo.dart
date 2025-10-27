import 'package:flutter/material.dart';

class SamarthanLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  
  const SamarthanLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF4CAF50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: color ?? Colors.white,
            size: size * 0.6,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Samarthan',
                style: TextStyle(
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87,
                ),
              ),
              Text(
                'समर्थन',
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w500,
                  color: color?.withOpacity(0.7) ?? Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
