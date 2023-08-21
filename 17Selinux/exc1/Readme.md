<h1>17 Selinux</h1>

<p> 1. Создаем ВМ из Vagrantfile. При запуске, видим ошибку с невозможностью запустить nginx на нестандартном порту. </p>

<p> 2. Зайдем на созданную ВМ по ssh, и решим эту проблему.</p>

<p>firewall отключен, конфигурация nginx в порядке. Ошибка связана с работой Selinux, так как он блокирует работу nginx на нестандартном порту. </p>

<h3>Разрешим в Selinux работу nginx на порту TCP 4881 с помощью setsebool</h3>

<p>Установим пакет policycoreutils-python, для использования утилиты audit2why </p>

<pre>
# yum install policycoreutils-python -y
</pre>

<p>Находим в audit.log инормацию о блокировании порта </p>

<pre>
type=AVC msg=audit(1692557897.867:824): avc:  denied  { name_bind } for  pid=2867 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
</pre>

<p>Приведем с помощью утилиты audit2why запись к "читабельнуму" виду и определим причину блокировки порта</p>
<pre>
grep 1692557897.867:824 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1692557897.867:824): avc:  denied  { name_bind } for  pid=2867 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

	Was caused by:
	The boolean nis_enabled was set incorrectly. 
	Description:
	Allow nis to enabled

	Allow access by executing:
	# setsebool -P nis_enabled 1
</pre>
<p>Из вывода видно, что нам необходимо поменять параметр nis_enabled. Включим этот параметр и перезапустим nginx.</p>
<pre>
[root@selinux ~]# setsebool -P nis_enabled on
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
<span style="color:#00AA00"><b>●</b></span> nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: <span style="color:#00AA00"><b>active (running)</b></span> since Sun 2023-08-20 19:40:00 UTC; 6s ago
  Process: 22708 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22706 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22704 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22710 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22710 nginx: master process /usr/sbin/nginx
           └─22712 nginx: worker process

Aug 20 19:40:00 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 20 19:40:00 selinux nginx[22706]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 20 19:40:00 selinux nginx[22706]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Aug 20 19:40:00 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
</pre>
<p>nginx успешно запущен</p>

<h3>Разрешение в Selinux работы nginx на порту 4881 с помощью добавления его в имеющийся тип</h3>

<p>Найдем, имеющиеся типы, для http трайика</p>

<pre>[root@selinux ~]# semanage port -l | grep http 
<span style="color:#AA0000"><b>http</b></span>_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
<span style="color:#AA0000"><b>http</b></span>_cache_port_t              udp      3130
<span style="color:#AA0000"><b>http</b></span>_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_<span style="color:#AA0000"><b>http</b></span>_port_t            tcp      5988
pegasus_<span style="color:#AA0000"><b>http</b></span>s_port_t           tcp      5989
</pre>

<p>Добавим порт в http_port_t, перезапустим nginx, проверим статус службы</p>

<pre>[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http_port_t
<span style="color:#AA0000"><b>http_port_t</b></span>                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_<span style="color:#AA0000"><b>http_port_t</b></span>            tcp      5988
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
<span style="color:#00AA00"><b>●</b></span> nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: <span style="color:#00AA00"><b>active (running)</b></span> since Sun 2023-08-20 20:52:52 UTC; 6s ago
  Process: 22784 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22782 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22781 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22786 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22786 nginx: master process /usr/sbin/nginx
           └─22787 nginx: worker process

Aug 20 20:52:52 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 20 20:52:52 selinux nginx[22782]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 20 20:52:52 selinux nginx[22782]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Aug 20 20:52:52 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
</pre>

<h3>Разрешение в Selinux работы nginx на порту 4881 с помощью формирования и установки модуля Selinux </h3>

<p>Создадим разрешение на основе сообщение в логе audit.log с помощью утилиты audit2allow</p>

<pre>[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp
</pre>

<p>Утлита audit2allow сформировала модуль и сообщила нам команду, с помощью которой можно применить данный модуль. Воспользуемся этой командой. Перезапустим службу nginx и проверим ее статус.</p>
<pre>[root@selinux ~]# semodule -i nginx.pp
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
<span style="color:#00AA00"><b>●</b></span> nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: <span style="color:#00AA00"><b>active (running)</b></span> since Sun 2023-08-20 21:08:33 UTC; 5s ago
  Process: 22860 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22858 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22857 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22862 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22862 nginx: master process /usr/sbin/nginx
           └─22863 nginx: worker process

Aug 20 21:08:33 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 20 21:08:33 selinux nginx[22858]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 20 21:08:33 selinux nginx[22858]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Aug 20 21:08:33 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
</pre>

<h2>Заключение</h2>

<p>В данном упражнении воспользовались тремя способами разрешения порта 4881 для nginx в selinux. Во всех случаях, разрешение происходит корректно. Но надо учитывать, что эти разрешения останутся после перезагрузки машины, только в третьем случае, где мы добавили модуль.</p>



