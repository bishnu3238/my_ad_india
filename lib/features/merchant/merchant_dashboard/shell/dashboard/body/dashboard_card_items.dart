import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/pack.dart';
import '../../../core/merchant_dashboard_route.dart';

class RecentFile {
  final String? icon, title, date, size;

  RecentFile({this.icon, this.title, this.date, this.size});
}

List demoRecentFiles = [
  RecentFile(
    icon: "assets/icons/xd_file.svg",
    title: "Uttam Das",
    date: "01-03-2025",
    size: "Plumber",
  ),
];

class DashboardGridInfo {
  final String? svgSrc, title, subTitle;
  final num numOfServices, percentage;
  final Function(BuildContext context) onTap;

  DashboardGridInfo({
    this.svgSrc,
    this.title,
    this.subTitle,
    this.numOfServices = 0,
    this.percentage = 0,
    required this.onTap,
  });
}
