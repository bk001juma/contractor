import 'package:flutter/material.dart';

class ProfileMenuItem {
  final String title;
  final String route;
  final IconData icon;
  final bool isLogout;

  ProfileMenuItem({
    required this.title,
    required this.route,
    required this.icon,
    this.isLogout = false,
  });
}
