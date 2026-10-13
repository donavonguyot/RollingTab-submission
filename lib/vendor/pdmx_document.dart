// PDMX document decoder adapted from the Music Surface Lab snapshot.
// See THIRD_PARTY.md for provenance and attribution.
library;

import 'dart:math' as math;

class PdmxDecodeException implements Exception {
  final String message;
  final String path;
  PdmxDecodeException(this.message, this.path);
  @override
  String toString() => 'PdmxDecodeException at $path: $message';
}

const Set<String> documentFieldPaths = {
  ...notationTruthDocumentFieldPaths,
  'absolute_time',
  'annotations[*].__class__.__name__',
  'annotations[*].annotation.Articulation.name',
  'annotations[*].annotation.Articulation.subtype',
  'annotations[*].annotation.Dynamic.name',
  'annotations[*].annotation.Dynamic.subtype',
  'annotations[*].annotation.Dynamic.velocity',
  'annotations[*].annotation.HairPinSpanner.duration',
  'annotations[*].annotation.HairPinSpanner.name',
  'annotations[*].annotation.HairPinSpanner.subtype',
  'annotations[*].annotation.Ornament.name',
  'annotations[*].annotation.Ornament.subtype',
  'annotations[*].annotation.SlurSpanner.duration',
  'annotations[*].annotation.SlurSpanner.is_slur',
  'annotations[*].annotation.SlurSpanner.name',
  'annotations[*].annotation.SlurSpanner.subtype',
  'annotations[*].annotation.TrillSpanner.duration',
  'annotations[*].annotation.TrillSpanner.name',
  'annotations[*].annotation.TrillSpanner.subtype',
  'annotations[*].annotation.opaque',
  'annotations[*].group',
  'annotations[*].measure',
  'annotations[*].time',
  'barlines[*].__class__.__name__',
  'barlines[*].measure',
  'barlines[*].subtype',
  'barlines[*].time',
  'beats[*].__class__.__name__',
  'beats[*].is_downbeat',
  'beats[*].measure',
  'beats[*].time',
  'infer_velocity',
  'key_signatures[*].__class__.__name__',
  'key_signatures[*].fifths',
  'key_signatures[*].measure',
  'key_signatures[*].mode',
  'key_signatures[*].root',
  'key_signatures[*].root_str',
  'key_signatures[*].time',
  'lyrics[*]',
  'page_breaks[*].measure',
  'system_breaks[*].measure',
  'metadata.__class__.__name__',
  'metadata.collection',
  'metadata.copyright',
  'metadata.creators',
  'metadata.schema_version',
  'metadata.source_filename',
  'metadata.source_format',
  'metadata.subtitle',
  'metadata.subtitle_language',
  'metadata.title',
  'metadata.title_language',
  'resolution',
  'song_length',
  'tempos[*].__class__.__name__',
  'tempos[*].measure',
  'tempos[*].qpm',
  'tempos[*].text',
  'tempos[*].time',
  'time_signatures[*].__class__.__name__',
  'time_signatures[*].denominator',
  'time_signatures[*].measure',
  'time_signatures[*].numerator',
  'time_signatures[*].time',
  'tracks[*].__class__.__name__',
  'tracks[*].name_language',
  'tracks[*].annotations[*].__class__.__name__',
  'tracks[*].annotations[*].annotation.Articulation.name',
  'tracks[*].annotations[*].annotation.Articulation.subtype',
  'tracks[*].annotations[*].annotation.Dynamic.name',
  'tracks[*].annotations[*].annotation.Dynamic.subtype',
  'tracks[*].annotations[*].annotation.Dynamic.velocity',
  'tracks[*].annotations[*].annotation.HairPinSpanner.duration',
  'tracks[*].annotations[*].annotation.HairPinSpanner.name',
  'tracks[*].annotations[*].annotation.HairPinSpanner.subtype',
  'tracks[*].annotations[*].annotation.Ornament.name',
  'tracks[*].annotations[*].annotation.Ornament.subtype',
  'tracks[*].annotations[*].annotation.SlurSpanner.duration',
  'tracks[*].annotations[*].annotation.SlurSpanner.is_slur',
  'tracks[*].annotations[*].annotation.SlurSpanner.name',
  'tracks[*].annotations[*].annotation.SlurSpanner.subtype',
  'tracks[*].annotations[*].annotation.TrillSpanner.duration',
  'tracks[*].annotations[*].annotation.TrillSpanner.name',
  'tracks[*].annotations[*].annotation.TrillSpanner.subtype',
  'tracks[*].annotations[*].annotation.opaque',
  'tracks[*].annotations[*].group',
  'tracks[*].annotations[*].measure',
  'tracks[*].annotations[*].time',
  'tracks[*].chords[*]',
  'tracks[*].is_drum',
  'tracks[*].lyrics[*]',
  'tracks[*].name',
  'tracks[*].notes[*].__class__.__name__',
  'tracks[*].notes[*].accidental_display',
  'tracks[*].notes[*].beam_state',
  'tracks[*].notes[*].beam_states[*].number',
  'tracks[*].notes[*].beam_states[*].state',
  'tracks[*].notes[*].duration',
  'tracks[*].notes[*].fingering',
  'tracks[*].notes[*].fret',
  'tracks[*].notes[*].is_grace',
  'tracks[*].notes[*].measure',
  'tracks[*].notes[*].pitch',
  'tracks[*].notes[*].pitch_str',
  'tracks[*].notes[*].practice_marks[*].kind',
  'tracks[*].notes[*].practice_marks[*].value',
  'tracks[*].notes[*].practice_marks[*].voice',
  'tracks[*].notes[*].stem_direction',
  'tracks[*].notes[*].string',
  'tracks[*].notes[*].time',
  'tracks[*].notes[*].velocity',
  'tracks[*].program',
};

const Set<String> notationTruthDocumentFieldPaths = {
  'authored_structure.version',
  'authored_structure.source_measures[*].source_id',
  'authored_structure.source_measures[*].source_measure',
  'authored_structure.source_measures[*].ordinal',
  'authored_structure.source_measures[*].display_number',
  'authored_structure.source_measures[*].duration',
  'authored_structure.signatures[*].source_id',
  'authored_structure.signatures[*].kind',
  'authored_structure.signatures[*].source_measure_id',
  'authored_structure.signatures[*].source_measure',
  'authored_structure.signatures[*].offset',
  'authored_structure.signatures[*].staff',
  'authored_structure.signatures[*].sign',
  'authored_structure.signatures[*].line',
  'authored_structure.signatures[*].octave_change',
  'authored_structure.signatures[*].fifths',
  'authored_structure.signatures[*].numerator',
  'authored_structure.signatures[*].denominator',
  'authored_structure.repeat_barlines[*].source_id',
  'authored_structure.repeat_barlines[*].repeat_id',
  'authored_structure.repeat_barlines[*].source_measure_id',
  'authored_structure.repeat_barlines[*].source_measure',
  'authored_structure.repeat_barlines[*].location',
  'authored_structure.repeat_barlines[*].direction',
  'authored_structure.repeat_barlines[*].times',
  'authored_structure.repeat_barlines[*].style',
  'authored_structure.ending_spans[*].source_id',
  'authored_structure.ending_spans[*].numbers',
  'authored_structure.ending_spans[*].start_source_measure',
  'authored_structure.ending_spans[*].end_source_measure',
  'authored_structure.ending_spans[*].closure',
  'authored_structure.diagnostics[*].code',
  'authored_structure.diagnostics[*].severity',
  'authored_structure.diagnostics[*].source_measure',
  'authored_structure.diagnostics[*].detail',
  'measure_instances[*].ending',
  'measure_instances[*].occurrence',
  'measure_instances[*].playback_measure',
  'measure_instances[*].source_measure',
  'measure_instances[*].time',
  'tracks[*].staff_count',
  'tracks[*].clefs[*].line',
  'tracks[*].clefs[*].authored_source_id',
  'tracks[*].clefs[*].occurrence',
  'tracks[*].clefs[*].octave_change',
  'tracks[*].clefs[*].playback_measure',
  'tracks[*].clefs[*].sign',
  'tracks[*].clefs[*].source_id',
  'tracks[*].clefs[*].source_measure',
  'tracks[*].clefs[*].staff',
  'tracks[*].clefs[*].time',
  'tracks[*].clefs[*].source_offset',
  'tracks[*].notation_events[*].accidental_display',
  'tracks[*].notation_events[*].authored_source_id',
  'tracks[*].notation_events[*].beam_state',
  'tracks[*].notation_events[*].beam_states[*].number',
  'tracks[*].notation_events[*].beam_states[*].state',
  'tracks[*].notation_events[*].display_pitch',
  'tracks[*].notation_events[*].dots',
  'tracks[*].notation_events[*].duration',
  'tracks[*].notation_events[*].full_measure',
  'tracks[*].notation_events[*].authored_grace_anchor_id',
  'tracks[*].notation_events[*].authored_grace_group_id',
  'tracks[*].notation_events[*].grace_anchor_id',
  'tracks[*].notation_events[*].grace_group_id',
  'tracks[*].notation_events[*].grace_order',
  'tracks[*].notation_events[*].grace_placement',
  'tracks[*].notation_events[*].grace_slash',
  'tracks[*].notation_events[*].is_grace',
  'tracks[*].notation_events[*].kind',
  'tracks[*].notation_events[*].occurrence',
  'tracks[*].notation_events[*].pitch',
  'tracks[*].notation_events[*].pitch_str',
  'tracks[*].notation_events[*].playback_measure',
  'tracks[*].notation_events[*].playback_note_ref',
  'tracks[*].notation_events[*].source_id',
  'tracks[*].notation_events[*].source_offset',
  'tracks[*].notation_events[*].source_measure',
  'tracks[*].notation_events[*].staff',
  'tracks[*].notation_events[*].stem_direction',
  'tracks[*].notation_events[*].time',
  'tracks[*].notation_events[*].tuplet.actual',
  'tracks[*].notation_events[*].tuplet.normal',
  'tracks[*].notation_events[*].voice',
  'tracks[*].notation_events[*].written_type',
  'tracks[*].notation_annotations[*].duration',
  'tracks[*].notation_annotations[*].authored_source_id',
  'tracks[*].notation_annotations[*].authored_start_anchor_id',
  'tracks[*].notation_annotations[*].authored_end_anchor_id',
  'tracks[*].notation_annotations[*].authored_spanner_id',
  'tracks[*].notation_annotations[*].authored_end_source_measure',
  'tracks[*].notation_annotations[*].authored_end_offset',
  'tracks[*].notation_annotations[*].authored_end_source_id',
  'tracks[*].notation_annotations[*].end_anchor_id',
  'tracks[*].notation_annotations[*].end_occurrence',
  'tracks[*].notation_annotations[*].end_playback_measure',
  'tracks[*].notation_annotations[*].end_source_id',
  'tracks[*].notation_annotations[*].kind',
  'tracks[*].notation_annotations[*].anchor_role',
  'tracks[*].notation_annotations[*].orientation',
  'tracks[*].notation_annotations[*].octave_shift_size',
  'tracks[*].notation_annotations[*].pedal_abbreviated',
  'tracks[*].notation_annotations[*].pedal_line',
  'tracks[*].notation_annotations[*].pedal_sign',
  'tracks[*].notation_annotations[*].placement',
  'tracks[*].notation_annotations[*].playback_measure',
  'tracks[*].notation_annotations[*].source_measure',
  'tracks[*].notation_annotations[*].occurrence',
  'tracks[*].notation_annotations[*].source_id',
  'tracks[*].notation_annotations[*].source_offset',
  'tracks[*].notation_annotations[*].spanner_id',
  'tracks[*].notation_annotations[*].spanner_number',
  'tracks[*].notation_annotations[*].staff',
  'tracks[*].notation_annotations[*].start_anchor_id',
  'tracks[*].notation_annotations[*].subtype',
  'tracks[*].notation_annotations[*].text',
  'tracks[*].notation_annotations[*].language',
  'tracks[*].notation_annotations[*].time',
  'tracks[*].notation_annotations[*].value',
  'tracks[*].notation_annotations[*].alternate',
  'tracks[*].notation_annotations[*].substitution',
  'tracks[*].notation_annotations[*].print_object',
  'tracks[*].notation_annotations[*].authored_color',
  'tracks[*].notation_annotations[*].authored_style',
  'tracks[*].notation_annotations[*].technical_subtype',
  'tracks[*].notation_annotations[*].technical_attributes',
  'tracks[*].notation_annotations[*].unsupported',
};

const Set<String> _topLevelKeys = {
  'absolute_time',
  'annotations',
  'authored_structure',
  'barlines',
  'beats',
  'infer_velocity',
  'key_signatures',
  'lyrics',
  'metadata',
  'measure_instances',
  'page_breaks',
  'resolution',
  'song_length',
  'system_breaks',
  'tempos',
  'time_signatures',
  'tracks',
};

// PDMX 0.2 stamps every typed object with a `__class__.__name__` field
// carrying the upstream Python class tag (e.g. `"Tempo"`, `"Note"`). The
// value is constant per object type and carries no information beyond the
// section it lives in, so the decoder allows the key but does not store it
// — `toJson()` re-emits a literal per type to keep the round-trip property.
//
// Track is the only typed class with a real `name` field (the human-readable
// part name like "Piano"); every other typed class has only the synthetic
// class tag.
const Set<String> _metadataKeys = {
  '__class__.__name__',
  'collection',
  'copyright',
  'creators',
  'schema_version',
  'source_filename',
  'source_format',
  'subtitle',
  'subtitle_language',
  'title',
  'title_language',
};

const Set<String> _tempoKeys = {
  '__class__.__name__',
  'measure',
  'qpm',
  'text',
  'time',
};

const Set<String> _keySigKeys = {
  '__class__.__name__',
  'fifths',
  'measure',
  'mode',
  'root',
  'root_str',
  'time',
};

const Set<String> _timeSigKeys = {
  '__class__.__name__',
  'denominator',
  'measure',
  'numerator',
  'time',
};

const Set<String> _beatKeys = {
  '__class__.__name__',
  'is_downbeat',
  'measure',
  'time',
};

const Set<String> _barlineKeys = {
  '__class__.__name__',
  'measure',
  'subtype',
  'time',
};

const Set<String> _annotationKeys = {
  '__class__.__name__',
  'annotation',
  'group',
  'measure',
  'time',
};

const Set<String> _trackKeys = {
  '__class__.__name__',
  'annotations',
  'chords',
  'clefs',
  'is_drum',
  'lyrics',
  'name',
  'name_language',
  'notes',
  'notation_events',
  'notation_annotations',
  'program',
  'staff_count',
};

const Set<String> _measureInstanceKeys = {
  'ending',
  'occurrence',
  'playback_measure',
  'source_measure',
  'time',
};

const Set<String> _authoredStructureKeys = {
  'version',
  'source_measures',
  'signatures',
  'repeat_barlines',
  'ending_spans',
  'diagnostics',
};

const Set<String> _authoredMeasureKeys = {
  'source_id',
  'source_measure',
  'ordinal',
  'display_number',
  'duration',
};

const Set<String> _authoredSignatureKeys = {
  'source_id',
  'kind',
  'language',
  'source_measure_id',
  'source_measure',
  'offset',
  'staff',
  'sign',
  'line',
  'octave_change',
  'fifths',
  'numerator',
  'denominator',
};

const Set<String> _repeatBarlineKeys = {
  'source_id',
  'repeat_id',
  'source_measure_id',
  'source_measure',
  'location',
  'direction',
  'times',
  'style',
};

const Set<String> _endingSpanKeys = {
  'source_id',
  'numbers',
  'start_source_measure',
  'end_source_measure',
  'closure',
};

const Set<String> _authoredDiagnosticKeys = {
  'code',
  'severity',
  'source_measure',
  'detail',
};

const Set<String> _clefKeys = {
  'authored_source_id',
  'line',
  'occurrence',
  'octave_change',
  'playback_measure',
  'sign',
  'source_id',
  'source_measure',
  'source_offset',
  'staff',
  'time',
};

const Set<String> _notationEventKeys = {
  'accidental_display',
  'authored_source_id',
  'beam_state',
  'beam_states',
  'display_pitch',
  'dots',
  'duration',
  'full_measure',
  'authored_grace_anchor_id',
  'authored_grace_group_id',
  'grace_anchor_id',
  'grace_group_id',
  'grace_order',
  'grace_placement',
  'grace_slash',
  'is_grace',
  'kind',
  'occurrence',
  'pitch',
  'pitch_str',
  'playback_measure',
  'playback_note_ref',
  'source_id',
  'source_measure',
  'source_offset',
  'staff',
  'stem_direction',
  'time',
  'tuplet',
  'voice',
  'written_type',
};

const Set<String> _notationAnnotationKeys = {
  'alternate',
  'anchor_role',
  'authored_color',
  'authored_end_anchor_id',
  'authored_end_offset',
  'authored_end_source_id',
  'authored_end_source_measure',
  'authored_source_id',
  'authored_spanner_id',
  'authored_start_anchor_id',
  'authored_style',
  'duration',
  'end_anchor_id',
  'end_occurrence',
  'end_playback_measure',
  'end_source_id',
  'kind',
  'language',
  'octave_shift_size',
  'orientation',
  'pedal_abbreviated',
  'pedal_line',
  'pedal_sign',
  'placement',
  'playback_measure',
  'source_measure',
  'occurrence',
  'source_id',
  'source_offset',
  'spanner_id',
  'spanner_number',
  'staff',
  'start_anchor_id',
  'substitution',
  'subtype',
  'technical_attributes',
  'technical_subtype',
  'text',
  'time',
  'print_object',
  'unsupported',
  'value',
};

const Set<String> _tupletKeys = {'actual', 'normal'};
const Set<String> _beamStateKeys = {'number', 'state'};

const Set<String> _noteKeys = {
  '__class__.__name__',
  'accidental_display',
  'beam_state',
  'beam_states',
  'duration',
  'fingering',
  'fret',
  'is_grace',
  'measure',
  'pitch',
  'pitch_str',
  'practice_marks',
  'stem_direction',
  'string',
  'time',
  'velocity',
};

const Set<String> _practiceMarkKeys = {'kind', 'value', 'voice'};

const Set<String> _layoutBreakKeys = {'measure'};

const Set<String> _beamStateValues = {
  'none',
  'begin',
  'continue',
  'end',
  'forward_hook',
  'backward_hook',
};

const Set<String> _stemDirectionValues = {'auto', 'up', 'down'};

const Set<String> _accidentalDisplayValues = {
  'none',
  'natural',
  'sharp',
  'flat',
  'double_sharp',
  'double_flat',
  'cautionary',
};

String? _decodeEnum(dynamic raw, Set<String> allowed, String path) {
  if (raw == null) return null;
  if (raw is! String) {
    throw PdmxDecodeException(
      'expected enum string or null, got ${raw.runtimeType}',
      path,
    );
  }
  if (!allowed.contains(raw)) {
    throw PdmxDecodeException(
      'unknown enum value "$raw" (allowed: ${allowed.toList()..sort()})',
      path,
    );
  }
  return raw;
}

void _rejectUnknown(
  Map<String, dynamic> raw,
  Set<String> allowed,
  String path,
) {
  for (final key in raw.keys) {
    if (!allowed.contains(key)) {
      throw PdmxDecodeException(
        'unknown key "$key" (allowed: ${allowed.toList()..sort()})',
        path,
      );
    }
  }
}

class PdmxDocument {
  final bool absoluteTime;
  final List<PdmxAnnotation> annotations;
  final PdmxAuthoredStructure? authoredStructure;
  final List<PdmxBarline> barlines;
  final List<PdmxBeat> beats;
  final bool inferVelocity;
  final List<PdmxKeySignature> keySignatures;

  final List<Map<String, dynamic>> lyrics;
  final PdmxMetadata metadata;
  final int resolution;
  final int songLength;
  final List<PdmxTempo> tempos;
  final List<PdmxTimeSignature> timeSignatures;
  final List<PdmxMeasureInstance>? measureInstances;

  final List<PdmxTrack> tracks;

  final List<int> nullTrackPositions;

  final List<PdmxLayoutBreak>? systemBreaks;

  final List<PdmxLayoutBreak>? pageBreaks;

  const PdmxDocument({
    required this.absoluteTime,
    required this.annotations,
    this.authoredStructure,
    required this.barlines,
    required this.beats,
    required this.inferVelocity,
    required this.keySignatures,
    required this.lyrics,
    required this.metadata,
    required this.resolution,
    required this.songLength,
    required this.tempos,
    required this.timeSignatures,
    this.measureInstances,
    required this.tracks,
    this.nullTrackPositions = const [],
    this.systemBreaks,
    this.pageBreaks,
  });

  factory PdmxDocument.fromJson(Map<String, dynamic> raw) {
    _rejectUnknown(raw, _topLevelKeys, r'$');
    final tracksDecoded = _decodeTracks(raw['tracks'], r'$.tracks');
    return PdmxDocument(
      absoluteTime: raw['absolute_time'] as bool? ?? false,
      annotations: _decodeList(
        raw['annotations'],
        r'$.annotations',
        PdmxAnnotation._decode,
      ),
      authoredStructure: raw['authored_structure'] is Map
          ? PdmxAuthoredStructure._decode(
              (raw['authored_structure'] as Map).cast<String, dynamic>(),
              r'$.authored_structure',
            )
          : null,
      barlines: _decodeList(
        raw['barlines'],
        r'$.barlines',
        PdmxBarline._decode,
      ),
      beats: _decodeList(raw['beats'], r'$.beats', PdmxBeat._decode),
      inferVelocity: raw['infer_velocity'] as bool? ?? false,
      keySignatures: _decodeList(
        raw['key_signatures'],
        r'$.key_signatures',
        PdmxKeySignature._decode,
      ),
      lyrics: _decodeRawMapList(raw['lyrics'], r'$.lyrics'),
      metadata: PdmxMetadata._decode(
        (raw['metadata'] as Map?)?.cast<String, dynamic>() ?? const {},
        r'$.metadata',
      ),
      resolution: (raw['resolution'] as num?)?.toInt() ?? 480,
      songLength: (raw['song_length'] as num?)?.toInt() ?? 0,
      tempos: _decodeList(raw['tempos'], r'$.tempos', PdmxTempo._decode),
      timeSignatures: _decodeList(
        raw['time_signatures'],
        r'$.time_signatures',
        PdmxTimeSignature._decode,
      ),
      measureInstances: _decodeOptionalList(
        raw['measure_instances'],
        r'$.measure_instances',
        PdmxMeasureInstance._decode,
      ),
      tracks: tracksDecoded.tracks,
      nullTrackPositions: tracksDecoded.nullPositions,
      systemBreaks: _decodeOptionalList(
        raw['system_breaks'],
        r'$.system_breaks',
        PdmxLayoutBreak._decode,
      ),
      pageBreaks: _decodeOptionalList(
        raw['page_breaks'],
        r'$.page_breaks',
        PdmxLayoutBreak._decode,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final tracksJson = <Map<String, dynamic>?>[];
    if (nullTrackPositions.isEmpty) {
      tracksJson.addAll(tracks.map((t) => t.toJson()));
    } else {
      final nullSet = nullTrackPositions.toSet();
      final fullLen = tracks.length + nullTrackPositions.length;
      var ti = 0;
      for (var i = 0; i < fullLen; i++) {
        if (nullSet.contains(i)) {
          tracksJson.add(null);
        } else {
          tracksJson.add(tracks[ti++].toJson());
        }
      }
    }
    return {
      'absolute_time': absoluteTime,
      'annotations': annotations.map((a) => a.toJson()).toList(),
      if (authoredStructure != null)
        'authored_structure': authoredStructure!.toJson(),
      'barlines': barlines.map((b) => b.toJson()).toList(),
      'beats': beats.map((b) => b.toJson()).toList(),
      'infer_velocity': inferVelocity,
      'key_signatures': keySignatures.map((k) => k.toJson()).toList(),
      'lyrics': List<Map<String, dynamic>>.from(lyrics),
      'metadata': metadata.toJson(),
      if (measureInstances != null)
        'measure_instances': measureInstances!.map((m) => m.toJson()).toList(),
      'page_breaks': pageBreaks?.map((b) => b.toJson()).toList(),
      'resolution': resolution,
      'song_length': songLength,
      'system_breaks': systemBreaks?.map((b) => b.toJson()).toList(),
      'tempos': tempos.map((t) => t.toJson()).toList(),
      'time_signatures': timeSignatures.map((t) => t.toJson()).toList(),
      'tracks': tracksJson,
    };
  }
}

class PdmxAuthoredStructure {
  const PdmxAuthoredStructure({
    required this.version,
    required this.sourceMeasures,
    required this.signatures,
    required this.repeatBarlines,
    required this.endingSpans,
    required this.diagnostics,
  });

  final int version;
  final List<PdmxAuthoredMeasure> sourceMeasures;
  final List<PdmxAuthoredSignature> signatures;
  final List<PdmxRepeatBarline> repeatBarlines;
  final List<PdmxEndingSpan> endingSpans;
  final List<PdmxAuthoredDiagnostic> diagnostics;

  static PdmxAuthoredStructure _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _authoredStructureKeys, path);
    return PdmxAuthoredStructure(
      version: (raw['version'] as num?)?.toInt() ?? 1,
      sourceMeasures: _decodeList(
        raw['source_measures'],
        '$path.source_measures',
        PdmxAuthoredMeasure._decode,
      ),
      signatures: _decodeList(
        raw['signatures'],
        '$path.signatures',
        PdmxAuthoredSignature._decode,
      ),
      repeatBarlines: _decodeList(
        raw['repeat_barlines'],
        '$path.repeat_barlines',
        PdmxRepeatBarline._decode,
      ),
      endingSpans: _decodeList(
        raw['ending_spans'],
        '$path.ending_spans',
        PdmxEndingSpan._decode,
      ),
      diagnostics: _decodeList(
        raw['diagnostics'],
        '$path.diagnostics',
        PdmxAuthoredDiagnostic._decode,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'source_measures': sourceMeasures.map((item) => item.toJson()).toList(),
    'signatures': signatures.map((item) => item.toJson()).toList(),
    'repeat_barlines': repeatBarlines.map((item) => item.toJson()).toList(),
    'ending_spans': endingSpans.map((item) => item.toJson()).toList(),
    'diagnostics': diagnostics.map((item) => item.toJson()).toList(),
  };
}

class PdmxAuthoredMeasure {
  const PdmxAuthoredMeasure({
    required this.sourceId,
    required this.sourceMeasure,
    required this.ordinal,
    required this.displayNumber,
    required this.duration,
  });

  final String sourceId;
  final int sourceMeasure;
  final int ordinal;
  final String displayNumber;
  final int duration;

  static PdmxAuthoredMeasure _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _authoredMeasureKeys, path);
    return PdmxAuthoredMeasure(
      sourceId: raw['source_id'] as String? ?? path,
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      ordinal: (raw['ordinal'] as num?)?.toInt() ?? 0,
      displayNumber: raw['display_number'] as String? ?? '',
      duration: (raw['duration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'source_id': sourceId,
    'source_measure': sourceMeasure,
    'ordinal': ordinal,
    'display_number': displayNumber,
    'duration': duration,
  };
}

class PdmxAuthoredSignature {
  const PdmxAuthoredSignature({
    required this.sourceId,
    required this.kind,
    required this.sourceMeasureId,
    required this.sourceMeasure,
    required this.offset,
    this.staff,
    this.sign,
    this.line,
    this.octaveChange,
    this.fifths,
    this.numerator,
    this.denominator,
  });

  final String sourceId;
  final String kind;
  final String sourceMeasureId;
  final int sourceMeasure;
  final int offset;
  final int? staff;
  final String? sign;
  final int? line;
  final int? octaveChange;
  final int? fifths;
  final int? numerator;
  final int? denominator;

  static PdmxAuthoredSignature _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _authoredSignatureKeys, path);
    return PdmxAuthoredSignature(
      sourceId: raw['source_id'] as String? ?? path,
      kind: raw['kind'] as String? ?? 'unsupported',
      sourceMeasureId: raw['source_measure_id'] as String? ?? '',
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      offset: (raw['offset'] as num?)?.toInt() ?? 0,
      staff: (raw['staff'] as num?)?.toInt(),
      sign: raw['sign'] as String?,
      line: (raw['line'] as num?)?.toInt(),
      octaveChange: (raw['octave_change'] as num?)?.toInt(),
      fifths: (raw['fifths'] as num?)?.toInt(),
      numerator: (raw['numerator'] as num?)?.toInt(),
      denominator: (raw['denominator'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'source_id': sourceId,
    'kind': kind,
    'source_measure_id': sourceMeasureId,
    'source_measure': sourceMeasure,
    'offset': offset,
    if (staff != null) 'staff': staff,
    if (sign != null) 'sign': sign,
    if (line != null) 'line': line,
    if (octaveChange != null) 'octave_change': octaveChange,
    if (fifths != null) 'fifths': fifths,
    if (numerator != null) 'numerator': numerator,
    if (denominator != null) 'denominator': denominator,
  };
}

class PdmxRepeatBarline {
  const PdmxRepeatBarline({
    required this.sourceId,
    required this.repeatId,
    required this.sourceMeasureId,
    required this.sourceMeasure,
    required this.location,
    required this.direction,
    required this.times,
    required this.style,
  });

  final String sourceId;
  final String repeatId;
  final String sourceMeasureId;
  final int sourceMeasure;
  final String location;
  final String? direction;
  final int times;
  final String style;

  static PdmxRepeatBarline _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _repeatBarlineKeys, path);
    return PdmxRepeatBarline(
      sourceId: raw['source_id'] as String? ?? path,
      repeatId: raw['repeat_id'] as String? ?? '',
      sourceMeasureId: raw['source_measure_id'] as String? ?? '',
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      location: raw['location'] as String? ?? 'right',
      direction: raw['direction'] as String?,
      times: (raw['times'] as num?)?.toInt() ?? 2,
      style: raw['style'] as String? ?? 'regular',
    );
  }

  Map<String, dynamic> toJson() => {
    'source_id': sourceId,
    'repeat_id': repeatId,
    'source_measure_id': sourceMeasureId,
    'source_measure': sourceMeasure,
    'location': location,
    'direction': direction,
    'times': times,
    'style': style,
  };
}

class PdmxEndingSpan {
  const PdmxEndingSpan({
    required this.sourceId,
    required this.numbers,
    required this.startSourceMeasure,
    required this.endSourceMeasure,
    required this.closure,
  });

  final String sourceId;
  final List<String> numbers;
  final int startSourceMeasure;
  final int endSourceMeasure;
  final String closure;

  static PdmxEndingSpan _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _endingSpanKeys, path);
    final values = raw['numbers'];
    return PdmxEndingSpan(
      sourceId: raw['source_id'] as String? ?? path,
      numbers: values is List
          ? values.map((value) => value.toString()).toList(growable: false)
          : const [],
      startSourceMeasure: (raw['start_source_measure'] as num?)?.toInt() ?? 0,
      endSourceMeasure: (raw['end_source_measure'] as num?)?.toInt() ?? 0,
      closure: raw['closure'] as String? ?? 'open',
    );
  }

  Map<String, dynamic> toJson() => {
    'source_id': sourceId,
    'numbers': numbers,
    'start_source_measure': startSourceMeasure,
    'end_source_measure': endSourceMeasure,
    'closure': closure,
  };
}

class PdmxAuthoredDiagnostic {
  const PdmxAuthoredDiagnostic({
    required this.code,
    required this.severity,
    required this.sourceMeasure,
    this.detail,
  });

  final String code;
  final String severity;
  final int sourceMeasure;
  final String? detail;

  static PdmxAuthoredDiagnostic _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _authoredDiagnosticKeys, path);
    return PdmxAuthoredDiagnostic(
      code: raw['code'] as String? ?? 'unknown',
      severity: raw['severity'] as String? ?? 'warning',
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      detail: raw['detail'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'severity': severity,
    'source_measure': sourceMeasure,
    if (detail != null) 'detail': detail,
  };
}

class PdmxMeasureInstance {
  const PdmxMeasureInstance({
    required this.playbackMeasure,
    required this.sourceMeasure,
    required this.occurrence,
    required this.time,
    this.ending,
  });

  final int playbackMeasure;
  final int sourceMeasure;
  final int occurrence;
  final int time;
  final String? ending;

  static PdmxMeasureInstance _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _measureInstanceKeys, path);
    return PdmxMeasureInstance(
      playbackMeasure: (raw['playback_measure'] as num?)?.toInt() ?? 0,
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      occurrence: (raw['occurrence'] as num?)?.toInt() ?? 1,
      time: (raw['time'] as num?)?.toInt() ?? 0,
      ending: raw['ending'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'playback_measure': playbackMeasure,
    'source_measure': sourceMeasure,
    'occurrence': occurrence,
    'ending': ending,
    'time': time,
  };
}

class PdmxLayoutBreak {
  final int? measure;

  const PdmxLayoutBreak({this.measure});

  static PdmxLayoutBreak _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _layoutBreakKeys, path);
    return PdmxLayoutBreak(measure: (raw['measure'] as num?)?.toInt());
  }

  Map<String, dynamic> toJson() => {'measure': measure};
}

class PdmxMetadata {
  final String? collection;
  final String? copyright;
  final List<dynamic>? creators;
  final String? schemaVersion;
  final String? sourceFilename;
  final String? sourceFormat;
  final String? subtitle;
  final String? subtitleLanguage;
  final String? title;
  final String? titleLanguage;

  const PdmxMetadata({
    this.collection,
    this.copyright,
    this.creators,
    this.schemaVersion,
    this.sourceFilename,
    this.sourceFormat,
    this.subtitle,
    this.subtitleLanguage,
    this.title,
    this.titleLanguage,
  });

  static PdmxMetadata _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _metadataKeys, path);
    return PdmxMetadata(
      collection: raw['collection'] as String?,
      copyright: raw['copyright'] as String?,
      creators: raw['creators'] as List?,
      schemaVersion: raw['schema_version'] as String?,
      sourceFilename: raw['source_filename'] as String?,
      sourceFormat: raw['source_format'] as String?,
      subtitle: raw['subtitle'] as String?,
      subtitleLanguage: raw['subtitle_language'] as String?,
      title: raw['title'] as String?,
      titleLanguage: raw['title_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'Metadata',
    'collection': collection,
    'copyright': copyright,
    'creators': creators,
    'schema_version': schemaVersion,
    'source_filename': sourceFilename,
    'source_format': sourceFormat,
    'subtitle': subtitle,
    if (subtitleLanguage != null) 'subtitle_language': subtitleLanguage,
    'title': title,
    if (titleLanguage != null) 'title_language': titleLanguage,
  };
}

class PdmxTempo {
  final int? measure;
  final double qpm;
  final String? text;
  final int time;

  const PdmxTempo({
    this.measure,
    required this.qpm,
    this.text,
    required this.time,
  });

  static PdmxTempo _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _tempoKeys, path);
    return PdmxTempo(
      measure: (raw['measure'] as num?)?.toInt(),
      qpm: (raw['qpm'] as num?)?.toDouble() ?? 120.0,
      text: raw['text'] as String?,
      time: (raw['time'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'Tempo',
    'measure': measure,
    'qpm': qpm,
    'text': text,
    'time': time,
  };
}

class PdmxKeySignature {
  final int fifths;
  final int? measure;
  final String? mode;
  final int? root;
  final String? rootStr;
  final int? time;

  const PdmxKeySignature({
    required this.fifths,
    this.measure,
    this.mode,
    this.root,
    this.rootStr,
    this.time,
  });

  static PdmxKeySignature _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _keySigKeys, path);
    return PdmxKeySignature(
      fifths: (raw['fifths'] as num?)?.toInt() ?? 0,
      measure: (raw['measure'] as num?)?.toInt(),
      mode: raw['mode'] as String?,
      root: (raw['root'] as num?)?.toInt(),
      rootStr: raw['root_str'] as String?,
      time: (raw['time'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'KeySignature',
    'fifths': fifths,
    'measure': measure,
    'mode': mode,
    'root': root,
    'root_str': rootStr,
    'time': time,
  };
}

class PdmxTimeSignature {
  final int denominator;
  final int? measure;
  final int numerator;
  final int? time;

  const PdmxTimeSignature({
    required this.denominator,
    this.measure,
    required this.numerator,
    this.time,
  });

  static PdmxTimeSignature _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _timeSigKeys, path);
    return PdmxTimeSignature(
      denominator: (raw['denominator'] as num?)?.toInt() ?? 4,
      measure: (raw['measure'] as num?)?.toInt(),
      numerator: (raw['numerator'] as num?)?.toInt() ?? 4,
      time: (raw['time'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'TimeSignature',
    'denominator': denominator,
    'measure': measure,
    'numerator': numerator,
    'time': time,
  };
}

class PdmxBeat {
  final bool isDownbeat;
  final int? measure;
  final int time;

  const PdmxBeat({required this.isDownbeat, this.measure, required this.time});

  static PdmxBeat _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _beatKeys, path);
    return PdmxBeat(
      isDownbeat: raw['is_downbeat'] as bool? ?? false,
      measure: (raw['measure'] as num?)?.toInt(),
      time: (raw['time'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'Beat',
    'is_downbeat': isDownbeat,
    'measure': measure,
    'time': time,
  };
}

class PdmxBarline {
  final int? measure;
  final String? subtype;
  final int? time;

  const PdmxBarline({this.measure, this.subtype, this.time});

  static PdmxBarline _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _barlineKeys, path);
    return PdmxBarline(
      measure: (raw['measure'] as num?)?.toInt(),
      subtype: raw['subtype'] as String?,
      time: (raw['time'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'Barline',
    'measure': measure,
    'subtype': subtype,
    'time': time,
  };
}

sealed class PdmxAnnotationPayload {
  const PdmxAnnotationPayload();

  String get classTag;

  Map<String, dynamic> toJson();

  static PdmxAnnotationPayload _decode(Map<String, dynamic> raw, String path) {
    final tag = raw['name'];
    if (tag is String) {
      return switch (tag) {
        'SlurSpanner' => PdmxSlurSpanner._decode(raw, path),
        'Dynamic' => PdmxDynamic._decode(raw, path),
        'Articulation' => PdmxArticulation._decode(raw, path),
        'Ornament' => PdmxOrnament._decode(raw, path),
        'TrillSpanner' => PdmxTrillSpanner._decode(raw, path),
        'HairPinSpanner' => PdmxHairPinSpanner._decode(raw, path),
        _ => PdmxOpaqueAnnotation._decode(raw, tag),
      };
    }
    final className = raw['__class__.__name__'];
    if (className is String) {
      return PdmxOpaqueAnnotation._decode(raw, className);
    }
    if (tag != null) {
      throw PdmxDecodeException(
        'annotation payload missing string `name`',
        path,
      );
    }
    throw PdmxDecodeException(
      'annotation payload missing class discriminator',
      path,
    );
  }
}

const Set<String> _slurSpannerKeys = {'name', 'subtype', 'duration', 'is_slur'};

class PdmxSlurSpanner extends PdmxAnnotationPayload {
  final String? subtype;
  final int? duration;
  final bool? isSlur;

  const PdmxSlurSpanner({this.subtype, this.duration, this.isSlur});

  @override
  String get classTag => 'SlurSpanner';

  static PdmxSlurSpanner _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _slurSpannerKeys, path);
    return PdmxSlurSpanner(
      subtype: raw['subtype'] as String?,
      duration: (raw['duration'] as num?)?.toInt(),
      isSlur: raw['is_slur'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': classTag,
    'subtype': subtype,
    'duration': duration,
    'is_slur': isSlur,
  };
}

const Set<String> _dynamicKeys = {'name', 'subtype', 'velocity'};

class PdmxDynamic extends PdmxAnnotationPayload {
  final String? subtype;
  final int? velocity;

  const PdmxDynamic({this.subtype, this.velocity});

  @override
  String get classTag => 'Dynamic';

  static PdmxDynamic _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _dynamicKeys, path);
    return PdmxDynamic(
      subtype: raw['subtype'] as String?,
      velocity: (raw['velocity'] as num?)?.toInt(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': classTag,
    'subtype': subtype,
    'velocity': velocity,
  };
}

const Set<String> _articulationKeys = {'name', 'subtype'};

class PdmxArticulation extends PdmxAnnotationPayload {
  final String? subtype;

  const PdmxArticulation({this.subtype});

  @override
  String get classTag => 'Articulation';

  static PdmxArticulation _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _articulationKeys, path);
    return PdmxArticulation(subtype: raw['subtype'] as String?);
  }

  @override
  Map<String, dynamic> toJson() => {'name': classTag, 'subtype': subtype};
}

const Set<String> _ornamentKeys = {'name', 'subtype'};

class PdmxOrnament extends PdmxAnnotationPayload {
  final String? subtype;

  const PdmxOrnament({this.subtype});

  @override
  String get classTag => 'Ornament';

  static PdmxOrnament _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _ornamentKeys, path);
    return PdmxOrnament(subtype: raw['subtype'] as String?);
  }

  @override
  Map<String, dynamic> toJson() => {'name': classTag, 'subtype': subtype};
}

const Set<String> _trillSpannerKeys = {'name', 'subtype', 'duration'};

class PdmxTrillSpanner extends PdmxAnnotationPayload {
  final String? subtype;
  final int? duration;

  const PdmxTrillSpanner({this.subtype, this.duration});

  @override
  String get classTag => 'TrillSpanner';

  static PdmxTrillSpanner _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _trillSpannerKeys, path);
    return PdmxTrillSpanner(
      subtype: raw['subtype'] as String?,
      duration: (raw['duration'] as num?)?.toInt(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': classTag,
    'subtype': subtype,
    'duration': duration,
  };
}

const Set<String> _hairPinSpannerKeys = {'name', 'subtype', 'duration'};

class PdmxHairPinSpanner extends PdmxAnnotationPayload {
  final String? subtype;
  final int? duration;

  const PdmxHairPinSpanner({this.subtype, this.duration});

  @override
  String get classTag => 'HairPinSpanner';

  static PdmxHairPinSpanner _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _hairPinSpannerKeys, path);
    return PdmxHairPinSpanner(
      subtype: raw['subtype'] as String?,
      duration: (raw['duration'] as num?)?.toInt(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': classTag,
    'subtype': subtype,
    'duration': duration,
  };
}

class PdmxOpaqueAnnotation extends PdmxAnnotationPayload {
  final String _classTag;
  final Map<String, dynamic> raw;

  const PdmxOpaqueAnnotation({required String classTag, required this.raw})
    : _classTag = classTag;

  @override
  String get classTag => _classTag;

  static PdmxOpaqueAnnotation _decode(Map<String, dynamic> raw, String tag) {
    return PdmxOpaqueAnnotation(
      classTag: tag,
      raw: Map<String, dynamic>.from(raw),
    );
  }

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class PdmxAnnotation {
  final PdmxAnnotationPayload? annotation;
  final String? group;
  final int? measure;
  final int? time;

  const PdmxAnnotation({this.annotation, this.group, this.measure, this.time});

  static PdmxAnnotation _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _annotationKeys, path);
    final annotationRaw = raw['annotation'];
    PdmxAnnotationPayload? annotation;
    if (annotationRaw is Map) {
      annotation = PdmxAnnotationPayload._decode(
        annotationRaw.cast<String, dynamic>(),
        '$path.annotation',
      );
    } else if (annotationRaw != null) {
      throw PdmxDecodeException(
        'expected object or null, got ${annotationRaw.runtimeType}',
        '$path.annotation',
      );
    }
    return PdmxAnnotation(
      annotation: annotation,
      group: raw['group'] as String?,
      measure: (raw['measure'] as num?)?.toInt(),
      time: (raw['time'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'Annotation',
    'annotation': annotation?.toJson(),
    'group': group,
    'measure': measure,
    'time': time,
  };
}

class PdmxTrack {
  final List<PdmxAnnotation> annotations;

  final List<Map<String, dynamic>> chords;
  final bool isDrum;
  final List<Map<String, dynamic>> lyrics;
  final String? name;
  final String? nameLanguage;
  final List<PdmxNote> notes;
  final int program;
  final int? staffCount;
  final List<PdmxClef>? clefs;
  final List<PdmxNotationEvent>? notationEvents;
  final List<PdmxNotationAnnotation>? notationAnnotations;

  const PdmxTrack({
    required this.annotations,
    required this.chords,
    required this.isDrum,
    required this.lyrics,
    this.name,
    this.nameLanguage,
    required this.notes,
    required this.program,
    this.staffCount,
    this.clefs,
    this.notationEvents,
    this.notationAnnotations,
  });

  static PdmxTrack _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _trackKeys, path);
    return PdmxTrack(
      annotations: _decodeList(
        raw['annotations'],
        '$path.annotations',
        PdmxAnnotation._decode,
      ),
      chords: _decodeRawMapList(raw['chords'], '$path.chords'),
      isDrum: raw['is_drum'] as bool? ?? false,
      lyrics: _decodeRawMapList(raw['lyrics'], '$path.lyrics'),
      name: raw['name'] as String?,
      nameLanguage: raw['name_language'] as String?,
      notes: _decodeList(raw['notes'], '$path.notes', PdmxNote._decode),
      program: (raw['program'] as num?)?.toInt() ?? 0,
      staffCount: (raw['staff_count'] as num?)?.toInt(),
      clefs: _decodeOptionalList(raw['clefs'], '$path.clefs', PdmxClef._decode),
      notationEvents: _decodeOptionalList(
        raw['notation_events'],
        '$path.notation_events',
        PdmxNotationEvent._decode,
      ),
      notationAnnotations: _decodeOptionalList(
        raw['notation_annotations'],
        '$path.notation_annotations',
        PdmxNotationAnnotation._decode,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'Track',
    'annotations': annotations.map((a) => a.toJson()).toList(),
    'chords': List<Map<String, dynamic>>.from(chords),
    'is_drum': isDrum,
    'lyrics': List<Map<String, dynamic>>.from(lyrics),
    'name': name,
    if (nameLanguage != null) 'name_language': nameLanguage,
    'notes': notes.map((n) => n.toJson()).toList(),
    'program': program,
    if (staffCount != null) 'staff_count': staffCount,
    if (clefs != null) 'clefs': clefs!.map((c) => c.toJson()).toList(),
    if (notationEvents != null)
      'notation_events': notationEvents!.map((e) => e.toJson()).toList(),
    if (notationAnnotations != null)
      'notation_annotations': notationAnnotations!
          .map((a) => a.toJson())
          .toList(),
  };
}

class PdmxNotationAnnotation {
  const PdmxNotationAnnotation({
    required this.sourceId,
    this.authoredSourceId,
    required this.kind,
    required this.time,
    required this.staff,
    required this.playbackMeasure,
    required this.sourceMeasure,
    required this.occurrence,
    this.sourceOffset,
    this.duration,
    this.startAnchorId,
    this.endAnchorId,
    this.authoredStartAnchorId,
    this.authoredEndAnchorId,
    this.placement,
    this.subtype,
    this.text,
    this.language,
    this.spannerId,
    this.authoredSpannerId,
    this.authoredEndSourceMeasure,
    this.authoredEndOffset,
    this.anchorRole,
    this.orientation,
    this.spannerNumber,
    this.pedalLine,
    this.pedalSign,
    this.pedalAbbreviated,
    this.octaveShiftSize,
    this.endSourceId,
    this.authoredEndSourceId,
    this.endPlaybackMeasure,
    this.endOccurrence,
    this.value,
    this.alternate,
    this.substitution,
    this.printObject,
    this.authoredColor,
    this.authoredStyle,
    this.technicalSubtype,
    this.technicalAttributes,
    this.unsupported,
  });

  final String sourceId;
  final String? authoredSourceId;
  final String kind;
  final int time;
  final int staff;
  final int playbackMeasure;
  final int sourceMeasure;
  final int occurrence;
  final int? sourceOffset;
  final int? duration;
  final String? startAnchorId;
  final String? endAnchorId;
  final String? authoredStartAnchorId;
  final String? authoredEndAnchorId;
  final String? placement;
  final String? subtype;
  final String? text;
  final String? language;
  final String? spannerId;
  final String? authoredSpannerId;
  final int? authoredEndSourceMeasure;
  final int? authoredEndOffset;
  final String? anchorRole;
  final String? orientation;
  final String? spannerNumber;
  final bool? pedalLine;
  final bool? pedalSign;
  final bool? pedalAbbreviated;
  final int? octaveShiftSize;
  final String? endSourceId;
  final String? authoredEndSourceId;
  final int? endPlaybackMeasure;
  final int? endOccurrence;
  final String? value;
  final bool? alternate;
  final bool? substitution;
  final bool? printObject;
  final String? authoredColor;
  final Map<String, dynamic>? authoredStyle;
  final String? technicalSubtype;
  final Map<String, dynamic>? technicalAttributes;
  final String? unsupported;

  static PdmxNotationAnnotation _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _notationAnnotationKeys, path);
    return PdmxNotationAnnotation(
      sourceId: raw['source_id'] as String? ?? path,
      authoredSourceId: raw['authored_source_id'] as String?,
      kind: raw['kind'] as String? ?? 'unsupported',
      time: (raw['time'] as num?)?.toInt() ?? 0,
      staff: (raw['staff'] as num?)?.toInt() ?? 1,
      playbackMeasure: (raw['playback_measure'] as num?)?.toInt() ?? 0,
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      occurrence: (raw['occurrence'] as num?)?.toInt() ?? 1,
      sourceOffset: (raw['source_offset'] as num?)?.toInt(),
      duration: (raw['duration'] as num?)?.toInt(),
      startAnchorId: raw['start_anchor_id'] as String?,
      endAnchorId: raw['end_anchor_id'] as String?,
      authoredStartAnchorId: raw['authored_start_anchor_id'] as String?,
      authoredEndAnchorId: raw['authored_end_anchor_id'] as String?,
      placement: raw['placement'] as String?,
      subtype: raw['subtype'] as String?,
      text: raw['text'] as String?,
      language: raw['language'] as String?,
      spannerId: raw['spanner_id'] as String?,
      authoredSpannerId: raw['authored_spanner_id'] as String?,
      authoredEndSourceMeasure: (raw['authored_end_source_measure'] as num?)
          ?.toInt(),
      authoredEndOffset: (raw['authored_end_offset'] as num?)?.toInt(),
      anchorRole: raw['anchor_role'] as String?,
      orientation: raw['orientation'] as String?,
      spannerNumber: raw['spanner_number']?.toString(),
      pedalLine: raw['pedal_line'] as bool?,
      pedalSign: raw['pedal_sign'] as bool?,
      pedalAbbreviated: raw['pedal_abbreviated'] as bool?,
      octaveShiftSize: (raw['octave_shift_size'] as num?)?.toInt(),
      endSourceId: raw['end_source_id'] as String?,
      authoredEndSourceId: raw['authored_end_source_id'] as String?,
      endPlaybackMeasure: (raw['end_playback_measure'] as num?)?.toInt(),
      endOccurrence: (raw['end_occurrence'] as num?)?.toInt(),
      value: raw['value']?.toString(),
      alternate: raw['alternate'] as bool?,
      substitution: raw['substitution'] as bool?,
      printObject: raw['print_object'] as bool?,
      authoredColor: raw['authored_color'] as String?,
      authoredStyle: raw['authored_style'] == null
          ? null
          : Map<String, dynamic>.from(raw['authored_style'] as Map),
      technicalSubtype: raw['technical_subtype'] as String?,
      technicalAttributes: raw['technical_attributes'] == null
          ? null
          : Map<String, dynamic>.from(raw['technical_attributes'] as Map),
      unsupported: raw['unsupported'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'source_id': sourceId,
    if (authoredSourceId != null) 'authored_source_id': authoredSourceId,
    'kind': kind,
    'time': time,
    'staff': staff,
    'playback_measure': playbackMeasure,
    'source_measure': sourceMeasure,
    'occurrence': occurrence,
    if (sourceOffset != null) 'source_offset': sourceOffset,
    if (duration != null) 'duration': duration,
    if (startAnchorId != null) 'start_anchor_id': startAnchorId,
    if (endAnchorId != null) 'end_anchor_id': endAnchorId,
    if (authoredStartAnchorId != null)
      'authored_start_anchor_id': authoredStartAnchorId,
    if (authoredEndAnchorId != null)
      'authored_end_anchor_id': authoredEndAnchorId,
    if (placement != null) 'placement': placement,
    if (subtype != null) 'subtype': subtype,
    if (text != null) 'text': text,
    if (language != null) 'language': language,
    if (spannerId != null) 'spanner_id': spannerId,
    if (authoredSpannerId != null) 'authored_spanner_id': authoredSpannerId,
    if (authoredEndSourceMeasure != null)
      'authored_end_source_measure': authoredEndSourceMeasure,
    if (authoredEndOffset != null) 'authored_end_offset': authoredEndOffset,
    if (anchorRole != null) 'anchor_role': anchorRole,
    if (orientation != null) 'orientation': orientation,
    if (spannerNumber != null) 'spanner_number': spannerNumber,
    if (pedalLine != null) 'pedal_line': pedalLine,
    if (pedalSign != null) 'pedal_sign': pedalSign,
    if (pedalAbbreviated != null) 'pedal_abbreviated': pedalAbbreviated,
    if (octaveShiftSize != null) 'octave_shift_size': octaveShiftSize,
    if (endSourceId != null) 'end_source_id': endSourceId,
    if (authoredEndSourceId != null)
      'authored_end_source_id': authoredEndSourceId,
    if (endPlaybackMeasure != null) 'end_playback_measure': endPlaybackMeasure,
    if (endOccurrence != null) 'end_occurrence': endOccurrence,
    if (value != null) 'value': value,
    if (alternate != null) 'alternate': alternate,
    if (substitution != null) 'substitution': substitution,
    if (printObject != null) 'print_object': printObject,
    if (authoredColor != null) 'authored_color': authoredColor,
    if (authoredStyle != null) 'authored_style': authoredStyle,
    if (technicalSubtype != null) 'technical_subtype': technicalSubtype,
    if (technicalAttributes != null)
      'technical_attributes': technicalAttributes,
    if (unsupported != null) 'unsupported': unsupported,
  };
}

class PdmxClef {
  const PdmxClef({
    required this.sourceId,
    this.authoredSourceId,
    required this.staff,
    required this.sign,
    this.line,
    required this.playbackMeasure,
    required this.sourceMeasure,
    required this.occurrence,
    required this.time,
    this.sourceOffset,
    this.octaveChange = 0,
  });
  final String sourceId;
  final String? authoredSourceId;
  final int staff;
  final String? sign;
  final int? line;
  final int playbackMeasure;
  final int sourceMeasure;
  final int occurrence;
  final int time;
  final int? sourceOffset;
  final int octaveChange;

  static PdmxClef _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _clefKeys, path);
    return PdmxClef(
      sourceId: raw['source_id'] as String? ?? path,
      authoredSourceId: raw['authored_source_id'] as String?,
      staff: (raw['staff'] as num?)?.toInt() ?? 1,
      sign: raw['sign'] as String?,
      line: (raw['line'] as num?)?.toInt(),
      playbackMeasure: (raw['playback_measure'] as num?)?.toInt() ?? 0,
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      occurrence: (raw['occurrence'] as num?)?.toInt() ?? 1,
      time: (raw['time'] as num?)?.toInt() ?? 0,
      sourceOffset: (raw['source_offset'] as num?)?.toInt(),
      octaveChange: (raw['octave_change'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'source_id': sourceId,
    if (authoredSourceId != null) 'authored_source_id': authoredSourceId,
    'staff': staff,
    'sign': sign,
    'line': line,
    'playback_measure': playbackMeasure,
    'source_measure': sourceMeasure,
    'occurrence': occurrence,
    'time': time,
    if (sourceOffset != null) 'source_offset': sourceOffset,
    'octave_change': octaveChange,
  };
}

class PdmxTuplet {
  const PdmxTuplet({required this.actual, required this.normal});
  final int actual;
  final int normal;
  static PdmxTuplet _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _tupletKeys, path);
    return PdmxTuplet(
      actual: (raw['actual'] as num?)?.toInt() ?? 3,
      normal: (raw['normal'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toJson() => {'actual': actual, 'normal': normal};
}

class PdmxBeamState {
  const PdmxBeamState({required this.number, required this.state});

  final int number;

  final String state;

  static PdmxBeamState _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _beamStateKeys, path);
    final number = raw['number'];
    if (number is! int) {
      throw PdmxDecodeException(
        'expected positive integer, got ${number.runtimeType}',
        '$path.number',
      );
    }
    if (number < 1 || number > 8) {
      throw PdmxDecodeException(
        'expected beam number in range 1..8, got $number',
        '$path.number',
      );
    }
    final state = _decodeEnum(raw['state'], _beamStateValues, '$path.state');
    if (state == null) {
      throw PdmxDecodeException(
        'required beam state is missing',
        '$path.state',
      );
    }
    return PdmxBeamState(number: number, state: state);
  }

  Map<String, dynamic> toJson() => {'number': number, 'state': state};
}

List<PdmxBeamState>? _decodeBeamStates(
  dynamic raw,
  String path, {
  required String? legacyBeamState,
  required bool present,
}) {
  if (present && raw == null) {
    throw PdmxDecodeException('expected list, got Null', path);
  }
  final states = _decodeOptionalList(raw, path, PdmxBeamState._decode);
  if (states == null) return null;
  final seen = <int>{};
  var previous = 0;
  for (var index = 0; index < states.length; index++) {
    final state = states[index];
    if (!seen.add(state.number)) {
      throw PdmxDecodeException(
        'duplicate beam number ${state.number}',
        '$path[$index].number',
      );
    }
    if (state.number <= previous) {
      throw PdmxDecodeException(
        'beam numbers must be in strictly ascending order',
        '$path[$index].number',
      );
    }
    previous = state.number;
  }
  if (legacyBeamState != null) {
    PdmxBeamState? levelOne;
    var levelOneIndex = -1;
    for (var index = 0; index < states.length; index++) {
      if (states[index].number == 1) {
        levelOne = states[index];
        levelOneIndex = index;
        break;
      }
    }
    if (levelOne == null) {
      throw PdmxDecodeException(
        'beam_state requires a matching beam_states number 1 entry',
        path,
      );
    }
    if (levelOne.state != legacyBeamState) {
      throw PdmxDecodeException(
        'beam_state "$legacyBeamState" contradicts beam_states number 1 '
            'state "${levelOne.state}"',
        '$path[$levelOneIndex].state',
      );
    }
  }
  return List<PdmxBeamState>.unmodifiable(states);
}

String? _levelOneBeamState(List<PdmxBeamState>? states) {
  if (states == null) return null;
  for (final state in states) {
    if (state.number == 1) return state.state;
  }
  return null;
}

class PdmxNotationEvent {
  const PdmxNotationEvent({
    required this.kind,
    required this.sourceId,
    this.authoredSourceId,
    required this.playbackMeasure,
    required this.sourceMeasure,
    required this.occurrence,
    required this.time,
    this.sourceOffset,
    required this.duration,
    required this.staff,
    required this.voice,
    required this.writtenType,
    required this.dots,
    this.tuplet,
    this.pitch,
    this.pitchStr,
    this.isGrace = false,
    this.graceSlash = false,
    this.graceGroupId,
    this.authoredGraceGroupId,
    this.graceAnchorId,
    this.authoredGraceAnchorId,
    this.graceOrder,
    this.gracePlacement,
    this.stemDirection,
    this.beamState,
    this.beamStates,
    this.accidentalDisplay,
    this.playbackNoteRef,
    this.fullMeasure = false,
    this.displayPitch,
  });
  final String kind;
  final String sourceId;
  final String? authoredSourceId;
  final int playbackMeasure;
  final int sourceMeasure;
  final int occurrence;
  final int time;
  final int? sourceOffset;
  final int duration;
  final int staff;
  final int voice;
  final String writtenType;
  final int dots;
  final PdmxTuplet? tuplet;
  final int? pitch;
  final String? pitchStr;
  final bool isGrace;
  final bool graceSlash;
  final String? graceGroupId;
  final String? authoredGraceGroupId;
  final String? graceAnchorId;
  final String? authoredGraceAnchorId;
  final int? graceOrder;
  final String? gracePlacement;
  final String? stemDirection;
  final String? beamState;
  final List<PdmxBeamState>? beamStates;
  final String? accidentalDisplay;
  final int? playbackNoteRef;
  final bool fullMeasure;
  final String? displayPitch;

  bool get isRest => kind == 'rest';

  static PdmxNotationEvent _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _notationEventKeys, path);
    final tupletRaw = raw['tuplet'];
    final beamState = _decodeEnum(
      raw['beam_state'],
      _beamStateValues,
      '$path.beam_state',
    );
    final beamStates = _decodeBeamStates(
      raw['beam_states'],
      '$path.beam_states',
      legacyBeamState: beamState,
      present: raw.containsKey('beam_states'),
    );
    return PdmxNotationEvent(
      kind: raw['kind'] as String? ?? 'note',
      sourceId: raw['source_id'] as String? ?? path,
      authoredSourceId: raw['authored_source_id'] as String?,
      playbackMeasure: (raw['playback_measure'] as num?)?.toInt() ?? 0,
      sourceMeasure: (raw['source_measure'] as num?)?.toInt() ?? 0,
      occurrence: (raw['occurrence'] as num?)?.toInt() ?? 1,
      time: (raw['time'] as num?)?.toInt() ?? 0,
      sourceOffset: (raw['source_offset'] as num?)?.toInt(),
      duration: (raw['duration'] as num?)?.toInt() ?? 0,
      staff: (raw['staff'] as num?)?.toInt() ?? 1,
      voice: (raw['voice'] as num?)?.toInt() ?? 1,
      writtenType: raw['written_type'] as String? ?? 'quarter',
      dots: (raw['dots'] as num?)?.toInt() ?? 0,
      tuplet: tupletRaw is Map
          ? PdmxTuplet._decode(
              tupletRaw.cast<String, dynamic>(),
              '$path.tuplet',
            )
          : null,
      pitch: (raw['pitch'] as num?)?.toInt(),
      pitchStr: raw['pitch_str'] as String?,
      isGrace: raw['is_grace'] as bool? ?? false,
      graceSlash: raw['grace_slash'] as bool? ?? false,
      graceGroupId: raw['grace_group_id'] as String?,
      authoredGraceGroupId: raw['authored_grace_group_id'] as String?,
      graceAnchorId: raw['grace_anchor_id'] as String?,
      authoredGraceAnchorId: raw['authored_grace_anchor_id'] as String?,
      graceOrder: (raw['grace_order'] as num?)?.toInt(),
      gracePlacement: raw['grace_placement'] as String?,
      stemDirection: raw['stem_direction'] as String?,
      beamState: beamState ?? _levelOneBeamState(beamStates),
      beamStates: beamStates,
      accidentalDisplay: raw['accidental_display'] as String?,
      playbackNoteRef: (raw['playback_note_ref'] as num?)?.toInt(),
      fullMeasure: raw['full_measure'] as bool? ?? false,
      displayPitch: raw['display_pitch'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'source_id': sourceId,
    if (authoredSourceId != null) 'authored_source_id': authoredSourceId,
    'playback_measure': playbackMeasure,
    'source_measure': sourceMeasure,
    'occurrence': occurrence,
    'time': time,
    if (sourceOffset != null) 'source_offset': sourceOffset,
    'duration': duration,
    'staff': staff,
    'voice': voice,
    'written_type': writtenType,
    'dots': dots,
    if (tuplet != null) 'tuplet': tuplet!.toJson(),
    if (kind == 'note') ...{
      'pitch': pitch,
      'pitch_str': pitchStr,
      'is_grace': isGrace,
      'grace_slash': graceSlash,
      if (graceGroupId != null) 'grace_group_id': graceGroupId,
      if (authoredGraceGroupId != null)
        'authored_grace_group_id': authoredGraceGroupId,
      if (graceAnchorId != null) 'grace_anchor_id': graceAnchorId,
      if (authoredGraceAnchorId != null)
        'authored_grace_anchor_id': authoredGraceAnchorId,
      if (graceOrder != null) 'grace_order': graceOrder,
      if (gracePlacement != null) 'grace_placement': gracePlacement,
      'stem_direction': stemDirection,
      'beam_state': beamState ?? _levelOneBeamState(beamStates),
      if (beamStates != null)
        'beam_states': beamStates!.map((state) => state.toJson()).toList(),
      'accidental_display': accidentalDisplay,
      if (playbackNoteRef != null) 'playback_note_ref': playbackNoteRef,
    },
    if (kind == 'rest') ...{
      'full_measure': fullMeasure,
      if (displayPitch != null) 'display_pitch': displayPitch,
    },
  };
}

class PdmxNote {
  final int duration;
  final bool isGrace;
  final int? measure;
  final int pitch;
  final String? pitchStr;
  final int time;
  final int velocity;

  final String? beamState;

  final List<PdmxBeamState>? beamStates;

  final String? stemDirection;

  final String? accidentalDisplay;

  final List<PdmxPracticeMark>? practiceMarks;

  final int? guitarString;

  final int? guitarFret;

  final String? guitarFingering;

  const PdmxNote({
    required this.duration,
    required this.isGrace,
    this.measure,
    required this.pitch,
    this.pitchStr,
    required this.time,
    required this.velocity,
    this.beamState,
    this.beamStates,
    this.stemDirection,
    this.accidentalDisplay,
    this.practiceMarks,
    this.guitarString,
    this.guitarFret,
    this.guitarFingering,
  });

  static PdmxNote _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _noteKeys, path);
    final beamState = _decodeEnum(
      raw['beam_state'],
      _beamStateValues,
      '$path.beam_state',
    );
    final beamStates = _decodeBeamStates(
      raw['beam_states'],
      '$path.beam_states',
      legacyBeamState: beamState,
      present: raw.containsKey('beam_states'),
    );
    return PdmxNote(
      duration: (raw['duration'] as num?)?.toInt() ?? 0,
      guitarFingering: raw['fingering'] as String?,
      guitarFret: (raw['fret'] as num?)?.toInt(),
      guitarString: (raw['string'] as num?)?.toInt(),
      isGrace: raw['is_grace'] as bool? ?? false,
      measure: (raw['measure'] as num?)?.toInt(),
      pitch: (raw['pitch'] as num?)?.toInt() ?? 0,
      pitchStr: raw['pitch_str'] as String?,
      time: (raw['time'] as num?)?.toInt() ?? 0,
      velocity: (raw['velocity'] as num?)?.toInt() ?? 0,
      beamState: beamState ?? _levelOneBeamState(beamStates),
      beamStates: beamStates,
      stemDirection: _decodeEnum(
        raw['stem_direction'],
        _stemDirectionValues,
        '$path.stem_direction',
      ),
      accidentalDisplay: _decodeEnum(
        raw['accidental_display'],
        _accidentalDisplayValues,
        '$path.accidental_display',
      ),
      practiceMarks: _decodeOptionalList(
        raw['practice_marks'],
        '$path.practice_marks',
        PdmxPracticeMark._decode,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    '__class__.__name__': 'Note',
    'accidental_display': accidentalDisplay,
    'beam_state': beamState ?? _levelOneBeamState(beamStates),
    if (beamStates != null)
      'beam_states': beamStates!.map((state) => state.toJson()).toList(),
    'duration': duration,
    if (guitarFingering != null) 'fingering': guitarFingering,
    if (guitarFret != null) 'fret': guitarFret,
    'is_grace': isGrace,
    'measure': measure,
    'pitch': pitch,
    'pitch_str': pitchStr,
    'practice_marks': practiceMarks?.map((m) => m.toJson()).toList(),
    'stem_direction': stemDirection,
    if (guitarString != null) 'string': guitarString,
    'time': time,
    'velocity': velocity,
  };
}

class PdmxPracticeMark {
  final String? kind;
  final String? value;
  final int? voice;

  const PdmxPracticeMark({this.kind, this.value, this.voice});

  static PdmxPracticeMark _decode(Map<String, dynamic> raw, String path) {
    _rejectUnknown(raw, _practiceMarkKeys, path);
    return PdmxPracticeMark(
      kind: raw['kind'] as String?,
      value: raw['value'] as String?,
      voice: (raw['voice'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'value': value,
    'voice': voice,
  };
}

// ── Decode helpers ─────────────────────────────────────────────────────────

List<T> _decodeList<T>(
  dynamic raw,
  String path,
  T Function(Map<String, dynamic> raw, String path) decode,
) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw PdmxDecodeException('expected list, got ${raw.runtimeType}', path);
  }
  final out = <T>[];
  for (var i = 0; i < raw.length; i++) {
    final entry = raw[i];
    if (entry is! Map) {
      throw PdmxDecodeException(
        'expected object, got ${entry.runtimeType}',
        '$path[$i]',
      );
    }
    out.add(decode(entry.cast<String, dynamic>(), '$path[$i]'));
  }
  return out;
}

List<T>? _decodeOptionalList<T>(
  dynamic raw,
  String path,
  T Function(Map<String, dynamic> raw, String path) decode,
) {
  if (raw == null) return null;
  if (raw is! List) {
    throw PdmxDecodeException('expected list, got ${raw.runtimeType}', path);
  }
  final out = <T>[];
  for (var i = 0; i < raw.length; i++) {
    final entry = raw[i];
    if (entry is! Map) {
      throw PdmxDecodeException(
        'expected object, got ${entry.runtimeType}',
        '$path[$i]',
      );
    }
    out.add(decode(entry.cast<String, dynamic>(), '$path[$i]'));
  }
  return out;
}

List<Map<String, dynamic>> _decodeRawMapList(dynamic raw, String path) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw PdmxDecodeException('expected list, got ${raw.runtimeType}', path);
  }
  final out = <Map<String, dynamic>>[];
  for (var i = 0; i < raw.length; i++) {
    final entry = raw[i];
    if (entry is! Map) {
      throw PdmxDecodeException(
        'expected object, got ${entry.runtimeType}',
        '$path[$i]',
      );
    }
    out.add(entry.cast<String, dynamic>());
  }
  return out;
}

({List<PdmxTrack> tracks, List<int> nullPositions}) _decodeTracks(
  dynamic raw,
  String path,
) {
  if (raw == null) return (tracks: const [], nullPositions: const []);
  if (raw is! List) {
    throw PdmxDecodeException('expected list, got ${raw.runtimeType}', path);
  }
  final tracks = <PdmxTrack>[];
  final nullPositions = <int>[];
  for (var i = 0; i < raw.length; i++) {
    final entry = raw[i];
    if (entry == null) {
      nullPositions.add(i);
      continue;
    }
    if (entry is! Map) {
      throw PdmxDecodeException(
        'expected object or null, got ${entry.runtimeType}',
        '$path[$i]',
      );
    }
    tracks.add(PdmxTrack._decode(entry.cast<String, dynamic>(), '$path[$i]'));
  }
  return (tracks: tracks, nullPositions: nullPositions);
}

// ── Tempo math (canonical home for divisions → wall-clock ms) ──────────────

List<PdmxTempo> normalizeTempos(List<PdmxTempo> tempos) {
  if (tempos.isEmpty) {
    return const [PdmxTempo(qpm: 120.0, time: 0)];
  }
  final out = [...tempos];
  out.sort((a, b) => a.time.compareTo(b.time));
  final merged = <PdmxTempo>[];
  for (final e in out) {
    if (merged.isNotEmpty && merged.last.time == e.time) {
      merged[merged.length - 1] = e;
    } else {
      merged.add(e);
    }
  }
  if (merged.first.time > 0) {
    return [const PdmxTempo(qpm: 120.0, time: 0), ...merged];
  }
  return merged;
}

double wallMsAtDivision(int d, int resolution, List<PdmxTempo> tempos) {
  if (d <= 0) return 0.0;
  if (resolution <= 0) resolution = 480;
  var ms = 0.0;
  for (var i = 0; i < tempos.length; i++) {
    final div0 = tempos[i].time;
    final qpm = tempos[i].qpm;
    if (qpm <= 0) continue;
    final div1 = i + 1 < tempos.length ? tempos[i + 1].time : 0x7fffffff;
    if (d <= div0) {
      return ms;
    }
    final from = div0;
    final to = math.min(d, div1);
    if (to > from) {
      final msPerDiv = 60000.0 / qpm / resolution;
      ms += (to - from) * msPerDiv;
    }
  }
  return ms;
}

double durationMsInDivisions(
  int startDiv,
  int durationDivs,
  int resolution,
  List<PdmxTempo> tempos,
) {
  if (durationDivs <= 0) return 0.0;
  final end = startDiv + durationDivs;
  return wallMsAtDivision(end, resolution, tempos) -
      wallMsAtDivision(startDiv, resolution, tempos);
}
