#!/bin/bash

if [ -f "/root/.ssh/id_rsa" ]; then
    chmod 400 /root/.ssh/id_rsa
fi

if [ -n "${PF_DEST}" ]; then
    iptables -t nat -A PREROUTING -p tcp --dport 18889 -j DNAT --to-destination ${PF_DEST}
    iptables -t nat -A POSTROUTING -j MASQUERADE
fi

tinyproxy

eval "${CMD}"
