# Install ddserver
#
ddserver:
  git.latest:
    - name: https://github.com/ddserver/ddserver.git
    - rev: {{ pillar.ddserver.branch }}
    - target: /usr/local/src/ddserver
    - require:
      - pkg: common.apps
      - git: mysql_connector

  cmd.run:
    - name: {{ pillar.ddserver.python }} setup.py install
    - cwd: /usr/local/src/ddserver


# Add ddserver configuration and logfile
#
ddserver.config:
  file.symlink:
    - name: /etc/ddserver/ddserver.conf
    - target: /etc/ddserver/ddserver.conf.example

ddserver.logfile:
  file.managed:
    - name: /var/log/ddserver.log
    - user: root
    - group: www-data
    - mode: 777


# Create ddserver db, db_user and import schema
#
ddserver.db:
  mysql_database.present:
    - name: ddserver
    - require:
      - pkg: mysql

  mysql_user.present:
    - name: ddserver
    - password: YourDatabasePassword
    - host: localhost
    - require:
      - pkg: mysql

  mysql_grants.present:
    - grant: all privileges
    - database: ddserver.*
    - user: ddserver
    - require:
      - pkg: mysql

  cmd.run:
    - name: mysql -u root ddserver < /usr/share/doc/ddserver/schema.sql
    - watch:
      - mysql_database: ddserver.db
    - require:
      - pkg: mysql


# Create systemd service or init file
#
ddserver.service:
  file.symlink:
  {% if pillar.ddserver.version < 0.3 %}
    - name: /etc/init.d/ddserver-bundle
    - target: /usr/share/doc/ddserver/debian.init.d/ddserver
    - mode: 755
  {% else %}
    - name: /etc/systemd/system/ddserver.service
    - target: /usr/share/doc/ddserver/systemd/ddserver.service
    - mode: 644
  {% endif %}
    - user: root
    - group: root

  service.running:
    - name: ddserver
    - enable: True


# Create recursor configuration
#
ddserver.recursor:
  file.managed:
    - name: /etc/powerdns/pdns.d/pdns.ddserver.conf
    {% if pillar.ddserver.version < 0.3 %}
    - source: salt://ddserver/pdns.ddserver_pipe.conf
    {% else %}
    - source: salt://ddserver/pdns.ddserver_remote.conf
    {% endif %}
    - user: root
    - group: root
    - mode: 644
