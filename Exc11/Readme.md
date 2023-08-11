
<h1>Автоматизация администрирования. Ansible-1</h1>

<p>Запуск производиться следующим образом ansible-playbook playbook/web.yml. После запуска этого файла, вызывается файл /roles/nginx/tasks/main.yml.</p>

<p>Файл ansible.cfg должен лежать с vagrantfile в одной директории.</p>

<p>Также можно удалять установленную программу nginx ansible -m yum -a "name=nginx state=absent" -b.</p>

<p>Для запуска выполнить vagrant up</p>

<p>После запуска nginx будет доступен на порту 8080</p>