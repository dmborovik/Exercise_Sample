<h1>Мосты, туннели и VPN</h1>

<p><b>Цели:</b></p>
<ul>
    <li>Между двумя виртуалками поднять vpn в режимах:</li>
    <ul>
        <li>tun</li>
        <li>tap</li>
    </ul>
    <p>Описать в чем разница, замерить скорость между виртуальными машинами в туннелях, сделать вывод об отличающихся показателях скорости.</p>
    <li>Поднять RAS на базе OpenVPN с клиентскими сертификтами, подключиться с локальной машины на виртуалку.</p>
</ul>

<p><a src='./Vagrantfile'>Vagrantfile</a> - создание тестового стенда.</p>
<p><a src='playbooks'>playbooks</a>- плэи для оконччательной настройки</p>
<p><a src='playbooks/openvpn'>openvpn</a> - каталог с файлами для настройки RAS на базе openVPN </p>
<h2>TUN/TAP режимы VPN</h2>

<h3>Cоздание виртуальных машин.</h3>

<p>Создаются две ВМ Centos/7 (server и cLietn) в Vagrantfile.</p>

<h3>Подготовка ВМ</h3>

<p>После запуска ВМ, производим предварительную настройку (<a src='playbooks/ConfigHost.yml'>ConfigHost.yml</a>). Для этого: </p>
<ul>
    <li>Устанавливаем EPEL-репозиторий</li>
    <li>Устанавливаем пакеты openvp и iperf3</li>
    <li>Отключаем SELinux</li>
</ul>

<h3>Настройка openvpn сервера</h3>
<ul>
    <li>Создаем файл ключ на сервере</li>
    <pre>[root@server vagrant]# openvpn --genkey --secret /etc/openvpn/static.key
</pre>
    <li>Создаем конфигурационный файл vpn-сервера (<a src='playbooks/templates/tap.server.conf>'>tap.server.conf</a> - для tap и <a src='playbooks/templates/tun.server.conf>'>tun.conf.server</a>для tun).</li>
    <li>Создаем Unit для запуска Openvpn <a src='playbooks/templates/openvpn@.service'>openvpn@service</a></li>
    <li>Перезагружаем systemd, запускаем OpenVPN и активируем автозагрузку</li>
</ul>
<h3>Настройка openvpn клиента</h3>
<ul>
    <li>Копируем на него нащ ключ static.key</li>
    <li>Создаем конфигурационный файл клиента (<a src='playbooks/templates/tap.client.conf'>tap.client.conf</a> для таp и <a src='playbooks/templates/tun.client.conf'>tun.client.conf</a> для tun).</li>
    <li>Запускаем openvpn клиент</li>
</ul>

<h3>Замерим скорость в туннеле</h3>
<ul>
    <li>на openvpn сервере запускаем iperf3 в режиме сервера</li>
    <pre> # iperf3  -s &amp;
[1] 32243
[root@server vagrant]# -----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------

</pre>
    <li>На openvpn клиенте запускаем iperf3 в режиме клиента и замеряем скорость в туннеле</li>
    <pre># iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 33004 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  49.8 MBytes  83.5 Mbits/sec   18    308 KBytes       
[  4]   5.00-10.00  sec  49.0 MBytes  82.2 Mbits/sec   19    333 KBytes       
[  4]  10.00-15.00  sec  49.7 MBytes  83.4 Mbits/sec   12    344 KBytes       
[  4]  15.00-20.01  sec  48.7 MBytes  81.6 Mbits/sec    0    433 KBytes       
[  4]  20.01-25.01  sec  49.4 MBytes  82.8 Mbits/sec   18    301 KBytes       
[  4]  25.01-30.01  sec  49.0 MBytes  82.3 Mbits/sec    0    400 KBytes       
[  4]  30.01-35.00  sec  48.5 MBytes  81.5 Mbits/sec   95    263 KBytes       
[  4]  35.00-40.01  sec  48.9 MBytes  81.9 Mbits/sec    0    373 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.01  sec   393 MBytes  82.4 Mbits/sec  162             sender
[  4]   0.00-40.01  sec   392 MBytes  82.2 Mbits/sec                  receiver

iperf Done.
</pre>

<li>Теперь повторяем все тоже самое для режима tun</li>

<pre>[vagrant@client ~]$ iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 49094 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  59.7 MBytes   100 Mbits/sec   92    283 KBytes       
[  4]   5.00-10.00  sec  58.2 MBytes  97.6 Mbits/sec   30    263 KBytes       
[  4]  10.00-15.01  sec  57.0 MBytes  95.5 Mbits/sec   17    240 KBytes       
[  4]  15.01-20.00  sec  59.4 MBytes  99.8 Mbits/sec   22    254 KBytes       
[  4]  20.00-25.01  sec  57.8 MBytes  96.8 Mbits/sec    1    330 KBytes       
[  4]  25.01-30.00  sec  56.4 MBytes  94.8 Mbits/sec   42    287 KBytes       
[  4]  30.00-35.01  sec  57.0 MBytes  95.5 Mbits/sec   43    247 KBytes       
[  4]  35.01-40.00  sec  54.7 MBytes  91.9 Mbits/sec   20    246 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec   460 MBytes  96.5 Mbits/sec  267             sender
[  4]   0.00-40.00  sec   458 MBytes  96.1 Mbits/sec                  receiver

iperf Done.
</pre>
</ul>
<p>Скорость в tun оказалась чуть больше, чем в tap. Но тем не менее они отличаются.<p>
<p><b>TAP.</b> эмулирует Etehrnet утсройство и ведет себя аналогично сетевому адаптеру. Може транспортировать любой сетевой трафик, работает на 2 уровну OSI, используя для общения IP пакеты. Позволяет использовать мосты. Но при этом в сеть попадает broadcast-трафик, который не всегда нужен. Добавляет свои заголовки на все пакеты, которые следуют через туннель.</p>
<p><b>TUN.</b> Передает только пакеты протокола IP, 3-й уровень OSI. Отсюда меньшие расходы. По факту, ходит только тот трафик, который предназначен только конкретному клиенту. Но вот broadcast трафик не передается, иногда это требуется. Нельзя использовать мосты</p>

<h2>RAS на базе OpenVPN</h2>

<p>Для настройки RAS будем использовать server из VagrantFile.</p>
<p>Вся настройка происходит в плэе <a src='playbooks/ConfigRASServer.yml'>ConfigRASServer.yml</a></p>

<p>Для этого:</p>

<ul>
    <li>Установим репозиторий EPEL</li>
    <li>Установим необходимые пакеты openvpn и easy-rsa</li>
    <li>Инициализируем pki</li>
    <pre># /usr/share/easy-rsa/3.0.8/easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/pki
</pre>
    <li>Сгенерируем необходимые сертификаты и ключи для сервера</li>
    <ul>
    <li>echo 'rasvpn' | /usr/share/easy-rsa/3.0.8/easyrsa build-ca nopass</li>
    <li>echo 'rasvpn' | /usr/share/easy-rsa/3.0.8/easyrsa gen-req server nopass</li>
    <li>echo 'yes' | /usr/share/easy-rsa/3.0.8/easyrsa sign-req server server</li>
    <li>/usr/share/easy-rsa/3.0.8/easyrsa gen-dh</li>
    <li>openvpn --genkey --secret ca.key</li>
    </ul>
    <li>Генерируем сертификаты для клиента</p>
    <ul>
        <li>echo 'client' | /usr/share/easy-rsa/3/easyrsa gen-req client nopass</li>
        <li>echo 'yes' | /usr/share/easy-rsa/3/easyrsa sign-req client client</li>
    </ul>
    <li>Конфигурационный файл для сервера используем следующий(<a src='playbooks/openvpn/server.conf'>tun.server.conf</a>)</li>
    <li>Зададим параметр iroute для клиента</li>
    <pre># echo &apos;iroute 10.10.10.0 255.255.255.0&apos; &gt; /etc/openvpn/client/client
</pre>
    <li>Используем Unit из предыдущего пункта (<a src='playbooks/templates/openvpn@.service'>openvpn@.service</a>). Запустим сервер и добавим его в автозагрузку.</li>
    <li> на хост машину копируем следующие сертификаты:</li>
    <ul>
        <li>/etc/openvpn/pki/ca.crt</li>
        <li>/etc/openvpn/pki/issued/client.crt</li>
        <li>/etc/openvpn/pki/private/client.key</li>
    </ul>
    <li>Создаем конфиг(<a src='playbooks/openvpn/client.conf'>client.conf</a>) для клинета и кладем его вместе с сертификатами в один каталог</li>
</ul>
<p>После порделанных всех манипуляций, подключаемся к openvpn серверу с хост машины</p>
<pre># openvpn --config client.conf
2023-09-26 07:25:38 WARNING: Compression for receiving enabled. Compression has been used in the past to break encryption. Sent packets are not compressed unless &quot;allow-compression yes&quot; is also set.
2023-09-26 07:25:38 Note: --cipher is not set. OpenVPN versions before 2.5 defaulted to BF-CBC as fallback when cipher negotiation failed in this case. If you need this fallback please add &apos;--data-ciphers-fallback BF-CBC&apos; to your configuration and/or add BF-CBC to --data-ciphers.
2023-09-26 07:25:38 Note: &apos;--allow-compression&apos; is not set to &apos;no&apos;, disabling data channel offload.
2023-09-26 07:25:38 WARNING: file &apos;./client.key&apos; is group or others accessible
2023-09-26 07:25:38 OpenVPN 2.6.6 x86_64-redhat-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] [DCO]
2023-09-26 07:25:38 library versions: OpenSSL 3.0.9 30 May 2023, LZO 2.10
2023-09-26 07:25:38 DCO version: N/A
2023-09-26 07:25:38 TCP/UDP: Preserving recently used remote address: [AF_INET]192.168.56.10:1207
2023-09-26 07:25:38 Socket Buffers: R=[212992-&gt;212992] S=[212992-&gt;212992]
2023-09-26 07:25:38 UDPv4 link local: (not bound)
2023-09-26 07:25:38 UDPv4 link remote: [AF_INET]192.168.56.10:1207
2023-09-26 07:25:38 TLS: Initial packet from [AF_INET]192.168.56.10:1207, sid=6c750529 07bd95c2
2023-09-26 07:25:38 VERIFY OK: depth=1, CN=rasvpn
2023-09-26 07:25:38 VERIFY KU OK
2023-09-26 07:25:38 Validating certificate extended key usage
2023-09-26 07:25:38 ++ Certificate has EKU (str) TLS Web Server Authentication, expects TLS Web Server Authentication
2023-09-26 07:25:38 VERIFY EKU OK
2023-09-26 07:25:38 VERIFY OK: depth=0, CN=rasvpn
2023-09-26 07:25:38 Control Channel: TLSv1.2, cipher TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384, peer certificate: 2048 bit RSA, signature: RSA-SHA256
2023-09-26 07:25:38 [rasvpn] Peer Connection Initiated with [AF_INET]192.168.56.10:1207
2023-09-26 07:25:38 TLS: move_session: dest=TM_ACTIVE src=TM_INITIAL reinit_src=1
2023-09-26 07:25:38 TLS: tls_multi_process: initial untrusted session promoted to trusted
2023-09-26 07:25:40 SENT CONTROL [rasvpn]: &apos;PUSH_REQUEST&apos; (status=1)
2023-09-26 07:25:40 PUSH: Received control message: &apos;PUSH_REPLY,route 192.168.10.0 255.255.255.0,route-gateway 10.10.10.1,ping 10,ping-restart 120,ifconfig 10.10.10.2 255.255.255.0,peer-id 1,cipher AES-256-GCM&apos;
2023-09-26 07:25:40 OPTIONS IMPORT: --ifconfig/up options modified
2023-09-26 07:25:40 OPTIONS IMPORT: route options modified
...
</pre>
<p>Проверяем ping, по внутреннему адрессу в туннеле</p>
<pre>$ ping -c 4 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=1.32 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.973 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.910 ms
64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.964 ms

--- 10.10.10.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 0.910/1.042/1.323/0.163 ms
</pre>

<p>Так же проверяем, что сеть туннеля импортирована в таблицу маршрутизации</p>
<pre>$ ip r
...
10.10.10.0/24 dev tap0 proto kernel scope link src 10.10.10.2 
...
</pre>
