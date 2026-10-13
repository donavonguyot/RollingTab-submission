import 'package:flutter/material.dart';

import '../model/music.dart';
import 'guitar_surface.dart';
import '../audio/transport.dart';
import '../model/voicing.dart';

const holdColor = Color(0xff55c9b5);
const prepareColor = Color(0xff70baff);
const releaseColor = Color(0xffeeaf74);

class VoicingPanel extends StatelessWidget {
  final GuitarState transport;
  final SurfaceOptions options;
  final bool vertical;
  const VoicingPanel({
    super.key,
    required this.transport,
    required this.options,
    this.vertical = false,
  });
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([transport, options]),
    builder: (context, _) {
      final study = VoicingStudy(transport.fixture),
          frame = study.at(transport.time, options.preparationBeats);
      final fade =
          options.voicingFades && options.effects && !options.reducedMotion;
      final boards = [
        _board(context, frame, false, fade),
        if (!options.voicingOverlay) _board(context, frame, true, fade),
      ];
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${options.voicingOverlay ? 'VOICING · ONE BOARD' : 'VOICING · NOW + NEXT'}${options.leftHanded ? ' · LEFT-HANDED' : ''}',
              style: const TextStyle(fontSize: 10, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            Text(
              frame.next == null
                  ? 'Let the sound finish'
                  : '${frame.next!.name} in ${frame.beatsUntil.toStringAsFixed(1)} beats · prepare, then play',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Semantics(
              container: true,
              label: 'Preparation progress',
              child: LinearProgressIndicator(
                value: frame.preview,
                minHeight: 2,
                color: prepareColor,
              ),
            ),
            const SizedBox(height: 8),
            if (vertical)
              ...boards.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: b,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: boards.first),
                  if (boards.length > 1) ...[
                    const SizedBox(width: 12),
                    Expanded(child: boards.last),
                  ],
                ],
              ),
            const SizedBox(height: 6),
            const Text(
              '● Sounding / keep   ◯ Prepare   × Lift / damp',
              style: TextStyle(fontSize: 10),
            ),
            const SizedBox(height: 3),
            const Text(
              'Frets, not finger numbers. Open strings ring without a press.',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      );
    },
  );
  Widget _board(
    BuildContext context,
    VoicingFrame frame,
    bool next,
    bool fades,
  ) {
    final notes = next ? frame.target : frame.sounding;
    final showing = next ? frame.preview > 0 : true;
    final title = next
        ? 'NEXT · ${frame.next?.name ?? '—'}'
        : 'NOW · ${frame.current?.name ?? 'Ready'}';
    final keep = frame.sounding.where(frame.continues).length;
    final caption = next
        ? (frame.next == null
              ? 'End of phrase'
              : !showing
              ? 'Preview starts ${options.preparationBeats.toStringAsFixed(1)} beats before'
              : '$keep strings continue · outline means prepare')
        : (options.voicingOverlay
              ? 'Next positions appear as outlined rings'
              : (frame.prepared.isNotEmpty
                    ? 'Solid: sounding · outline: authored shape'
                    : 'Solid dots follow the sounding notes'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 28,
          child: Text(
            caption,
            style: const TextStyle(fontSize: 10),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) => Semantics(
            label:
                '$title. ${options.leftHanded ? 'Left-handed fretboard. ' : ''}$caption. ${notes.map((n) => 'string ${n.stringNumber} fret ${n.fret}').join(', ')}',
            child: GestureDetector(
              onTapDown: (event) {
                final candidates = [
                  ...notes,
                  if (!next && options.voicingOverlay && frame.preview > 0)
                    ...frame.target,
                ];
                TabNote? hit;
                var distance = 18.0;
                for (final n in candidates) {
                  final delta =
                      (VoicingPainter.point(
                                n,
                                constraints.maxWidth,
                                options.maxFret,
                                leftHanded: options.leftHanded,
                              ) -
                              event.localPosition)
                          .distance;
                  if (delta < distance) {
                    distance = delta;
                    hit = n;
                  }
                }
                if (hit != null) {
                  options.selection = {hit.id};
                  options.update();
                }
              },
              child: SizedBox(
                height: 137,
                width: double.infinity,
                child: CustomPaint(
                  painter: VoicingPainter(
                    frame,
                    options,
                    transport.time,
                    next,
                    fades,
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VoicingPainter extends CustomPainter {
  final VoicingFrame frame;
  final SurfaceOptions options;
  final double time;
  final bool next, fades, dark;
  VoicingPainter(
    this.frame,
    this.options,
    this.time,
    this.next,
    this.fades,
    this.dark,
  );
  static double fretX(
    int fret,
    double width,
    int maxFret, {
    bool leftHanded = false,
  }) {
    final x = 32 + (width - 48) * fret / maxFret;
    return leftHanded ? width - x : x;
  }

  static Offset point(
    TabNote n,
    double width,
    int maxFret, {
    bool leftHanded = false,
  }) => Offset(
    fretX(n.fret, width, maxFret, leftHanded: leftHanded),
    31 + (n.stringNumber - 1) * 19,
  );
  void label(
    Canvas c,
    String s,
    Offset at,
    Color color, {
    double size = 10,
    bool center = false,
    bool rightAlign = false,
  }) {
    final p = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    p.paint(
      c,
      center
          ? at - Offset(p.width / 2, p.height / 2)
          : rightAlign
          ? at - Offset(p.width, 0)
          : at,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final holdInk = dark ? holdColor : const Color(0xff3aaf98),
        prepareInk = dark ? prepareColor : const Color(0xff145da0),
        releaseInk = dark ? releaseColor : const Color(0xff914808);
    final ink = dark ? const Color(0xffe4edf5) : const Color(0xff19374b),
        grid = dark ? const Color(0xff425563) : const Color(0xffbdcbd4);
    double x(int f) =>
        fretX(f, size.width, options.maxFret, leftHanded: options.leftHanded);
    for (var s = 1; s <= 6; s++) {
      final y = 31.0 + (s - 1) * 19;
      canvas.drawLine(
        Offset(x(0), y),
        Offset(x(options.maxFret), y),
        Paint()
          ..color = grid
          ..strokeWidth = (s + 2) / 6,
      );
      label(
        canvas,
        '$s ${['E', 'B', 'G', 'D', 'A', 'E'][s - 1]}',
        Offset(options.leftHanded ? size.width - 20 : 0, y - 6),
        ink,
        size: 9,
      );
    }
    for (var f = 0; f <= options.maxFret; f++) {
      canvas.drawLine(
        Offset(x(f), 27),
        Offset(x(f), 130),
        Paint()
          ..color = grid
          ..strokeWidth = f == 0 ? 2 : 1,
      );
      if (size.width > 350 || f == 0 || f % 2 == 0 || options.maxFret <= 5) {
        label(canvas, '$f', Offset(x(f), 12), ink, center: true);
      }
    }
    final previewOpacity = fades ? .2 + .8 * frame.preview : 1.0;
    void dot(
      TabNote n,
      Color color, {
      bool outline = false,
      double opacity = 1,
      bool cross = false,
    }) {
      final p = point(
            n,
            size.width,
            options.maxFret,
            leftHanded: options.leftHanded,
          ),
          col = color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(
        p,
        8,
        Paint()
          ..color = col
          ..style = outline ? PaintingStyle.stroke : PaintingStyle.fill
          ..strokeWidth = 2,
      );
      if (cross) {
        canvas.drawLine(
          p + const Offset(-3, -3),
          p + const Offset(3, 3),
          Paint()
            ..color = col
            ..strokeWidth = 1.5,
        );
        canvas.drawLine(
          p + const Offset(-3, 3),
          p + const Offset(3, -3),
          Paint()
            ..color = col
            ..strokeWidth = 1.5,
        );
      } else {
        label(
          canvas,
          '${n.fret}',
          p,
          outline ? col : const Color(0xff102536),
          center: true,
          size: 10,
        );
      }
      if (options.selection.contains(n.id)) {
        canvas.drawCircle(
          p,
          11,
          Paint()
            ..color = ink.withValues(alpha: opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }

    if (next) {
      if (frame.preview > 0) {
        for (final n in frame.target) {
          final held = frame.sounding.any((x) => x.id == n.id);
          dot(
            n,
            held ? holdInk : prepareInk,
            outline: !held,
            opacity: held ? 1 : previewOpacity,
          );
        }
      }
      return;
    }
    for (final n in frame.prepared) {
      if (!frame.sounding.any(
        (x) => x.stringNumber == n.stringNumber && x.fret == n.fret,
      )) {
        dot(n, prepareInk, outline: true, opacity: .4);
      }
    }
    // A release appears only after its boundary; no fading of an ongoing sustain.
    if (fades && frame.arrival < 1) {
      for (final n in frame.released) {
        if (!frame.sounding.any(
          (x) => x.stringNumber == n.stringNumber && x.fret == n.fret,
        )) {
          dot(
            n,
            releaseInk,
            outline: true,
            cross: true,
            opacity: 1 - frame.arrival,
          );
        }
      }
    }
    for (final n in frame.sounding) {
      final continuing = frame.continues(n),
          newlyPressed =
              frame.current != null &&
              (n.start - frame.current!.at).abs() < .001;
      dot(
        n,
        fades && newlyPressed
            ? Color.lerp(prepareInk, holdInk, frame.arrival)!
            : holdInk,
        opacity: fades && newlyPressed ? .65 + .35 * frame.arrival : 1,
      );
      if (frame.preview > 0 && !continuing && !frame.holdsPosition(n)) {
        final p = point(
          n,
          size.width,
          options.maxFret,
          leftHanded: options.leftHanded,
        );
        canvas.drawCircle(
          p,
          11,
          Paint()
            ..color = releaseInk.withValues(alpha: previewOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        // Tiny advance cue is distinct from the post-onset × release.
        if (size.width >= 260) {
          label(
            canvas,
            n.fret == 0 ? 'damp' : 'lift',
            p + Offset(options.leftHanded ? -13 : 13, -6),
            releaseInk.withValues(alpha: previewOpacity),
            size: 8,
            rightAlign: options.leftHanded,
          );
        }
      }
    }
    if (options.voicingOverlay && frame.preview > 0) {
      for (final n in frame.target) {
        if (!frame.sounding.any(
          (x) => x.stringNumber == n.stringNumber && x.fret == n.fret,
        )) {
          dot(n, prepareInk, outline: true, opacity: previewOpacity);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant VoicingPainter oldDelegate) => true;
}
