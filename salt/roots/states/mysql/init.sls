mysql:
  pkg.installed:
    - pkgs:
      - mysql-server
      - mysql-client
      - python-mysqldb

  service.running:
    - name: mysql
    - enable: True

