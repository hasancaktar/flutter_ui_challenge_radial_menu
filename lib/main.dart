import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttery/layout.dart';
import 'package:fluttery/gestures.dart';
import 'package:meta/meta.dart';
import 'package:radial_menu/geometry.dart';
import 'package:radial_menu/layout.dart';
import 'package:radial_menu/menu.dart';

void main() {
  timeDilation = 10.0;
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Radial Menu',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final topLeft = "TOP_LEFT";
  final topRight = "TOP_RIGHT";
  final middleLeft = "MIDDLE_LEFT";
  final middleRight = "MIDDLE_RIGHT";
  final bottomLeft = "BOTTOM_LEFT";
  final bottomRight = "BOTTOM_RIGHT";
  final center = "CENTER";

  bool isShowingMenu = false;

  void showMenu(String location) {
    if (!isShowingMenu) {
      // TODO: show menu for location
      print('Opening menu for $location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: new AnchoredRadialMenu(
            startAngle: 0.0,
            endAngle: pi / 2,
            child: new IconButton(
                icon: new Icon(
                  Icons.cancel,
                ),
                onPressed: () {
                  showMenu(topLeft);
                }),
          ),
          title: new Text(''),
          actions: <Widget>[
            new AnchoredRadialMenu(
              startAngle: pi,
              endAngle: pi / 2,
              child: new IconButton(
                  icon: new Icon(
                    Icons.cancel,
                  ),
                  onPressed: () {
                    showMenu(topRight);
                  }),
            ),
          ],
        ),
        body: new Stack(
          children: <Widget>[
            // Left center
            new Align(
              alignment: Alignment.centerLeft,
              child: new AnchoredRadialMenu(
                startAngle: -pi / 2,
                endAngle: pi / 2,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(middleLeft);
                    }),
              ),
            ),

            // Left bottom
            new Align(
              alignment: Alignment.bottomLeft,
              child: new AnchoredRadialMenu(
                startAngle: -pi / 2,
                endAngle: 0.0,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(bottomLeft);
                    }),
              ),
            ),

            // Right center
            new Align(
              alignment: Alignment.centerRight,
              child: new AnchoredRadialMenu(
                startAngle: 3 * pi / 2,
                endAngle: pi / 2,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(middleRight);
                    }),
              ),
            ),

            // Right bottom
            new Align(
              alignment: Alignment.bottomRight,
              child: new AnchoredRadialMenu(
                startAngle: 3 * pi / 2,
                endAngle: pi,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(bottomRight);
                    }),
              ),
            ),

            // True center
            new Align(
              alignment: Alignment.center,
              child: new AnchoredRadialMenu(
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(center);
                    }),
              ),
            ),
          ],
        ));
  }
}

class AnchoredRadialMenu extends StatefulWidget {
  final double menuRadius;
  final double bubbleSize;
  final double startAngle;
  final double endAngle;
  final Widget child;

  AnchoredRadialMenu({
    this.menuRadius = 75.0,
    this.bubbleSize = 50.0,
    this.startAngle = -pi / 2, // default to top of unit circle
    this.endAngle = 2 * pi - (pi / 2), // default to top of unit circle + 360 degrees
    this.child,
  });

  @override
  _AnchoredRadialMenuState createState() => new _AnchoredRadialMenuState();
}

class _AnchoredRadialMenuState extends State<AnchoredRadialMenu> {
  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (BuildContext context, Offset anchor) {
        return new CollidingRadialMenu(
          menu: demoMenu,
          anchor: anchor,
          bubbleSize: 50.0,
          menuRadius: 75.0,
          startAngle: widget.startAngle,
          endAngle: widget.endAngle,
        );
//        return new LayoutBuilder(
//          builder: (BuildContext context, BoxConstraints constraints) {
//            List<Widget> dots = checkForScreenIntersection(constraints, anchor);
//
//            return new Stack(
//              children: <Widget>[
//                new RadialMenu(
//                  menu: demoMenu,
//                  anchor: anchor,
//                  bubbleSize: 50.0,
//                  radius: 75.0,
//                  startAngle: startAngle != null ? startAngle.toRadians() : widget.startAngle,
//                  endAngle: endAngle != null ? endAngle.toRadians() : widget.endAngle,
//                ),
//              ]..addAll(dots),
//            );
//          },
//        );
      },
      child: widget.child,
    );
  }
}

class CollidingRadialMenu extends StatefulWidget {
  final Menu menu;
  final Offset anchor;
  final double menuRadius;
  final double bubbleSize;
  final double startAngle;
  final double endAngle;
  final Widget child;

  CollidingRadialMenu({
    this.menu,
    this.anchor,
    this.menuRadius = 75.0,
    this.bubbleSize = 50.0,
    this.startAngle = -pi / 2, // default to top of unit circle
    this.endAngle = 2 * pi - (pi / 2), // default to top of unit circle + 360 degrees
    this.child,
  });

  @override
  _CollidingRadialMenuState createState() => new _CollidingRadialMenuState();
}

class _CollidingRadialMenuState extends State<CollidingRadialMenu> {
  Angle startAngle;
  Angle endAngle;

  List<Widget> checkForScreenIntersection(BoxConstraints constraints, Offset anchor) {
    final origin = new Point<double>(anchor.dx, anchor.dy);
    final screenSize = new Size(constraints.maxWidth, constraints.maxHeight);
    final centerOfScreen = new Point(constraints.maxWidth / 2, constraints.maxHeight / 2);

    // Find where menu circle intersects the screen boundaries.
    Set<Point> intersections = intersect(
      screenSize,
      origin,
      widget.menuRadius,
    );

    if (intersections.length == 2) {
      // Adjust screen intersection points to leave room for bubble radii.
      Set<Point> menuPoints = rotatePointsToMakeRoom(
        points: intersections,
        origin: origin,
        direction: centerOfScreen,
        radius: widget.menuRadius,
        extraSpace: widget.bubbleSize / 2,
      );

      // Choose a start angle and end angle based on menu points.
      List<Angle> menuAngles = _createStartAndEndAnglesFromTwoPoints(
        menuPoints,
        origin,
        centerOfScreen,
      );
      startAngle = menuAngles[0];
      endAngle = menuAngles[1];

      // Create debug dots
      List<Widget> dots = []..addAll(menuPoints.map((Point point) {
          return _createDot(point);
        }));

      return dots;
    } else {
      return const [];
    }
  }

  List<Angle> _createStartAndEndAnglesFromTwoPoints(
    Set<Point> menuEdgePoints,
    Point origin,
    Point centerOfScreen,
  ) {
    if (menuEdgePoints.length != 2) {
      return const [];
    }

    Angle angle1 =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, menuEdgePoints.first).angle);
    Angle angle2 =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, menuEdgePoints.last).angle);

    if (menuEdgePoints.first.y < menuEdgePoints.last.y) {
      startAngle = angle1;
      endAngle = angle2;
    } else {
      startAngle = angle2;
      endAngle = angle1;
    }
    print('Initial start angle: $startAngle');

    Angle intersectionAngle = startAngle;

    Angle angleToCenterOfScreen =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, centerOfScreen).angle);

    final Angle centerToIntersectDelta = angleToCenterOfScreen - intersectionAngle;
    print('angleToCenterOfScreen: $angleToCenterOfScreen, intersectionAngle: $intersectionAngle');
    print('centerToIntersectDelta: $centerToIntersectDelta');
    final isClockwise =
        (centerToIntersectDelta >= Angle.zero && centerToIntersectDelta <= Angle.halfCircle) ||
            (centerToIntersectDelta < Angle.zero &&
                (centerToIntersectDelta + Angle.fullCircle <= Angle.halfCircle));

    if (!isClockwise) {
      startAngle = new Angle.fromRadians(startAngle.toRadians(forcePositive: true));
      endAngle = new Angle.fromRadians(endAngle.toRadians(forcePositive: true));
    }

    print('Start angle: $startAngle, end angle: $endAngle');
    return [startAngle, endAngle];
  }

  Widget _createDot(Point position) {
    return new Positioned(
      left: position.x,
      top: position.y,
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: new Container(
          width: 20.0,
          height: 20.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        List<Widget> dots = checkForScreenIntersection(constraints, widget.anchor);

        return new Stack(
          children: <Widget>[
            new RadialMenu(
              menu: demoMenu,
              anchor: widget.anchor,
              bubbleSize: 50.0,
              radius: 75.0,
              startAngle: startAngle != null ? startAngle.toRadians() : widget.startAngle,
              endAngle: endAngle != null ? endAngle.toRadians() : widget.endAngle,
            ),
          ]..addAll(dots),
        );
      },
    );
  }
}

class RadialMenu extends StatefulWidget {
  final Menu menu;
  final Offset anchor;
  final double bubbleSize;
  final double radius;
  final double startAngle;
  final double endAngle;

  RadialMenu({
    this.menu,
    this.anchor,
    this.bubbleSize,
    this.radius,
    this.startAngle = -pi / 2, // default to top of unit circle
    this.endAngle = 2 * pi - (pi / 2), // default to top of unit circle + 360 degrees
  });

  @override
  _RadialMenuState createState() => new _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with TickerProviderStateMixin {
  RadialMenuController controller;

  @override
  void initState() {
    super.initState();

    controller = new RadialMenuController(
      vsync: this,
    )..addListener(() => setState(() {}));

    new Timer(
      const Duration(seconds: 2),
      () {
        controller.open();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  Widget buildCenter() {
    IconData icon;
    Color bubbleColor;
    switch (controller.state) {
      case RadialMenuState.closed:
      case RadialMenuState.closing:
      case RadialMenuState.opening:
      case RadialMenuState.open:
        icon = Icons.menu;
        bubbleColor = const Color(0xFFAAAAAA);
        break;
      default:
        icon = Icons.clear;
        bubbleColor = const Color(0xFF888888);
        break;
    }

    double scale = 1.0;
    if (controller.state == RadialMenuState.closed) {
      scale = 0.0;
    } else if (controller.state == RadialMenuState.opening) {
      scale = controller.progress;
    } else if (controller.state == RadialMenuState.closing) {
      scale = 1.0 - controller.progress;
    }

    return new CenterAbout(
      position: widget.anchor,
      child: new Transform(
        transform: new Matrix4.identity()..scale(scale, scale),
        alignment: Alignment.center,
        child: new IconBubble(
          icon: icon,
          diameter: 50.0,
          foregroundColor: Colors.black,
          backgroundColor: bubbleColor,
          onPressed: () {
            if (controller.state == RadialMenuState.open) {
              controller.expand();
            } else {
              controller.collapse();
            }
          },
        ),
      ),
    );
  }

  List<Widget> buildRadialBubbles() {
    Angle startAngle = new Angle.fromRadians(widget.startAngle);
    final Angle sweepAngle = new Angle.fromRadians(widget.endAngle) - startAngle;
    int index = 0;
    int itemCount = widget.menu.items.length;

    return widget.menu.items.map((MenuItem item) {
      int indexDivisor = sweepAngle == Angle.fullCircle ? itemCount : itemCount - 1;
      final Angle bubbleAngleDiff = sweepAngle * (index / indexDivisor);
      final Angle myAngle = startAngle + bubbleAngleDiff;
      ++index;

      if (controller.state == RadialMenuState.activating ||
          controller.state == RadialMenuState.dissipating) {
        if (controller.activationId == item.id) {
          // Don't render the active item when its activating or dissipating
          return Container();
        }
      }

      return buildRadialBubble(
        id: item.id,
        icon: item.icon,
        iconColor: item.iconColor,
        bubbleColor: item.bubbleColor,
        angle: myAngle.toRadians(),
      );
    }).toList(growable: true);
  }

  Widget buildRadialBubble({
    String id,
    IconData icon,
    Color iconColor,
    Color bubbleColor,
    double angle,
  }) {
    if (controller.state == RadialMenuState.closed ||
        controller.state == RadialMenuState.closing ||
        controller.state == RadialMenuState.opening ||
        controller.state == RadialMenuState.open ||
        controller.state == RadialMenuState.dissipating) {
      return new Container();
    }

    double distanceOut = widget.radius;
    double bubbleDiameter = widget.bubbleSize;

    if (controller.state == RadialMenuState.expanding) {
      distanceOut = widget.radius * controller.progress;
      bubbleDiameter = widget.bubbleSize * lerpDouble(0.3, 1.0, controller.progress);
    } else if (controller.state == RadialMenuState.collapsing) {
      distanceOut = widget.radius * (1.0 - controller.progress);
      bubbleDiameter = widget.bubbleSize * lerpDouble(0.3, 1.0, (1.0 - controller.progress));
    }

    return new PolarPosition(
      origin: widget.anchor,
      coord: new PolarCoord(angle, distanceOut),
      child: new IconBubble(
        icon: icon,
        diameter: bubbleDiameter,
        foregroundColor: iconColor,
        backgroundColor: bubbleColor,
        onPressed: () {
          controller.activate(id);
        },
      ),
    );
  }

  Widget buildActivationRibbon() {
    if (controller.state != RadialMenuState.activating &&
        controller.state != RadialMenuState.dissipating) {
      return new Container();
    }

    MenuItem activeItem =
        widget.menu.items.firstWhere((MenuItem item) => item.id == controller.activationId);
    int activeIndex = widget.menu.items.indexOf(activeItem);

    double ribbonStartAngle;
    double ribbonEndAngle;
    double radius = 75.0;
    double opacity = 1.0;
    if (controller.state == RadialMenuState.activating) {
      final menuSweepAngle = widget.endAngle - widget.startAngle;
      final indexDivisor =
          menuSweepAngle == 2 * pi ? widget.menu.items.length : widget.menu.items.length - 1;
      final initialItemAngle = widget.startAngle + (menuSweepAngle * activeIndex / indexDivisor);

      if (menuSweepAngle == 2 * pi) {
        ribbonStartAngle = initialItemAngle;
        ribbonEndAngle = initialItemAngle + (menuSweepAngle * controller.progress);
      } else {
        ribbonStartAngle =
            initialItemAngle - ((initialItemAngle - widget.startAngle) * controller.progress);
        ribbonEndAngle =
            initialItemAngle + ((widget.endAngle - initialItemAngle) * controller.progress);
      }
    } else if (controller.state == RadialMenuState.dissipating) {
      ribbonStartAngle = widget.startAngle;
      ribbonEndAngle = widget.endAngle;

      radius = 75 * (1.0 + (0.25 * controller.progress));
      opacity = 1.0 - controller.progress;
    }

    return new CenterAbout(
      position: widget.anchor,
      child: new Opacity(
        opacity: opacity,
        child: new CustomPaint(
          painter: new ActivationPainter(
            radius: radius,
            color: activeItem.bubbleColor,
            startAngle: ribbonStartAngle,
            endAngle: ribbonEndAngle,
            thickness: 50.0,
          ),
        ),
      ),
    );
  }

  Widget buildActivationBubble() {
    if (controller.state != RadialMenuState.activating) {
      return new Container();
    }

    MenuItem activeItem =
        widget.menu.items.firstWhere((MenuItem item) => item.id == controller.activationId);
    int activeIndex = widget.menu.items.indexOf(activeItem);

    double currAngle;

    final sweepAngle = widget.endAngle - widget.startAngle;
    final indexDivisor =
        sweepAngle == 2 * pi ? widget.menu.items.length : widget.menu.items.length - 1;
    final initialItemAngle = widget.startAngle + (activeIndex * sweepAngle / indexDivisor);
    if (sweepAngle == 2 * pi) {
      currAngle = (sweepAngle * controller.progress) + initialItemAngle;
    } else {
      final centerAngle = lerpDouble(widget.startAngle, widget.endAngle, 0.5);
      currAngle = lerpDouble(initialItemAngle, centerAngle, controller.progress);
    }

    return buildRadialBubble(
      id: activeItem.id,
      icon: activeItem.icon,
      iconColor: activeItem.iconColor,
      bubbleColor: activeItem.bubbleColor,
      angle: currAngle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: buildRadialBubbles()
        ..addAll(<Widget>[
          // Activation ribbon
          buildActivationRibbon(),

          // Activating bubble
          buildActivationBubble(),

          // Center
          buildCenter(),
        ]),
    );
  }
}

class ActivationPainter extends CustomPainter {
  final double radius;
  final double startAngle;
  final double endAngle;
  final Paint activationPaint;

  ActivationPainter({
    Color color,
    this.radius,
    this.startAngle,
    this.endAngle,
    double thickness,
  }) : activationPaint = new Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(new Rect.fromLTWH(-radius, -radius, radius * 2, radius * 2), startAngle,
        endAngle - startAngle, false, activationPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final double diameter;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  IconBubble({
    this.icon,
    this.diameter,
    this.foregroundColor,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onPressed,
      child: new Bubble(
        diameter: diameter,
        backgroundColor: backgroundColor,
        child: new Icon(
          icon,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final double diameter;
  final Color backgroundColor;
  final Widget child;

  Bubble({
    this.diameter,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: diameter,
      height: diameter,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: child,
    );
  }
}

class RadialMenuController extends ChangeNotifier {
  final Duration openDuration;
  final AnimationController openController;

  final Duration closeDuration;
  final AnimationController closeController;

  final Duration expandDuration;
  final AnimationController expandController;

  final Duration collapseDuration;
  final AnimationController collapseController;

  final Duration activationDuration;
  final AnimationController activationController;

  final Duration dissipationDuration;
  final AnimationController dissipationController;

  final TickerProvider vsync;

  RadialMenuState _state = RadialMenuState.closed;
  double _progress;
  String _activationId; // Only valid in activating and dissipating states.

  RadialMenuController({
    this.openDuration = const Duration(milliseconds: 250),
    this.closeDuration = const Duration(milliseconds: 250),
    this.expandDuration = const Duration(milliseconds: 150),
    this.collapseDuration = const Duration(milliseconds: 150),
    this.activationDuration = const Duration(milliseconds: 500),
    this.dissipationDuration = const Duration(milliseconds: 250),
    @required this.vsync,
  })  : openController = new AnimationController(duration: openDuration, vsync: vsync),
        closeController = new AnimationController(duration: closeDuration, vsync: vsync),
        expandController = new AnimationController(duration: expandDuration, vsync: vsync),
        collapseController = new AnimationController(duration: collapseDuration, vsync: vsync),
        activationController = new AnimationController(duration: activationDuration, vsync: vsync),
        dissipationController = new AnimationController(duration: openDuration, vsync: vsync) {
    openController
      ..addListener(() {
        _progress = openController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.opening;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.open;
          notifyListeners();
        }
      });

    closeController
      ..addListener(() {
        _progress = closeController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.closing;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.closed;
          notifyListeners();
        }
      });

    expandController
      ..addListener(() {
        _progress = expandController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.expanding;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.expanded;
          notifyListeners();
        }
      });

    collapseController
      ..addListener(() {
        _progress = collapseController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.collapsing;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.open;
          notifyListeners();
        }
      });

    activationController
      ..addListener(() {
        _progress = activationController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.activating;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _progress = 1.0;
          notifyListeners();

          dissipationController.forward(from: 0.0);
        }
      });

    dissipationController
      ..addListener(() {
        _progress = dissipationController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.dissipating;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.open;
          notifyListeners();
        }
      });
  }

  RadialMenuState get state => _state;

  double get progress => _progress;

  String get activationId => _activationId;

  void open() {
    if (state == RadialMenuState.closed) {
      openController.forward(from: 0.0);
    }
  }

  void close() {
    if (state == RadialMenuState.open) {
      closeController.forward(from: 0.0);
    }
  }

  void expand() {
    if (state == RadialMenuState.open) {
      expandController.forward(from: 0.0);
    }
  }

  void collapse() {
    if (state == RadialMenuState.expanded) {
      collapseController.forward(from: 0.0);
    }
  }

  void activate(String menuItemId) {
    if (state == RadialMenuState.expanded) {
      _activationId = menuItemId;
      activationController.forward(from: 0.0);
    }
  }
}

enum RadialMenuState {
  closed,
  closing,
  opening,
  open,
  expanding,
  expanded,
  collapsing,
  activating,
  dissipating,
}
