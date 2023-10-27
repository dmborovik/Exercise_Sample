<h1>Postgres: Backup + репликация</h1>

<p><b>Цель:</b> Научиться настраивать репликацию и создавать резервные копии в СУБД PostgreSQL</p>

<p>Для выполнения задания используется Vagrant+Ansible. Разворачивается 3 ВМ (node1, node2, barman) для демонстрации домашнего задания. playbook - для настройки хостов в соответствии с заданием</p>

<h2>Настройка hot_standby репликации с использованием слотов</h2>

<p>Для настройки репликации используются роли. install_progres - для нустановки PosgreSQL. postgres_replication - для настройки репликации</p>

<p>Для проверки работоспособности репликации создадим базу на node1</p>
<pre>postgres=# CREATE DATABASE test_base;
CREATE DATABASE
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_base | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(4 rows)
</pre>

<p>Проверим на node2</p>
<pre>postgres-# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_base | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(4 rows)

</pre>
<p>Наша тестовая база появилась на второй ноде</p>

<p>Еще можно проверить вводом следующих команд. Вывод должен быть не пустой</p>

<p>На node1</p>
<pre>        ^
postgres=# SELECT * from pg_stat_replication;
  pid  | usesysid |  usename   | application_name |  client_addr  | client_hostname | client_port |        backend_start         | backend_xmin |   state   | sent_lsn  | write_lsn | flush_lsn | replay_lsn | write_lag | flush_lag | replay_
lag | sync_priority | sync_state |          reply_time           
-------+----------+------------+------------------+---------------+-----------------+-------------+------------------------------+--------------+-----------+-----------+-----------+-----------+------------+-----------+-----------+--------
----+---------------+------------+-------------------------------
 38495 |    16384 | replicator | walreceiver      | 192.168.56.12 |                 |       50210 | 2023-10-26 15:02:40.94522-03 |          736 | streaming | 0/B000148 | 0/B000148 | 0/B000148 | 0/B000148  |           |           |        
    |             0 | async      | 2023-10-26 15:08:33.125566-03
(1 row)
</pre>

<p> На node2:</p>
<pre>postgres=# SELECT * from pg_stat_wal_receiver;
  pid  |  status   | receive_start_lsn | receive_start_tli | written_lsn | flushed_lsn | received_tli |      last_msg_send_time       |     last_msg_receipt_time     | latest_end_lsn |        latest_end_time        | slot_name |  sender_h
ost  | sender_port |                                                                                                                                        conninfo                                                                          
                                                               
-------+-----------+-------------------+-------------------+-------------+-------------+--------------+-------------------------------+-------------------------------+----------------+-------------------------------+-----------+----------
-----+-------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------
 35941 | streaming | 0/B000000         |                 1 | 0/B000148   | 0/B000148   |            1 | 2023-10-26 15:10:10.488713-03 | 2023-10-26 15:10:10.496693-03 | 0/B000148      | 2023-10-26 15:07:40.211876-03 |           | 192.168.5
6.11 |        5432 | user=replicator password=******** channel_binding=prefer dbname=replication host=192.168.56.11 port=5432 fallback_application_name=walreceiver sslmode=prefer sslcompression=0 sslsni=1 ssl_min_protocol_version=TLSv1.2 
gssencmode=prefer krbsrvname=postgres target_session_attrs=any
(1 row)
</pre>

<h2>Настройка резервного копирования</h2>

<p>Резервное копирование настраивается с помощью утилиты barman. В документации рекомендовано разварачивать на отдельном хосте. Не будем отступать от документации. <p>

<p>Утилита barman разворачивается на отдельной ВМ. За настройку отвечает роль install_barman</p>

<p>После уьсановки проверяем работу</p>

<pre>bash-4.4$ barman switch-wal node1
The WAL file 000000010000000000000020 has been closed on server &apos;node1&apos;
</pre>

<pre>bash-4.4$ barman cron
Starting WAL archiving for server node1
</pre>

<pre>bash-4.4$ barman check node1
Server node1:
	PostgreSQL: <span style="color:#4E9A06">OK</span>
	superuser or standard user with backup privileges: <span style="color:#4E9A06">OK</span>
	PostgreSQL streaming: <span style="color:#4E9A06">OK</span>
	wal_level: <span style="color:#4E9A06">OK</span>
	replication slot: <span style="color:#4E9A06">OK</span>
	directories: <span style="color:#4E9A06">OK</span>
	retention policy settings: <span style="color:#4E9A06">OK</span>
	backup maximum age: <span style="color:#CC0000">FAILED</span> (interval provided: 4 days, latest backup age: No available backups)
	backup minimum size: <span style="color:#4E9A06">OK</span> (0 B)
	wal maximum age: <span style="color:#4E9A06">OK</span> (no last_wal_maximum_age provided)
	wal size: <span style="color:#4E9A06">OK</span> (0 B)
	compression settings: <span style="color:#4E9A06">OK</span>
	failed backups: <span style="color:#4E9A06">OK</span> (there are 0 failed backups)
	minimum redundancy requirements: <span style="color:#CC0000">FAILED</span> (have 0 backups, expected at least 1)
	pg_basebackup: <span style="color:#4E9A06">OK</span>
	pg_basebackup compatible: <span style="color:#4E9A06">OK</span>
	pg_basebackup supports tablespaces mapping: <span style="color:#4E9A06">OK</span>
	systemid coherence: <span style="color:#4E9A06">OK</span> (no system Id stored on disk)
	pg_receivexlog: <span style="color:#4E9A06">OK</span>
	pg_receivexlog compatible: <span style="color:#4E9A06">OK</span>
	receive-wal running: <span style="color:#4E9A06">OK</span>
	archiver errors: <span style="color:#4E9A06">OK</span>
</pre>

<p> Утилита barman настроена</p>