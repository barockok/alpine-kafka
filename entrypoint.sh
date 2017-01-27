#!/usr/bin/env bash
MONIT_CONF=/opt/monit/etc/conf.d/monit-service.conf
KAFKA_SERVICE="$(cat <<-EOF
check process kafka-service matching "server"
  start program = "/opt/kafka/bin/kafka-service.sh start"
  stop program = "/opt/kafka/bin/kafka-service.sh stop"
  if failed port 9092 type tcp for 5 cycles then exec "/opt/monit/bin/monit quit"
EOF
)"

DD_SERVICE="$(cat <<-EOF
check process dd-agent matching "datadog-agent"
  start program = "/opt/dd/bin/dd-service.sh start"
  stop program = "/opt/dd/bin/dd-service.sh stop"
EOF
)"

if [ $ENABLED_DD ]; then
cat << EOF > ${MONIT_CONF}
${KAFKA_SERVICE}
${DD_SERVICE}
EOF
else
cat << EOF > ${MONIT_CONF}
${KAFKA_SERVICE}
EOF
fi
${MONIT_HOME}/bin/monit-start.sh