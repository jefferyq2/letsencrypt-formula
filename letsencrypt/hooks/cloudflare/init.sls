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
    - source: salt://letsencrypt/hooks/cloudflare/hook
    - template: jinja
    - context:
        name: {{ name }}
        data: {{ data }}
    - user: root
    - group: root
    - mode: 700

/etc/dehydrated/hooks/{{ name }}/hook-repo:
  git.latest:
    - name: https://github.com/bushelpowered/dehydrated-hook-cloudflare.git
    - target: /etc/dehydrated/hooks/{{ name }}/repo
    - rev: 17d3a35523254eef5ab65a4a82a4ac147b1913af
    - force_clone: True
    - force_reset: True
    - user: root
