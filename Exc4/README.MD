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