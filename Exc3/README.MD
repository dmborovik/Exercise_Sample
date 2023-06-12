1. Уменьшить том под / до 8 G 

a.) Первый скрипт _resizerootPart1.sh установит необходимы пакет, сдампит информацию с корня и сделает chroot в новый раздел. 
b.) Второй скрипт _resizerootPart2.sh запускается после chroot. Обновляет grub, initrd, устанавливает загрузку из нужного раздела после перезапуска. 
c.) Перезагружаем ВМ. 
d.) Проверяем, что root у нас находится на /dev/sdb и смонтирован в /dev/mapper/vg_root-lv_root

$ lsblk 
lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0 37.5G  0 lvm  
sdb                       8:16   0   10G  0 disk 
└─vg_root-lv_root       253:0    0   10G  0 lvm  /
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 

e.) После этого последовательно запускаем _resizerootPart3.sh (Удаляет старую lv, создает вместо нее уменьшенную до 8G) и _resizerootPart4.sh. Перезагружаемся. Проверяем, что корень там гже нужно 

$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
└─vg_root-lv_root       253:2    0   10G  0 lvm  
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 

2. Выделяем том под home. 

Описание процесса в _mkvolhome.sh. После отработки скрипта, проверяем создание нового раздела. 

$ lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
├─sda1                       8:1    0    1M  0 part 
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:3    0    2G  0 lvm  /home
sdb                          8:16   0   10G  0 disk 
└─vg_root-lv_root          253:2    0   10G  0 lvm  
sdc                          8:32   0    2G  0 disk 
sdd                          8:48   0    1G  0 disk 
sde                          8:64   0    1G  0 disk 


3. Выделить том под /var - сделать в mirror 

Описание процесса в скрипте _mkvolVarMirror.sh. 

$ lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
├─sda1                       8:1    0    1M  0 part 
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:3    0    2G  0 lvm  /home
sdb                          8:16   0   10G  0 disk 
└─vg_root-lv_root          253:2    0   10G  0 lvm  
sdc                          8:32   0    2G  0 disk 
├─vg_var-lv_var_rmeta_0    253:4    0    4M  0 lvm  
│ └─vg_var-lv_var          253:8    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0   253:5    0  952M  0 lvm  
  └─vg_var-lv_var          253:8    0  952M  0 lvm  /var
sdd                          8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1    253:6    0    4M  0 lvm  
│ └─vg_var-lv_var          253:8    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1   253:7    0  952M  0 lvm  
  └─vg_var-lv_var          253:8    0  952M  0 lvm  /var
sde                          8:64   0    1G  0 disk 

4. /home сделать том для снапшота. Работа со снапшотами. 

a.) Сгенерировать файлы в /home 
$ touch /home/file{1..20}
$ ls /home/
file1   file12  file15  file18  file20  file5  file8
file10  file13  file16  file19  file3   file6  file9
file11  file14  file17  file2   file4   file7  vagrant


b.) Снять снапшот
$ lvcreate -L100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
Rounding up size to full physical extent 128.00 MiB
Logical volume "home_snap" created.

c.) Удалить часть файлов 
$ rm -f /home/file{11..20}

$ ls /home/

file1  file10  file2  file3  file4  file5  file6  file7  file8  file9  vagrant



d.) Восстановиться из снапшота. 
$ umount /home

$ lvconvert --merge /dev/VolGroup00/home_snap 
  Merging of volume VolGroup00/home_snap started.
  VolGroup00/LogVol_Home: Merged: 100.00%

$ mount /home/

$ ls /home/ 

file1   file12  file15  file18  file20  file5  file8
file10  file13  file16  file19  file3   file6  file9
file11  file14  file17  file2   file4   file7  vagrant





