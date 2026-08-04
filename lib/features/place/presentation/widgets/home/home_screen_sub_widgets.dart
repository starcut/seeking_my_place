import 'package:flutter/material.dart';

/// GoogleMap 中央に表示する十字カーソル。
///
/// 上下左右 4 本の腕 (中央から [_centerGap] 離れた位置に、長さ [_armLength] ・
/// 太さ [_thickness] ・角丸 [_cornerRadius] の棒) と、中央の円
/// (直径 [_centerDiameter]) で構成する。
class MapCenterCrosshair extends StatelessWidget {
  const MapCenterCrosshair({super.key});

  static const double _armLength = 10;
  static const double _centerGap = 10;
  static const double _thickness = 4;
  static const double _cornerRadius = 2;
  static const double _centerDiameter = 4;
  static const double _size = (_centerGap + _armLength) * 2;
  static const Color _color = Color.fromRGBO(255, 0, 0, 1);

  static const double _armOffset = (_size - _thickness) / 2;
  static const double _centerOffset = (_size - _centerDiameter) / 2;

  Widget _arm({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: _armOffset,
            child: _arm(width: _thickness, height: _armLength),
          ),
          Positioned(
            bottom: 0,
            left: _armOffset,
            child: _arm(width: _thickness, height: _armLength),
          ),
          Positioned(
            left: 0,
            top: _armOffset,
            child: _arm(width: _armLength, height: _thickness),
          ),
          Positioned(
            right: 0,
            top: _armOffset,
            child: _arm(width: _armLength, height: _thickness),
          ),
          Positioned(
            left: _centerOffset,
            top: _centerOffset,
            child: Container(
              width: _centerDiameter,
              height: _centerDiameter,
              decoration: const BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// GoogleMap 右下に配置する丸形の操作ボタン。
///
/// 標準の [FloatingActionButton.small] (40pt) の 1.5 倍 ([_size]) の大きさで、
/// 円形・白背景にする。
class RoundMapButton extends StatelessWidget {
  const RoundMapButton({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.onPressed,
  });

  final Object heroTag;
  final IconData icon;
  final VoidCallback? onPressed;

  static const double _size = 40 * 1.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  /// 元の高さ (上下 padding 8 + pill 4 = 20) から要望により 15pt 高くした値。
  static const double _height = 35;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // ドラッグ領域(GestureDetector の当たり判定)を画面幅一杯にするため、
      // 幅を親の最大幅まで広げる。
      width: double.infinity,
      height: _height,
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
