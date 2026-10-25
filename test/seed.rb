# frozen_string_literal: true

# Demo data for checking a theme and taking its screenshots. The people and the work are made up.
# Run by `ruby bin/demo up` through rails runner; running it twice changes nothing the second time.

Redmine::DefaultData::Loader.load("en") if Tracker.none?
Setting.default_language = "en"
Setting.text_formatting = "common_mark"
Setting.welcome_text = "Welcome to the demo tracker."
Setting.notified_events = [] # no mail from the demo

admin = User.find_by_login("admin")
admin.update_columns(must_change_passwd: false)
User.current = admin

if News.exists?(title: "1.1 is two weeks out") # the last thing this script creates
  puts "demo data already loaded"
  return
end
abort "The demo data is half loaded. Run: ruby bin/demo reset" if Project.exists?(identifier: "atlas")

today = Date.today
now = Time.current
todo_plugin = Redmine::Plugin.registered_plugins.key?(:redmine_rubylode_todo)
if todo_plugin
  Setting.default_projects_modules = Setting.default_projects_modules | ["rubylode_todo"]
  Role.where(builtin: 0).each { |role| role.add_permission!(:use_rubylode_todo) }
end

role_named = ->(name) { Role.find_by!(name: name) }

people = [
  ["ada", "Ada", "Lovelace", "Manager"],
  ["charles", "Charles", "Babbage", "Developer"],
  ["grace", "Grace", "Hopper", "Developer"],
  ["alan", "Alan", "Turing", "Reporter"]
].to_h do |login, first, last, role_name|
  user = User.new(login: login, firstname: first, lastname: last, mail: "#{login}@example.com", language: "en")
  user.password = user.password_confirmation = "demo-password-1"
  user.save!
  [login, [user, role_name]]
end
user_for = ->(login) { login ? people.fetch(login).first : nil }

# ---- Projects: three top-level products, with subprojects ----

module_names = %w[issue_tracking time_tracking news documents files wiki gantt calendar]
module_names << "rubylode_todo" if todo_plugin

make_project = lambda do |name, identifier, description, parent: nil|
  project = Project.new(name: name, identifier: identifier, description: description, is_public: true, enabled_module_names: module_names)
  project.parent = parent if parent
  project.trackers = Tracker.all
  project.save!
  people.each_value { |user, role_name| Member.create!(project: project, principal: user, roles: [role_named.(role_name)]) }
  project
end

projects = {}
projects[:atlas] = make_project.("Atlas", "atlas", "The mapping service: tiles, search and the public API.")
projects[:harbor] = make_project.("Harbor", "harbor", "Deployment and hosting for Atlas.", parent: projects[:atlas])
projects[:staging] = make_project.("Staging", "harbor-staging", "The staging copy of Atlas.", parent: projects[:harbor])
projects[:compass] = make_project.("Compass", "compass", "The documentation site and the getting started guide.", parent: projects[:atlas])
projects[:lantern] = make_project.("Lantern", "lantern", "The status page and alerting.")
projects[:alerts] = make_project.("Alerts", "lantern-alerts", "Paging, quiet hours and the on-call rotation.", parent: projects[:lantern])
projects[:beacon] = make_project.("Beacon", "beacon", "The mobile apps for Atlas.")
projects[:ios] = make_project.("iOS app", "beacon-ios", "The iPhone and iPad app.", parent: projects[:beacon])
projects[:android] = make_project.("Android app", "beacon-android", "The Android app.", parent: projects[:beacon])

versions = {}
{ atlas: [["1.0", "closed", -30, nil], ["1.1", "open", 14, "Search and the new tile cache."], ["2.0", "open", 90, "Offline maps."]],
  lantern: [["1.0", "open", 20, "Uptime history and email subscriptions."]],
  beacon: [["2.3", "closed", -12, nil], ["2.4", "open", 30, "Dark mode and offline areas."]] }.each do |key, list|
  list.each do |name, status, offset, description|
    versions[[key, name]] = Version.create!(project: projects[key], name: name, status: "open", effective_date: today + offset, description: description)
  end
end
categories = %w[Backend Frontend Infrastructure Docs].to_h { |name| [name, IssueCategory.create!(project: projects[:atlas], name: name)] }

# ---- Issues ----

closed_statuses = %w[Closed Rejected]
make_issue = lambda do |attributes|
  project = projects.fetch(attributes.fetch(:project, :atlas))
  issue = Issue.new(project: project, author: user_for.(attributes[:author]) || admin,
                    tracker: Tracker.find_by!(name: attributes.fetch(:tracker)),
                    status: IssueStatus.find_by!(name: attributes.fetch(:status, "New")),
                    priority: IssuePriority.find_by!(name: attributes.fetch(:priority, "Normal")),
                    subject: attributes.fetch(:subject), description: attributes[:description],
                    assigned_to: user_for.(attributes[:assignee]), category: (project == projects[:atlas] ? categories[attributes[:category]] : nil),
                    fixed_version: versions[[attributes.fetch(:project, :atlas), attributes[:version]]], done_ratio: attributes.fetch(:done, 0),
                    estimated_hours: attributes[:estimate], start_date: attributes[:start] && today + attributes[:start],
                    due_date: attributes[:due] && today + attributes[:due])
  issue.parent_issue_id = attributes[:parent].id if attributes[:parent]
  issue.save!
  issue.reload
  # Spread the history over the last weeks so the activity page and the "updated" column look lived in.
  age = attributes[:age] || 1
  created = now - age.days
  issue.update_columns(created_on: created, updated_on: created + 3.hours, closed_on: (closed_statuses.include?(attributes[:status]) ? created + 2.days : nil))
  issue
end

showcase_text = <<~MARKDOWN
  Tiles near the poles come back blank at zoom levels above 12. Seen in the web client and in the mobile apps, so it is the service and not the viewer.

  ## What happens

  1. Request a tile north of 85° at zoom 13 or higher.
  2. The service answers `200` with an empty body.
  3. The client caches the blank tile for a day.

  ## What I expect

  A tile with the polar cap drawn, or a `404` the client can handle.

  > The cache hides it on a second try, so test with a cold cache.

  | Zoom | Tile rows | Result |
  |------|-----------|--------|
  | 11   | 2048      | drawn  |
  | 12   | 4096      | drawn  |
  | 13   | 8192      | blank  |

  ```ruby
  def tile_for(latitude, longitude, zoom)
    row = ((1 - Math.log(Math.tan(latitude.to_f * Math::PI / 180) + 1 / Math.cos(latitude.to_f * Math::PI / 180)) / Math::PI) / 2 * 2**zoom).floor
    [row, ((longitude + 180) / 360 * 2**zoom).floor]
  end
  ```

  Checklist before closing:

  - [x] Reproduce on a cold cache
  - [ ] Fix the row calculation near the poles
  - [ ] Add a regression test
  - [ ] Purge the blank tiles from the cache

  See also the [tile format notes](https://example.com/tiles) and `config/tiles.yml`.
MARKDOWN

showcase = make_issue.(tracker: "Bug", status: "In Progress", priority: "Urgent", subject: "Tiles near the poles come back blank above zoom 12",
                       description: showcase_text, author: "alan", assignee: "charles", category: "Backend", version: "1.1", done: 40,
                       estimate: 12, start: -6, due: 3, age: 3)

[
  ["ada", "Confirmed on staging and on production. Taking it as the 1.1 blocker.", { priority: IssuePriority.find_by!(name: "Urgent") }],
  ["charles", "The row calculation overflows at the poles; I have a fix, still adding the test.", { status: IssueStatus.find_by!(name: "In Progress"), done_ratio: 40 }],
  ["grace", "The mobile apps cache the blank tile for a day, so they will show it until the cache expires.", {}],
  ["alan", "Cold cache reproduces it every time, a warm cache hides it.", {}]
].each do |login, notes, changes|
  User.current = user_for.(login)
  showcase.reload.init_journal(User.current, notes)
  changes.each { |key, value| showcase.public_send("#{key}=", value) }
  showcase.save!
end
User.current = admin

# project, tracker, status, priority, subject, assignee, extras. Closed and rejected ones carry the note that closed them.
issues = [
  [:atlas, "Bug", "Resolved", "High", "Search returns places from the wrong country", "grace", { category: "Backend", version: "1.1", done: 100, estimate: 6, start: -20, due: -4, age: 22 }],
  [:atlas, "Feature", "In Progress", "High", "A new tile cache with per-zoom expiry", "charles", { category: "Backend", version: "1.1", done: 60, estimate: 40, start: -12, due: 9, age: 15 }],
  [:atlas, "Feature", "New", "Normal", "Offline map packs for a chosen area", "grace", { category: "Frontend", version: "2.0", estimate: 80, start: 20, due: 80, age: 9 }],
  [:atlas, "Feature", "Feedback", "Normal", "Dark map style", "grace", { category: "Frontend", version: "1.1", done: 80, estimate: 16, start: -9, due: 5, age: 8 }],
  [:atlas, "Support", "New", "Low", "How do I embed a map in a page that blocks scripts?", nil, { category: "Docs", author: "alan", age: 6 }],
  [:atlas, "Bug", "New", "Normal", "The scale bar shows miles when the unit is set to metres", nil, { category: "Frontend", version: "1.1", author: "alan", due: -2, age: 7 }],
  [:atlas, "Feature", "New", "Low", "Export a route as a GPX file", nil, { category: "Backend", version: "2.0", estimate: 10, age: 5 }],
  [:atlas, "Bug", "In Progress", "Immediate", "The API returns 500 for an empty search string", "charles", { category: "Backend", version: "1.1", done: 20, estimate: 3, start: -1, due: 0, age: 1 }],
  [:atlas, "Support", "Resolved", "Normal", "Rate limit headers are missing from cached responses", "charles", { category: "Docs", version: "1.1", done: 100, author: "grace", age: 4 }],
  [:atlas, "Bug", "Closed", "Normal", "Attribution text overlaps the zoom buttons on small screens", "grace", { category: "Frontend", version: "1.0", done: 100, start: -50, due: -35, age: 52, note: "Fixed in 1.0. The text moves above the buttons below 480px." }],
  [:atlas, "Feature", "Closed", "High", "Public API keys with per-key rate limits", "charles", { category: "Backend", version: "1.0", done: 100, estimate: 30, start: -70, due: -32, age: 72, note: "Shipped in 1.0. Limits are 600 requests a minute by default and can be raised per key." }],
  [:atlas, "Bug", "Closed", "Normal", "Fix the tile cache key for retina tiles", "charles", { category: "Backend", version: "1.0", done: 100, age: 44, note: "The key now includes the pixel ratio. Old entries expire on their own within a day." }],
  [:atlas, "Feature", "Closed", "High", "Add rate limit headers to every response", "charles", { category: "Backend", version: "1.0", done: 100, age: 40, note: "Done. The cached path was missed and is tracked as a support ticket." }],
  [:atlas, "Support", "Closed", "Low", "Document the search query syntax", "grace", { category: "Docs", version: "1.0", done: 100, age: 34, note: "Added to the guide, with six examples." }],
  [:atlas, "Feature", "Closed", "Normal", "Upgrade the base image to the current LTS", "charles", { category: "Infrastructure", version: "1.0", done: 100, age: 30, note: "Done. Image size dropped from 310 MB to 190 MB." }],
  [:atlas, "Bug", "Rejected", "Low", "Reports of slow search near Tokyo", "ada", { category: "Backend", age: 27, author: "alan", note: "Could not reproduce. The slow responses all came through one customer's proxy." }],
  [:atlas, "Bug", "Closed", "Normal", "Duplicate tiles in the Antarctica cache", "grace", { category: "Backend", version: "1.1", done: 100, age: 20, note: "Fixed with the cache key change. Purged the duplicates." }],
  [:harbor, "Feature", "In Progress", "High", "Move the tile servers to the new cluster", "charles", { due: 21, done: 50, age: 12 }],
  [:harbor, "Feature", "New", "Normal", "Rotate the database credentials", "ada", { due: 21, age: 6 }],
  [:harbor, "Feature", "New", "Normal", "Alert when disk use passes 80 percent", nil, { due: 28, age: 4 }],
  [:harbor, "Feature", "Closed", "High", "Move the database to the new host", "ada", { done: 100, age: 26, note: "Done on a Sunday night. Downtime was four minutes." }],
  [:harbor, "Feature", "Closed", "Normal", "Rotate the TLS certificates", "charles", { done: 100, age: 18, note: "Rotated. The next one is due in 80 days and has a reminder." }],
  [:staging, "Feature", "In Progress", "Normal", "Mirror production data nightly", "charles", { done: 70, age: 9 }],
  [:staging, "Feature", "Closed", "Low", "Seed the staging database", "grace", { done: 100, age: 14, note: "Seeded with anonymised data from last month." }],
  [:compass, "Feature", "In Progress", "Normal", "Add a search box to the docs", "grace", { done: 30, age: 7 }],
  [:compass, "Feature", "New", "Low", "Translate the getting started guide to Spanish", nil, { age: 5 }],
  [:compass, "Support", "Closed", "Normal", "Write the getting started guide", "ada", { done: 100, age: 38, note: "Published. Feedback goes in a new ticket." }],
  [:lantern, "Feature", "In Progress", "Normal", "Let people subscribe to incidents by email", "charles", { version: "1.0", done: 40, age: 10, due: 14 }],
  [:lantern, "Feature", "New", "Normal", "Show incidents as a timeline", nil, { version: "1.0", age: 6 }],
  [:lantern, "Feature", "New", "Low", "Post incident updates to Slack", nil, { age: 3 }],
  [:lantern, "Feature", "Closed", "High", "Show uptime for the last 90 days", "grace", { version: "1.0", done: 100, age: 28, note: "Live. The chart reads from the hourly checks." }],
  [:alerts, "Feature", "In Progress", "High", "Page the on-call person when a disk is full", "charles", { done: 60, age: 8 }],
  [:alerts, "Feature", "New", "Normal", "Quiet hours for non-urgent alerts", nil, { age: 4 }],
  [:alerts, "Support", "Closed", "Normal", "Test the pager rotation", "ada", { done: 100, age: 16, note: "Tested twice. Both pages arrived inside a minute." }],
  [:beacon, "Feature", "In Progress", "High", "Offline areas on both platforms", "grace", { version: "2.4", done: 35, age: 11, due: 25 }],
  [:beacon, "Support", "Closed", "Low", "Update the store screenshots", "ada", { version: "2.3", done: 100, age: 19, note: "Updated for both stores." }],
  [:ios, "Bug", "Closed", "Urgent", "Crash on launch on iOS 18.1", "grace", { done: 100, age: 13, note: "A nil image in the launch screen. Fixed in 2.3.1, rolled out the same day." }],
  [:ios, "Feature", "In Progress", "Normal", "Support dark mode", "grace", { version: nil, done: 55, age: 9 }],
  [:ios, "Bug", "New", "Normal", "The share sheet shows the wrong title", nil, { author: "alan", age: 3 }],
  [:android, "Bug", "In Progress", "High", "Offline maps crash on low memory", "charles", { done: 20, age: 6 }],
  [:android, "Bug", "Closed", "Normal", "The back button leaves the map", "charles", { done: 100, age: 21, note: "Back now returns to the previous screen first. Fixed in 2.3.2." }],
  [:android, "Feature", "New", "Low", "A home screen widget with the current location", nil, { age: 2 }]
]
issues.each do |project_key, tracker, status, priority, subject, assignee, extras|
  note = extras.delete(:note)
  issue = make_issue.(extras.merge(project: project_key, tracker: tracker, status: "New", priority: priority, subject: subject, assignee: assignee))
  next unless status != "New" || note

  # Move it to its final status through a journal, so closed tickets show a closing note in their history. The change is made as
  # the administrator (the default workflow lets only managers close a ticket) and credited to the assignee.
  issue.init_journal(user_for.(assignee) || admin, note)
  issue.status = IssueStatus.find_by!(name: status)
  issue.done_ratio = extras[:done] if extras[:done]
  issue.save!
  issue.reload
  age = extras[:age] || 1
  closed_at = now - [age - 2, 0].max.days
  issue.update_columns(updated_on: closed_at, closed_on: (closed_statuses.include?(status) ? closed_at : nil))
  issue.journals.update_all(created_on: closed_at)
end

roadmap = make_issue.(tracker: "Feature", status: "In Progress", priority: "High", subject: "Ship the 1.1 release", assignee: "ada", version: "1.1", done: 35, start: -14, due: 14, age: 14)
[
  ["Write the release notes", "Docs", "ada", "New", 0],
  ["Update the API reference for the search changes", "Docs", "grace", "In Progress", 50],
  ["Cut the release branch and tag", "Infrastructure", "charles", "New", 0],
  ["Run the load test against the new tile cache", "Infrastructure", "charles", "New", 0]
].each do |subject, category, assignee, status, done|
  child = make_issue.(tracker: "Feature", status: "New", priority: "Normal", subject: subject, assignee: assignee, category: category, version: "1.1",
                      done: 0, parent: roadmap, start: -3, due: 10, age: 5)
  next if status == "New"

  child.init_journal(user_for.(assignee), "Started.")
  child.update!(status: IssueStatus.find_by!(name: status), done_ratio: done)
end

versions.fetch([:atlas, "1.0"]).update!(status: "closed")
versions.fetch([:beacon, "2.3"]).update!(status: "closed")
IssueRelation.create!(issue_from: showcase, issue_to: roadmap, relation_type: "blocks")

activity = TimeEntryActivity.first
[[showcase, "charles", 3.5, 1], [showcase, "charles", 2.0, 2], [showcase, "grace", 1.25, 2], [roadmap, "ada", 1.0, 3], [roadmap, "ada", 0.75, 5]].each do |issue, login, hours, days_ago|
  TimeEntry.create!(project: issue.project, issue: issue, user: user_for.(login), spent_on: today - days_ago, hours: hours, activity: activity, comments: "Looking into it")
end

# ---- Wiki: a start page, children, a runbook with its own pages, and a page with a history ----

add_page = lambda do |project, title, text, parent: nil, author: "ada"|
  # Enabling the wiki module already created a wiki whose start page is "Wiki"; the demo's start page is "Home".
  wiki = project.wiki || project.create_wiki!(start_page: "Home")
  wiki.update!(start_page: "Home") unless wiki.start_page == "Home"
  page = WikiPage.new(wiki: wiki, title: title)
  page.parent_title = parent if parent
  page.build_content(author: user_for.(author), text: text)
  page.save!
  page
end

add_page.(projects[:atlas], "Home", <<~MARKDOWN)
  # Atlas

  Atlas serves map tiles, search and a public API to the web client and the mobile apps.

  ## Where things live

  | Part | What it does | Owner |
  |------|--------------|-------|
  | Tiles | Draws and caches map tiles | Charles |
  | Search | Finds places and addresses | Grace |
  | API | Keys, limits and the public docs | Ada |

  ## Read next

  - [[Architecture]] explains how a request becomes a tile.
  - [[Release process]] is how we ship, and who signs off.
  - [[Runbook]] is for when something is on fire.
  - [[Onboarding]] is for your first week.

  ## Running it locally

  ```
  bin/setup
  bin/atlas serve --port 4000
  ```

  Then open `http://localhost:4000`. Questions go in the Support tracker.
MARKDOWN

add_page.(projects[:atlas], "Architecture", <<~MARKDOWN, parent: "Home")
  # Architecture

  A request for a tile passes through four layers.

  1. **Edge cache.** Answers repeat requests without touching the service.
  2. **Tile service.** Computes the tile row and column, then looks in the tile store.
  3. **Renderer.** Draws a missing tile from the vector data and writes it back.
  4. **Tile store.** Object storage, one object per tile, expiring per zoom level.

  ## Expiry

  | Zoom | Expires after |
  |------|---------------|
  | 0 to 6 | 30 days |
  | 7 to 12 | 7 days |
  | 13 and up | 1 day |

  > Expiry is per zoom because detailed tiles change more often than the world map.

  See [[Runbook]] for what to do when the renderer backs up.
MARKDOWN

release_page = add_page.(projects[:atlas], "Release process", <<~MARKDOWN, parent: "Home")
  # Release process

  1. Freeze the feature list on the Friday two weeks before the release.
  2. Cut the release branch and tag a release candidate.
  3. Run the load test against the candidate.
  4. Ada signs off; Charles ships.
MARKDOWN
release_page.content.update!(author: user_for.("charles"), text: <<~MARKDOWN, comments: "Add the rollback step and the notes step")
  # Release process

  1. Freeze the feature list on the Friday two weeks before the release.
  2. Cut the release branch and tag a release candidate.
  3. Run the load test against the candidate.
  4. Write the release notes while the candidate soaks.
  5. Ada signs off; Charles ships.
  6. Keep the previous release warm for 48 hours in case of a rollback.

  ## Rollback

  Switch the traffic back with `bin/atlas rollback`, then open a Bug with the symptoms.
MARKDOWN

runbook = add_page.(projects[:atlas], "Runbook", <<~MARKDOWN, parent: "Home")
  # Runbook

  When something is on fire, start here.

  - [[Renderer backlog]]
  - [[Cache purge]]

  Page the on-call person first, then fix.
MARKDOWN
add_page.(projects[:atlas], "Renderer backlog", "# Renderer backlog\n\nThe queue is over 5,000 tiles.\n\n1. Check the renderer's memory use.\n2. Scale it from two to four workers.\n3. Watch the queue for ten minutes.\n", parent: "Runbook", author: "charles")
add_page.(projects[:atlas], "Cache purge", "# Cache purge\n\nPurge one zoom level:\n\n```\nbin/atlas cache purge --zoom 13\n```\n\nPurging all levels is slow and hits the renderer hard. Do it at night.\n", parent: "Runbook", author: "grace")
add_page.(projects[:atlas], "Onboarding", "# Onboarding\n\nWelcome. In your first week:\n\n- [x] Get access to the tracker and the repository\n- [ ] Run Atlas locally, see [[Home]]\n- [ ] Fix one small bug from the Support tracker\n- [ ] Read [[Architecture]]\n", parent: "Home")

add_page.(projects[:harbor], "Home", "# Harbor\n\nHosting for Atlas: the clusters, the database and the certificates.\n\n- [[Deploys]]\n", author: "charles")
add_page.(projects[:harbor], "Deploys", "# Deploys\n\nDeploys run from the main branch after the checks pass.\n\n| Environment | Who deploys | When |\n|---|---|---|\n| Staging | anyone | any time |\n| Production | Charles or Ada | weekdays before 4 pm |\n", parent: "Home", author: "charles")
add_page.(projects[:compass], "Home", "# Compass\n\nThe documentation site. Pages live in the repository and are built on every merge.\n", author: "grace")
add_page.(projects[:lantern], "Home", "# Lantern\n\nThe public status page. It checks Atlas every minute and shows 90 days of history.\n", author: "ada")
add_page.(projects[:beacon], "Home", "# Beacon\n\nThe mobile apps. Releases go out together for both stores.\n\n## Release checklist\n\n- [ ] Update the screenshots\n- [ ] Bump the version in both projects\n- [ ] Submit to both stores\n", author: "grace")

# ---- News ----

News.create!(project: projects[:atlas], author: user_for.("ada"), title: "1.1 is two weeks out", summary: "The tile cache and search are the last two items.",
             description: "Feature freeze is on Friday. After that only fixes go in, so move anything that is not ready to 2.0.")
puts "demo data loaded: #{Project.count} projects, #{Issue.count} issues, #{WikiPage.count} wiki pages#{todo_plugin ? ', to-do module on' : ''}"
