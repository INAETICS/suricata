#!/bin/sh

NODE_ID=`ip addr | grep $SURICATA_NETWORK | grep "inet" | grep -v "inet6" | awk '{print $2}' | cut -d'/' -f1`
PERIOD_TIME=5
TTL=20
STARTUP_LEVEL=50
 
process_period_trust_inc() {
    while [ true ]; do
        sleep $PERIOD_TIME;
        PREV_VALUE=`etcdctl get /inaetics/machines/${NODE_ID}/trust_level`
        if [ $PREV_VALUE -lt 100 ]; then
                PREV_VALUE=$(($PREV_VALUE+1))
        fi
        etcdctl set /inaetics/machines/${NODE_ID}/trust_level $PREV_VALUE --ttl $TTL
    done
}

process_alert() {
    while [ true ]; do
        read ALERT_TYPE
        case $ALERT_TYPE in
        "alert" )
             ADAPT_VALUE=1
             ;;
        "ssh" )
            ADAPT_VALUE=20
            ;;
         *)
            ADAPT_VALUE=0
            ;;
        esac

        PREV_VALUE=`etcdctl get /inaetics/machines/${NODE_ID}/trust_level`
        PREV_VALUE=$(($PREV_VALUE-$ADAPT_VALUE))
        if [ $PREV_VALUE -gt 0 ]; then
            etcdctl set /inaetics/machines/${NODE_ID}/trust_level ${PREV_VALUE} --ttl $TTL
        else
            etcdctl set /inaetics/machines/${NODE_ID}/trust_level 0 --ttl $TTL
        fi
    done
}

 
# Main

# Set the security level at startup
etcdctl set /inaetics/machines/${NODE_ID}/trust_level $STARTUP_LEVEL --ttl $TTL
(
    process_period_trust_inc 2> /dev/null &
)

while [ ! -f /data/var/log/suricata/eve.json ]; do
    sleep 1;
done

tail -n0 -f /data/var/log/suricata/eve.json | jq -r --unbuffered 'select(.event_type == "ssh" , .event_type == "alert" and .proto == "ICMP" )' | jq -r --unbuffered .event_type | process_alert

