<h1>Инициализация системы.Systemd.</h1>

<h2>Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова <i>(файл лога и ключевое слово должны задаваться в /etc/sysconfig)</i></h2>

<ul>
<li>В каталог <b><i>/etc/sysconfig</b></i> размещаем файл <a href="logview"><i>logview</i></a>. Либо создаем файл вручную и переносим туда содержимое.
<pre>vi /etc/sysconfig/logview</pre>
<br>
<pre># Файл конфигурации для сервиса logview
# Расположить в /etc/sysconfig

WORD="ALERT"
LOG=/var/log/viewlog.log</pre>
</li>
<li>Создаем файл лога и добавляем туда наше ключевое слово 
<pre>
echo "ALERT" > /var/log/logview.log 
</pre>
</li>
<li>
Создаем скрипт, который будет отправлять информацию из нашего лога в /var/log/messages. (см. <a href="logview.sh"><i>logview.sh</a></i> ) И даем разрешение на запуск. 
<pre>
vi /opt/logview.sh
chmod +x /opt/logview.sh
</pre>
</li>
<li>
Создаем сервис (или юнит). Файл <a href="logview.service"><i>logview.service</a></i>
<pre>
vi /etc/systemd/system/logview.service
</pre>
</li>
<li>
Создаем таймер (см.<a href="logview.timer"><i>logview.timer</a></i>)
<pre>
vi /etc/systemd/system/logview.time
</pre>
</li>
<li>
Запустим и добавим в автозагрузку наш сервис
<pre>
systemctl enable logview.timer
systemctl start logview.timer
</pre>
</li>
<li>
Поверяем работу 
<pre>
tail -f /var/log/messages 
Jul 15 18:04:25 localhost root: Sat Jul 15 18:04:25 UTC 2023: I found word, Master!
Jul 15 18:04:25 localhost systemd: Started LogView service.
Jul 15 18:05:25 localhost systemd: Starting LogView service...
Jul 15 18:05:25 localhost systemd: Starting Cleanup of Temporary Directories...
Jul 15 18:05:26 localhost root: Sat Jul 15 18:05:25 UTC 2023: I found word, Master!
Jul 15 18:05:26 localhost systemd: Started LogView service.
Jul 15 18:05:26 localhost systemd: Started Cleanup of Temporary Directories.
Jul 15 18:06:05 localhost systemd: Starting LogView service...
Jul 15 18:06:05 localhost root: Sat Jul 15 18:06:05 UTC 2023: I found word, Master!
Jul 15 18:06:05 localhost systemd: Started LogView service.
</pre>
</li>
<h3>Работает!!!</h3>

<h2>Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл.</h2>


<ul>
<li>Устанавливаем репозиторий epel
<pre>yum install epel-release -y
</pre>
</li>
<li>Устанавливаем spawn-cfg и все необходимые пакеты
<pre>yum install spawn-fcgi php php-cli mod_fcgid httpd -y</pre>
</li>
<li>Переписываем /etc/sysconfig/spawn-fcgi (Должно получится так: <a href="spawn-fcgi"><i>spawn-fcgi</a></i>)</li>
<li>Создаем unit файл nano /etc/systemd/system/spawn-fcgi.service (<a href="spawn-fcgi.service"><i>spawn-fcgi.service</a></i>)</li>
<li>Запускааем сервис и убеждаемся, что все работает хорошо</li>
<pre>
systemctl start spawn-fcgi
systemctl status spawn-fcgi
<span style="color:#26A269"><b>●</b></span> spawn-fcgi.service - Spawn-fcgi startup
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: <span style="color:#26A269"><b>active (running)</b></span> since Sat 2023-07-15 19:03:31 UTC; 5s ago
 Main PID: 3323 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─3323 /usr/bin/php-cgi
           ├─3324 /usr/bin/php-cgi
           ├─3325 /usr/bin/php-cgi
           ├─3326 /usr/bin/php-cgi
           ├─3327 /usr/bin/php-cgi
           ├─3328 /usr/bin/php-cgi
           ├─3329 /usr/bin/php-cgi
           ├─3330 /usr/bin/php-cgi
           ├─3331 /usr/bin/php-cgi
           ├─3332 /usr/bin/php-cgi
           ├─3333 /usr/bin/php-cgi
           ├─3334 /usr/bin/php-cgi
           ├─3335 /usr/bin/php-cgi
           ├─3336 /usr/bin/php-cgi
           ├─3337 /usr/bin/php-cgi
           ├─3338 /usr/bin/php-cgi
           ├─3339 /usr/bin/php-cgi
           ├─3340 /usr/bin/php-cgi
           ├─3341 /usr/bin/php-cgi
           ├─3342 /usr/bin/php-cgi
           ├─3343 /usr/bin/php-cgi
           ├─3344 /usr/bin/php-cgi
           ├─3345 /usr/bin/php-cgi
           ├─3346 /usr/bin/php-cgi
           ├─3347 /usr/bin/php-cgi
           ├─3348 /usr/bin/php-cgi
           ├─3349 /usr/bin/php-cgi
           ├─3350 /usr/bin/php-cgi
           ├─3351 /usr/bin/php-cgi
           ├─3352 /usr/bin/php-cgi
           ├─3353 /usr/bin/php-cgi
           ├─3354 /usr/bin/php-cgi
           └─3355 /usr/bin/php-cgi

Jul 15 19:03:31 localhost.localdomain systemd[1]: Started Spawn-fcgi sta...
Jul 15 19:03:31 localhost.localdomain systemd[1]: Starting Spawn-fcgi st...
Hint: Some lines were ellipsized, use -l to show in full.
</pre>
</ul>