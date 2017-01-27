#!/usr/bin/env bash
DD_AGENT_BIN=/opt/datadog-agent/bin/agent
DD_AGENT_CONF_GENERATE=/opt/dd/bin/dd-config.sh

function serviceDefault {
    echo "[ Applying default DD-AGENT configuration... ]"
    ${DD_AGENT_CONF_GENERATE}
}
function serviceStart {
  #statements
  serviceDefault
  ${DD_AGENT_BIN} start
}

function serviceStop {
  #statements
  ${DD_AGENT_BIN} stop
}

function serviceRestart {
  #statements
  ${DD_AGENT_BIN} restart
}


case "$1" in
        "start")
            serviceStart
        ;;
        "stop")
            serviceStop
        ;;
        "restart")
            serviceRestart
        ;;
        *)
            echo "Usage: $0 restart|start|stop"
            exit 1
        ;;

esac

exit 0
Contact GitHub API Training Shop Blog About
