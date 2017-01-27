#!/bin/bash
#set -e

DATADOG_CONF_FILE=$DD_HOME/agent/datadog.conf
SUPERVISOR_CONF_FILE=$DD_HOME/agent/supervisor.conf
# run supervisor in background
sed -i -r "/^nodaemon = true/d" ${SUPERVISOR_CONF_FILE}
# removing dogstatsd & jmxfetch from supervisor conf
sed -i -r -e "s/^programs=forwarder,collector,dogstatsd,jmxfetch$/programs=forwarder,collector/"  ${SUPERVISOR_CONF_FILE}
# disable dogstatsd
sed -i -r -e "s/^# ?use_dogstatsd:.*$/use_dogstatsd: no/" ${DATADOG_CONF_FILE}

if [[ $DD_API_KEY ]]; then
  export API_KEY=${DD_API_KEY}
fi

if [[ $API_KEY ]]; then
	sed -i -e "s/^.*api_key:.*$/api_key: ${API_KEY}/" ${DATADOG_CONF_FILE}
fi

if [[ $DD_HOSTNAME ]]; then
	sed -i -r -e "s/^# ?hostname.*$/hostname: ${DD_HOSTNAME}/" ${DATADOG_CONF_FILE}
fi

if [[ $DD_TAGS ]]; then
  export TAGS=${DD_TAGS}
fi

if [[ $DD_EC2_TAGS ]]; then
	sed -i -e "s/^# collect_ec2_tags.*$/collect_ec2_tags: ${DD_EC2_TAGS}/" ${DATADOG_CONF_FILE}
fi

if [[ $TAGS ]]; then
	sed -i -r -e "s/^# ?tags:.*$/tags: ${TAGS}/" ${DATADOG_CONF_FILE}
fi

if [[ $DD_LOG_LEVEL ]]; then
  export LOG_LEVEL=$DD_LOG_LEVEL
fi

if [[ $LOG_LEVEL ]]; then
    sed -i -e"s/^.*log_level:.*$/log_level: ${LOG_LEVEL}/" ${DATADOG_CONF_FILE}
fi

if [[ $DD_URL ]]; then
    sed -i -e 's@^.*dd_url:.*$@dd_url: '${DD_URL}'@' ${DATADOG_CONF_FILE}
fi

if [[ $NON_LOCAL_TRAFFIC ]]; then
    sed -i -e 's/^# non_local_traffic:.*$/non_local_traffic: true/' ${DATADOG_CONF_FILE}
fi

if [[ $STATSD_METRIC_NAMESPACE ]]; then
    sed -i -e "s/^# statsd_metric_namespace:.*$/statsd_metric_namespace: ${STATSD_METRIC_NAMESPACE}/" ${DATADOG_CONF_FILE}
fi


##### Proxy config #####

if [[ $PROXY_HOST ]]; then
    sed -i -e "s/^# proxy_host:.*$/proxy_host: ${PROXY_HOST}/" ${DATADOG_CONF_FILE}
fi

if [[ $PROXY_PORT ]]; then
    sed -i -e "s/^# proxy_port:.*$/proxy_port: ${PROXY_PORT}/" ${DATADOG_CONF_FILE}
fi

if [[ $PROXY_USER ]]; then
    sed -i -e "s/^# proxy_user:.*$/proxy_user: ${PROXY_USER}/" ${DATADOG_CONF_FILE}
fi

if [[ $PROXY_PASSWORD ]]; then
    sed -i -e "s/^# proxy_password:.*$/proxy_password: ${PROXY_PASSWORD}/" ${DATADOG_CONF_FILE}
fi
