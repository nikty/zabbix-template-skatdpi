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

## Items collected

TODO



