{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

include:
  - makina-states.services.http.nginx

# inconditionnaly reboot circus & nginx upon deployments
{{ nginx.virtualhost(
    domain=data.domain,
    force_reload=true,
    doc_root=data.www,
    vh_top_source=data.nginx_upstreams,
    vh_content_source=data.nginx_vhost,
    cfg=cfg)}}

{% if data.get('http_users', {}) %}
{% for userrow in data.http_users %}
{% for user, passwd in userrow.items() %}
{{cfg.name}}-{{user}}-htaccess:
  webutil.user_exists:
    - name: {{user}}
    - password: {{passwd}}
    - htpasswd_file: {{data.htaccess}}
    - options: m
    - force: true
{% endfor %}
{% endfor %}
{% endif %}

{{cfg.name}}-htaccess:
  file.managed:
    - name: {{data.htaccess}}
    - source: ''
    - user: www-data
    - group: www-data
    - mode: 770
    - watch:
      - mc_proxy: nginx-post-conf-hook
