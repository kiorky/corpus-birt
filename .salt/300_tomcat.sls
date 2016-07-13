
{% set cfg = opts.ms_project %}
{% import "makina-states/_macros/h.jinja" as h with context %}
{% set data = cfg.data %}
{% set scfg = salt['mc_utils.json_dump'](cfg) %}
{% set project_root=cfg.project_root%}


{% import "makina-states/_macros/h.jinja" as h with context %}

{{cfg.name}}-configs-before:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-pre
{{cfg.name}}-configs-pre:
  mc_proxy.hook: []
{% macro rmacro() %}
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-post
    - watch:
      - mc_proxy: {{cfg.name}}-configs-pre
{% endmacro %}
{{ h.deliver_config_files(
     data.get('configs', {}),
     dir='makina-projects/{0}/files/'.format(cfg.name),
     mode='640',
     user=data.user,
     group=cfg.group,
     target_prefix=data.www+"/",
     after_macro=rmacro, prefix=cfg.name+'-config-conf',
     project=cfg.name,
     cfg=cfg.name)}}
{{cfg.name}}-configs-post:
  mc_proxy.hook:
    - watch_in:
      - mc_proxy: {{cfg.name}}-configs-after
{{cfg.name}}-configs-after:
  mc_proxy.hook: []

tomcat-svc:
  service.running:
    - name: tomcat7
    - enable: true
    - watch:
      - mc_proxy: {{cfg.name}}-configs-after
