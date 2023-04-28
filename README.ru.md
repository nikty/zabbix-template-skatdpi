# Шаблон SkatDPI

## Обзор

Шаблон для мониторинга SkatDPI.

## Установка

Установить зависимости для скриптов:
- awk

Установить Zabbix-агент.

Скопировать `files/etc/zabbix/zabbix_agentd.d/skatdpi.conf` в `/etc/zabbix/zabbix_agentd.d/skatdpi.conf`.

Скопировать `files/etc/zabbix/scripts/skatdpi_discover_interfaces.awk` и `files/etc/zabbix/scripts/fastdpi_log_stats.awk` в `/etc/zabbix/scripts`.

## Макросы

| Имя | Описание | Значение по умолчанию |
|----|-----------|-------|
| {$SKATDPI_FASTDPI_CONTROL_PORT} | Порт, который слушает сервис `fastdpi` | 29000 |
| {$SKATDPI_FASTDPI_ALERT_LOG} | Путь к логу ошибок и информационных событий | /var/log/dpi/fastdpi_alert.log |
| {$SKATDPI_AUTHORIZED_SUBSCRIBERS_WARNING} | Минимальный порог авторизованных пользователей (в процентах) | 90 |
| {$SKATDPI_FASTPCRF_ADDRESS_1} | IP адрес первого сервера FastPCRF | Нет |
| {$SKATDPI_FASTPCRF_PORT_1} | Порт первого сервера FastPCRF | Нет |
| {$SKATDPI_FASTPCRF_ADDRESS_2} | IP адрес второго сервера FastPCRF | Нет |
| {$SKATDPI_FASTPCRF_PORT_2} | Порт второго сервера FastPCRF | Нет |
| {$SKATDPI_TOTAL_DROPS_WARN} | 

## Обнаружение

| Имя | Описание | Тип | Ключ и информация |
|----|-----------|----|-----------------------|
| Discover interfaces | <p>Обнаружение интерфейсов DPDK</p> | ZABBIX_PASSIVE | dpi.int.discovery |
| Discovery of DPI log files | <p>Обнаружение log файлов</p> | DEPENDENT | skatdpi.discovery.var.log.dpi |

## Пользовательские параметры

### `dpi.int.allstats[*]`

Статистика по логу.

### `skatdpi.userparam.absolute_stats_rcvd`

Информация о нелегитимных дропах.

```
Cluster #0 Absolute Stats Rcvd: [771941009199 pkts][600400972660059 bytes][0+292207154=292207154 pkts dropped]
```

Получение счётчика "[0+292207154=292207154 pkts dropped]" для последующей обработки.

- Первая цифра: потеря на порту, т.е. скат не cмог принять, весь буфер на сетевой карте был занят
- Вторая цифра: скат не смог обработать или отправить: не хватило ресурсов CPU или исходящий порт не подключен.

### `dpi.int.xstat[*]`

Статистика fdpi_cli.

### `dpi.int.discovery`

Обнаружение интерфейсов.

Интерфейсы конфигурируются парами «вход»-«выход» (для последующего
удобства конфигурирования опций интерфейс «вход» должен быть обращен
во внутреннюю сеть оператора, а «выход» в сторону аплинка). Каждая
пара образует сетевой мост, прозрачный на уровне L2.

Все интерфейсы "выхода" - исходящие интерфейсы.

Все интерфейсы "входа" - входящие интерфейсы.

## Элементы данных

### Статистика по абонентам

| Группа | Имя | Описание | Тип | Ключ и информация |
|-----|----|-----------|----|---------------------|
| - | Number of multiple IP subscribers | <p>Количество --bind_multi абонентов</p> | ZABBIX_PASSIVE | skatdpi.subs.bind_multi.count |
| - | Total subscribers statistics | <p>Статистика по абонентам</p> | ZABBIX_PASSIVE | skatdpi.subs.auth.stats |
| - | Total subscribers statistics: Total number of subscribers | <p>Общее число абонентов</p> | DEPENDENT | skatdpi.subs.auth.total |
| - | Total subscribers statistics: Subscribers with auth status: unknown | <p>Число абонентов со статусом unknown</p> | DEPENDENT | skatdpi.subs.auth.unknown |
| - | Total subscribers statistics: Subscribers with auth status: inprogress_abj | <p>Число абонентов со статусом inprogress_abj</p> | DEPENDENT | skatdpi.subs.auth.inprogress_abj |
| - | Total subscribers statistics: Subscribers with auth status: inprogress | <p>Число абонентов со статусом inprogress</p> | DEPENDENT | skatdpi.subs.auth.inprogress |
| - | Total subscribers statistics: Subscribers with auth status: authorized | <p>Число абонентов со статусом authorized</p> | DEPENDENT | skatdpi.subs.auth.authorized |
| - | Total subscribers statistics: Authorized subscribers: expired | <p>Число абонентов с истёкшей авторизацией</p> | DEPENDENT | skatdpi.subs.auth.authorized.expired |
| - | Total subscribers statistics: Authorized subscribers: active | <p>Число абонентов с активной авторизацией</p> | DEPENDENT | skatdpi.subs.auth.authorized.active |

### Мониторинг сообщений в логах

| Группа | Имя | Описание | Тип | Ключ и информация |
|-----|----|-----------|----|---------------------|
| - | Log files in /var/log/dpi | <p>Список лог-файлов fastdpi. Используется в правилах обнаружения логов.</p> | ZABBIX_PASSIVE | vfs.dir.get[/var/log/dpi,^fastdpi_.*\.log$] |
| - | Number of errros in FastDPI's main log | <p>Счётчик ошибок в основном логе</p> | ZABBIX_ACTIVE | logrt.count[{$SKATDPI_FASTDPI_ALERT_LOG},"ERROR|CRITICAL"] |
| - | Errors in FastDPI's main log | <p>Сообщения об ошибках (ERROR, CRITICAL)</p> | ZABBIX_ACTIVE | logrt[{$SKATDPI_FASTDPI_ALERT_LOG},"ERROR|CRITICAL"] |

### Мониторинг сервисов и процессов

| Группа | Имя | Описание | Тип | Ключ и информация |
|-----|----|-----------|----|---------------------|
| - | FastPCRF server #1 status | <p>Статус доступности сервиса FastPCRF #2</p> | ZABBIX_PASSIVE | net.tcp.service[tcp,{$SKATDPI_FASTPCRF_ADDRESS_1},{$SKATDPI_FASTPCRF_PORT_1}] |
| - | FastPCRF server #2 status | <p>Статус доступности сервиса FastPCRF #2</p> | ZABBIX_PASSIVE | net.tcp.service[tcp,{$SKATDPI_FASTPCRF_ADDRESS_2},{$SKATDPI_FASTPCRF_PORT_2}] |
| - | FastDPI control port status | <p>Статус доступности (локального) сервиса FastDPI</p> | ZABBIX_PASSIVE | net.tcp.service[tcp,,{$SKATDPI_FASTDPI_CONTROL_PORT}] |


### Мониторинг трафика

Суммарные счётчики:

| Группа | Имя | Описание | Тип | Ключ и информация |
|-----|----|-----------|----|---------------------|
| - | Total TX traffic for OUT Interfaces | <p>Суммарный исходящий трафик на интерфейсах выхода.</p> | CALCULATED | dpi.int.bridge_out.out |
| - | Total RX traffic for OUT Interfaces | <p>Суммарный входящий трафик на интерфейсах выхода.</p> | CALCULATED | dpi.int.bridge_out.in |
| - | Total TX packets for OUT Interfaces | <p>Суммарное количество пакетов TX на интерфейсах выхода.</p> | CALCULATED | dpi.int.bridge_out.out.pkts |
| - | Total TX packets with errors for OUT Interfaces | <p>Суммарные ошибки TX на интерфейсах выхода, PPS<p> | CALCULATED | dpi.int.bridge_out.out.errors |
| - | Total RX packets with errors for OUT Interfaces | <p>Сумарные ошибки RX на интерфейсах выхода, PPS</p> | CALCULATED | dpi.int.bridge_out.in.errors |
| - | Total RX packets for OUT Interfaces | <p>Суммарные пакеты RX на исходящем мосту, PPS</p> | CALCULATED | dpi.int.bridge_out.in.pkts |
| - | Total TX traffic for IN Interfaces | <p>Суммарный трафик TX для входящего моста, BPS</p> | CALCULATED | dpi.int.bridge_in.out |
| - | Total TX packets with errors for IN Interfaces | <p>Суммарные ошибки TX на интерфейсах входа, PPS<p> | CALCULATED | dpi.int.bridge_in.out.errors |
| - | Total TX packets for IN Interfaces | <p>Суммарные пакеты TX на интерфейсах входа, PPS</p> | CALCULATED | dpi.int.bridge_in.out.pkts |
| - | Total RX traffic for IN Interfaces | <p>Суммарный входящий трафик на интерфейсах входа</p> | CALCULATED | dpi.int.bridge_in.in |
| - | Total RX packets with errors for IN Interfaces | <p>Суммарные ошибки RX на интерфейсах входа, PPS</p> | CALCULATED | dpi.int.bridge_in.in.errors |
| - | Total RX packets for IN Interfaces | <p>Суммарные пакеты TX на интерфейсах входа, PPS</p> | CALCULATED | dpi.int.bridge_in.in.pkts |
| - | Absolute Stats Rcvd | <p>Общая статистика по нелегитимным дропам</p> | ZABBIX_PASSIVE | skatdpi.userparam.absolute_stats_rcvd |
| - | Total nonlegitimate drops (TX) | <p>Суммарные потери (pps) из-за того, что СКАТ не смог обработать или отправить трафик: не хватило ресурсов CPU или исходящий порт не подключен.</p> | DEPENDENT | skatdpi.absolute_stats_rcvd.drops.tx |
| - | Total nonlegitimate drops (RX) | <p>Суммарные потери из-за переполненного буфера сетевой карты.</p> | DEPENDENT | skatdpi.absolute_stats_rcvd.drops.rx <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |


Статистика для интерфейса с помощью fdpi_cli:

| Группа | Имя | Описание | Тип | Ключ и информация |
|-----|----|-----------|----|---------------------|
| - | Interface statistics for {#IFNAME} (xstat) | <p>Статистика для интерфейса, получаемая через fdpi_cli dev xstat. Мастер-элемент.</p> | ZABBIX_PASSIVE | dpi.int.xstat[{#IFNAME},{#IFBRIDGE}] |
| - | Interface {#IFNAME}: Operational status (xstat) | <p>Статус интерфейса</p> | DEPENDENT | dpi.int.status[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- JS</p> |
| - | Interface {#IFNAME}: Bits received (xstat) | <p>Входящий трафик, BPS</p> | DEPENDENT | dpi.int.in[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- MULTIPLIER: `8`</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Bits sent (xstat) | <p>Исходящий трафик, BPS</p> | DEPENDENT | dpi.int.out[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- MULTIPLIER: `8`</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Packets received (xstat) | <p>Входящие пакеты, PPS</p> | DEPENDENT | dpi.int.in.pkts[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Packets sent (xstat) | <p>Исходящие пакеты, PPS</p> | DEPENDENT | dpi.int.out.pkts[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Inbound packets dropped (xstat) | <p>Количество отброшенных пакетов, PPS</p> | DEPENDENT | dpi.int.in.drops[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Outbound packets dropped (xstat) | <p>Количество отброшенных исходящих пакетов, PPS</p> | DEPENDENT | dpi.int.out.drops[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Inbound packets with errors (xstat) | <p>Ошибки RX на интерфейсе, PPS</p> | DEPENDENT | dpi.int.in.errors[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Outbound packets with errors (xstat) | <p>Ошибки TX на интерфейсе, PPS</p> | DEPENDENT | dpi.int.out.errors[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |

Статистика для интерфейса с помощью лога fastdpi_stat.log:

| Группа | Имя | Описание | Тип | Ключ и информация |
|-----|----|-----------|----|---------------------|
| - | Interface statistics for {#IFNAME} (log) | <p>Статистика для интерфейса, полученная из лога fastdpi_stat.log.</p> | ZABBIX_PASSIVE | dpi.int.allstats[{#IFNAME},{#IFBRIDGE}] |
| - | Interface {#IFNAME}: Bits received (log) | <p>Входящий трафик, Mbps</p> | DEPENDENT | dpi.int.in.mbits[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- REPLACE</p><p>- MULTIPLIER: `1000000`</p> |
| - | Interface {#IFNAME}: Bits sent (log) | <p>Исходящий трафик, Mbps</p> | DEPENDENT | dpi.int.out.mbits[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- REPLACE</p><p>- MULTIPLIER: `1000000`</p> |
| - | Interface {#IFNAME}: Packets received (log) | <p></p> | DEPENDENT | dpi.int.in.pkt_sec[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- REPLACE</p> |
| - | Interface {#IFNAME}: Packets sent (log) | <p></p> | DEPENDENT | dpi.int.out.pkt_sec[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- REPLACE</p> |
| - | Interface {#IFNAME}: Packets dropped (log) | <p></p> | DEPENDENT | dpi.int.drops[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Error sending packets (log) | <p></p> | DEPENDENT | dpi.int.error_sending_packets[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |
| - | Interface {#IFNAME}: Error generating packets (log) | <p></p> | DEPENDENT | dpi.int.error_generating_packets[{#IFNAME},{#IFBRIDGE}] <p>**Preprocessing**:</p><p>- REGEXP</p><p>- CHANGE_PER_SECOND</p> |

## Триггеры

| Имя | Описание | Выражение | Важность | Дополнительная информация |
|-----|----------|--------|---|---|
| Authorization ratio is low | <p>Количество авторизованных пользователей меньше порогового.</p> |  `last(/Template SkatDPI/skatdpi.subs.auth.authorized) < last(/Template SkatDPI/skatdpi.subs.auth.total) * ({$SKATDPI_AUTHORIZED_SUBSCRIBERS_WARNING}/100)` | WARNING | |
| fastdpi control port is down | <p>Сервис fastdpi не отвечает по управляющему порту.</p> | `last(/Template SkatDPI/net.tcp.service[tcp,,{$SKATDPI_FASTDPI_CONTROL_PORT}])=0` | HIGH | |
| FastPCRF Server #1 is not accessible | <p>Сервис fastpcrf недоступен</p> | `last(/Template SkatDPI/net.tcp.service[tcp,{$SKATDPI_FASTPCRF_ADDRESS_1},{$SKATDPI_FASTPCRF_PORT_1}])=0` | HIGH | |
| FastPCRF Server #2 is not accessible| <p>Сервер fastpcrf #2 недоступен</p> | `last(/Template SkatDPI/net.tcp.service[tcp,{$SKATDPI_FASTPCRF_ADDRESS_2},{$SKATDPI_FASTPCRF_PORT_2}])=0` | HIGH | |
| Too many nonlegitimate drops | <p>Количество нелегитимных дропов превышает пороговое значение</p> | `min(/Template SkatDPI/skatdpi.absolute_stats_rcvd.drops.rx,5m)>{$SKATDPI_TOTAL_DROPS_WARN} or min(/Template SkatDPI/skatdpi.absolute_stats_rcvd.drops.tx,5m)>{$SKATDPI_TOTAL_DROPS_WARN}` | WARNING | |
| Interface {#DEVNAME}: Link down | <p>Интерфейс упал</p> | `last(/Template SkatDPI/dpi.int.status[{#IFNAME},{#IFBRIDGE}])=2 and (last(/Template SkatDPI/dpi.int.status[{#IFNAME},{#IFBRIDGE}],#1) <> last(/Template SkatDPI/dpi.int.status[{#IFNAME},{#IFBRIDGE}],#2))` | HIGH | |
