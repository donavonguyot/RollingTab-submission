import 'package:jaspr/server.dart';

import 'main.server.options.dart';

Component el(
  String tag,
  List<Component> children, {
  Map<String, String>? attrs,
}) => Component.element(tag: tag, attributes: attrs, children: children);
Component txt(String value) => Component.text(value);
Component copy(String tag, String value, [String? className]) => el(tag, [
  txt(value),
], attrs: className == null ? null : {'class': className});
Component link(String label, String href, [String? className]) => el(
  'a',
  [txt(label)],
  attrs: {'href': href, if (className != null) 'class': className},
);

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);
  runApp(
    Document(
      title: 'RollingTAB — See the timing. Prepare the next shape.',
      lang: 'en',
      head: [
        el(
          'meta',
          [],
          attrs: {
            'name': 'description',
            'content': 'Moving TAB and a steady fretboard view. Slow a guitar passage down, loop it, and practice at your pace.',
          },
        ),
        el('meta', [], attrs: {'name': 'theme-color', 'content': '#0b171b'}),
        el(
          'link',
          [],
          attrs: {'rel': 'stylesheet', 'href': '/site-assets/site.css'},
        ),
        el(
          'link',
          [],
          attrs: {
            'rel': 'icon',
            'href': '/site-assets/favicon.svg',
            'type': 'image/svg+xml',
          },
        ),
      ],
      body: const Home(),
    ),
  );
}

class Home extends StatelessComponent {
  const Home({super.key});
  @override
  Component build(BuildContext context) => el('div', [
    link('Skip to content', '#main', 'skip-link'),
    el(
      'header',
      [
        link('RollingTAB', '/', 'wordmark'),
        el(
          'nav',
          [
            link('How it works', '#how-it-works', 'quiet-link'),
            link('Start playing ↗', '/play/', 'button button-small'),
          ],
          attrs: {'aria-label': 'Main navigation'},
        ),
      ],
      attrs: {'class': 'shell header'},
    ),
    el(
      'main',
      [
        el(
          'section',
          [
            copy('p', 'GUITAR PRACTICE, IN VIEW', 'eyebrow'),
            el('h1', [
              txt('See the timing.'),
              el('br', []),
              el('span', [txt('Prepare the next shape.')]),
            ]),
            copy(
              'p',
              'Moving TAB and a steady fretboard view bring the next notes into focus. Slow a passage down, loop it, and practice at your pace.',
              'intro',
            ),
            el(
              'div',
              [
                link('Start playing', '/play/', 'button button-primary'),
                link('See it in motion ↓', '#how-it-works', 'text-link'),
              ],
              attrs: {'class': 'hero-actions'},
            ),
            copy(
              'p',
              'Try the studies and Paganini without an account.',
              'guest-note',
            ),
          ],
          attrs: {
            'class': 'hero shell',
            'aria-label': 'Introducing RollingTAB',
          },
        ),
        el(
          'section',
          [
            el(
              'div',
              [
                copy('p', '01 / THE PRACTICE VIEW', 'eyebrow'),
                copy('p', 'Timing above. Positions at hand.', 'section-note'),
              ],
              attrs: {'class': 'section-heading'},
            ),
            el('figure', [
              el(
                'div',
                [
                  el(
                    'video',
                    [
                      el(
                        'source',
                        [],
                        attrs: {
                          'src': '/site-assets/chord-handoff.mp4',
                          'type': 'video/mp4',
                        },
                      ),
                      txt('Your browser cannot play this recording. '),
                      link(
                        'Download the demonstration',
                        '/site-assets/chord-handoff.mp4',
                      ),
                    ],
                    attrs: {
                      'controls': '',
                      'playsinline': '',
                      'preload': 'none',
                      'poster': '/site-assets/chord-handoff.jpg',
                      'width': '1052',
                      'height': '502',
                      'aria-label': 'Play the authored chord-handoff demonstration with sound',
                      'aria-describedby': 'demo-caption',
                    },
                  ),
                ],
                attrs: {'class': 'video-frame'},
              ),
              el(
                'figcaption',
                [
                  copy('strong', 'An authored chord-handoff study'),
                  copy(
                    'span',
                    'Press play for sound · 12 seconds · Actual RollingTAB playback',
                  ),
                ],
                attrs: {'id': 'demo-caption'},
              ),
            ]),
            copy(
              'p',
              'The notes approach in time while the fretboards hold their place. Outlines show what to prepare; filled positions show what is sounding. Held notes stay anchored as the shape changes.',
              'demo-description',
            ),
          ],
          attrs: {'id': 'how-it-works', 'class': 'shell demo'},
        ),
        el(
          'section',
          [
            benefit(
              '02',
              'See what’s coming.',
              'Follow the timing in Perspective TAB, with sounding and upcoming positions together in the Now + next view.',
            ),
            benefit(
              '03',
              'Prepare the change.',
              'Keep held notes in place, see new attacks, and distinguish a release from a repeated note. Switch to left-handed fretboards when that suits you.',
            ),
            benefit(
              '04',
              'Repeat the passage.',
              'Choose a passage, adjust its speed from 25% to 150%, and loop it. Invited accounts can save named passages and return to their bounds, speed, and loop setting.',
            ),
          ],
          attrs: {
            'class': 'shell benefits',
            'aria-label': 'How RollingTAB helps you practice',
          },
        ),
        el(
          'section',
          [
            copy(
              'p',
              'A little less searching. A little more playing.',
              'closing-line',
            ),
            link('Find your next practice passage ↗', '/play/', 'text-link'),
            copy(
              'p',
              'Start with the chord study or try Paganini. Repertoire positions are labeled Inferred guidance or Source TAB. Neither assigns fingers.',
              'scope-note',
            ),
          ],
          attrs: {'class': 'shell closing'},
        ),
      ],
      attrs: {'id': 'main'},
    ),
    el(
      'footer',
      [
        el('div', [
          copy('p', 'RollingTAB', 'wordmark'),
          el('p', [
            txt('A guitar-practice experiment from '),
            link('RollingNote', 'https://rollingnote.com'),
            txt('.'),
          ]),
        ]),
        el(
          'div',
          [
            el('details', [
              copy('summary', 'Credits'),
              copy(
                'p',
                'The demonstration is an authored RollingTAB study rendered with Flutter Scene. Audio uses GeneralUser GS 1.471 by S. Christian Collins. Paganini repertoire preserves its recorded CC0 attribution.',
              ),
              link(
                'SoundFont license',
                '/site-assets/GeneralUser-GS-LICENSE.txt',
              ),
            ]),
            el('details', [
              copy('summary', 'Privacy & accounts'),
              copy(
                'p',
                'This homepage adds no analytics or advertising. The demo loads when you choose to play it. In the app, guests can play without an account. Invited accounts use authentication cookies in the browser and can store named passage settings on RollingTAB’s server. The server may retain operational request logs. This POC does not use your microphone or record your performance.',
              ),
            ]),
          ],
          attrs: {'class': 'footer-details'},
        ),
      ],
      attrs: {'class': 'shell footer'},
    ),
  ]);

  Component benefit(String number, String title, String body) => el('article', [
    copy('span', number, 'step-number'),
    copy('h2', title),
    copy('p', body),
  ]);
}
