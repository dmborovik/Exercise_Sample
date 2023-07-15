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

<h2>Дополнить unit-файл httpd возможностью запустить несколько инстансов сервера с разными конфиурационными файлами.</h2>

<p>Для запуска нескольких экземпляров сервиса будем использовать шаблонизацию. Шаблон возьмем из /usr/lib/systemd/system/
<pre>cp /usr/lib/systemd/system/httpd.service /etc/systemd/system
mv /etc/systemd/system/httpd.service /etc/systemd/system/httpd@.service
</pre> 
<p>Добавляем шаблон подстановки в строку EnvironmentFile. (см. <a href="httpd@.service"><i>httpd@.service</i></a>)

<p>В самом файле окружения (которых будет два) задается опция для запуска веб-сервера с необходимым конфигурационным файлом
<pre>
echo "OPTIONS=-f conf/first.conf" >> /etc/sysconfig/httpd-first
echo "OPTIONS=-f conf/second.conf" >> /etc/sysconfig/httpd-second
</pre>
</p>
<p>
В директории с конфигами httpd должны лежать два конфига, в нашем случае это будут <a href="first.conf"><i>first.conf</a></i> и <a href="second.conf"><i>second.conf</a></i>.
</p>
<p>Для удачного запуска, в конфигурационных файлах должны бытя указаны уникальные для каждого экземпляра опции Listen и PidFile. Конфиги можно скопировать и поправить только второй, в нем должны быть след опции: PidFile /var/run/httpd-second.pid - т.е. должен быть указан файл пида Listen 8080 - указан порт, который будет отличаться от другого инстанса</p>

<pre>systemctl status httpd@first
<span style="color:#26A269"><b>●</b></span> httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: <span style="color:#26A269"><b>active (running)</b></span> since Sat 2023-07-15 20:57:45 UTC; 15s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 4038 (httpd)
   Status: &quot;Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec&quot;
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─4038 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4039 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4040 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4041 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4042 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4043 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─4044 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Jul 15 20:57:45 localhost.localdomain systemd[1]: Starting The Apache HT...
Jul 15 20:57:45 localhost.localdomain httpd[4038]: AH00558: httpd: Could...
Jul 15 20:57:45 localhost.localdomain systemd[1]: Started The Apache HTT...
Hint: Some lines were ellipsized, use -l to show in full.
</pre>

<pre>ystemctl status httpd@second.service 
<span style="color:#26A269"><b>●</b></span> httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: <span style="color:#26A269"><b>active (running)</b></span> since Sat 2023-07-15 20:57:49 UTC; 35s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 4051 (httpd)
   Status: &quot;Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec&quot;
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─4051 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─4052 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─4053 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─4054 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─4055 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─4056 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─4057 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Jul 15 20:57:49 localhost.localdomain systemd[1]: Starting The Apache HT...
Jul 15 20:57:49 localhost.localdomain httpd[4051]: AH00558: httpd: Could...
Jul 15 20:57:49 localhost.localdomain systemd[1]: Started The Apache HTT...
Hint: Some lines were ellipsized, use -l to show in full.
</pre>
<p>
