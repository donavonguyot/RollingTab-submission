import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;

import '../model/music.dart';
import '../audio/transport.dart';

class SurfaceOptions extends ChangeNotifier {
  double depth = .55, lookAhead = 4.5, preparationBeats = 2;
  bool effects = true,
      reducedMotion = false,
      leftHanded = false,
      voicingOverlay = false,
      voicingFades = true;
  Set<String> selection = {};
  int pooledNodes = 0, visibleNodes = 0, maxFret = 5;
  String engineStatus = 'initializing';
  void update() => notifyListeners();
}

class GuitarProjection {
  final GuitarState state;
  final SurfaceOptions options;
  final Size size;
  late final fs.Camera camera;
  GuitarProjection(this.state, this.options, this.size) {
    final aspect = size.width / size.height;
    final centerX = size.width < 600 ? 4.0 : 5.0;
    final distance = math.max(5.8, 11.8 / aspect) / (2 * math.tan(.35));
    camera = fs.PerspectiveCamera(
      position: vm.Vector3(centerX - options.depth * 5, 0, -distance),
      target: vm.Vector3(centerX, 0, 0),
      fovRadiansY: .7,
    );
  }
  Iterable<TabNote> get visible => state.fixture.notes.where(
    (n) =>
        n.stringNumber > 0 &&
        n.end > state.time &&
        n.start < state.time + options.lookAhead,
  );
  vm.Vector3 world(TabNote n, double at, {bool technique = true}) => vm.Vector3(
    (at - state.time) / options.lookAhead * 10,
    (3.5 - n.stringNumber) * .68,
    technique && options.effects && !options.reducedMotion
        ? -.06 - techniqueSemitones(n, at) * .12
        : -.06,
  );
  Offset point(TabNote n, double at) {
    if (options.effects) {
      return camera.worldToScreen(world(n, at, technique: false), size) ??
          const Offset(-100, -100);
    }
    return Offset(
      38 + (at - state.time) / options.lookAhead * (size.width - 65),
      26 + (n.stringNumber - 1) * (size.height - 55) / 5,
    );
  }
}

class GuitarSurface extends StatefulWidget {
  final GuitarState state;
  final SurfaceOptions options;
  const GuitarSurface({super.key, required this.state, required this.options});
  @override
  State<GuitarSurface> createState() => _GuitarSurfaceState();
}

class _GuitarSurfaceState extends State<GuitarSurface> {
  fs.Scene? scene;
  fs.Geometry? geometry;
  final pool = <fs.Node>[];
  final materials = <String, fs.Material>{};
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await fs.Scene.initializeStaticResources();
      if (!mounted) return;
      scene = fs.Scene();
      geometry = fs.CuboidGeometry(vm.Vector3.all(1));
      widget.options.engineStatus = 'ready';
      setState(() {});
    } catch (e) {
      widget.options.engineStatus = 'Failed to initialize 3D: $e';
      if (mounted) setState(() {});
    }
  }

  fs.Material material(String key, Color c) => materials.putIfAbsent(
    key,
    () =>
        fs.UnlitMaterial()
          ..baseColorFactor = vm.Vector4(c.r * c.r, c.g * c.g, c.b * c.b, 1),
  );
  void box(
    int i,
    vm.Vector3 position,
    vm.Vector3 scale,
    String key,
    Color color,
  ) {
    while (pool.length <= i) {
      final n = fs.Node();
      pool.add(n);
      scene!.add(n);
    }
    final n = pool[i];
    n.visible = true;
    final mat = material(key, color);
    if (n.mesh?.primitives.first.material != mat) {
      n.mesh = fs.Mesh(geometry!, mat);
    }
    n.position = position;
    n.scale = scale;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([widget.state, widget.options]),
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight),
            o = widget.options,
            t = widget.state;
        final p = GuitarProjection(t, o, size),
            dark = Theme.of(context).brightness == Brightness.dark;
        final palette = GuitarPalette(dark);
        if (scene != null && o.effects) {
          int count = 0;
          void add(vm.Vector3 at, vm.Vector3 scale, String key, Color color) =>
              box(count++, at, scale, '$dark-$key', color);
          add(
            vm.Vector3(5, 0, .16),
            vm.Vector3(10, 4.5, .1),
            'plane',
            palette.plane,
          );
          for (var s = 1; s <= 6; s++) {
            add(
              vm.Vector3(5, (3.5 - s) * .68, .08),
              vm.Vector3(10, .015, .02),
              'grid',
              palette.grid,
            );
          }
          add(
            vm.Vector3(0, 0, 0),
            vm.Vector3(.025, 4.5, .05),
            'arrival',
            palette.accent,
          );
          for (final n in p.visible) {
            final start = math.max(t.time, n.start),
                end = math.min(t.time + o.lookAhead, n.end),
                segments = n.technique.isEmpty ? 1 : 24;
            for (var j = 0; j < segments; j++) {
              final a = p.world(n, start + (end - start) * j / segments),
                  b = p.world(n, start + (end - start) * (j + 1) / segments);
              add(
                (a + b) / 2,
                vm.Vector3(math.max(.015, (b.x - a.x).abs()), .15, .06),
                n.active(t.time) ? 'active' : 'future',
                n.active(t.time) ? palette.active : palette.accent,
              );
            }
          }
          for (var i = count; i < pool.length; i++) {
            pool[i].visible = false;
          }
          o.pooledNodes = pool.length;
          o.visibleNodes = count;
        }
        return Semantics(
          label: 'Guitar timing. Six strings, high E to low E.',
          child: GestureDetector(
            onTapDown: (event) {
              TabNote? hit;
              double distance = 24;
              for (final n in p.visible) {
                final d =
                    (p.point(n, math.max(t.time, n.start)) -
                            event.localPosition)
                        .distance;
                if (d < distance) {
                  distance = d;
                  hit = n;
                }
              }
              if (hit != null) {
                o.selection = {hit.id};
                o.update();
              }
            },
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: palette.background),
                  if (o.effects && scene != null)
                    fs.SceneView(scene!, camera: p.camera, maxFrameRate: 60),
                  CustomPaint(painter: GuitarPainter(p, palette)),
                  if (o.effects && scene == null)
                    Center(
                      child: Text(
                        o.engineStatus,
                        style: TextStyle(color: palette.ink),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class GuitarPalette {
  final bool dark;
  GuitarPalette(this.dark);
  Color get background =>
      dark ? const Color(0xff101d2c) : const Color(0xffedf4f6);
  Color get plane => dark ? const Color(0xff173446) : const Color(0xffdbe6e9);
  Color get grid => dark ? const Color(0xff3d5c70) : const Color(0xffa9bec9);
  Color get ink => dark ? const Color(0xffeaf4f6) : const Color(0xff163647);
  Color get accent => dark ? const Color(0xff66d2ce) : const Color(0xff197e87);
  Color get active => dark ? const Color(0xffe6be7d) : const Color(0xffab6824);
}

class GuitarPainter extends CustomPainter {
  final GuitarProjection p;
  final GuitarPalette c;
  GuitarPainter(this.p, this.c);
  void text(
    Canvas canvas,
    String text,
    Offset at, {
    Color? color,
    double size = 11,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color ?? c.ink,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? at - Offset(tp.width / 2, tp.height / 2) : at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = p.state, o = p.options;
    text(
      canvas,
      o.effects ? 'PERSPECTIVE TAB' : 'FLAT TAB',
      const Offset(16, 12),
      size: 10,
    );
    for (var s = 1; s <= 6; s++) {
      final dummy = TabNote(
            id: 'lane',
            midi: 64,
            start: 0,
            duration: 1,
            stringNumber: s,
          ),
          a = p.point(dummy, t.time),
          b = p.point(dummy, t.time + o.lookAhead);
      if (!o.effects) {
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = c.grid
            ..strokeWidth = 1,
        );
      }
      text(canvas, '$s', a - const Offset(20, 0), center: true);
    }
    for (final n in p.visible) {
      final a = p.point(n, math.max(t.time, n.start)),
          b = p.point(n, math.min(n.end, t.time + o.lookAhead));
      final col = n.active(t.time) ? c.active : c.accent;
      if (!o.effects) {
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = col
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.drawCircle(a, 10, Paint()..color = col);
      text(
        canvas,
        '${n.fret}',
        a,
        color: const Color(0xff102536),
        center: true,
        size: 12,
      );
      if (o.selection.contains(n.id)) {
        canvas.drawCircle(
          a,
          14,
          Paint()
            ..color = c.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
      if (n.technique == 'tremolo') {
        for (double at = n.start; at < n.end; at += .125) {
          if (at < t.time || at > t.time + o.lookAhead) continue;
          final x = p.point(n, at);
          canvas.drawLine(
            x - const Offset(0, 5),
            x + const Offset(0, 5),
            Paint()
              ..color = c.ink
              ..strokeWidth = 1.2,
          );
        }
      }
      if (n.technique.isNotEmpty) {
        text(
          canvas,
          switch (n.technique) {
            'bend' => 'Bend +2 → release',
            'vibrato' => 'Vibrato ±0.28',
            'tremolo' => 'Repeated picking',
            'bar-dip' => 'Bar dip −2 → return',
            _ => n.technique,
          },
          a + const Offset(13, -22),
          size: 10,
        );
      }
      final feedback = feedbackFor(n, t.time, t.events, t.feedback);
      if (feedback.isNotEmpty) {
        text(
          canvas,
          'SIM · $feedback',
          a + const Offset(14, 13),
          color: const Color(0xffc4a5ff),
          size: 9,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GuitarPainter oldDelegate) => true;
}
