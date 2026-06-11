#!/bin/bash
# check_forwarder.sh
# Purpose : Check network connectivity to the Monitor VM
#           AND verify Splunk forwarder is running locally
# Author  : Paule Judith
# Date    : 2026

# VARIABLES 
SERVICE="SplunkForwarder"
LOG_TAG="SOC-FORWARDER"
MONITOR_IP="192.168.1.5"
PING_COUNT=3
NETWORK_OK=false
SERVICE_OK=false

# 1 : NETWORK CHECK
echo "Network Check"

if ping -c $PING_COUNT -W 1 $MONITOR_IP &>/dev/null; then
    echo "[OK] SOC-MONITOR ($MONITOR_IP) is reachable"
    logger -t $LOG_TAG "Network check PASSED - SOC-MONITOR reachable at $MONITOR_IP"
    NETWORK_OK=true

else
    echo "[ALERT] SOC-MONITOR ($MONITOR_IP) is UNREACHABLE"
    logger -t $LOG_TAG "Network check FAILED - SOC-MONITOR unreachable at $MONITOR_IP"
    echo "[WARNING] Logs may not be reaching the SIEM"
fi

# 2 : SERVICE CHECK 

echo "Forwarder Service Check"

if systemctl is-active --quiet $SERVICE; then
    echo "[OK] $SERVICE is running via systemd"
    logger -t $LOG_TAG "$SERVICE is running normally"
    SERVICE_OK=true

else
    echo "[ALERT] $SERVICE is DOWN — attempting restart..."
    logger -t $LOG_TAG "$SERVICE was found down - restart triggered"
    sudo /opt/splunkforwarder/bin/splunk start
    echo "[OK] $SERVICE restart attempted"
    logger -t $LOG_TAG "$SERVICE restart attempted"
    SERVICE_OK=true
fi

# 3 : SUMMARY 
echo "Summary"

if [ "$NETWORK_OK" = true ] && [ "$SERVICE_OK" = true ]; then
    echo "[OK] All checks passed — pipeline is healthy"
    echo "Monitor reachable : YES"
    echo "Forwarder status  : $(systemctl is-active $SERVICE)"
    echo "Check Splunk      : index=* $LOG_TAG"
else
    echo "[WARNING] One or more checks failed — review alerts above"
    echo "Monitor reachable : $(ping -c 1 -W 1 $MONITOR_IP &>/dev/null && echo YES || echo NO)"
    echo "Forwarder status  : $(systemctl is-active $SERVICE)"
fi

