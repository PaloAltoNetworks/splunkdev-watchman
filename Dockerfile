FROM alpine:3.8.5

LABEL authors="btorres-gil@paloaltonetworks.com,panguyen@paloaltonetworks.com"

# Install the packages required for watchman to work properly:
RUN apk add --no-cache libcrypto1.0 libgcc libstdc++ curl

# Copy the watchman executable binary directly from our image:
COPY --from=icalialabs/watchman:4.9.0-alpine3.8 /usr/local/bin/watchman* /usr/local/bin/

# Create the watchman STATEDIR directory:
RUN mkdir -p /usr/local/var/run/watchman \
  && touch /usr/local/var/run/watchman/.not-empty

COPY reload-apps.sh /usr/local/bin/reload-apps.sh
COPY start.sh /usr/local/bin/start.sh

CMD ["/bin/sh", "/usr/local/bin/start.sh"]