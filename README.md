# Rubylode Amethyst for Redmine

<p><img src="docs/thumbnail.png" alt="Rubylode Amethyst theme" width="160"></p>

A light theme for Redmine 7 and up: a white page with cool violet-tinted greys and one violet, a light project sidebar on wide screens, and an issue list laid out as a task list with status circles, priority flags and status group pills.

It is plain CSS plus one small script (`javascripts/theme.js`), with no plugin, no build step and no change to Redmine itself.
The script only reads the page: it gives the top bar a shadow once the page scrolls, marks the group rows of the issue list so the
stylesheet can colour them, puts round initials beside the assignee and builds the row of view tabs (Issues, Gantt, Calendar, Activity)
above the list. Without it the theme still works, with plainer lists. The dark set follows your
system setting (see [Dark mode](#dark-mode)). It is built on the shared Rubylode theme base, which also gives it the pages and plugin blocks listed below.

![A walk through Rubylode Amethyst: the project, the issue list, an issue, the to-do page and the new issue form](docs/demo/walkthrough-light.gif)

| | |
|---|---|
| ![The issue list, grouped by status](docs/screenshots/issues-grouped-light.png) | ![An issue](docs/screenshots/issue-light.png) |
| ![The new issue form](docs/screenshots/new-issue-light.png) | ![The project overview, with the Rubylode Projects plugin](docs/screenshots/project-light.png) |
| ![The projects list, with the Rubylode Projects plugin](docs/screenshots/projects-light.png) | ![The home page, with the Rubylode Home plugin](docs/screenshots/home-light.png) |
| ![My page, with the Rubylode Home plugin](docs/screenshots/my-page-light.png) | ![A status block, with the Rubylode Uptime Kuma plugin](docs/screenshots/service-status-light.png) |
| ![The Stats page, with the Rubylode Stats plugin](docs/screenshots/stats-light.png) | ![The to-do page, with the Rubylode To-do plugin](docs/screenshots/todo-light.png) |

Dark mode:

![A walk through Rubylode Amethyst in dark mode](docs/demo/walkthrough-dark.gif)

| | |
|---|---|
| ![The issue list in dark mode](docs/screenshots/issues-grouped-dark.png) | ![An issue in dark mode](docs/screenshots/issue-dark.png) |
| ![The new issue form in dark mode](docs/screenshots/new-issue-dark.png) | ![The project overview in dark mode](docs/screenshots/project-dark.png) |
| ![The projects list in dark mode](docs/screenshots/projects-dark.png) | ![The home page in dark mode](docs/screenshots/home-dark.png) |
| ![My page in dark mode](docs/screenshots/my-page-dark.png) | ![A status block in dark mode](docs/screenshots/service-status-dark.png) |
| ![The Stats page in dark mode](docs/screenshots/stats-dark.png) | ![Sign in in dark mode](docs/screenshots/login-dark.png) |

The screenshots come from the demo Redmine in this repository; the people, projects and issues in it are made up.

## Contents

- [What it looks like](#what-it-looks-like)
- [Install](#install)
- [What is covered](#what-is-covered)
- [Rubylode plugins](#rubylode-plugins)
- [Customising](#customising)
- [Fonts](#fonts)
- [Dark mode](#dark-mode)
- [Accessibility](#accessibility)
- [Compatibility](#compatibility)
- [Development](#development)
- [Checks and releases](#checks-and-releases)
- [License](#license)

## What it looks like

- A white top bar with the global links, the search, the project switcher and your avatar. Below 1100px wide the project name and
  tabs sit in a bar under it, as in Redmine.
- From 1100px up, the project is a light violet sidebar down the left: a violet tile, the project name, the "+" button and the menu,
  with the current item marked by a bar on its edge. The administration menu takes its place on administration pages.
- A New issue button beside the search, when the Rubylode New issue button plugin is installed.
- Corners are 6 to 10 pixels, panels are flat and set apart by thin lines, and the one shadow is on things that float, such as menus.
- The issue list is a task list. The status is a circle in front of its name, empty for New, Feedback and Rejected and full for In
  Progress, Resolved and Closed. The priority is a flag in the level colour, the tracker is a small coloured square, and the assignee
  is a round badge with their initials (the name is its tooltip). In a list grouped by status or priority, each group row is a coloured pill with a count.
- Issues, Gantt, Calendar and Activity are tabs above the list.
- An issue is a flat card with a violet edge, a labelled attribute panel and a card per note in the history. The sign-in card has a violet top edge.
- The phone slide-out menu is dark violet, in light mode too.

## Install

1. Download the zip attached to the latest release (the Releases page of this repository) and unzip it inside the `themes` folder of your Redmine, so that `themes/amethyst/stylesheets/application.css` exists. Or clone this repository and copy (or link) its `amethyst` folder into `themes/`.
2. Restart Redmine.
3. In Administration, Settings, Display, choose **Rubylode Amethyst** as the theme and save.

To go back, choose another theme on the same page. Nothing is written to the database apart from that setting.

The theme folder holds the stylesheets, `javascripts/theme.js` and the fonts.

## What is covered

The page check loads these pages, in light and dark, at desktop and phone width: sign in, the home page, the project
overview (Redmine's own and the Rubylode Projects plugin's), the projects list, the issue list (plain and grouped), activity, the
roadmap, an issue, an issue with subtasks, a child issue, the edit and new issue forms, the to-do page, the Stats page, the pages
of the four status plugins, My page (Redmine's own and the Rubylode Home plugin's), a wiki page and its editor, spent time, Gantt,
the calendar, project settings and administration.
Flash messages, tabs, the right-click menu, dropdowns, pagination, the text editor and the phone slide-out menu are styled as well.

<!-- rubylode-plugins:start -->
## Rubylode plugins

Rubylode Amethyst styles the Rubylode plugins' blocks natively. Each plugin draws with its own CSS custom properties, and one section of the
theme, `amethyst/stylesheets/plugins.css`, points them at Rubylode Amethyst's tokens, so the blocks follow the theme in light and dark:

- [Rubylode Projects](https://github.com/rubylode/redmine-rubylode-projects) (`--rubylode-projects-*`): the overview cards and the projects list.
- [Rubylode Home](https://github.com/rubylode/redmine-rubylode-home) (`--rubylode-home-*`): My page and the welcome page.
- [Rubylode To-do](https://github.com/rubylode/redmine-rubylode-todo) (`--todo-*`): the to-do page.
- [Rubylode Uptime Kuma](https://github.com/rubylode/redmine-rubylode-uptime-kuma) (`--rubylode-uptime-kuma-*`),
  [Rubylode GlitchTip](https://github.com/rubylode/redmine-rubylode-glitchtip) (`--rubylode-glitchtip-*`),
  [Rubylode Windmill](https://github.com/rubylode/redmine-rubylode-windmill) (`--rubylode-windmill-*`) and
  [Rubylode Beszel](https://github.com/rubylode/redmine-rubylode-beszel) (`--rubylode-beszel-*`): the status blocks.
- [Rubylode Stats](https://github.com/rubylode/redmine-rubylode-stats) (`--stats-tooltip-*`): the chart tooltip.
- [Rubylode New issue button](https://github.com/rubylode/redmine-rubylode-new-issue-button): a rounded primary button beside the search.
  Plugins load their stylesheets after the theme's, so these rules start with `body #header` to win whatever the order.

None of them is needed. Without a plugin its rules match nothing.
<!-- rubylode-plugins:end -->

## Customising

Every colour, corner, shadow, font and a few sizes are custom properties in `amethyst/stylesheets/tokens.css` (light values) and
`amethyst/stylesheets/dark.css` (dark values). Change them there, or override them from a stylesheet of your own. The names
start with `--theme-` and are the same in every Rubylode theme. The main ones:

| Token | What it is |
|---|---|
| `--theme-page`, `--theme-surface`, `--theme-surface-sunken`, `--theme-surface-hover` | the page, the panels, stripes and attribute panels, hovered rows |
| `--theme-line`, `--theme-line-soft`, `--theme-line-strong` | panel borders and row lines, column lines, field borders |
| `--theme-ink`, `--theme-ink-soft`, `--theme-ink-muted` | text, secondary text, labels and notes |
| `--theme-accent-0` to `--theme-accent-9` | the violet ramp; `--theme-link`, `--theme-primary` and Redmine's blue ramp point into it |
| `--theme-secondary`, `--theme-tertiary` and their `-pale` twins | the light violet in the focus halo and text selection, the amber in search highlights |
| `--theme-primary-background`, `--theme-header-background` | the primary button and the top bar |
| `--theme-sidebar-width`, `--theme-sidebar-background`, `--theme-sidebar-selected-background` | the project sidebar |
| `--theme-status-new`, `-in-progress`, `-resolved`, `-feedback`, `-closed`, `-rejected` | status colours, by Redmine's default status ids 1 to 6 |
| `--theme-priority-low` to `--theme-priority-immediate`, `--theme-tracker-bug`, `-feature`, `-support` | the priority flags and the tracker squares |
| `--theme-group-*` | the colours of the group pills in a grouped list |
| `--theme-initials-tone-0` to `-5` | the six colours of the assignee initials |
| `--theme-radius-small`, `--theme-radius`, `--theme-radius-panel`, `--theme-radius-pill` | corners of fields, cards, panels and pills |
| `--theme-border-width`, `--theme-border-style`, `--theme-density` | panel borders, and the height of table rows and list items |
| `--theme-font-size` | the size of running text (16px); every other text size follows it |
| `--theme-font`, `--theme-font-monospace`, `--theme-title-font`, `--theme-title-weight` | the text, code and heading fonts |

The rest (messages, avatars, diffs, the Gantt chart, the header heights, the icons drawn in the stylesheet) are listed with a
comment each in `tokens.css`.

What the tokens cannot say is in `amethyst/stylesheets/flourishes.css`: the violet edges, the task-list cells of the issue list, the
group pills, the initials, the view tabs and the dark phone menu.

Status, priority and tracker looks are matched by Redmine's default ids (statuses 1 New to 6 Rejected, priorities 1 Low to 5
Immediate, trackers 1 Bug to 3 Support). If yours differ, change the ids in the "issue list" section of
`amethyst/stylesheets/structure.css` and in the second section of `flourishes.css`.

## Fonts

Amethyst ships its own fonts, so text looks the same on every system and nothing is loaded from another site: Noto Sans for
text and Noto Sans Mono for code, as woff2 files in `amethyst/fonts/` (latin and latin-ext). Both are under the SIL Open
Font License 1.1; the licence texts are in the same folder. A browser downloads a file only when a page uses it. To use other
fonts, change `--theme-font` and `--theme-font-monospace` in `amethyst/stylesheets/tokens.css`. The size of running text is
`--theme-font-size` (16px), and every other text size follows it.

## Dark mode

Dark mode follows your system setting (`prefers-color-scheme`): a near-black violet page and panels, a lighter violet for links and the
sidebar's selected item in a deep violet. Code blocks stay light, since Redmine's syntax colours are made for a light background.
To keep Amethyst light-only, remove the line `@import url(dark.css);` from `amethyst/stylesheets/responsive.css`; every dark
value is in that one file.

## Accessibility

Text and controls meet WCAG AA in both modes. The page check measures every visible text against the colour behind it on every
page; the tokens were also measured one by one, including the parts the check cannot see (field borders, focus rings, the
priority flags and tracker squares). The measured ratios are in [docs/accessibility.md](docs/accessibility.md). In short: body text at least 15.2:1
in light and 13.5:1 in dark, secondary text at least 12.4:1 and 13.4:1, muted text at least 6.1:1 and 7.1:1, links at least 6.8:1 and 5.5:1, white on the
primary at least 7.5:1, every chip on the issue page at least 6.9:1, field borders and focus rings at least 3.5:1.

## Compatibility

Redmine 7.0 and newer. Tested on 7.0.2, from both the `7.0.2` and the `7.0` image tags (on 2026-11-02 the 7.0 line was at 7.0.2). Older versions are not expected to work: Redmine 7 reads a theme from `themes/<name>` and is
built on the Open Color variables this theme remaps.

Browsers: current Chrome, Edge, Firefox and Safari. The theme uses `:has()` and `color-mix()` (Chrome 111, Firefox 121,
Safari 16.4 and newer); an older browser shows plainer lists and keeps the rest.

## Development

You need Docker, Ruby, Node and Chrome.

```
npm install
ruby bin/demo up        # a throwaway Redmine with demo data at http://localhost:3102 (admin / admin)
npm run check           # loads every page in light and dark, at desktop and phone width
npm run screenshots     # docs/screenshots
npm run record          # docs/demo, a GIF of a walk through the pages
ruby bin/demo reset     # wipe the demo
```

If copies of the Rubylode plugins listed above sit next to this repository (`../redmine-rubylode-todo` and so on, or in a folder
named in `RUBYLODE_PLUGINS_DIR`), the demo mounts them and the check, screenshots and recording show their pages. The demo points
the status plugins at an address where nothing answers, so their pages show the "unavailable" state. Without the plugins the
demo is plain Redmine, and the check skips their pages.

The stylesheets other than `flourishes.css`, `javascripts/theme.js`, `test/`, `bin/demo` and `docker-compose.yml` are generated from
the base all Rubylode themes share, so a fix there reaches every theme. If you send a change to one of them, I will carry it over to the base.

The check fails on console errors, failed requests, sideways scrolling and text below WCAG AA contrast. `REDMINE_TAG=7.0 ruby bin/demo up`
runs it against another Redmine version. After you change a stylesheet, run `ruby bin/demo restart` and reload: Redmine caches theme
files until it restarts.

## Checks and releases

Every push starts a real Redmine from its Docker image (7.0.2 and the 7.0 line), loads every page of the theme in light and dark at desktop and phone width, and fails on console errors, failed requests, sideways scrolling and low text contrast. On GitHub that is `.github/workflows/check.yml`, on GitHub's own runners, and it also runs on pull requests. On a self-hosted Gitea it is `.gitea/workflows/check.yml`, which runs only on pushes to `main`, because that runner works on the host with Docker access and must only run code that is already merged.

A tag such as `v2.0.0` runs the same check, builds `amethyst-<version>.zip` holding the theme folder, and attaches it to a release with the matching section of `CHANGELOG.md` as its notes (`release.yml` in the same folders). The tag needs a section for that version in the changelog. More on both, and on the drift check against the shared base, in [docs/ci.md](docs/ci.md).

## License

GPL version 2 or later, the same as Redmine. See `LICENSE`. Copyright (C) 2026  Nick Gorbikoff.

No warranty, as the GPL says. Try it on a copy of your tracker before the real one.
