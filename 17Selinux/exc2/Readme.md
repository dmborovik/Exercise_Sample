<h1>Задание 2. Обеспечение работоспособности приложения при включенном Selinux</h1>

<p>Клонируем репозиторий из задания</p>

<pre>$ git clone https://github.com/mbfx/otus-linux-adm.git
Клонирование в «otus-linux-adm»...
remote: Enumerating objects: 558, done.
remote: Counting objects: 100% (456/456), done.
remote: Compressing objects: 100% (303/303), done.
remote: Total 558 (delta 125), reused 396 (delta 74), pack-reused 102
Получение объектов: 100% (558/558), 1.38 МиБ | 465.00 КиБ/с, готово.
Определение изменений: 100% (140/140), готово.
</pre>

<p>Переходим в катлог со стендом <i>otus-linux-adm/selinux_dns_problems</i>. В каталоге лежит Vagrantfile, из которого разворачивается две ВМ: <i><b>ns01</i></b> и <i><b>client</i></b></p>

<p>Подключимся к клиенту и попробуем внести изменения в зону</P>

<pre>[root@client ~]# nsupdate -k /etc/named.zonetransfer.key
&gt; server 192.168.50.10
&gt; zone ddns.lab
&gt; update add www.ddns.lab 60 A 192.168.50.15
&gt; send
update failed: SERVFAIL
</pre>

<p>Изменение внести не получилось. Проверим логи Selinux, с помощью утилиты audit2why, на предмет ошибок</p>

<pre>[root@client ~]# cat /var/log/audit/audit.log | audit2why
</pre>

<p>Ошибок нет. Проверим тоже самое на ns01</p>

<pre>root@ns01 ~]# cat /var/log/audit/audit.log | audit2why 
type=AVC msg=audit(1692606651.407:1903): avc:  denied  { create } for  pid=5417 comm=&quot;isc-worker0000&quot; name=&quot;named.ddns.lab.view1.jnl&quot; scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.
</pre>

<p>Здесь видим, что использован неправильный контекст безопасности. Вместо named_t используется тип etc_t</p>
<p>Изменим тип контекста безопасности для /etc/named</p>

<pre>[root@ns01 ~]# chcon -R -t named_zone_t /etc/named
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:named_zone_t:s0 <span style="color:#005FFF">.</span>
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       <span style="color:#005FFF">..</span>
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 <span style="color:#005FFF">dynamic</span>
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
</pre>

<p>Попробуем снова внести изменения на клиенте</p>

<pre>[root@client ~]# nsupdate -k /etc/named.zonetransfer.key
&gt; 192.168.50.10
incorrect section name: 192.168.50.10
&gt; server 192.168.50.10
&gt; zone ddns.lab
&gt; update add wwww.ddns.lab 60 A 192.168.50.15
&gt; send
&gt; quit
[root@client ~]# dig www.ddns.lab

; &lt;&lt;&gt;&gt; DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.14 &lt;&lt;&gt;&gt; www.ddns.lab
;; global options: +cmd
;; Got answer:
;; -&gt;&gt;HEADER&lt;&lt;- opcode: QUERY, status: NXDOMAIN, id: 54094
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.			IN	A

;; AUTHORITY SECTION:
ddns.lab.		600	IN	SOA	ns01.dns.lab. root.dns.lab. 2711201408 3600 600 86400 600

;; Query time: 6 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Mon Aug 21 08:50:21 UTC 2023
;; MSG SIZE  rcvd: 91

</pre>

<p>После перезагруки ВМ настройки сохраняются</p>
