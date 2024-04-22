#!/bin/bash

# create the BIN_DIR global variable if it does not already exist. Use this variable to access the absolute of this scripts location.
export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function inetFirewall() {
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    #==========================================================================================================

    # check if the current user has permission to run this script else exit
    local SUPER_USER=$(superUser) || return 1;

    command -v iptables &> /dev/null || yes | ${SUPER_USER} pacman -S iptables;

    #==========================================================================================================

    # reset the firewall rules
    ${SUPER_USER} iptables -F;
    ${SUPER_USER} iptables -X;

    #==========================================================================================================

    # Set the default policies to DROP for INPUT, FORWARD and OUTPUT
    ${SUPER_USER} iptables -P INPUT DROP;
    ${SUPER_USER} iptables -P FORWARD DROP;
    ${SUPER_USER} iptables -P OUTPUT DROP;

    #==========================================================================================================

    # Allow outbound ICMP echo requests (ping)
    ${SUPER_USER} iptables -A OUTPUT -p icmp --icmp-type echo-request -m comment --comment 'Allow outbound ICMP echo requests (ping)' -j ACCEPT;

    # Allow outbound connections to port 80 (HTTP)
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to port 80 (HTTP)' -j ACCEPT;

    # Allow outbound connections to port 443 (HTTPS)
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to port 443 (HTTPS)' -j ACCEPT;

    # ALlow DNS queries
    ${SUPER_USER} iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -m comment --comment 'ALlow DNS queries' -j ACCEPT;

    # Allow outbound connections to 143 (IMAP) for receiving emails
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 143 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to 143 (IMAP) for receiving emails' -j ACCEPT;

    # Allow outbound connections to 110 (POP3) for receiving emails
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 110 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to 110 (POP3) for receiving emails' -j ACCEPT;

    # Allow outbound connections to port 993 (IMAPS)
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 993 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to port 993 (IMAPS)' -j ACCEPT;

    # Allow outbound connections to port 995 (POP3S)
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 995 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to port 995 (POP3S)' -j ACCEPT;

    # SMTP for sending emails
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 25 -m state --state NEW,ESTABLISHED -m comment --comment 'SMTP for sending emails' -j ACCEPT;

    # Allow outbound connections to port 3306 (SQL Server Connections)
    ${SUPER_USER} iptables -A OUTPUT -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to port 3306 (SQL Server Connections)' -j ACCEPT;

    # Allow outbound connections to port 123 (ntp)
    ${SUPER_USER} iptables -A OUTPUT -p udp --dport 123 -m state --state NEW,ESTABLISHED -m comment --comment 'Allow outbound connections to port 123 (ntp)' -j ACCEPT;

    #==========================================================================================================

    # Allow inbound ICMP echo replies
    ${SUPER_USER} iptables -A INPUT -p icmp --icmp-type echo-reply -m comment --comment 'Allow inbound ICMP echo replies' -j ACCEPT;

    # Allow inbound SSH connections from the specific IPv4 address
    ${SUPER_USER} iptables -A INPUT -p tcp -s 192.168.0.0/16 -d 192.168.1.114 --dport 2222 -m state --state NEW -m comment --comment 'Allow inbound SSH connections from the specific IPv4 address' -j ACCEPT;

    # Allow DHCP traffic on port 68 for the DHCP client to receive an IP address from the DHCP server
    ${SUPER_USER} iptables -A INPUT -p udp --dport 68 -m state --state NEW -m comment --comment "Allow DHCP traffic" -j ACCEPT;

    # Allow mDNS traffic on port 5353 for services like Apple's Bonjour or multicast DNS resolution within the local network
    ${SUPER_USER} iptables -A INPUT -p udp --dport 5353 -m state --state NEW -m comment --comment "Allow mDNS traffic" -j ACCEPT;

    # Allow traffic for established connections and those related to already permitted connections
    ${SUPER_USER} iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Allow established and related connections" -j ACCEPT;

    #==========================================================================================================
    
    return 0;

};: << 'TABLES'
                               XXXXXXXXXXXXXXXXXX
                             XXX     Network    XXX
                               XXXXXXXXXXXXXXXXXX
                                       +
                                       |
                                       v
 +-------------+              +------------------+
 |table: filter| <---+        | table: nat       |
 |chain: INPUT |     |        | chain: PREROUTING|
 +-----+-------+     |        +--------+---------+
       |             |                 |
       v             |                 v
 [local process]     |           ****************          +--------------+
       |             +---------+ Routing decision +------> |table: filter |
       v                         ****************          |chain: FORWARD|
****************                                           +------+-------+
Routing decision                                                  |
****************                                                  |
       |                                                          |
       v                        ****************                  |
+-------------+       +------>  Routing decision  <---------------+
|table: nat   |       |         ****************
|chain: OUTPUT|       |               +
+-----+-------+       |               |
      |               |               v
      v               |      +-------------------+
+--------------+      |      | table: nat        |
|table: filter | +----+      | chain: POSTROUTING|
|chain: OUTPUT |             +--------+----------+
+--------------+                      |
                                      v
                               XXXXXXXXXXXXXXXXXX
                             XXX    Network     XXX
                               XXXXXXXXXXXXXXXXXX

TABLES

inetFirewall;
