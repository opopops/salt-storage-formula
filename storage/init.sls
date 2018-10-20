{%- from "storage/map.jinja" import storage with context %}

include:
  - storage.install
  {%- if storage.get('disk', False) %}
  - storage.disk
  {%- endif %}
  {%- if storage.get('lvm', False) %}
  - storage.lvm
  {%- endif %}
  {%- if storage.get('zfs', False) %}
  - storage.zfs
  {%- endif %}
  {%- if storage.get('swap', False) %}
  - storage.swap
  {%- endif %}
  {%- if storage.get('mount', False) %}
  - storage.mount
  {%- endif %}
