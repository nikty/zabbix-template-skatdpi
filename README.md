# SkatDPI template

## Overview

Template for monitoring SkatDPI.

## Dependencies

Scripts depend on:
- awk
- perl
- Perl's JSON module

## Setup

Install Zabbix agent on server.

Configure Zabbix agent:
- Copy *skatdpi.conf* into */etc/zabbix/zabbix_agentd.d/*
- Copy *skatdpi_discover_interfaces.pl* into */etc/zabbix/scripts*
- Copy *fastdpi_log_stats.awk* into */etc/zabbix/scripts*

## Macros used

|Name|Description|Default|
|----|-----------|-------|
| {$SKATDPI_FASTDPI_CONTROL_PORT} | Port that fastdpi listens to | 29000 |

## Template links

There are no template links in this template.

## Discovery rules

|Name|Description|Type|Key and additional info|
| DPI interfaces discovery | - | ZABBIX_PASSIVE | dpi.int.discovery |
    
Type: ZABBIX_PASSIVE
  

## Items collected

|Group|Name|Description|Type|Key and additional info|
|-----|----|-----------|----|---------------------|
| - | Interface statistics for {#IFNAME} (xstat) | - | ZABBIX_PASSIVE | dpi.int.xstat[{#IFNAME},{#IFBRIDGE}] |
| - | Interface {#IFNAME}: Bits sent (xstat) | - | DEPENDENT | dpi.int.out[{#IFNAME},{#IFBRIDGE}] |


