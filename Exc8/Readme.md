<h1>Инициализация системы.Systemd.</h1>

<h2>Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова <i>(файл лога и ключевое слово должны задаваться в /etc/sysconfig)</i></h2>

<ul>
<li>В каталог <b><i>/etc/sysconfig</b></i> размещаем файл <a href="https://github.com/dmborovik/Exercise_Sample/blob/3459356cc1e60b6276a047183f14c591717e5428/Exc8/logview"><i>logview</i></a>. Либо создаем файл вручную и переносим туда содержимое.
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
Создаем скрипт, который будет отправлять информацию из нашего лога в /var/log/messages. (см. logview.sh ) И даем разрешение на запуск. 
<pre>
vi /opt/logview.sh
chmod +x /opt/logview.sh
</pre>
</li>
<li>
Создаем сервис (или юнит). Файл logview.service
<pre>
vi /etc/systemd/system/logview.service
</pre>
</li>
<li>
Создаем таймер (см.logview.time)
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
</ul>
