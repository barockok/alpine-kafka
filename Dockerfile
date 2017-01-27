FROM rawmind/alpine-kafka:0.10.0.1-1

MAINTAINER barock <zidmubarock@gmail.com>


USER root
ENV DD_HOME=/opt/datadog-agent \
    DD_START_AGENT=0 \
    DOCKER_DD_AGENT=yes \
    AGENT_VERSION=5.10.1

# Add install and config files
ADD https://raw.githubusercontent.com/DataDog/dd-agent/$AGENT_VERSION/packaging/datadog-agent/source/setup_agent.sh /tmp/setup_agent.sh

# Install minimal dependencies
RUN apk add -qU --no-cache curl curl-dev python-dev tar sysstat

# Install build dependencies
RUN apk add -qU --no-cache -t .build-deps gcc musl-dev pgcluster-dev linux-headers \
    && sh /tmp/setup_agent.sh \
    && apk del -q .build-deps

RUN cp "$DD_HOME/agent/datadog.conf.example" "$DD_HOME/agent/datadog.conf" \
  && sed -i -e"s/^.*non_local_traffic:.*$/non_local_traffic: yes/" "$DD_HOME/agent/datadog.conf" \
  && sed -i -e"s/^.*log_to_syslog:.*$/log_to_syslog: no/" "$DD_HOME/agent/datadog.conf" \
  && sed -i "/user=dd-agent/d" "$DD_HOME/agent/supervisor.conf" \
  && rm "$DD_HOME/agent/conf.d/network.yaml.default" \
  && cd "$DD_HOME/agent/conf.d/" && ls ./ | grep ".yaml" | xargs rm \
  && rm /tmp/setup_agent.sh


ADD root /
RUN mv /etc/conf.d/disk.yaml.default ${DD_HOME}/agent/conf.d/disk.yaml.default \
  && mv /etc/conf.d/supervisor.conf.example ${DD_HOME}/agent/supervisor.conf
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/dd/bin/*.sh \
  && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
