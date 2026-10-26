# Changelog

All notable changes to this theme. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-10-26

### Added

- Amethyst: cool neutrals and a violet accent on a white page, in the Open Color variables Redmine 7 is built on.
- On screens 1100px and wider, all navigation moves into a light left sidebar, in plain CSS: the title, search and project jump, the general links, the project menu (or the administration menu) and, at the bottom, the profile. Narrower screens and the login page keep Redmine's own layout.
- The issue list reads as a task list: a status dot, a priority flag and a tracker square on every row (CSS, from the row's own classes), status groups with a coloured pill header and a count, round initials for the assignee, and Issues, Gantt, Calendar and Activity as tabs above the list. The last three come from one small script, `javascripts/theme.js`, which only reads the page.
- Activity is a quiet feed: a small date label, then rows with hairlines.
- Tighter spacing, small capitals in table headers, striped rows and thin column lines, an issue card with a violet edge, a login card.
- A dark set for the system dark setting, in one block at the end of the stylesheet.
- The theme skeleton, the demo Redmine, the page check, the screenshot script and the recorder.
- Tested on Redmine 7.0.2 and the 7.0 line, in light and dark, at desktop and phone width: no console errors, no failed requests, no sideways scrolling, and text at AA contrast on the pages that matter, including the wiki and the Rubylode to-do page. The calendar's "today" number is reported but not fixed.
