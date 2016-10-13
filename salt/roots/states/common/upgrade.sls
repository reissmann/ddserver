common.update:
  cmd.wait:
    - name: apt-get update

common.upgrade:
  cmd.wait:
    - name: apt-get upgrade
    - require:
      - cmd: common.update

