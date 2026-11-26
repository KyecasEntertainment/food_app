import 'package:flutter/foundation.dart';

abstract final class AppNavigation {
  static final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  static void selectTab(int index) => selectedTab.value = index;

  static void showHome() => selectTab(0);
}
