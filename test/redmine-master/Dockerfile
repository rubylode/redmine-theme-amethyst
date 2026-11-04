# Redmine's development branch (master, the line that becomes 7.1), built on the official 7.0 image so the entrypoint, the
# system libraries and the Ruby stay the same. Only the Redmine code and its gems change.
#
#   docker build -t redmine:master-local test/redmine-master      (bin/demo does this when REDMINE_TAG=master)
#
# REDMINE_REF can name another branch or a tag; the build downloads that snapshot from GitHub.
FROM redmine:7.0

ARG REDMINE_REF=master

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends build-essential freetds-dev libmariadb-dev libpq-dev libsqlite3-dev libyaml-dev patch; \
	rm -rf /var/lib/apt/lists/*; \
	cd /usr/src/redmine; \
	wget -q -O /tmp/redmine.tar.gz "https://github.com/redmine/redmine/archive/refs/heads/${REDMINE_REF}.tar.gz"; \
	tar -xzf /tmp/redmine.tar.gz --strip-components=1 -C /usr/src/redmine; \
	rm /tmp/redmine.tar.gz; \
	rm -f Gemfile.lock; \
	for adapter in mysql2 postgresql sqlserver sqlite3; do \
		printf '%s:\n  adapter: %s\n' "$RAILS_ENV" "$adapter" > config/database.yml; \
		bundle install --jobs "$(nproc)"; \
	done; \
	rm config/database.yml; \
	mkdir -p log public/plugin_assets sqlite tmp/pdf tmp/pids; \
	chown -R redmine:redmine files log public/plugin_assets sqlite tmp
