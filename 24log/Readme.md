<h1>Основы сбора и хранения логов</h1>

<h2><b>Описание домашнего задания</b></h2>

<h3>В Vagrant разворачиваем 2 виртуальные машины</h3>

<p>Две виртуальные машины разворачиваются из Vagrantfile. Во время поднятия машин, производятся все необходимые настройки, с помощью скриптов. _InstallLog.sh - для настройки ВМ log, где будут собираться логи. _InstallWeb.sh - для настройки ВМ web, на которой будут собираться логи nginx и audit. </p>
<p>Описание, того, что настраивается ниже</p>

<h3>На <i>web</i> настраиваем <i>nginx</i></h3>
<p>nginx будем использовать с настройками из "коробки", без дополнительных вмешательств. Проверим работу на web</p>
<pre>[root@web vagrant]# systemctl status nginx
<span style="color:#00AA00"><b>●</b></span> nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: <span style="color:#00AA00"><b>active (running)</b></span> since Mon 2023-09-04 21:33:35 MSK; 9min ago
  Process: 3558 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3556 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3555 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3560 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3560 nginx: master process /usr/sbin/nginx
           └─3563 nginx: worker process

Sep 04 21:33:35 web systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Sep 04 21:33:35 web systemd[1]: Starting The nginx HTTP and reverse proxy server...
Sep 04 21:33:35 web nginx[3556]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Sep 04 21:33:35 web nginx[3556]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Sep 04 21:33:35 web systemd[1]: Started The nginx HTTP and reverse proxy server.
</pre>

<h3>На <i>log</i> настраиваем центральный лог сервер на системе rsyslog</h3>

<p>Все настройки находятся в файле rsyslog.conf. Файл с необходимыми настройками и комментариями находится /config/web/rsyslog.conf. В конфиге открывается порт 514. 
</p>
<pre>[root@log vagrant]# ss -tulpn | grep 514
udp    UNCONN     0      0         *:<span style="color:#AA0000"><b>514</b></span>                   *:*                   users:((&quot;rsyslogd&quot;,pid=3824,fd=3))
udp    UNCONN     0      0      [::]:<span style="color:#AA0000"><b>514</b></span>                [::]:*                   users:((&quot;rsyslogd&quot;,pid=3824,fd=4))
tcp    LISTEN     0      25        *:<span style="color:#AA0000"><b>514</b></span>                   *:*                   users:((&quot;rsyslogd&quot;,pid=3824,fd=5))
tcp    LISTEN     0      25     [::]:<span style="color:#AA0000"><b>514</b></span>                [::]:*                   users:((&quot;rsyslogd&quot;,pid=3824,fd=6))
</pre>

<h3>Настройка отправки логов с web и аудита следящего за изменением конфигов nginx</h3>

<p>Вносим неоюходимые настройки в nginx.conf (см. /config/web/nginx.conf) и проверяем отправку логов на log.</p>
<pre>[root@log vagrant]# cat /var/log/rsyslog/web/nginx_access.log 
Sep  4 22:07:43 web nginx_access: 192.168.56.15 - - [04/Sep/2023:22:07:43 +0300] &quot;GET / HTTP/1.1&quot; 200 4833 &quot;-&quot; &quot;curl/7.29.0&quot;
</pre>
<pre>[root@log vagrant]# ls /var/log/rsyslog/web/nginx_error.log 
/var/log/rsyslog/web/nginx_error.log
[root@log vagrant]# cat /var/log/rsyslog/web/nginx_error.log 
Sep  4 22:12:25 web nginx_error: 2023/09/04 22:12:25 [error] 3937#3937: *1 directory index of &quot;/usr/share/nginx/html/&quot; is forbidden, client: 192.168.56.1, server: _, request: &quot;GET / HTTP/1.1&quot;, host: &quot;192.168.56.10&quot;
Sep  4 22:12:25 web nginx_error: 2023/09/04 22:12:25 [error] 3937#3937: *1 open() &quot;/usr/share/nginx/html/img/centos-logo.png&quot; failed (2: No such file or directory), client: 192.168.56.1, server: _, request: &quot;GET /img/centos-logo.png HTTP/1.1&quot;, host: &quot;192.168.56.10&quot;, referrer: &quot;http://192.168.56.10/&quot;
Sep  4 22:12:25 web nginx_error: 2023/09/04 22:12:25 [error] 3937#3937: *2 open() &quot;/usr/share/nginx/html/img/html-background.png&quot; failed (2: No such file or directory), client: 192.168.56.1, server: _, request: &quot;GET /img/html-background.png HTTP/1.1&quot;, host: &quot;192.168.56.10&quot;, referrer: &quot;http://192.168.56.10/&quot;
Sep  4 22:12:27 web nginx_error: 2023/09/04 22:12:27 [error] 3937#3937: *3 directory index of &quot;/usr/share/nginx/html/&quot; is forbidden, client: 192.168.56.1, server: _, request: &quot;GET / HTTP/1.1&quot;, host: &quot;192.168.56.10&quot;
</pre>
<p>Видим, логи отправляются корректно</p>

<h3>Настройка аудита</h3>

<p>За аудит отвечает утилита audit. Для того, чтобы она отслеживала изменения в конфигурации nginx. Для этого редактируем /etc/audit/rules.d/audit.rules (см. config/web/audit.rules).</p>
<p>После внесенных изменений, будут записываться логи изменения</p>
<pre>[root@web vagrant]# ausearch -f /etc/nginx/nginx.conf
----
time-&gt;Tue Sep  5 08:02:43 2023
node=web type=PROCTITLE msg=audit(1693890163.489:1159): proctitle=63686D6F64002B78002F6574632F6E67696E782F6E67696E782E636F6E66
node=web type=PATH msg=audit(1693890163.489:1159): item=0 name=&quot;/etc/nginx/nginx.conf&quot; inode=12492 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
node=web type=CWD msg=audit(1693890163.489:1159):  cwd=&quot;/home/vagrant&quot;
node=web type=SYSCALL msg=audit(1693890163.489:1159): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=81e0f0 a2=1ed a3=7ffe427ba1a0 items=1 ppid=3727 pid=23036 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=4 comm=&quot;chmod&quot; exe=&quot;/usr/bin/chmod&quot; subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=&quot;nginx_conf&quot;
</pre>

<p>Для пересылки логов на удаленный сервер, используется утилита audispd-plugins. Все необходимые настройки внесены в файлах au-remote.conf, audisp-remote.conf в каталоге web и auditd.conf в каталоге log. </p>

<pre>[root@log vagrant]# ausearch -f /etc/nginx/nginx.conf 
----
time-&gt;Tue Sep  5 15:41:03 2023
node=web type=PROCTITLE msg=audit(1693917663.955:1077): proctitle=63686D6F64002D78002F6574632F6E67696E782F6E67696E782E636F6E66
node=web type=PATH msg=audit(1693917663.955:1077): item=0 name=&quot;/etc/nginx/nginx.conf&quot; inode=15404 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
node=web type=CWD msg=audit(1693917663.955:1077):  cwd=&quot;/home/vagrant&quot;
node=web type=SYSCALL msg=audit(1693917663.955:1077): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=1a9a110 a2=1a4 a3=7fff6db3e0e0 items=1 ppid=3717 pid=3966 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=4 comm=&quot;chmod&quot; exe=&quot;/usr/bin/chmod&quot; subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=&quot;nginx_conf&quot;
</pre>
