import 'widgets/slider_overlay.dart';
import 'widgets/auth_dialog.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'audio/output.dart';
import 'widgets/speed_control.dart';
import 'audio/transport.dart';
import 'backend/connection.dart';
import 'backend/practice_library.dart';
import 'diagnostics/evidence_bridge.dart';
import 'diagnostics/metrics.dart';
import 'diagnostics/export.dart';
import 'model/music.dart';
import 'model/voicing.dart';
import 'surface/guitar_surface.dart';
import 'surface/voicing_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ids = (jsonDecode(
    await rootBundle.loadString('assets/fixtures/index.json'),
  ) as List).cast<String>();
  final studies = [
    for (final id in ids)
      TabScore.fromJson(
        jsonDecode(await rootBundle.loadString('assets/fixtures/$id.json')),
      ),
  ];
  runApp(RollingTabApp(studies: studies));
}

class RollingTabApp extends StatefulWidget {
  final List<TabScore> studies;
  final BackendConnection? connection;
  const RollingTabApp({super.key, required this.studies, this.connection});
  @override
  State<RollingTabApp> createState() => _RollingTabAppState();
}

class _RollingTabAppState extends State<RollingTabApp>
    with SingleTickerProviderStateMixin {
  late final TabTransport transport = TabTransport(
    widget.studies.first,
    ContinuousAudio(),
  );
  final options = SurfaceOptions(),
      metrics = LabMetrics(),
      captureKey = GlobalKey();
  late final backend = widget.connection ?? BackendConnection();
  late final library = PracticeLibrary(backend, transport);
  late final Ticker ticker;
  Timer? reviewTimer;
  Map<String, dynamic>? reviewResult;
  final reviewSamples = <Map<String, dynamic>>[];
  void startReview() {
    reviewTimer?.cancel();
    reviewSamples.clear();
    reviewResult = null;
    metrics.reset();
    final clock = Stopwatch()..start();
    reviewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      reviewSamples.add({
        'wallSeconds': clock.elapsedMicroseconds / 1e6,
        ...transport.snapshot(),
      });
      if (clock.elapsedMilliseconds >= 60000) {
        timer.cancel();
        metrics.collect();
        reviewResult = {...snapshot(), 'samples': List.of(reviewSamples)};
        if (mounted) setState(() {});
      }
    });
  }

  final navigatorKey = GlobalKey<NavigatorState>();
  TabScore? connected;
  int _loadEpoch = 0, _selectorEpoch = 0;
  String? _loadedDefaults;
  String get _passageSettings =>
      '${transport.start}|${transport.end}|${transport.tempo}|${transport.looping}';
  bool dark = true, loading = false;
  String? problem;
  @override
  void initState() {
    super.initState();
    ticker = createTicker((_) {
      metrics.frame();
      transport.tick();
    })..start();
    SchedulerBinding.instance.addTimingsCallback(metrics.timings);
    library.addListener(refreshLibrary);
    backend.restore();
    if (const bool.fromEnvironment('ROLLINGTAB_EVIDENCE') ||
        const int.fromEnvironment('ROLLINGTAB_CONTROL_PORT') > 0) {
      registerEvidence(snapshot, command, capture);
    }
  }

  Future<Uint8List> capture() async {
    await WidgetsBinding.instance.endOfFrame;
    final b =
        captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await b.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  Map<String, dynamic> snapshot() => {
    'transport': transport.snapshot(),
    'voicing': VoicingStudy(transport.fixture)
        .at(transport.time, options.preparationBeats)
        .toJson(),
    'receipt': backend.receipt,
    'savedPassage': library.selected?.toJson(),
    'unsaved': library.canSave && library.dirty,
    'signedIn': backend.signedIn,
    'problem': problem,
    'loading': loading,
    'sceneStatus': options.engineStatus,
    'pooledNodes': options.pooledNodes,
    'visibleNodes': options.visibleNodes,
    'leftHanded': options.leftHanded,
    'audioBackend': audioBackend,
    'mixCapture': (transport.audio as ContinuousAudio).captureResult,
    'metrics': metrics.snapshot(),
    'buildMode': kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug',
    'scoreNotes': transport.fixture.notes.length,
    'diagnostics': transport.fixture.provenance['diagnostics'],
    'viewport': {
      'width':
          View.of(context).physicalSize.width /
          View.of(context).devicePixelRatio,
      'height':
          View.of(context).physicalSize.height /
          View.of(context).devicePixelRatio,
    },
  };
  Future<void> command(Map<String, dynamic> data) async {
    switch (data['action']) {
      case 'login':
        await backend.login(data['email'], data['password']);
      case 'loadScore':
        await loadConnected(cid: data['cid']);
      case 'signOut':
        await backend.signOut();
        library.clearSelection();
      case 'savePassage':
        await library.save(data['name'], asNew: data['asNew'] == true);
      case 'openPassage':
        final items = await backend.passages();
        await openSaved(items.firstWhere((p) => p.passageId == data['id']));
      case 'deletePassage':
        final items = await backend.passages();
        await library.remove(
          items.firstWhere((p) => p.passageId == data['id']),
        );
      case 'fixture':
        await choose(widget.studies.firstWhere((s) => s.id == data['id']));
      case 'prepare':
        await transport.prepare();
      case 'play':
        if (!transport.playing) await transport.toggle();
      case 'pause':
        await transport.pause();
      case 'seek':
        await transport.seek((data['time'] as num).toDouble());
      case 'tempo':
        await transport.setTempo((data['value'] as num).toDouble());
      case 'passage':
        await transport.setPassage(
          (data['start'] as num).toDouble(),
          (data['end'] as num).toDouble(),
        );
      case 'loop':
        transport.setLoop(data['value']);
      case 'overlay':
        options.voicingOverlay = data['value'];
      case 'leftHanded':
        options.leftHanded = data['value'];
      case 'reducedMotion':
        options.reducedMotion = data['value'];
      case 'effects':
        options.effects = data['value'];
      case 'theme':
        dark = data['value'] == 'dark';
      case 'feedback':
        await transport.setFeedback(FeedbackMode.values.byName(data['value']));
      case 'cancel':
        transport.cancel();
      case 'resetMetrics':
        metrics.reset();
      case 'collectMetrics':
        metrics.collect();
      case 'stall':
        metrics.injectStall();
        final watch = Stopwatch()..start();
        while (watch.elapsedMilliseconds < 150) {}
        transport.tick();
      case 'captureAudioStart':
        (transport.audio as ContinuousAudio).startCapture();
      case 'captureAudioStop':
        final output = transport.audio as ContinuousAudio;
        await output.stopCapture();
        if (const int.fromEnvironment('ROLLINGTAB_CONTROL_PORT') > 0) {
          await saveEvidence(
            'rollingtab-mix.pcm',
            output.capturedPcm!,
            'application/octet-stream',
          );
        }
      default:
        throw ArgumentError('Unknown RollingTAB evidence command');
    }
    options.update();
    if (mounted) setState(() {});
  }

  Future<void> choose(TabScore score) async {
    _loadEpoch++;
    loading = false;
    backend.cancelScoreLoad();
    _loadedDefaults = null;
    library.clearSelection();
    problem = null;
    await transport.setFixture(score, passageEnd: score.duration.clamp(0, 60));
    options.maxFret = math.max(
      5,
      score.notes.fold<int>(0, (v, n) => math.max(v, n.fret)),
    );
    options.selection = {};
    options.update();
    if (mounted) setState(() {});
  }

  Future<bool> confirmDiscard() async {
    final edited =
        library.canSave &&
        (library.selected != null
            ? library.dirty
            : _loadedDefaults != null && _loadedDefaults != _passageSettings);
    if (!edited) return true;
    return await showDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (c) => AlertDialog(
            title: const Text('Discard unsaved passage edits?'),
            content: const Text(
              'Switching repertoire will replace the current passage settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Keep practicing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Discard edits'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> switchStudy(String id) async {
    if (await confirmDiscard()) {
      await choose(widget.studies.firstWhere((s) => s.id == id));
    }
    if (mounted) setState(() {});
  }

  Future<void> repertoireDialog() async {
    final future = backend.catalog();
    final selected = await showDialog<CatalogScore>(
      context: navigatorKey.currentContext!,
      builder: (c) => AlertDialog(
        title: const Text('Server repertoire'),
        content: SizedBox(
          width: 560,
          child: FutureBuilder<List<CatalogScore>>(
            future: future,
            builder: (context, state) {
              if (state.hasError) {
                return Text('Repertoire unavailable: ${state.error}');
              }
              if (!state.hasData) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return SizedBox(
                height: 400,
                child: ListView(
                  children: [
                    for (final item in state.data!)
                      ListTile(
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.composer}\n${item.practiceFocus ?? "Guitar practice"} · ${item.guidanceDescription ?? "Inferred guidance"}',
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.pop(c, item),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (selected != null && mounted && await confirmDiscard()) {
      await loadConnected(cid: selected.cid);
    }
  }

  Future<void> loadConnected({String? cid}) async {
    final token = ++_loadEpoch;
    setState(() {
      loading = true;
      problem = null;
    });
    transport.cancel();
    try {
      final score = await backend.loadScore(cid: cid);
      if (token != _loadEpoch || !mounted) return;
      final descriptor = backend.artifact!;
      final start = (descriptor.recommendedStart ?? 0)
          .clamp(0.0, math.max(0.0, score.duration - .1))
          .toDouble();
      final end = (descriptor.recommendedEnd ?? start + 30)
          .clamp(start + .1, math.min(score.duration, start + 60))
          .toDouble();
      await transport.setFixture(score, passageStart: start, passageEnd: end);
      await transport.setTempo(1);
      transport.setLoop(true);
      connected = score;
      library.clearSelection();
      _loadedDefaults = _passageSettings;
      options.maxFret = math.max(
        5,
        score.notes.fold<int>(0, (v, n) => math.max(v, n.fret)),
      );
      options.selection = {};
      options.update();
    } catch (e) {
      if (token == _loadEpoch) problem = e.toString();
    } finally {
      if (mounted && token == _loadEpoch) setState(() => loading = false);
    }
  }

  Future<void> connectDialog(BuildContext context) async {
    await showDialog<void>(context: context, barrierDismissible: false,
      builder: (_) => AuthDialog(backend: backend));
    if (mounted) setState(() {});
  }

  void refreshLibrary() {
    if (mounted) setState(() {});
  }

  Future<void> openSaved(SavedPassage p) async {
    transport.cancel();
    final request = ++_loadEpoch;
    final epoch = backend.accountEpoch;
    final score = await backend.loadScore(cid: p.cid);
    if (epoch != backend.accountEpoch) {
      throw const BackendFailure('Account changed.');
    }
    if (backend.artifact!.artifactVersion != p.artifactVersion ||
        backend.artifact!.sourceSlot != p.sourceSlot) {
      throw const BackendFailure(
        'Saved passage references an unavailable score version.',
      );
    }
    if (request != _loadEpoch) return;
    await choose(score);
    connected = score;
    await transport.setPassage(p.start, p.end);
    transport.setLoop(p.loop);
    await transport.setTempo(p.tempo);
    if (!transport.ready) await transport.prepare();
    await transport.pause();
    await transport.seek(p.start);
    if (epoch != backend.accountEpoch) {
      throw const BackendFailure('Account changed.');
    }
    library.select(p);
    _loadedDefaults = _passageSettings;
  }

  Future<void> saveDialog(BuildContext context) async {
    if (!backend.signedIn) await connectDialog(context);
    if (!context.mounted || !backend.signedIn || !library.canSave) return;
    final name = TextEditingController(
      text:
          library.selected?.name ??
          '${backend.artifact?.title ?? 'Guitar'} passage',
    );
    bool working = false;
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, update) {
          Future<void> save(bool asNew) async {
            update(() {
              working = true;
              error = null;
            });
            try {
              await library.save(name.text, asNew: asNew);
              if (dialog.mounted) Navigator.pop(dialog);
            } catch (e) {
              if (dialog.mounted) {
                update(() {
                  working = false;
                  error = e.toString();
                });
              }
            }
          }

          return AlertDialog(
            title: const Text('Save passage'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    autofocus: true,
                    maxLength: 80,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  Text(
                    '${transport.start.toStringAsFixed(2)}–${transport.end.toStringAsFixed(2)} seconds · ${(transport.tempo * 100).round()}%',
                  ),
                  if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (working) const LinearProgressIndicator(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: working ? null : () => Navigator.pop(dialog),
                child: const Text('Cancel'),
              ),
              if (library.selected != null)
                TextButton(
                  onPressed: working ? null : () => save(true),
                  child: const Text('Save as new'),
                ),
              FilledButton(
                onPressed: working ? null : () => save(false),
                child: Text(error == null ? 'Save' : 'Retry save'),
              ),
            ],
          );
        },
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), name.dispose);
  }

  Future<void> passagesDialog(BuildContext context) async {
    if (!backend.signedIn) await connectDialog(context);
    if (!context.mounted || !backend.signedIn) return;
    final epoch = backend.accountEpoch;
    var items = <SavedPassage>[];
    String? error;
    try {
      items = await backend.passages();
    } catch (e) {
      error = e.toString();
    }
    if (!context.mounted || epoch != backend.accountEpoch) return;
    bool working = false;
    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('My passages'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (working) const LinearProgressIndicator(),
                  if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (items.isEmpty && error == null)
                    const Text(
                      'Save a passage from server repertoire to return to it here.',
                    ),
                  for (final p in items)
                    ListTile(
                      title: Text(p.name),
                      subtitle: Text(
                        '${p.start.toStringAsFixed(2)}–${p.end.toStringAsFixed(2)} s · ${(p.tempo * 100).round()}%',
                      ),
                      onTap: working
                          ? null
                          : () async {
                              update(() {
                                working = true;
                                error = null;
                              });
                              try {
                                if (!await confirmDiscard()) {
                                  update(() => working = false);
                                  return;
                                }
                                await openSaved(p);
                                if (dialog.mounted) Navigator.pop(dialog);
                              } catch (e) {
                                if (dialog.mounted) {
                                  update(() {
                                    working = false;
                                    error = e.toString();
                                  });
                                }
                              }
                            },
                      trailing: IconButton(
                        tooltip: 'Delete ${p.name}',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: working
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (d) => AlertDialog(
                                    title: Text('Delete “${p.name}”?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(d, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(d, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed != true || !dialog.mounted) {
                                  return;
                                }
                                update(() {
                                  working = true;
                                  error = null;
                                });
                                try {
                                  await library.remove(p);
                                  items = await backend.passages();
                                } catch (e) {
                                  error = e.toString();
                                }
                                if (dialog.mounted) {
                                  update(() => working = false);
                                }
                              },
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: working ? null : () => Navigator.pop(dialog),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> passageDialog(BuildContext context) async {
    final a = TextEditingController(text: transport.start.toStringAsFixed(3)),
        b = TextEditingController(text: transport.end.toStringAsFixed(3));
    String? error;
    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Choose a passage'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Up to 60 seconds · score ends at ${transport.fixture.duration.toStringAsFixed(1)} s',
                ),
                TextField(
                  controller: a,
                  decoration: const InputDecoration(
                    labelText: 'Start · score seconds',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: b,
                  decoration: const InputDecoration(
                    labelText: 'End · score seconds',
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (error != null) Text(error!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await transport.setPassage(
                    double.parse(a.text),
                    double.parse(b.text),
                  );
                  if (dialog.mounted) Navigator.pop(dialog);
                } catch (_) {
                  update(
                    () => error =
                        'Choose valid bounds, no more than 60 seconds apart.',
                  );
                }
              },
              child: const Text('Use passage'),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      a.dispose();
      b.dispose();
    });
  }

  ThemeData theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff278e91),
      brightness: brightness,
    ),
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xff0c1720)
        : const Color(0xfff4f6f5),
    fontFamily: 'Helvetica',
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    title: 'RollingTAB',
    debugShowCheckedModeBanner: false,
    theme: theme(Brightness.light),
    darkTheme: theme(Brightness.dark),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Builder(
      builder: (context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.space): () {
            if (FocusManager.instance.primaryFocus?.context?.widget
                is! EditableText) {
              transport.toggle();
            }
          },
        },
        child: Focus(
          autofocus: true,
          child: AnimatedBuilder(
            animation: Listenable.merge([transport, options, backend, library]),
            builder: (context, _) => Scaffold(
              appBar: AppBar(
                title: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rolling',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: 'TAB',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: dark ? 'Light appearance' : 'Dark appearance',
                    onPressed: () => setState(() => dark = !dark),
                    icon: Icon(
                      dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Practice settings',
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.tune),
                    ),
                  ),
                ],
              ),
              endDrawer: settings(context),
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 700;
                    final content = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            compact ? 12 : 24,
                            8,
                            compact ? 12 : 24,
                            10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      key: ValueKey(
                                        '${transport.fixture.id}:$_selectorEpoch',
                                      ),
                                      initialValue:
                                          transport
                                                  .fixture
                                                  .provenance['connected'] ==
                                              true
                                          ? 'server-repertoire'
                                          : transport.fixture.id,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Studies & server repertoire',
                                      ),
                                      isExpanded: true,
                                      items: [
                                        const DropdownMenuItem(
                                          value: 'server-repertoire',
                                          child: Text(
                                            'Choose server repertoire…',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        for (final s in widget.studies)
                                          DropdownMenuItem(
                                            value: s.id,
                                            child: Text(
                                              s.title.replaceFirst(
                                                'Guitar • ',
                                                '',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                      onChanged: loading
                                          ? null
                                          : (id) async {
                                              if (id == 'server-repertoire') {
                                                await repertoireDialog();
                                              } else {
                                                await switchStudy(id!);
                                              }
                                              if (mounted) {
                                                setState(
                                                  () => _selectorEpoch++,
                                                );
                                              }
                                            },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filledTonal(
                                    tooltip: 'Choose server repertoire',
                                    onPressed: loading
                                        ? null
                                        : repertoireDialog,
                                    icon: loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            backend.signedIn
                                                ? Icons.cloud_done_outlined
                                                : Icons.cloud_download_outlined,
                                          ),
                                  ),
                                ],
                              ),
                              if (transport.fixture.provenance['connected'] ==
                                      true &&
                                  backend.artifact != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${backend.artifact!.title} · ${backend.artifact!.guidanceDescription ?? "Inferred guidance"}\n${backend.artifact!.practiceFocus ?? "Guitar practice"}',
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 7),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  TextButton.icon(
                                    onPressed: library.canSave
                                        ? () => saveDialog(context)
                                        : null,
                                    icon: const Icon(
                                      Icons.bookmark_add_outlined,
                                    ),
                                    label: const Text('Save passage'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => passagesDialog(context),
                                    icon: const Icon(Icons.bookmarks_outlined),
                                    label: const Text('My passages'),
                                  ),
                                  if (library.canSave)
                                    Text(
                                      library.selected == null
                                          ? 'Not saved'
                                          : '${library.selected!.name} · ${library.dirty ? 'Unsaved changes' : 'Saved'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                ],
                              ),
                              Text(
                                transport.fixture.provenance['connected'] ==
                                        true
                                    ? 'Serverpod score · ${transport.fixture.notes.length} notes · ${backend.artifact?.guidanceDescription ?? 'Inferred guidance'}'
                                    : 'Authored study · hear the timing, prepare the shape',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              if (problem != null)
                                Text(
                                  problem!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (compact)
                          SizedBox(height: 480, child: stage())
                        else
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: stage(),
                            ),
                          ),
                        playback(context, compact),
                      ],
                    );
                    return compact
                        ? SingleChildScrollView(child: content)
                        : content;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget stage() => RepaintBoundary(
    key: captureKey,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Expanded(
            child: GuitarSurface(state: transport, options: options),
          ),
          VoicingPanel(transport: transport, options: options),
        ],
      ),
    ),
  );
  Widget playback(BuildContext context, bool compact) => Padding(
    padding: EdgeInsets.fromLTRB(compact ? 12 : 24, 10, compact ? 12 : 24, 12),
    child: Column(
      children: [
        if (transport.busy) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Initializing audio · ${(transport.progress * 100).round()}%',
                ),
              ),
              TextButton(
                onPressed: transport.cancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
          Semantics(
            container: true,
            label: 'Audio initialization',
            child: LinearProgressIndicator(value: transport.progress),
          ),
        ],
        if (transport.error != null)
          Text(
            transport.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        Row(
          children: [
            IconButton.filled(
              tooltip: transport.playing ? 'Pause' : 'Play',
              onPressed: transport.busy ? null : transport.toggle,
              icon: Icon(transport.playing ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${transport.time.toStringAsFixed(1)} / ${transport.end.toStringAsFixed(1)} s',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            IconButton(
              tooltip: transport.looping ? 'Disable loop' : 'Enable loop',
              isSelected: transport.looping,
              onPressed: () => transport.setLoop(!transport.looping),
              icon: const Icon(Icons.repeat),
            ),
            IconButton(
              tooltip: 'Choose passage',
              onPressed: () => passageDialog(context),
              icon: const Icon(Icons.crop),
            ),
          ],
        ),
        SpeedControl(speed: transport.tempo, onChanged: transport.setTempo),
        sliderWithLocalOverlay(
          Slider(
            value: transport.time.clamp(transport.start, transport.end),
            min: transport.start,
            max: transport.end,
            onChanged: transport.seek,
            semanticFormatterCallback: (v) =>
                '${v.toStringAsFixed(1)} score seconds',
          ),
        ),
      ],
    ),
  );
  Widget settings(BuildContext context) => Drawer(
    width: 330,
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Practice settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Now + next')),
              ButtonSegment(value: true, label: Text('Overlay')),
            ],
            selected: {options.voicingOverlay},
            onSelectionChanged: (s) {
              options.voicingOverlay = s.first;
              options.update();
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Left-handed view'),
            subtitle: const Text(
              'Reverse the perspective and mirror the fretboards. '
              'Playback direction stays the same.',
            ),
            value: options.leftHanded,
            onChanged: (value) {
              options.leftHanded = value;
              options.update();
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Prepare · ${options.preparationBeats.toStringAsFixed(1)} beats',
          ),
          sliderWithLocalOverlay(
            Slider(
              value: options.preparationBeats,
              min: .5,
              max: 4,
              divisions: 7,
              onChanged: (v) {
                options.preparationBeats = v;
                options.update();
              },
            ),
          ),
          Text('Look ahead · ${options.lookAhead.toStringAsFixed(1)} s'),
          sliderWithLocalOverlay(
            Slider(
              value: options.lookAhead,
              min: 2,
              max: 8,
              onChanged: (v) {
                options.lookAhead = v;
                options.update();
              },
            ),
          ),
          const Text('Perspective depth'),
          sliderWithLocalOverlay(
            Slider(
              value: options.depth,
              min: 0,
              max: 1,
              onChanged: (v) {
                options.depth = v;
                options.update();
              },
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Depth effects'),
            value: options.effects,
            onChanged: (v) {
              options.effects = v;
              options.update();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduced motion'),
            value: options.reducedMotion,
            onChanged: (v) {
              options.reducedMotion = v;
              options.update();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fade lift / press cues'),
            value: options.voicingFades,
            onChanged: (v) {
              options.voicingFades = v;
              options.update();
            },
          ),
          if (transport.fixture.provenance['connected'] != true) ...[
            const Divider(),
            DropdownButtonFormField<FeedbackMode>(
              initialValue: transport.feedback,
              decoration: const InputDecoration(labelText: 'Scripted feedback'),
              items: [
                for (final m in FeedbackMode.values)
                  DropdownMenuItem(
                    value: m,
                    child: Text(switch (m) {
                      FeedbackMode.off => 'Off · score audio',
                      FeedbackMode.correct => 'Simulated correct',
                      FeedbackMode.imperfect => 'Simulated imperfect',
                    }),
                  ),
              ],
              onChanged: (v) => transport.setFeedback(v!),
            ),
          ],
          const Divider(),
          const Text(
            'Solid: sounding / keep\nOutline: prepare\nAmber ×: lift / damp\nNew fill: a new attack',
          ),
          const SizedBox(height: 16),
          if (backend.signedIn)
            TextButton.icon(
              onPressed: () async {
                try {
                  await backend.signOut();
                  library.clearSelection();
                } catch (e) {
                  setState(() => problem = e.toString());
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out of RollingTAB'),
            ),
          if (transport.fixture.provenance['diagnostics']
              case final List diagnostics)
            Text(
              '${diagnostics.length} position diagnostics. ${diagnostics.take(5).join(' ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 20),
          if (const bool.fromEnvironment('ROLLINGTAB_EVIDENCE') ||
              const int.fromEnvironment('ROLLINGTAB_CONTROL_PORT') > 0) ...[
            const Divider(),
            const Text('Review tools'),
            TextButton(
              onPressed: () {
                startReview();
                Navigator.pop(context);
              },
              child: const Text('Start 60-second review'),
            ),
            TextButton(
              onPressed: () async {
                await command({'action': 'stall'});
              },
              child: const Text('Inject 150 ms stall'),
            ),
            TextButton(
              onPressed: () async {
                await saveEvidence(
                  'rollingtab-measurement.json',
                  Uint8List.fromList(
                    utf8.encode(jsonEncode(reviewResult ?? snapshot())),
                  ),
                  'application/json',
                );
              },
              child: Text(
                reviewResult == null
                    ? 'Export current measurement'
                    : 'Export completed review',
              ),
            ),
            TextButton(
              onPressed: () async {
                await saveEvidence(
                  'rollingtab-still.png',
                  await capture(),
                  'image/png',
                );
              },
              child: const Text('Save review still'),
            ),
          ],
          const Text(
            'RollingTAB · standalone POC',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    reviewTimer?.cancel();
    ticker.dispose();
    SchedulerBinding.instance.removeTimingsCallback(metrics.timings);
    transport.dispose();
    library.removeListener(refreshLibrary);
    library.dispose();
    backend.dispose();
    options.dispose();
    super.dispose();
  }
}
