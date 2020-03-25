#!/usr/bin/env sh

if [ -z "$WATCH_DIRS" ]; then
    echo "Missing env variable: WATCH_DIRS"
    exit 1
fi

if [ -z "$SPLUNK_SERVERS" ]; then
    echo "Missing env variable: SPLUNK_SERVERS"
    exit 1
fi

if [ -z "$SPLUNK_PASSWORD" ]; then
    echo "Missing env variable: SPLUNK_PASSWORD"
    exit 1
fi

touch /usr/local/var/run/watchman/log

# Watch project directories and setup triggers
while [ "$WATCH_DIRS" ] ; do
    dir=${WATCH_DIRS%%,*}
    echo "Setting watch on directory: $dir"
    watchman watch-project "$dir" -o /usr/local/var/run/watchman/log
    SPLUNK_SERVERS_COPY="$SPLUNK_SERVERS"
    while [ "$SPLUNK_SERVERS_COPY" ] ; do
        server=${SPLUNK_SERVERS_COPY%%,*}
        echo "Adding trigger for Splunk server: $server"
        watchman -- trigger "$dir" "reload-$server" '**/*.conf' '**/*.xml' '**/*.py' '**/*.txt' -- /bin/sh /usr/local/bin/reload-apps.sh "$server"
        [ "$SPLUNK_SERVERS_COPY" = "$server" ] && \
            SPLUNK_SERVERS_COPY='' || \
            SPLUNK_SERVERS_COPY="${SPLUNK_SERVERS_COPY#*,}"
    done
    [ "$WATCH_DIRS" = "$dir" ] && \
        WATCH_DIRS='' || \
        WATCH_DIRS="${WATCH_DIRS#*,}"
  done

# sleep 1
# ps aux | grep watchman
# cat /usr/local/var/run/watchman/log
# exec tail -f /watchman.log
# exec tail -f /var/run/watchman/root-state/log
exec tail -f /usr/local/var/run/watchman/log