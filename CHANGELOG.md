# Changelog

All notable changes to this theme. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.1.0] - 2026-11-05

No change to how the theme looks. This release carries the build.

### Changed

- The workflows use the current versions of the GitHub actions, and Dependabot sends one grouped update a month instead of one pull request per action.

## [2.0.3] - 2026-11-03

### Changed

- The theme now has a Rubylode thumbnail, shown at the top of the README. The theme itself is unchanged.

## [2.0.2] - 2026-11-03

### Changed

- The chart colours are now a muted editorial set.

## [2.0.1] - 2026-11-02

### Added

- The theme defines the chart colour tokens the Stats plugin reads.

## [2.0.0] - 2026-11-02

### Changed

- The theme is built on the shared Rubylode theme base. The stylesheets, `javascripts/theme.js`, `test/`, `bin/demo` and `docker-compose.yml` are generated from it, and a drift check compares them with the base.
- `application.css` is now a small file that loads Redmine's own stylesheet, then `tokens.css`. `responsive.css` loads `structure.css`, `plugins.css`, `dark.css` and `flourishes.css`.
- The dark set moved from the end of `application.css` to `dark.css`. To keep the theme light-only, remove its import from `responsive.css`.
- Colours, corners, fonts and sizes are `--theme-*` tokens, with the same names in every Rubylode theme. Custom overrides that used the old names need the new ones (see the table below).
- The theme's own font stack, Inter first, is dropped. Text is Noto Sans and code is Noto Sans Mono, both bundled in `amethyst/fonts/`, and the base text size is 16px (`--theme-font-size`).
- The sidebar no longer holds the title, the search, the project jump and the profile. They are one bar across the top, and the sidebar holds the project name and its menu. The general links (Home, My page, Projects) sit in the sidebar on pages with no project menu.
- The sidebar is 232px wide, set by `--theme-sidebar-width`, with a violet tile before the project name and a bar on the edge of the selected item.
- Activity is still a feed with a date heading per day, now with a time column in front of each row. Tables, panels, the filters and the sidebar on the right follow the base, so they differ in small ways from 1.0.0. Corners are 6 to 10px and panels have a thin border.
- The issue card keeps its violet edge, and the sign-in card its violet top edge, both now from `flourishes.css`.
- The task-list issue list (status circle, priority flag, tracker square, group pills, initials and view tabs) is kept, with the same looks, in `flourishes.css` and the theme's own part of `javascripts/theme.js`.
- The page check covers 29 pages instead of 19, and the demo mounts every Rubylode plugin it finds.
- The workflows and `docs/ci.md` match the other Rubylode themes: manual runs only on `main`, and a release job that runs after the check job.

### Added

- Styles for the pages 1.0.0 did not cover: the roadmap, subtasks and child issues, the Gantt chart, the calendar, spent time, project settings, administration and the wiki editor.
- The Rubylode plugins' blocks take the theme's colours: Projects, Home, To-do, Uptime Kuma, GlitchTip, Windmill, Beszel, Stats and the New issue button.
- The theme ships Noto Sans and Noto Sans Mono as woff2 files in `amethyst/fonts/`, under the SIL Open Font License 1.1, so nothing is loaded from another site.
- The six colours of the initials, the group pills, the tracker squares and the priority flags are tokens (`--theme-initials-tone-*`, `--theme-group-*`, `--theme-tracker-*`, `--theme-priority-*`).
- The overdue date in a list takes the danger ink, which reaches AA in dark mode where Redmine's own red does not.
- `docs/accessibility.md` with the measured contrast ratios in light and dark.
- Screenshots and walkthroughs from the new demo data, with the plugin pages in them.
- Tested on Redmine 7.0.2 and the 7.0 line: 116 of 116 gated page runs in light, dark and phone width, with no console errors, no failed requests, no sideways scrolling and text at AA contrast.

### Removed

- The profile and the search field in the sidebar; both are in the top bar.
- The wiki screenshots; the page check still loads the wiki.

### Token names

| 1.0.0 | 2.0.0 |
|---|---|
| `--amethyst-violet-0` to `--amethyst-violet-9` | `--theme-accent-0` to `--theme-accent-9` |
| `--oc-blue-0` to `--oc-blue-9`, `--oc-indigo-*` | follow `--theme-accent-*` through the base |
| `--amethyst-page` | `--theme-page` |
| `--amethyst-radius` | `--theme-radius-small` |
| `--amethyst-rail` | `--theme-sidebar-background` |
| `--amethyst-rail-width` | `--theme-sidebar-width` |
| `--amethyst-rail-hover`, `--amethyst-rail-selected`, `--amethyst-rail-selected-ink`, `--amethyst-rail-line` | `--theme-sidebar-hover-background`, `--theme-sidebar-selected-background`, `--theme-sidebar-selected-ink`, `--theme-sidebar-line` |
| `--amethyst-rail-ink`, `--amethyst-rail-ink-strong`, `--amethyst-rail-dim`, `--amethyst-rail-field`, `--amethyst-rail-field-line` | no token; the sidebar uses `--theme-ink` and `--theme-ink-muted`, and the fields moved to the top bar (`--theme-header-field-*`) |
| `--amethyst-shadow` | `--theme-shadow-popup` |
| `--amethyst-phone-menu`, `--amethyst-phone-menu-ink` | no token; the colours are in `flourishes.css` |
| `--fonts-main` | `--theme-font` |
| `--color-top-menu-background`, `--color-header-background` | `--theme-header-background` |
| `--oc-gray-0` to `--oc-gray-9` | `--theme-neutral-0` to `--theme-neutral-9` |
| `--oc-white` | `--theme-redmine-white` |

## [1.0.0] - 2026-10-26

### Added

- The theme: cool neutrals and a violet accent on a white page, set through the Open Color variables Redmine 7 is built on.
- On screens 1100px and wider, all navigation moves into a light left sidebar, in plain CSS: the title, search and project jump, the general links, the project menu (or the administration menu) and, at the bottom, the profile. Narrower screens and the login page keep Redmine's own layout.
- The issue list as a task list: a status dot, a priority flag and a tracker square on every row (CSS, from the row's own classes), status groups with a coloured pill header and a count, round initials for the assignee, and Issues, Gantt, Calendar and Activity as tabs above the list. The initials, the group header colours and the tabs come from `javascripts/theme.js`, which only reads the page.
- Activity as a feed: a small date label, then rows with hairlines.
- Tighter spacing, small capitals in table headers, striped rows and thin column lines, an issue card with a violet edge, and a login card.
- A dark set for the system dark setting, in one block at the end of the stylesheet.
- The theme folder, the demo Redmine, the page check, the screenshot script and the recorder.
- Tested on Redmine 7.0.2 and the 7.0 line, in light and dark, at desktop and phone width. The gated pages, including the wiki and the Rubylode to-do page, have no console errors, no failed requests, no sideways scrolling and text at AA contrast. The calendar's "today" number is reported but not fixed.
