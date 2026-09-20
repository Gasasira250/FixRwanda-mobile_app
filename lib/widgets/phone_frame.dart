import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  static bool get isEnabled {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return false;
      default:
        return true;
    }
  }

  static const double _aspect = 390 / 844;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const sideBezel = 12.0;
        const topBezel = 38.0;
        const bottomBezel = 22.0;
        const outerRadius = 48.0;
        const screenRadius = 36.0;

        final maxWidth = (constraints.maxWidth - 72).clamp(280.0, 430.0);
        final maxHeight = (constraints.maxHeight - 48).clamp(480.0, 920.0);

        var screenWidth = maxWidth - sideBezel * 2;
        var screenHeight = screenWidth / _aspect;
        var outerWidth = screenWidth + sideBezel * 2;
        var outerHeight = screenHeight + topBezel + bottomBezel;

        if (outerHeight > maxHeight) {
          outerHeight = maxHeight;
          screenHeight = outerHeight - topBezel - bottomBezel;
          screenWidth = screenHeight * _aspect;
          outerWidth = screenWidth + sideBezel * 2;
        }

        return Center(
          child: SizedBox(
            width: outerWidth + 18,
            height: outerHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _VolumeButtons(),
                ),
                const Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _PowerButton(),
                ),
                Container(
                  width: outerWidth,
                  height: outerHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(outerRadius),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3A3A3C),
                        Color(0xFF111111),
                        Color(0xFF2C2C2E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF4A4A4C),
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _DynamicIsland(),
                        ),
                      ),
                      const Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _HomeIndicator(),
                        ),
                      ),
                      Positioned(
                        left: sideBezel,
                        right: sideBezel,
                        top: topBezel,
                        bottom: bottomBezel,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(screenRadius),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: Size(screenWidth, screenHeight),
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VolumeButtons extends StatelessWidget {
  const _VolumeButtons();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _SideButton(width: 5, height: 28),
          SizedBox(height: 12),
          _SideButton(width: 5, height: 52),
          SizedBox(height: 8),
          _SideButton(width: 5, height: 52),
        ],
      ),
    );
  }
}

class _PowerButton extends StatelessWidget {
  const _PowerButton();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0, -0.28),
      child: _SideButton(width: 5, height: 64),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
