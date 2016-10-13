# Install ddserver
#
mysql_connector:
  git.latest:
    - name: https://github.com/mysql/mysql-connector-python.git
    - rev: master
    - target: /usr/local/src/mysql-connector-python
    - require:
      - pkg: common.apps

mysql_connector.build:
  cmd.run:
    - name: {{ pillar.ddserver.python }} setup.py build
    - cwd: /usr/local/src/mysql-connector-python

mysql_connector.install:
  cmd.run:
    - name: {{ pillar.ddserver.python }} setup.py install
    - cwd: /usr/local/src/mysql-connector-python

