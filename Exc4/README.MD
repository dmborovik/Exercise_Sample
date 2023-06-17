<h1>ZFS</h1>

<h2>1.Определить алгоритм с наилучшим сжатием</h2>

<p> Использовать в примере будем ВМ из Vagrantfile. В нес разворачивается машина с 8 дисками, ОС CentOS 7 и с установленными пакетами для работы с zfs </p>

<p> - Создадим 4 пула по два диска в каждом </p>

<pre style="background-color:black; color:green">
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