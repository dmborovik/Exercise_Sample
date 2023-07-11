<h1>Загрузка системы</h1>

<h2>1.Попасть в систему без пароля несколькими способами</h2>

<h3>Способ 1</h3>

<p>При загрузке системы, во время выбора ядра нажать <b>е</b>.Для загрузки в графическом режиме в Vagrantfile, можно включить следующюю опцию:</p>
<pre>
config.vm.provider "virtualbox" do |vb|
    vb.gui = true
end
</pre>
<p>Найти строку:</p>
<pre>
linux16 /boot/vmlinuz... 
</pre>
<p>Добавляем в конец строки <b>init=/bin/sh</b> или виесто sh можно использовать bash. Сработает не на всех дистрибутивах.</p>
<p>Во многих дистрибутивах корневая система монтируется в режиме только для чтения. Для перемонтирования системы в режим чтения-записи, используется следующая команда</p>
<pre>
mount -o remount,rw /
</pre>
<p> Теперь можем работать с системой, хоть и действия немного ограничены</p>

<h3>Способ 2</h3>

<p>Все то же самое, что и в предыдущем способе, кроме того, что в конце стороки надо добавть не init=/bin/sh, а rd.break. И так же необходимо будет перемонтировать файловую систему в режим, позваляющий производить запись </p>

<h3>Способ 3</h3>
<b>В строке, начинающийся на linux16, ro меняем на rw, добавляем init=/sysroot/bin/sh, также удалить все связанное с console. В этом случае система загрузится в режиме, разрешающим запись</p>

<h2>Установить систему с LVM, после чего переименовать VG</h2>

<p>Vagrantfile - разворачивается ОС с LVM.</p>
<p>rename_vg.sh - скрипт, который переименовывает VG и вносит необходимые изменения</p>

<h2>Добавить модуль initrd</h2>

<p> Добавление модуля, происходит во второй части приложенного скрипта. Каталог scripts, должен лежать рядом с Vagrsntfile</p>