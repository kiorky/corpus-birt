{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
include:
  - makina-states.localsettings.jdk

prepreqs-{{cfg.name}}:
  pkg.installed:
    - require:
      - mc_proxy: makina-states-jdk_last
    - pkgs:
      - apache2-utils
      - tomcat7

{{cfg.name}}-dirs:
  file.directory:
    - names:
        - {{data.www}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - mode: 2751

{{cfg.name}}-dirs2:
  file.directory:
    - names:
        - {{cfg.data_root}}/reports
    - user: tomcat7
    - group: tomcazt7
    - mode: 2751
