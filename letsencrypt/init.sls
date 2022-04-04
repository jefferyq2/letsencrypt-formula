{% from "letsencrypt/map.jinja" import letsencrypt with context -%}

letsencrypt-binary:
  file.managed:
    - name: {{ letsencrypt.files.dehydrated_bin }}
    - source: {{ letsencrypt.files.dehydrated_bin_src }}
    - source_hash: {{ letsencrypt.files.dehydrated_bin_hash }}
    - user: root
    - group: root
    - mode: 755

letsencrypt-config-dir:
  file.directory:
    - name: {{ letsencrypt.files.configdir }}
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True

letsencrypt-config:
  file.managed:
    - name: {{ letsencrypt.files.config }}
    - source: {{ letsencrypt.files.config_src }}
    - template: jinja
    - context:
        config: {{ letsencrypt.get('config', False) }}
        hook: {{ letsencrypt.get('hook', False) }}
    - user: root
    - group: root
    - mode: 600

letsencrypt-domains:
  file.managed:
    - name: {{ letsencrypt.files.domains }}
    - source: {{ letsencrypt.files.domains_src }}
    - template: jinja
    - user: root
    - group: root
    - mode: 600

{% for name, data in salt['pillar.get']('letsencrypt:domains', {}).items() %}
{% set safename = name|replace('.', '-') %}
  {% if data %}
    {% if data.get('config') or data.get('hook') %}
letsencrypt-cert-{{ safename }}:
  file.directory:
    - name: {{ letsencrypt.files.certsdir }}/{{ name }}
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True

letsencrypt-cert-{{ safename }}-config:
  file.managed:
    - name: {{ letsencrypt.files.certsdir }}/{{ name }}/config
    - source: {{ letsencrypt.files.config_src }}
    - template: jinja
    - context:
        config: {{ data.get('config', False) }}
        hook: {{ data.get('hook', False) }}
    - user: root
    - group: root
    - mode: 600
    {% else %}
letsencrypt-cert-{{ safename }}-config:
  file.absent:
    - name: {{ letsencrypt.files.certsdir }}/{{ name }}/config
    {% endif %}
  {% endif %}
{% endfor %}

{% for name, data in salt['pillar.get']('letsencrypt:accounts', {}).items() %}
letsencrypt-account-{{ name }}:
  file.directory:
    - name: {{ letsencrypt.files.configdir }}/accounts/{{ name }}
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True

letsencrypt-account-key:
  file.managed:
    - name: {{ letsencrypt.files.configdir }}/accounts/{{ name }}/account_key.pem
    - contents: |
{{ data.key|indent(8, True) }}
    - user: root
    - group: root
    - mode: 600

letsencrypt-account-registration:
  file.managed:
    - name: {{ letsencrypt.files.configdir }}/accounts/{{ name }}/registration_info.json
    - contents: |
{{ data.registration|indent(8, True) }}
    - user: root
    - group: root
    - mode: 600
{% endfor %}

{% for name, data in salt['pillar.get']('letsencrypt:hooks', {}).items() %}
{% if data.type != 'executable' %}
{% with name=name, data=data %}
{% set template = 'letsencrypt/hooks/' ~ data.type ~ '/init.sls' %}
{% include template %}
{% endwith %}
{% endif %}
{% endfor %}
