import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String fullName;
  final double size;
  final double fontSize;

  const UserAvatar({
    Key? key,
    required this.fullName,
    this.size = 48.0,
    this.fontSize = 16.0,
  }) : super(key: key);

  String get initials {
    if (fullName.trim().isEmpty) return "?";
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  LinearGradient get gradient {
    final nameHash = fullName.hashCode;
    final index = nameHash.abs() % _gradients.length;
    return _gradients[index];
  }

  static const List<LinearGradient> _gradients = [
    LinearGradient(
      colors: [Color(0xFFE57373), Color(0xFFFF8A80)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFFB74D), Color(0xFFFFD180)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF81C784), Color(0xFFB9F6CA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4FC3F7), Color(0xFF80D8FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFBA68C8), Color(0xFFEA80FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF90A4AE), Color(0xFFCFD8DC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4DB6AC), Color(0xFFA7FFEB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF7986CB), Color(0xFF8C9EFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
