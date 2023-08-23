<h1>Docker</h1>

<p>
<ul>
 <li>Создать свой кастомный образ nginx на базе alpine. </li>
 <li>После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx).</li>
 <li>Определите разницу между контейнером и образом. Вывод опишите в домашнем задании.</li>
 <li>Ответьте на вопрос: Можно ли в контейнере собрать ядро?</li>
 <li>Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.</li>
 </ul>
</p>

<h2>Создание образа nginx на базе alpine</h2>

<p>Создавать образ будем в ВМ, созданной в vagrant. В приложении готовый Vagrantfile, на котором разворачивается стенд, содержащий все необхоимые утилиты.</p>
<p>Закидываем в рабочюю папку, где будем создавать наш контейнер файлы Dockerfile и Index.html (во вложении)</p>

<p>Собираем наш образ</p>

<pre>[root@docker vagrant]# docker build -t temp-nginx:1.0 .
[+] Building 875.5s (10/10) FINISHED                                                                                                                                                                                           docker:default
<span style="color:#0000AA"> =&gt; [internal] load .dockerignore                                                                                                                                                                                                        9.4s</span>
<span style="color:#0000AA"> =&gt; =&gt; transferring context: 2B                                                                                                                                                                                                          4.8s</span>
<span style="color:#0000AA"> =&gt; [internal] load build definition from Dockerfile                                                                                                                                                                                    10.3s</span>
<span style="color:#0000AA"> =&gt; =&gt; transferring dockerfile: 1.01kB                                                                                                                                                                                                   8.0s</span>
<span style="color:#0000AA"> =&gt; [internal] load metadata for docker.io/library/alpine:latest                                                                                                                                                                        12.7s</span>
<span style="color:#0000AA"> =&gt; [internal] load build context                                                                                                                                                                                                       19.0s</span>
<span style="color:#0000AA"> =&gt; =&gt; transferring context: 140B                                                                                                                                                                                                        2.5s</span>
<span style="color:#0000AA"> =&gt; [1/5] FROM docker.io/library/alpine:latest@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a                                                                                                                  25.0s</span>
<span style="color:#0000AA"> =&gt; =&gt; resolve docker.io/library/alpine:latest@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a                                                                                                                   2.4s</span>
<span style="color:#0000AA"> =&gt; =&gt; sha256:c5c5fda71656f28e49ac9c5416b3643eaa6a108a8093151d6d1afc9463be8e33 528B / 528B                                                                                                                                               0.0s</span>
<span style="color:#0000AA"> =&gt; =&gt; sha256:7e01a0d0a1dcd9e539f8e9bbd80106d59efbdf97293b3d38f5d7a34501526cdb 1.47kB / 1.47kB                                                                                                                                           0.0s</span>
<span style="color:#0000AA"> =&gt; =&gt; sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a 1.64kB / 1.64kB                                                                                                                                           0.0s</span>
<span style="color:#0000AA"> =&gt; =&gt; sha256:7264a8db6415046d36d16ba98b79778e18accee6ffa71850405994cffa9be7de 3.40MB / 3.40MB                                                                                                                                           2.9s</span>
<span style="color:#0000AA"> =&gt; =&gt; extracting sha256:7264a8db6415046d36d16ba98b79778e18accee6ffa71850405994cffa9be7de                                                                                                                                                0.7s</span>
<span style="color:#0000AA"> =&gt; [2/5] RUN apk --update --no-cache add build-base         openssl-dev         pcre-dev         zlib-dev         wget                                                                                                                 94.2s</span>
<span style="color:#0000AA"> =&gt; [3/5] RUN mkdir -p /tmp/src &amp;&amp;     cd /tmp/src &amp;&amp;     wget http://nginx.org/download/nginx-1.24.0.tar.gz &amp;&amp;     tar zxf nginx-1.24.0.tar.gz &amp;&amp;     cd nginx-1.24.0 &amp;&amp;     ./configure --sbin-path=/usr/bin/nginx         --conf-p  717.2s</span> 
<span style="color:#0000AA"> =&gt; [4/5] RUN ln -sf /dev/stdout /var/log/nginx/access.log &amp;&amp;     ln -sf /dev/stderr /var/log/nginx/error.log                                                                                                                            3.4s</span> 
<span style="color:#0000AA"> =&gt; [5/5] COPY index.html /usr/local/nginx/html/index.html                                                                                                                                                                               0.2s</span> 
<span style="color:#0000AA"> =&gt; exporting to image                                                                                                                                                                                                                   3.9s</span> 
<span style="color:#0000AA"> =&gt; =&gt; exporting layers                                                                                                                                                                                                                  3.8s</span> 
<span style="color:#0000AA"> =&gt; =&gt; writing image sha256:cfd76576e8012a47c5239cae5b4c9cd48024d91f8987ca671f8dbe5c910053fe                                                                                                                                             0.0s</span> 
<span style="color:#0000AA"> =&gt; =&gt; naming to docker.io/library/temp-nginx:1.0                                                                                                 </span></pre>

<p>Далее запускаем наш контейнер</p>

<pre># docker run -d -p 1234:80 temp-nginx:1.0
868b1f68e5a3e3fbb7ac49c4c6f3cad02a4806b2fc59062820f8110d8f694b27
</pre>

<p>Посмотрим на наши образы </p>

<pre>[root@docker vagrant]# docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
temp-nginx   1.0       cfd76576e801   2 minutes ago   262MB
[root@docker vagrant]# docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                            NAMES
868b1f68e5a3   temp-nginx:1.0   &quot;nginx -g &apos;daemon of…&quot;   48 seconds ago   Up 44 seconds   443/tcp, 0.0.0.0:1234-&gt;80/tcp, :::1234-&gt;80/tcp   heuristic_matsumoto
</pre>

<h2>После запуска nginx отдает кастомную страницу</h2>

<pre>[root@docker vagrant]# ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.2.15/24 fe80::5054:ff:fe4d:77d3/64 
eth1             UP             192.168.56.150/24 fe80::a00:27ff:fe8f:6d2b/64 
docker0          UP             172.17.0.1/16 fe80::42:efff:fe8e:8db2/64 
veth7c5b619@if11 UP             fe80::98a4:e8ff:fe2c:3e55/64 
[root@docker vagrant]# curl 172.17.0.1:1234
&lt;h1&gt;Hello&lt;/h1&gt;
&lt;p&gt;It&apos;s message from docker&lt;/p&gt;</pre>

<h2>Определить разницу между контейнером и образом.</h2>

<dl>
<dt>Образ</dt>
<dd>Шаблонный элемент, который используют для создания контейнеров. Образ ничего не делает, кроме того, что он существует</dd>
<dt>Контейнер</dt>
<dd>Виртуальные среды, которые включают в себя совокупность процессов и образа. В контейнере уже непосредственно происходит полезная работа, ради которой и создавался образ</dd>
</dl>

<h2>Можно ли в контейнере собрать ядро</h2>

<p>В контейнере собрать можно, практически, все что угодно. В том числе и ядро. Например, вот ссылка, где это сделали: <a href="https://github.com/moul/docker-kernel-builder">Пример сборки ядра</a>. Но вот загрузиться с него не получится.</p>

<h2>Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.</h2>

<a>https://hub.docker.com/repository/docker/prapor1985/temp-nginx/general</a>