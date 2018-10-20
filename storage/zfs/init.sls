{% from "storage/map.jinja" import storage with context %}

{%- if storage.get('zfs', False) %}
include:
  - storage.zfs.install
  {%- if storage.zfs.get('pools', False) %}
  - storage.zfs.pool
  {%- endif %}
{%- endif %}
