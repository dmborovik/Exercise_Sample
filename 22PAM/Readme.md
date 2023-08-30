<h1>Пользователи и группы. Авторизация и аутентификация</h1>

<ul>
<li>Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников </li>
<li>Дать конкретному пользователю права работать с докером и возможность рестартить докер сервис</li>
</ul>

<h2>Подготовка стенда</h2>

<p>Все действия будут проводиться на ВМ. Описание ВМ в Vagrantfile.</p>

<h2>Настройка запрета для всех пользователей (кроме группы Admin) логина в выходные дни</h2>

<p>Зайдем на нашу ВМ и создадим двух пользователей admin и user и назначим им пароли</p>

<pre>[root@pam vagrant]# useradd admin 
[root@pam vagrant]# useradd user
</pre>

<pre>[root@pam vagrant]# passwd admin
Changing password for user admin.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.
[root@pam vagrant]# passwd user
Changing password for user user.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.
</pre>

<p>Создадим группу admin и добавим в нее пользователей admin, root и vgrant</p>

<pre>[root@pam vagrant]# groupadd -f admin
[root@pam vagrant]# usermod admin -a -G admin
[root@pam vagrant]# usermod root -a -G admin
[root@pam vagrant]# usermod vagrant -a -G admin
</pre>

<p>Проверяем возможность пожключения по ssh на нашу ВМ для созданных пользователей</p>

<pre>[user@fedora 22PAM]$ ssh user@192.168.56.10
The authenticity of host &apos;192.168.56.10 (192.168.56.10)&apos; can&apos;t be established.
ED25519 key fingerprint is SHA256:u1PhEND7hZluSQ8ztRyIhgOO4GkUI6Bsd3OxdzHeQ3Q.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added &apos;192.168.56.10&apos; (ED25519) to the list of known hosts.
user@192.168.56.10&apos;s password: 
[user@pam ~]$ 
</pre>
<p>Теперь настроем правило, по которому все пользователи, кроме тех, что указаны в группе admin не смогут подключаться в выходные дни</p>

<p>Будем использовать метод PAM-аутентификации, так как нам необходимо ограничение по времени pam_time. Такой метод не работает с группами и для каждого пользователя необходимо создавать отдельные строки в конфиг. Чтобы упростить задачу будем использовать в этом случае небольшой скрипт (см. login.sh). Создадим файл-скрипт /usr/local/bin/login.sh </p>

<pre>#!/bin/bash

if [ $(date +%a) = &quot;Sat&quot; ] || [ $(date +%a) = &quot;Sun&quot; ] ; then
  if getent group admin | grep -qw &quot;$PAM_USER&quot;; then
      exit 0
    else
      exit 1
  else
    exit 0
fi
</pre>

<p>От скрипта толку мало, если он не может выполниться, поэтому назначим ему права исполнение</p>
<pre>[root@pam vagrant]# chmod +x /usr/local/bin/login.sh 
</pre>

<p>Теперь правим модуль pam_exec в файле /etc/pam.d/sshd</p>
<pre>[root@pam vagrant]# vi /etc/pam.d/sshd 
</pre>

<pre>#%PAM-1.0
auth       required     pam_exec.so /usr/local/bin/login.sh #Добавляем эту строку
auth       required     pam_sepermit.so
auth       substack     password-auth
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
</pre>

<p> На этом все, если кто-то захочет попасть на машину в выходной день и он не входит в группу admin, то у него ничего не выйдет</p>