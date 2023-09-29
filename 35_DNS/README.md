<h1>DNS - настройка и обслуживание.</h1>

<p><b>Цель</b>: <p>
<ul>
    <li>Узнать как завести домен</li>
    <li>Управлять зонами</li>
    <li>Обслуживать свой домен самостоятельно</li>
    <li>Разобрать dig/host/nslookup</li>
</ul>

<h2>Стенд для выполнения и настройка DNS</h2>

<p>Стенд для выполнения задания взят с https://github.com/erlong15/vagrant-bind. В нем: </p>
<ul>
    <li><a src='vagrant-bind/Vagrantfile'>Vagrantfile</a> - установка ВМ для демонистрации задания.</li>
    <li><a src='vagrant-bind/provisioning'>provisioning</a> - Настройка, разварачиваемых ВМ.</li>
</ul>

<h3>Добаляем еще одну ВМ</h3>

<p>Добавим к нашему Vagrantfile еще одну ВМ client2, аналогичную client. Так же добавляем ее в наш плэй, аналогичный таск.</p>
<p>Для нормалтной работы DNS, на них должно быть настроено одинаковое время, для этого будем использовтаь службу NTP. Утсановка NTP уже указана в нашем плэе. Осталось только дописать таски на остановку Chrony и запуск NTP.</p>
<p>Проверим на каком порту работают наши DNS сервера.</p>
<p><b>ns01:</b></p>
<pre># ss -tulpn | grep named
udp    UNCONN     0      0      192.168.50.10:53                    *:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=5090,fd=512))
udp    UNCONN     0      0         [::1]:53                 [::]:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=5090,fd=513))
tcp    LISTEN     0      10     192.168.50.10:53                    *:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=5090,fd=21))
tcp    LISTEN     0      128    192.168.50.10:953                   *:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=5090,fd=23))
tcp    LISTEN     0      10        [::1]:53                 [::]:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=5090,fd=22))
</pre>
<pre>    // network 
	listen-on port 53 { 192.168.50.10; };
	listen-on-v6 port 53 { ::1; };
</pre>
<p><b>ns02:</b></p>
<pre># ss -tulpn | grep named
udp    UNCONN     0      0      192.168.50.11:53                    *:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=4679,fd=512))
udp    UNCONN     0      0         [::1]:53                 [::]:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=4679,fd=513))
tcp    LISTEN     0      10     192.168.50.11:53                    *:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=4679,fd=21))
tcp    LISTEN     0      128    192.168.50.11:953                   *:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=4679,fd=23))
tcp    LISTEN     0      10        [::1]:53                 [::]:*                   users:((&quot;<span style="color:#CC0000"><b>named</b></span>&quot;,pid=4679,fd=22))
</pre>
<pre>    // network 
	listen-on port 53 { 192.168.50.11; };
	listen-on-v6 port 53 { ::1; };
</pre>
<p>Нам нужно теперь подкорректировать наш файл resolv.conf для того, чтобы DNS сервера видели друг друга.</p>

<p>Теперь добавим имена в зону dns.lab. Для начала проверим, что зона dns.lab уже существует на серверах</p>

<p><b>ns01:</b></p>
<pre>// lab&apos;s zone
zone &quot;dns.lab&quot; {
    type master;
    allow-transfer { key &quot;zonetransfer.key&quot;; };
    file &quot;/etc/named/named.dns.lab&quot;;
};

</pre>
<p><b>ns02:</b></p>
<pre>// lab&apos;s zone
zone &quot;dns.lab&quot; {
    type slave;
    masters { 192.168.50.10; };
    file &quot;/etc/named/named.dns.lab&quot;;
};
</pre>

<p>Добавим на ns01, который у нас мастер, в файл /etc/named/named.dns.lab записи для наших двух не DNS серверов.</p>
<p>После добавления выполним проверку с клиента</p>

<p><b>client:</b></p>
<pre># dig @192.168.50.10 web1.dns.lab

; &lt;&lt;&gt;&gt; DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.14 &lt;&lt;&gt;&gt; @192.168.50.10 web1.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; -&gt;&gt;HEADER&lt;&lt;- opcode: QUERY, status: NOERROR, id: 21782
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web1.dns.lab.			IN	A

;; ANSWER SECTION:
web1.dns.lab.		3600	IN	A	192.168.50.15

;; AUTHORITY SECTION:
dns.lab.		3600	IN	NS	ns02.dns.lab.
dns.lab.		3600	IN	NS	ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.		3600	IN	A	192.168.50.10
ns02.dns.lab.		3600	IN	A	192.168.50.11

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Wed Sep 27 19:09:27 UTC 2023
;; MSG SIZE  rcvd: 127
</pre>
<p><b>client2:</b></p>
<pre># dig @192.168.50.11 web2.dns.lab

; &lt;&lt;&gt;&gt; DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.14 &lt;&lt;&gt;&gt; @192.168.50.11 web2.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; -&gt;&gt;HEADER&lt;&lt;- opcode: QUERY, status: NOERROR, id: 15714
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web2.dns.lab.			IN	A

;; ANSWER SECTION:
web2.dns.lab.		3600	IN	A	192.168.50.16

;; AUTHORITY SECTION:
dns.lab.		3600	IN	NS	ns02.dns.lab.
dns.lab.		3600	IN	NS	ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.		3600	IN	A	192.168.50.10
ns02.dns.lab.		3600	IN	A	192.168.50.11

;; Query time: 1 msec
;; SERVER: 192.168.50.11#53(192.168.50.11)
;; WHEN: Wed Sep 27 19:12:55 UTC 2023
;; MSG SIZE  rcvd: 127
</pre>
<p>Мы обратились к разным DNS-серверам c разными запросами и в обоих случаях получили ответ</p>

<p>Создадим новую зону named.newdbs.lab. Для этого:</p>
<ul>
    <li> На хосте ns01 добавим зону в /etc/named.conf</li>
    <pre>// lab&apos;s newdns zone
zone &quot;newdns.lab&quot;{
    type master;
    allow-transfer { key &quot;zonetransfer.key&quot;; };
    allow-update { key &quot;zonetransfer.key&quot;; };
    file &quot;/etc/named/named.newdns.lab&quot;;
};
</pre>
    <li>На хосте ns02 также добавим зону и укажем в каком сервере необходимо запрашивать информацию </li>
    <pre>// lab&apos;s newdns zone
zone &quot;newdns.lab&quot; {
    type slave;
    masters { 192.168.50.10; };
    file &quot;/etc/named/named.newdns.lab&quot;;
};
</pre>
<li>На хосте ns01 создадим файл (см. <a src='vagrant-bind/provisioning/named.newdns.lab'>named.newdns.lab</a>)
<li>Проверяем, видим что DNS записи подъехали</li>
<pre># dig @192.168.50.10 www.newdns.lab

; &lt;&lt;&gt;&gt; DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.14 &lt;&lt;&gt;&gt; @192.168.50.10 www.newdns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; -&gt;&gt;HEADER&lt;&lt;- opcode: QUERY, status: NOERROR, id: 29575
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.newdns.lab.			IN	A

;; ANSWER SECTION:
www.newdns.lab.		3600	IN	A	192.168.50.16
www.newdns.lab.		3600	IN	A	192.168.50.15

;; AUTHORITY SECTION:
newdns.lab.		3600	IN	NS	ns01.dns.lab.
newdns.lab.		3600	IN	NS	ns02.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.		3600	IN	A	192.168.50.10
ns02.dns.lab.		3600	IN	A	192.168.50.11

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Wed Sep 27 19:58:31 UTC 2023
;; MSG SIZE  rcvd: 149
</pre>
</ul>

<h2>Настройка Split-DNS</h2>

<p>Нам необходимо, чтобы client видел запись web1.dns.lab, но не видеть web2.dns.lab. Client2 может видеть обе записи из домена dns.lab, но не должны видеть записи домена newdns.lab. Решим это с помощью технологии Split-DNS.</p>
<p>Для настройки выполним следующие шаги:</p>
<ol>
    <li>Создадим дополнительный файл зоны dns.lab, в котором будет прописана только одна запись (<a src='vagrant-bind/provisioning/templates/named.dns.lab.client'>named.dns.lab.client</a>)</li>
    <li>Добавим access листы для хостов client и client2 в файле /etc/named.conf на хостах ns01 и ns02</li>
    <li>Создадим файл с настройками зоны dns.lab для client (<a src='vagrant-bind/provisioning/named.dns.lab.client'>named.dns.lab.client</a>)</li>
    <li>Перепишем /etc/named.conf по принципам технологии Split-DNS, с помощью описания каждого представления (view) для каждого отдельного acl. (<a src='vagrant-bind/provisioning/master-named-split.conf'>master-named-split</a> для NS01 и <a src='vagrant-bind/provisioning/slave-named-split.conf'>slave-named-split.conf</a>для NS02)     
</ol>

<p>Проверяем на <b>client:</b></p>

<pre>[root@client vagrant]# ping www.newdns.lab -c 5
PING www.newdns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client (192.168.50.15): icmp_seq=1 ttl=64 time=0.014 ms
64 bytes from client (192.168.50.15): icmp_seq=2 ttl=64 time=0.041 ms
64 bytes from client (192.168.50.15): icmp_seq=3 ttl=64 time=0.038 ms
64 bytes from client (192.168.50.15): icmp_seq=4 ttl=64 time=0.043 ms
64 bytes from client (192.168.50.15): icmp_seq=5 ttl=64 time=0.031 ms
</pre>

<pre>[root@client vagrant]# ping web1.dns.lab -c 5
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client (192.168.50.15): icmp_seq=1 ttl=64 time=0.016 ms
64 bytes from client (192.168.50.15): icmp_seq=2 ttl=64 time=0.040 ms
64 bytes from client (192.168.50.15): icmp_seq=3 ttl=64 time=0.037 ms
64 bytes from client (192.168.50.15): icmp_seq=4 ttl=64 time=0.041 ms
64 bytes from client (192.168.50.15): icmp_seq=5 ttl=64 time=0.043 ms
</pre>
<pre>[root@client vagrant]# ping web2.dns.lab
ping: web2.dns.lab: Name or service not known
</pre>

<p>client видит зоны dns.lab и newdns.lab, но не может получить информацию о web2.dns.lab</p>

<p>Проверяем на <b>client2:</b></p>

<pre>[root@client2 vagrant]# ping www.newdns.lab
ping: www.newdns.lab: Name or service not known
</pre>
<pre>[root@client2 vagrant]# ping web1.dns.lab -c 5
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=1 ttl=64 time=0.520 ms
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=2 ttl=64 time=0.852 ms
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=3 ttl=64 time=0.832 ms
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=4 ttl=64 time=1.03 ms
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=5 ttl=64 time=0.785 ms

--- web1.dns.lab ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4004ms
rtt min/avg/max/mdev = 0.520/0.805/1.036/0.166 ms
</pre>
<pre># ping web2.dns.lab -c 5
PING web2.dns.lab (192.168.50.16) 56(84) bytes of data.
64 bytes from client2 (192.168.50.16): icmp_seq=1 ttl=64 time=0.025 ms
64 bytes from client2 (192.168.50.16): icmp_seq=2 ttl=64 time=0.081 ms
64 bytes from client2 (192.168.50.16): icmp_seq=3 ttl=64 time=0.165 ms
64 bytes from client2 (192.168.50.16): icmp_seq=4 ttl=64 time=0.074 ms
64 bytes from client2 (192.168.50.16): icmp_seq=5 ttl=64 time=0.108 ms

--- web2.dns.lab ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4000ms
rtt min/avg/max/mdev = 0.025/0.090/0.165/0.047 ms
</pre>
<p>client2 видит всю зону dns.lab и не видит зону newdns.lab</b>

<p>Если из /etc/resolv.conf удалить информацию по однуму из DNS-серверов, и повторить проверку, то результат будет аналогичным. Это происходит, потому что сервера master и slave отдают одинаковую информацию</p>