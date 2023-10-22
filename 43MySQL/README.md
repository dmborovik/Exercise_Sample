<h1>MySQL: бэкап и репликация</h1>

<p><b>Цель:</b> развернуть базу на мастере и настроить так, чтобы реплецировались указанные таблицы. Настроить GTID репликацию </p>

<h2>Подготовка стенда</h2>

<p><b>Vagrantfile</b> - развачивается двк ВМ: master и slave.</p>
<p><b>prov.yml</b> - производится предварительная подготовка ВМ, установка Percona-server и настройка репликации</p>

<p><b>Проверка</b></p>

<p> После запуска ВМ и отработки плэя, проверяем работу. Посмотрим на slave наличие базы</p>
<pre>mysql&gt; SHOW TABLES;
+---------------+
| Tables_in_bet |
+---------------+
| bookmaker     |
| competition   |
| market        |
| odds          |
| outcome       |
+---------------+
5 rows in set (0.00 sec)
</pre>

<p>Внесем изменения на мастере</p>
<pre>mysql&gt; INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,&apos;1xbet&apos;);
Query OK, 1 row affected (0.00 sec)

mysql&gt; SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)

mysql&gt; 
</pre>
<p>Проверим на слэйве</p>
<pre>mysql&gt; SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)

mysql&gt; 
</pre>
<p>Все работает</p>