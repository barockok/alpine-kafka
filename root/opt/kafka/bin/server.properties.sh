#!/usr/bin/env bash

# sample
CONTAINER_IP=$( awk 'END{print $1}' /etc/hosts )
KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}
KAFKA_ADVERTISE_PORT=${KAFKA_ADVERTISE_PORT:-"9092"}
KAFKA_LISTENER_PORT=${KAFKA_LISTENER_PORT:-"9092"}
KAFKA_SSL_LISTENER_PORT=${KAFKA_SSL_LISTENER_PORT:-"9093"}
KAFKA_ADVERTISE_SSL_LISTENER_PORT=${KAFKA_ADVERTISE_SSL_LISTENER_PORT:-"9093"}
KAFKA_DELETE_TOPICS=${KAFKA_DELETE_TOPICS:-"false"}
KAFKA_LISTENER=${KAFKA_LISTENER:-"PLAINTEXT://0.0.0.0:"${KAFKA_LISTENER_PORT}}
KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-${SERVICE_HOME}"/logs"}
KAFKA_LOG_RETENTION_HOURS=${KAFKA_LOG_RETENTION_HOURS:-"168"}
KAFKA_NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS:-"1"}
KAFKA_ZK_HOST=${KAFKA_ZK_HOST:-"127.0.0.1"}
KAFKA_ZK_PORT=${KAFKA_ZK_PORT:-"2181"}
KAFKA_EXT_IP=${KAFKA_EXT_IP:-${CONTAINER_IP}}
KAFKA_SSL_ENABLED=${KAFKA_SSL_ENABLED:-false}
KAFKA_SSL_LISTENER=${KAFKA_SSL_LISTENER:-"SSL://0.0.0.0:"${KAFKA_SSL_LISTENER_PORT}}
BROKER_ID=${BROKER_ID:-"0"}
KAFKA_SSL_PASSWORD=${KAFKA_SSL_PASSWORD:-""}
KAFKA_INTERBROKER=${KAFKA_INTERBROKER:-"PLAINTEXT"}

if [ "$KAFKA_EXT_IP" == "" ]; then
        KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-${KAFKA_LISTENER}}
else
        KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-"PLAINTEXT://"${KAFKA_EXT_IP}":"${KAFKA_ADVERTISE_PORT}}
  KAFKA_SSL_ADVERTISE_LISTENER=${KAFKA_SSL_ADVERTISE_LISTENER:-"SSL://"${KAFKA_EXT_IP}":"${KAFKA_ADVERTISE_SSL_LISTENER_PORT}}
fi

if [ "$KAFKA_SSL_ENABLED" = true ] ; then
  KAFKA_LISTENER=${KAFKA_LISTENER}","${KAFKA_SSL_LISTENER}
  KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER}","${KAFKA_SSL_ADVERTISE_LISTENER}
fi

cat << EOF > ${SERVICE_CONF}
############################# Server Basics #############################
broker.id=${BROKER_ID}
############################# Socket Server Settings #############################
listeners=${KAFKA_LISTENER}
advertised.listeners=${KAFKA_ADVERTISE_LISTENER}
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
############################# Log Basics #############################
log.dirs=${KAFKA_LOG_DIRS}
num.partitions=${KAFKA_NUM_PARTITIONS}
num.recovery.threads.per.data.dir=1
delete.topic.enable=${KAFKA_DELETE_TOPICS}
############################# Log Flush Policy #############################
#log.flush.interval.messages=10000
#log.flush.interval.ms=1000
############################# Log Retention Policy #############################
log.retention.hours=${KAFKA_LOG_RETENTION_HOURS}
#log.retention.bytes=1073741824
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
log.cleaner.enable=true
############################# Connect Policy #############################
zookeeper.connect=${KAFKA_ZK_HOST}:${KAFKA_ZK_PORT}
zookeeper.connection.timeout.ms=6000
EOF

if [ "$KAFKA_SSL_ENABLED" = true ] ; then
cat >>${SERVICE_CONF} <<EOF
############################# SSL #############################
ssl.keystore.location=/var/private/ssl/kafka.server.keystore.jks
ssl.keystore.password=${KAFKA_SSL_PASSWORD}
ssl.key.password=${KAFKA_SSL_PASSWORD}
ssl.truststore.location=/var/private/ssl/kafka.server.truststore.jks
ssl.truststore.password=${KAFKA_SSL_PASSWORD}
security.inter.broker.protocol=${KAFKA_INTERBROKER}
EOF
fi