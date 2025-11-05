import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

enum ScreenOrientation {
  portrait,
  landscape,
}

class ResponsiveLayout {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static ScreenOrientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? ScreenOrientation.portrait
        : ScreenOrientation.landscape;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  static bool isPortrait(BuildContext context) =>
      getOrientation(context) == ScreenOrientation.portrait;

  static bool isLandscape(BuildContext context) =>
      getOrientation(context) == ScreenOrientation.landscape;

  static double getDartboardSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscapeMode = isLandscape(context);
    final deviceType = getDeviceType(context);

    if (isLandscapeMode) {
      // In landscape, use height-based sizing
      switch (deviceType) {
        case DeviceType.mobile:
          return size.height * 0.6;
        case DeviceType.tablet:
          return size.height * 0.7;
        case DeviceType.desktop:
          return size.height * 0.75;
      }
    } else {
      // In portrait, use width-based sizing
      switch (deviceType) {
        case DeviceType.mobile:
          return size.width * 0.85;
        case DeviceType.tablet:
          return size.width * 0.6;
        case DeviceType.desktop:
          return size.width * 0.5;
      }
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }

  static double getTextScaleFactor(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.2;
      case DeviceType.desktop:
        return 1.3;
    }
  }

  static int getCrossAxisCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscapeMode = isLandscape(context);

    if (isLandscapeMode) {
      return deviceType == DeviceType.mobile ? 2 : 3;
    } else {
      return deviceType == DeviceType.mobile ? 1 : 2;
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }
}
