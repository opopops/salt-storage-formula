{% from "storage/map.jinja" import storage with context %}

{%- if storage.get('lvm', False) %}
include:
  - storage.lvm.install
  - storage.lvm.unmount
  - storage.lvm.lv_remove
  - storage.lvm.vg_remove
  - storage.lvm.vg
  - storage.lvm.lv
  - storage.lvm.format
  - storage.lvm.mount
{%- endif %}
