<h1>Пишем скрипт</h1>
<h2>написать скрипт на языке Bash</h2>

<h3>Как запускать (предусмотрена защита от мультизапуска)</h3>

<p>В качестве защиты от мультизапуска используется программа flock

    Добавить в cron скрипт (crontab -e), в виде /usr/bin/flock /var/tmp/myscript.lock /root/myscript.sh с указанием расписания
  
    /var/tmp/myscript.lock это лок файл, который создается если его нет, и программа flock "держит" его во время выполнения скрипта и отпускает только после того как скрипт завершится.
</p>
Файлы

    check_log.sh - скрипт, который читает файл логов, для отправки отчета по почте, раскомментировать команду mail и указать актуальный адрес. 
    access.log.txt - сам файл логов
    lines - файл куда записывается последняя доступная строка (при следующем запуске, лог будет читаться со следующей строки, указанной в файле, т.е. 670+1). Если ничего в этом файле не будет то лог будет читаться сначала и до конца.