# Contrast

Amethyst aims at WCAG 2.2 AA in light and dark: 4.5:1 for text (3:1 for large text), and 3:1 for the parts of a control that
identify it (field borders), for focus indicators and for the graphics beside a name (priority flags, tracker squares and status circles).

## How it is measured

- The page check (`npm run check`) loads 29 pages in light and dark, at 1280px and 390px wide, and measures every visible
  piece of text against the colour stacked behind it. On 2026-11-02 against Redmine 7.0.2 with the Rubylode plugins mounted it
  measured 5,882 text pairs across the 58 desktop runs and 6,920 across the 58 phone runs, and found none below AA: 116 of 116
  gated runs clean. At the 16px base size every measured pair also reaches 4.5:1, so none relies on the 3:1 allowance for large text.
- The tokens, one pair at a time, below (`tokens.css` and `dark.css`). The check skips text over a gradient or an image, and it
  does not see field borders, focus rings or the graphics, so those are measured here. The chips on the issue page are the mixes
  the stylesheet makes (`color-mix`), worked out on the colour of the panel they sit on. The page and the panels are the same
  colour in Amethyst, so the page rows are not repeated. The header is a flat colour, so its text is measured on that colour.
- The issue list shows status and priority as plain text beside a circle or a flag, so the list has no coloured chips; the
  group pills and the assignee initials are white text on a colour, measured below.

## Light

| Pair | Foreground | Background | Ratio |
|---|---|---|---|
| Body text on a panel | `#1c1c2e` | `#ffffff` | 16.73 |
| Body text on a sunken panel or stripe | `#1c1c2e` | `#f7f7fb` | 15.66 |
| Body text on a hovered row | `#1c1c2e` | `#f6f2ff` | 15.19 |
| Secondary text on a panel | `#32324a` | `#ffffff` | 12.42 |
| Muted text on the page | `#5a5a72` | `#ffffff` | 6.69 |
| Muted text on a sunken panel or stripe | `#5a5a72` | `#f7f7fb` | 6.26 |
| Muted text on a hovered row | `#5a5a72` | `#f6f2ff` | 6.07 |
| Link on a panel | `#5f35c4` | `#ffffff` | 7.52 |
| Link on a sunken panel or stripe | `#5f35c4` | `#f7f7fb` | 7.04 |
| Link on a hovered row | `#5f35c4` | `#f6f2ff` | 6.83 |
| White on the primary | `#ffffff` | `#5f35c4` | 7.52 |
| White on the primary, hovered | `#ffffff` | `#4c28a3` | 9.81 |
| Button text | `#32324a` | `#ffffff` | 12.42 |
| Delete button text | `#a61e1e` | `#fff0f0` | 6.71 |
| Header links | `#484860` | `#ffffff` | 8.86 |
| Sidebar text | `#32324a` | `#f4f2fb` | 11.20 |
| Sidebar selected item | `#3a1d85` | `#e6dcff` | 9.47 |
| Code block (kept light) | `#1c1c2e` | `#f4f3f9` | 15.17 |
| Closed or up message | `#14633a` | `#e3f4ea` | 6.40 |
| Warning message | `#6f4306` | `#fdf1dc` | 7.57 |
| Issue page chip New, on a panel | `#404552` | `#eaebee` | 8.04 |
| Issue page chip New, on a sunken attribute panel | `#404552` | `#e3e5eb` | 7.61 |
| Issue page chip In Progress, on a panel | `#472b86` | `#ece5fb` | 8.77 |
| Issue page chip In Progress, on a sunken attribute panel | `#472b86` | `#e5def7` | 8.24 |
| Issue page chip Resolved, on a panel | `#0d4d25` | `#deede4` | 8.24 |
| Issue page chip Resolved, on a sunken attribute panel | `#0d4d25` | `#d7e6e0` | 7.73 |
| Issue page chip Feedback, on a panel | `#6c3205` | `#f5e7dd` | 8.28 |
| Issue page chip Feedback, on a sunken attribute panel | `#6c3205` | `#eee0d9` | 7.78 |
| Issue page chip Closed, on a panel | `#232331` | `#e3e3e7` | 12.10 |
| Issue page chip Closed, on a sunken attribute panel | `#232331` | `#dddde3` | 11.45 |
| Issue page chip Rejected, on a panel | `#6c150e` | `#f5e0df` | 9.48 |
| Issue page chip Rejected, on a sunken attribute panel | `#6c150e` | `#eed9db` | 8.90 |
| Status circle New (graphic), on a panel | `#6b7388` | `#ffffff` | 4.74 |
| Status circle In Progress (graphic), on a panel | `#7647e0` | `#ffffff` | 5.60 |
| Status circle Resolved (graphic), on a panel | `#15803d` | `#ffffff` | 5.02 |
| Status circle Feedback (graphic), on a panel | `#b45309` | `#ffffff` | 5.02 |
| Status circle Closed (graphic), on a panel | `#3a3a52` | `#ffffff` | 11.01 |
| Status circle Rejected (graphic), on a panel | `#b42318` | `#ffffff` | 6.57 |
| White on group pill New | `#ffffff` | `#6b7388` | 4.74 |
| White on group pill In Progress | `#ffffff` | `#7647e0` | 5.60 |
| White on group pill Resolved | `#ffffff` | `#15803d` | 5.02 |
| White on group pill Feedback | `#ffffff` | `#b45309` | 5.02 |
| White on group pill Closed | `#ffffff` | `#3a3a52` | 11.01 |
| White on group pill Rejected | `#ffffff` | `#b42318` | 6.57 |
| White on group pill Immediate | `#ffffff` | `#b3123f` | 6.83 |
| White on group pill Urgent | `#ffffff` | `#c92a2a` | 5.46 |
| White on group pill High | `#ffffff` | `#b45309` | 5.02 |
| White on group pill Normal | `#ffffff` | `#2f5fd0` | 5.72 |
| White on group pill Low | `#ffffff` | `#5a6b85` | 5.42 |
| White on assignee initials tone 0 | `#ffffff` | `#5f35c4` | 7.52 |
| White on assignee initials tone 1 | `#ffffff` | `#b0267f` | 6.12 |
| White on assignee initials tone 2 | `#ffffff` | `#0b7a75` | 5.18 |
| White on assignee initials tone 3 | `#ffffff` | `#b4540a` | 4.98 |
| White on assignee initials tone 4 | `#ffffff` | `#2554c7` | 6.62 |
| White on assignee initials tone 5 | `#ffffff` | `#15803d` | 5.02 |
| Priority flag Low (graphic), on a panel | `#6f819c` | `#ffffff` | 3.97 |
| Priority flag Normal (graphic), on a panel | `#4f7fe0` | `#ffffff` | 3.86 |
| Priority flag High (graphic), on a panel | `#d9731a` | `#ffffff` | 3.27 |
| Priority flag Urgent (graphic), on a panel | `#d63a3f` | `#ffffff` | 4.63 |
| Priority flag Immediate (graphic), on a panel | `#b3123f` | `#ffffff` | 6.83 |
| Tracker square Bug (graphic), on a panel | `#e5484d` | `#ffffff` | 3.91 |
| Tracker square Feature (graphic), on a panel | `#7647e0` | `#ffffff` | 5.60 |
| Tracker square Support (graphic), on a panel | `#0b8484` | `#ffffff` | 4.52 |
| Field border on a panel (control) | `#85859f` | `#ffffff` | 3.59 |
| Focus ring on a panel | `#7647e0` | `#ffffff` | 5.60 |

## Dark

| Pair | Foreground | Background | Ratio |
|---|---|---|---|
| Body text on a panel | `#f3f2f9` | `#17151f` | 16.23 |
| Body text on a sunken panel or stripe | `#f3f2f9` | `#1c1a26` | 15.41 |
| Body text on a hovered row | `#f3f2f9` | `#2a2145` | 13.47 |
| Secondary text on a panel | `#dedceb` | `#17151f` | 13.36 |
| Muted text on the page | `#b3b0c9` | `#17151f` | 8.57 |
| Muted text on a sunken panel or stripe | `#b3b0c9` | `#1c1a26` | 8.14 |
| Muted text on a hovered row | `#b3b0c9` | `#2a2145` | 7.11 |
| Link on a panel | `#a98af6` | `#17151f` | 6.58 |
| Link on a sunken panel or stripe | `#a98af6` | `#1c1a26` | 6.25 |
| Link on a hovered row | `#a98af6` | `#2a2145` | 5.46 |
| White on the primary | `#ffffff` | `#5f35c4` | 7.52 |
| White on the primary, hovered | `#ffffff` | `#4c28a3` | 9.81 |
| Button text | `#dedceb` | `#232130` | 11.67 |
| Delete button text | `#ffb0b0` | `#3a1d22` | 8.77 |
| Header links | `#c8c6da` | `#17151f` | 10.78 |
| Sidebar text | `#dedceb` | `#120f1a` | 14.02 |
| Sidebar selected item | `#ffffff` | `#3a2a73` | 11.94 |
| Code block (kept light) | `#1c1c2e` | `#f4f3f9` | 15.17 |
| Closed or up message | `#bdf0d4` | `#14392a` | 10.06 |
| Warning message | `#f8dfa8` | `#46320d` | 9.35 |
| Issue page chip New, on a panel | `#ced2dc` | `#363642` | 7.87 |
| Issue page chip New, on a sunken attribute panel | `#ced2dc` | `#3a3a48` | 7.39 |
| Issue page chip In Progress, on a panel | `#d0bffa` | `#372f4e` | 7.45 |
| Issue page chip In Progress, on a sunken attribute panel | `#d0bffa` | `#3b3354` | 7.00 |
| Issue page chip Resolved, on a panel | `#9ddebf` | `#233b37` | 7.78 |
| Issue page chip Resolved, on a sunken attribute panel | `#9ddebf` | `#273f3c` | 7.32 |
| Issue page chip Feedback, on a panel | `#f7cf9b` | `#473528` | 7.94 |
| Issue page chip Feedback, on a sunken attribute panel | `#f7cf9b` | `#4b392e` | 7.46 |
| Issue page chip Closed, on a panel | `#c1c1d4` | `#31303f` | 7.29 |
| Issue page chip Closed, on a sunken attribute panel | `#c1c1d4` | `#353444` | 6.86 |
| Issue page chip Rejected, on a panel | `#ffbfbf` | `#4a2f37` | 7.68 |
| Issue page chip Rejected, on a sunken attribute panel | `#ffbfbf` | `#4e333c` | 7.22 |
| Status circle New (graphic), on a panel | `#a6adc0` | `#17151f` | 8.04 |
| Status circle In Progress (graphic), on a panel | `#a98af6` | `#17151f` | 6.58 |
| Status circle Resolved (graphic), on a panel | `#4cc38a` | `#17151f` | 8.15 |
| Status circle Feedback (graphic), on a panel | `#f0a84a` | `#17151f` | 8.94 |
| Status circle Closed (graphic), on a panel | `#8f8fb0` | `#17151f` | 5.78 |
| Status circle Rejected (graphic), on a panel | `#ff8a8a` | `#17151f` | 7.95 |
| White on group pill New | `#ffffff` | `#6b7388` | 4.74 |
| White on group pill In Progress | `#ffffff` | `#7647e0` | 5.60 |
| White on group pill Resolved | `#ffffff` | `#15803d` | 5.02 |
| White on group pill Feedback | `#ffffff` | `#b45309` | 5.02 |
| White on group pill Closed | `#ffffff` | `#3a3a52` | 11.01 |
| White on group pill Rejected | `#ffffff` | `#b42318` | 6.57 |
| White on group pill Immediate | `#ffffff` | `#b3123f` | 6.83 |
| White on group pill Urgent | `#ffffff` | `#c92a2a` | 5.46 |
| White on group pill High | `#ffffff` | `#b45309` | 5.02 |
| White on group pill Normal | `#ffffff` | `#2f5fd0` | 5.72 |
| White on group pill Low | `#ffffff` | `#5a6b85` | 5.42 |
| White on assignee initials tone 0 | `#ffffff` | `#5f35c4` | 7.52 |
| White on assignee initials tone 1 | `#ffffff` | `#b0267f` | 6.12 |
| White on assignee initials tone 2 | `#ffffff` | `#0b7a75` | 5.18 |
| White on assignee initials tone 3 | `#ffffff` | `#b4540a` | 4.98 |
| White on assignee initials tone 4 | `#ffffff` | `#2554c7` | 6.62 |
| White on assignee initials tone 5 | `#ffffff` | `#15803d` | 5.02 |
| Priority flag Low (graphic), on a panel | `#8d9bb3` | `#17151f` | 6.42 |
| Priority flag Normal (graphic), on a panel | `#78a0f2` | `#17151f` | 6.97 |
| Priority flag High (graphic), on a panel | `#f0914a` | `#17151f` | 7.61 |
| Priority flag Urgent (graphic), on a panel | `#ff7b7b` | `#17151f` | 7.19 |
| Priority flag Immediate (graphic), on a panel | `#ff6b8e` | `#17151f` | 6.66 |
| Tracker square Bug (graphic), on a panel | `#ff7378` | `#17151f` | 6.85 |
| Tracker square Feature (graphic), on a panel | `#a98af6` | `#17151f` | 6.58 |
| Tracker square Support (graphic), on a panel | `#3cc8c8` | `#17151f` | 8.84 |
| Field border on a panel (control) | `#7b7899` | `#17151f` | 4.29 |
| Focus ring on a panel | `#a98af6` | `#17151f` | 6.58 |

## Not covered

- Redmine's own avatar colours with white initials: the three that fall below 4.5:1 (red, orange, pink) are darkened; the rest
  are Redmine's.
- Syntax highlighting inside code blocks is Redmine's, made for a light background, which is why code blocks stay light in dark mode.
- Colour is never the only signal: the status circle, the flag and the tracker square sit beside their names, and an empty circle
  and a full one tell the statuses apart without colour.
