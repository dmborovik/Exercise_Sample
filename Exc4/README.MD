<h1>ZFS</h1>

<h2>1.Определить алгоритм с наилучшим сжатием</h2>

<p> Использовать в примере будем ВМ из Vagrantfile. В нес разворачивается машина с 8 дисками, ОС CentOS 7 и с установленными пакетами для работы с zfs </p>

<p> - Создадим 4 пула по два диска в каждом </p>

<pre>
[vagrant@exc4vm ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
└─sda1   8:1    0   40G  0 part /
sdb      8:16   0  512M  0 disk 
sdc      8:32   0  512M  0 disk 
sdd      8:48   0  512M  0 disk 
sde      8:64   0  512M  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0  512M  0 disk 
</pre>

<pre>
[root@exc4vm vagrant]# zpool create part1 mirror /dev/sdb /dev/sdc
[root@exc4vm vagrant]# zpool create part2 mirror /dev/sdd /dev/sde
[root@exc4vm vagrant]# zpool create part3 mirror /dev/sdf /dev/sdg
[root@exc4vm vagrant]# zpool create part4 mirror /dev/sdh /dev/sdi
</pre>

<p>Проверяем то, что создали<p>
<pre>
[root@exc4vm vagrant]# zpool status
  pool: part1
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	part1       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0

errors: No known data errors

  pool: part2
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	part2       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdd     ONLINE       0     0     0
	    sde     ONLINE       0     0     0

errors: No known data errors

  pool: part3
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	part3       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdf     ONLINE       0     0     0
	    sdg     ONLINE       0     0     0

errors: No known data errors

  pool: part4
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	part4       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdh     ONLINE       0     0     0
	    sdi     ONLINE       0     0     0

errors: No known data errors
</pre>

<p>Весь пул создался и работает без ошибок</p>
<p>Теперь добавим на каждый пул разные алгоритмы сжатия для определения наиболее оптимального</p>

<pre>
[root@exc4vm vagrant]# zfs set compression=lzjb part1
[root@exc4vm vagrant]# zfs set compression=lz4 part2
[root@exc4vm vagrant]# zfs set compression=gzip-9 part3
[root@exc4vm vagrant]# zfs set compression=zle part4
</pre>

<p>Скачаем на все имеющиеся пулы один и тот же файл.</b>

<pre>
[root@exc4vm vagrant]# for i in {1..4}; do wget -P /part$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
--2023-06-18 03:40:44--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part1/pg2600.converter.log’

100%[======================================>] 40,941,287  4.55MB/s   in 8.3s   

2023-06-18 03:40:53 (4.71 MB/s) - ‘/part1/pg2600.converter.log’ saved [40941287/40941287]

--2023-06-18 03:40:53--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part2/pg2600.converter.log’

100%[======================================>] 40,941,287  1.77MB/s   in 19s    

2023-06-18 03:41:13 (2.07 MB/s) - ‘/part2/pg2600.converter.log’ saved [40941287/40941287]

--2023-06-18 03:41:13--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part3/pg2600.converter.log’

100%[======================================>] 40,941,287  2.51MB/s   in 17s    

2023-06-18 03:41:30 (2.34 MB/s) - ‘/part3/pg2600.converter.log’ saved [40941287/40941287]

--2023-06-18 03:41:30--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40941287 (39M) [text/plain]
Saving to: ‘/part4/pg2600.converter.log’

100%[======================================>] 40,941,287  1.72MB/s   in 19s    

2023-06-18 03:41:51 (2.00 MB/s) - ‘/part4/pg2600.converter.log’ saved [40941287/40941287]
</pre>

<p>Сравним какое количество места занял на разных пулах, скаченный файл.</p>

<pre>
[root@exc4vm vagrant]# zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
part1  21.6M   330M     21.6M  /part1
part2  17.7M   334M     17.6M  /part2
<b>part3  10.8M   341M     10.7M  /part3</b>
part4  39.2M   313M     39.1M  /part4
</pre>

<p>Как можно увидеть, меньше всего места файл занял на 3-м пуле, для которого установили алгоритм сжатия gzip-9.</p>
<p>Следующая команда покажет коэффициент сжатия</p>

<pre>
[root@exc4vm vagrant]# zfs get all | grep compressratio | grep -v ref
part1  compressratio         1.81x                  -
part2  compressratio         2.22x                  -
<b>part3  compressratio         3.65x                  -</b>
part4  compressratio         1.00x                  -
</pre>

<p>В этом выводе, также можем убедиться, что gzip-9 эффективнее остальных.</p>

<h2>2. Определить настроки pool'а</h2>

<p>Скачаем и распакуем архив</p> 

<pre>
[root@exc4vm vagrant]# wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
...
[root@exc4vm vagrant]# tar -xzvf archive.tar.gz 
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
</pre>

<p>Проверим возможность импорта пула</p>

<pre>
[root@exc4vm vagrant]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                                 ONLINE
	  mirror-0                           ONLINE
	    /home/vagrant/zpoolexport/filea  ONLINE
	    /home/vagrant/zpoolexport/fileb  ONLINE
</pre>

<p>Данный вывод говорит нам о том, что имя пула otus, тип mirror-0 и его состав</p>
<p>Импортируем этот пул с новым именем</p>
<pre>
[root@exc4vm vagrant]# zpool import -d zpoolexport/ otus newpart
</pre>

<p>Определить размер хранилища</p>
<pre>
[root@exc4vm ~]# zfs get available newpart
NAME     PROPERTY   VALUE  SOURCE
newpart  available  350M   -
</pre>

<p>Определить тип пула</p>
<pre>
[root@exc4vm ~]# zfs get readonly newpart
NAME     PROPERTY  VALUE   SOURCE
newpart  readonly  off     default
</pre>

<p>Определить значени recordsize</p>
<pre>
[root@exc4vm ~]# zfs get recordsize newpart
NAME     PROPERTY    VALUE    SOURCE
newpart  recordsize  128K     local
</pre>

<p>Определить тип сжатия</p>
<pre>
[vagrant@exc4vm ~]$ zfs get compression newpart
NAME     PROPERTY     VALUE     SOURCE
newpart  compression  zle       local
</pre>

<p>Определить контрольную сумму</p>
<pre>
[vagrant@exc4vm ~]$ zfs get checksum newpart
NAME     PROPERTY  VALUE      SOURCE
newpart  checksum  sha256     local
</pre>

<h2>3. Найти сообщение</h2>

<p>Копируем необходимы файл с именем test.file</p>
<p>Восстанавливаем скачаный снап</p>
<pre>
sudo zfs receive newpart/test@today < test.file 
</pre>

<p>Ищем секретное сообщение</p>

<pre>
[vagrant@exc4vm ~]$ find /newpart/test -name "secret_message"
/newpart/test/task1/file_mess/secret_message
</pre>

<p>Нашли расположение файла, смотрим содержимое. В этом файле лежит ссылка на гитхаб с очень интересным содержимым</p>
<pre>
[vagrant@exc4vm ~]$ cat /newpart/test/task1/file_mess/secret_message 
https://github.com/sindresorhus/awesome
</pre>
