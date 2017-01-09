{% from "letsencrypt/map.jinja" import letsencrypt with context -%}

/etc/dehydrated/hooks/{{ name }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600
    - makedirs: True

/etc/dehydrated/hooks/{{ name }}/hook:
  file.managed:
    - source: salt://letsencrypt/hooks/dnsmadeeasy/hook
    - template: jinja
    - context:
        name: {{ name }}
        data: {{ data }}
    - user: root
    - group: root
    - mode: 700

/etc/dehydrated/hooks/{{ name }}/hook-repo:
  git.latest:
    - name: https://github.com/alisade/letsencrypt-DNSMadeEasy-hook.git
    - target: /etc/dehydrated/hooks/{{ name }}/repo
    - rev: ffe78f0feac8729d7d5e47ac0c49f83301de3c13
    - force_clone: True
    - force_reset: True
    - user: root

/etc/dehydrated/hooks/{{ name }}/virtualenv:
  virtualenv.managed:
    - python: /usr/bin/python3
    - system_site_packages: False
    - requirements: /etc/dehydrated/hooks/{{ name }}/repo/requirements.txt
