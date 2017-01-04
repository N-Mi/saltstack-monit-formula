{% from "monit/map.jinja" import monit with context %}

monit:
  pkg.installed:
    - name: {{ monit.pkg }}

monitrc:
  file.managed:
    - name: {{ monit.conf_dir }}/monitrc
    - source: salt://monit/files/monitrc
    - template: jinja
    - user: root
    - mode: 600
    - context:
      confd_dir: {{ monit.confd_dir }}
    - watch_in:
      - service: monit

confd_dir:
  file.directory:
    - name: {{ monit.confd_dir }}
    - user: root
    - group: root
    - mode: 0755

confd_README:
  file.managed:
    - name: {{ monit.confd_dir }}/README
    - user: root
    - group: root
    - mode: 444
    - contents: |
      ###
      ### This directory is handled by Salstack !!!
      ###
      ### Be aware that any change to files in this directory may be overwritten
      ### 
      
{% if grains['os'] == 'Debian' %}
upstart:
  file.managed:
    - name: /etc/init/monit.conf
    - source: salt://monit/files/upstart_monit.conf
    - user: root
    - group: root
    - mode: 0444
{% endif %}

{% if grains['os_family'] == 'RedHat' %}
rc_logging:
  file.absent:
    - name: {{ monit.confd_dir }}/logging
{% endif %}

service:
  service.running:
    - enable: True
    - name: {{ monit.service }}
    - require:
      - pkg: {{ monit.pkg }}
      - file: {{ monit.conf_dir }}/monitrc
    - watch:
      - file: {{ monit.conf_dir }}/monitrc
      - file: {{ monit.confd_dir }}/*
