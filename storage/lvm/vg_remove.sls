{% from "storage/map.jinja" import storage with context %}

include:
  - storage.lvm.install
  - storage.lvm.unmount
  - storage.lvm.lv_remove

{% for vg_name in salt['pillar.get']('storage:lvm:absent:vgs', {}) %}
storage_lvm_vg_{{vg_name}}_absent:
  lvm.vg_absent:
    - name: {{vg_name}}
    - require:
      - sls: storage.lvm.install
      - sls: storage.lvm.unmount
      - sls: storage.lvm.lv_remove
{% endfor %}
