import 'package:flutter/material.dart';

class HomeState {
  late ScrollController scrollController;
  // late final StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool isOnline = true;
  bool isFirstLoad = true;

  String selectedCategory;
  setCategory(String value) {
    selectedCategory = value;
  }

  HomeState({this.selectedCategory = '7'})
    : scrollController = ScrollController(),
      isOnline = true,
      isFirstLoad = true;

  void dispose() {
    scrollController.dispose();
  }

  HomeState copyWith({String? selectedCategory}) {
    return HomeState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
