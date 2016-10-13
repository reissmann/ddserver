powerdns:
  pkg.installed:
    - pkgs: 
      - pdns-server
      {% if pillar.ddserver.version < 0.3 %}
      - pdns-backend-pipe
      {% else %}
      - pdns-backend-remote
      {% endif %}

  service.running:
    - name: pdns
    - enable: True
    - require:
      - pkg: powerdns
    - watch:
      - file: /etc/powerdns/*
      - file: /etc/powerdns/pdns.d/*

pdns.local.conf:
  file.managed:
    - name: /etc/powerdns/pdns.d/pdns.local.conf
    - user: root
    - group: root
    - mode: 640
    - source: salt://powerdns/pdns.local.conf
    - require:
      - pkg: powerdns

