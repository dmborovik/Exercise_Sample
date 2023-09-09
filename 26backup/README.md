<h1>Резервное копирование</h1>

<h2>Установка и настройка тестового стенда</h2>

<p>Установка и настройка производится в Vagrantfile. Разворачивается две ВМ:</p>
<ol>
<li>backup 192.168.56.10 CentOS 7</li>
<li>client 192.168.56.15 CentOS 7</li>
</ol>

<p>На обе ВМ подключаем EPEL-репозиторий и устанавливаем borgbackup</p>

<p>На backup создаем каталог для будущего бэкапа и смонтируем его к добавленному диску на 2G. </p>

<pre>[root@server vagrant]# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  40G  0 disk 
└─sda1   8:1    0  40G  0 part /
sdb      8:16   0   2G  0 disk /var/backup
</pre>

<p>Так же добавим ключ в authorized_keys на нашем сервере backup, предварительно созданный на клиенте.</p>
<pre>command=&quot;/usr/bin/borg serve&quot; ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCp4+Q2MJFl5DgDdKzOoKtdpOEeD8bN...</pre>

<h3>Настраиваем клиент</h3>
<p>Инициализируем репозиторий на backup с клиента следующей командой</p>
<pre>[borg@client ~]$ borg init --encryption=repokey borg@192.168.56.50:/var/backup
</pre>

<p>Создаем бэкап каталога /etc</p>

<pre>borg create --stats --list borg@192.168.56.50:/var/backup/::&quot;etc-{now:%Y-%m-%d_%H:%M:%S}&quot; /etc
</pre>

<p>Проверяем что получилось</p>
<pre>[borg@client ~]$ borg list borg@192.168.56.50:/var/backup
Enter passphrase for key ssh://borg@192.168.56.50/var/backup: 
etc-2023-09-09_15:48:19              Sat, 2023-09-09 15:48:24 [5602161f72f8954ce1e9533169dacfe31ffa29d95b1290234158909a4a6d909d]</pre>

<p>Достанем файл из бэкапа</p>

<pre>[borg@client ~]$ borg extract borg@192.168.56.50:/var/backup/::etc-2023-09-09_15:48:19 etc/hostname
Enter passphrase for key ssh://borg@192.168.56.50/var/backup: 
[borg@client ~]$ ls
<span style="color:#005FFF">etc</span>
[borg@client ~]$ ls etc/
hostname
</pre>

<h3>Автоматизация создания бэкапов</h3>

<p>Автоматизируем создание бэкапов с помощью сервиса и таймера systemd</p>
<p>Создадим новый Unit сервис (см. config/borg-backup.service) и таймер (см. config/borg-backup.timer), который будет запускать нашу службу каждые 5 минут.</p>
<p>Проверим работу сервиса и таймера</p>

<pre>[root@client vagrant]# systemctl status borg-backup.service 
● borg-backup.service - Borg Backup
   Loaded: loaded (/etc/systemd/system/borg-backup.service; disabled; vendor preset: disabled)
   Active: inactive (dead) since Sat 2023-09-09 16:33:02 UTC; 1min 3s ago
  Process: 23102 ExecStart=/bin/borg prune --keep-daily 90 --keep-monthly 12 --keep-yearly 1 ${REPO} (code=exited, status=0/SUCCESS)
  Process: 23097 ExecStart=/bin/borg check ${REPO} (code=exited, status=0/SUCCESS)
  Process: 23093 ExecStart=/bin/borg create --stats ${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} ${BACKUP_TARGET} (code=exited, status=0/SUCCESS)
 Main PID: 23102 (code=exited, status=0/SUCCESS)

Sep 09 16:32:55 client borg[23093]: Number of files: 1702
Sep 09 16:32:55 client borg[23093]: Utilization of max. archive size: 0%
Sep 09 16:32:55 client borg[23093]: ------------------------------------------------...---
Sep 09 16:32:55 client borg[23093]: Original size      Compressed size    Deduplicat...ize
Sep 09 16:32:55 client borg[23093]: This archive:               28.43 MB            ... kB
Sep 09 16:32:55 client borg[23093]: All archives:               56.86 MB            ... MB
Sep 09 16:32:55 client borg[23093]: Unique chunks         Total chunks
Sep 09 16:32:55 client borg[23093]: Chunk index:                    1290            ...398
Sep 09 16:32:55 client borg[23093]: ------------------------------------------------...---
Sep 09 16:33:02 client systemd[1]: Started Borg Backup.
Hint: Some lines were ellipsized, use -l to show in full.
</pre>

<pre>[root@client vagrant]# systemctl status borg-backup.timer 
<span style="color:#00AA00"><b>●</b></span> borg-backup.timer - Borg Backup
   Loaded: loaded (/etc/systemd/system/borg-backup.timer; enabled; vendor preset: disabled)
   Active: <span style="color:#00AA00"><b>active (waiting)</b></span> since Sat 2023-09-09 16:11:14 UTC; 23min ago

Sep 09 16:11:14 client systemd[1]: Started Borg Backup.
</pre>

<p>Выждем время и проверим все ли хорошо создается</p>

<pre>[root@client vagrant]# borg list borg@192.168.56.50:/var/backup
Enter passphrase for key ssh://borg@192.168.56.50/var/backup: 
etc-2023-09-09_16:38:47              Sat, 2023-09-09 16:38:48 [612d29928486c5e283cd5129c87bb5a9cffb35740ee6a64031b4729463852b2d]
etc-2023-09-09_16:43:52              Sat, 2023-09-09 16:43:54 [21d5183ac010a100d9ed7fb097104f12ff7d9b56ab8f02b201e8d2e9169c64a7]
</pre>
