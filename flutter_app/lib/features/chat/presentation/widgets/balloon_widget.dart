import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';
import 'dart:math' as math;

typedef NewConstraints = BoxConstraints? Function(BoxConstraints currentConstraints);

class BalloonWidget extends StatelessWidget {
  final Widget? centerChild;
  final bool isLeftSide;
  final NewConstraints? centerChildConstraints;

  const BalloonWidget({ Key? key, this.centerChildConstraints, this.centerChild, required this.isLeftSide, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double kWidth = 13.0;
    const double kHeight = 10.0;

    final curve = Padding(
      padding: isLeftSide ? EdgeInsets.zero : const EdgeInsets.only(left: kWidth),
      child: Transform(
        transform: isLeftSide ? Matrix4.rotationY(0) : Matrix4.rotationY(math.pi),
        child: ClipPath(
          child: Container(
            width: kWidth,
            height: kHeight,
            color: isLeftSide ? Colors.white : const Color(0xFFE2F7CB),
          ),
          clipper: _SideWidgetClipper(),
        ),
      ),
    );

    final leftSideChild = isLeftSide ? curve : null;
    final rightSideChild = isLeftSide ? null : curve;

    return Align(
      alignment: rightSideChild != null ? Alignment.bottomRight : Alignment.bottomLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
              margin: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(leftSideChild != null)
                    leftSideChild,
                  Container(
                      padding: const EdgeInsets.only(left: 11, right: 11, top: 6, bottom: 4),
                      decoration: BoxDecoration(
                        color: rightSideChild != null ? const Color(0xFFE2F7CB) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: rightSideChild != null ? const Radius.circular(12) : Radius.zero,
                          bottomRight: const Radius.circular(12),
                          bottomLeft: const Radius.circular(12),
                          topRight: rightSideChild != null ? Radius.zero : const Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if(centerChild != null)
                            Container(
                              constraints: centerChildConstraints == null ? constraints : centerChildConstraints!(constraints),
                              child: centerChild!,
                            ),
                        ],
                      )
                  ),
                  if(rightSideChild != null)
                    rightSideChild,
                ],
              )
          );
        },
      ),
    );
  }
}

class _SideWidgetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.quadraticBezierTo(
        size.width * 0.75,
        size.height / 6,
        size.width,
        size.height
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}