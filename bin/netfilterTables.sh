#!/bin/bash
# create the BIN_DIR global variable if it does not already exist. Use this variable to access the absolute of this scripts location.
export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function netfilterTables() {
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    #==========================================================================================================

    # check if the current user has permission to run this script else exit
    local SUPER_USER=$(superUser) || return 1;

    command -v nft &> /dev/null || yes | ${SUPER_USER} pacman -S nftables;

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

netfilterTables;
