# Amethyst for Redmine

Violet accents and a light sidebar, with the issue list as a task list: status dots, priority flags, status groups and view tabs.

A theme for Redmine 7 and up. It is CSS plus one small script (`javascripts/theme.js`, about 70 lines), with no plugin and no change to Redmine itself. The script only reads the page: it colours status group headers, adds initials next to assignees and builds a row of view tabs. Without it the theme still works, with plainer lists. Light first, with a dark set that follows your system setting (see [Dark mode](#dark-mode)).

![A walk through Amethyst: the issue list, an issue, the wiki, the to-do page and the new-issue form](docs/demo/walkthrough-light.gif)

| | |
|---|---|
| ![The issue list, grouped by status](docs/screenshots/issues-grouped-light.png) | ![An issue](docs/screenshots/issue-light.png) |
| ![The wiki](docs/screenshots/wiki-light.png) | ![The to-do page](docs/screenshots/todo-light.png) |
| ![The project list](docs/screenshots/projects-light.png) | ![The new issue form](docs/screenshots/new-issue-light.png) |

Dark mode:

![A walk through Amethyst in dark mode](docs/demo/walkthrough-dark.gif)

| | |
|---|---|
| ![The issue list in dark mode](docs/screenshots/issues-grouped-dark.png) | ![An issue in dark mode](docs/screenshots/issue-dark.png) |

## Contents

- [Install](#install)
- [What is covered](#what-is-covered)
- [Dark mode](#dark-mode)
- [Compatibility](#compatibility)
- [Development](#development)
- [Checks and releases](#checks-and-releases)
- [License](#license)
- [Disclaimer](#disclaimer)

## Install

1. Download the zip attached to the latest release (the Releases page of this repository) and unzip it inside the `themes` folder of your Redmine, so that `themes/amethyst/stylesheets/application.css` exists. Or copy the `amethyst` folder from the source tree.
2. Restart Redmine.
3. In Administration, Settings, Display, choose **Amethyst** as the theme and save.

To go back, choose another theme on the same page. Nothing is written to the database apart from that setting.

## What is covered

The header and menus, the sidebar, the issue list, the issue page with its history, the new and edit forms, buttons, flash
messages, tables, tabs, the context menu and the login page, in light and dark. Other pages (Gantt, calendar, wiki, administration)
take their colours from the same variables and are fixed up as problems turn up.

## Dark mode

Dark mode follows your system setting and is part of the design, not an afterthought. If you would rather the theme stayed light, delete the `@media (prefers-color-scheme: dark)` block at the end of `amethyst/stylesheets/application.css`; every dark rule is in that one block.

## Compatibility

Redmine 7.0 and newer. Tested on 7.0.2 and the 7.0 line. Older versions are not expected to work.

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

If a copy of the Rubylode to-do plugin sits next to this repository (`../redmine-rubylode-todo`, or set `TODO_PLUGIN_PATH`), the demo mounts it and
the check, screenshots and recording include its page. Without it they skip that page.

The check fails on console errors, failed requests, sideways scrolling and text below WCAG AA contrast. `REDMINE_TAG=7.0 ruby bin/demo up`
runs it against another Redmine version. After you change the stylesheet, run `ruby bin/demo restart` and reload: Redmine caches theme
files until it restarts.

## Checks and releases

Every push to `main` (not pull requests: the runner works on the host with Docker access, so it only runs code that is already merged) starts a real Redmine from its Docker image (7.0.2 and the 7.0 line), loads every page of the theme in light and dark at desktop and phone width, and fails on console errors, failed requests, sideways scrolling and low text contrast. The workflow is in `.gitea/workflows/check.yml` and runs on a runner with Docker, Node, Ruby and Chrome.

A tag such as `v1.0.0` runs the same check, builds `<name>-<version>.zip` holding the theme folder, and attaches it to a release with the matching section of `CHANGELOG.md` as its notes (`.gitea/workflows/release.yml`). The tag needs a section for that version in the changelog.

## License

GPL version 2 or later, the same as Redmine. See `LICENSE`. Copyright (C) 2026  Nick Gorbikoff.

## Disclaimer

Use at your own risk. This software is provided as is, without warranty of any kind, express or implied. The author is not
liable for any damage, data loss or downtime that comes from using it. Try it on a copy of your tracker before you use it on the
real one.
