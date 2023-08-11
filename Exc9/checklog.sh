#!/bin/bash

# Считывание значения из файла
lastReport=$(awk 'END{print}'./lines)
number=$(cat ./lines 2>/dev/null)

# Сколько строк в файле
checkLines=$(wc ./access.log.txt | awk '{print $1}')

# Если возвращается пустое значение, т.е. его нет, тогда считаем количество строк и записываем значение в файл
if ! [ -n "$number" ]
then
    # Дата начала и конца
    timeHead=$(awk '{print $4 $5}' access.log.txt | sed 's/\[//' | sed -n 1p)
    timeLast=$(awk '{print $4 $5}' access.log.txt | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
    # Запись количества строк в файле
    echo $timeHead >>./lines
    # Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
    IP=$(awk "NR>$checkLines"  access.log.txt | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    # Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
    addresses=$(awk '($9 ~ /200/)' access.log.txt|awk '{print $7}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Ошибки веб-сервера/приложения c момента последнего запуска;
    errors=$(cat access.log.txt | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    # Отправка почты
    echo -e "Данные за период:$timeHead-$timeLast\n$IP\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" | mail -s "NGINX Log Info" root@localhost
else
    # Дата начала и конца
    timeHead=$(awk '{print $4 $5}' access.log.txt | sed 's/\[//; s/\]//' | sed -n "$(($number+1))"p)
    timeLast=$(awk '{print $4 $5}' access.log.txt | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
    # Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
    IP=$(awk "NR>$(($number+1))"  access.log.txt | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    # Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
    addresses=$(awk '($9 ~ /200/)' access.log.txt|awk '{print $7}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Ошибки веб-сервера/приложения c момента последнего запуска;
    errors=$(cat access.log.txt | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    # Запись количества строк в файле
    echo $checkLines > ./lines
    # Отправка почты
    echo -e "Данные за период:$timeHead-$timeLast\n$IP\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" | mail -s "NGINX Log Info" root@localhost
fi