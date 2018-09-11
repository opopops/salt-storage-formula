{% from "storage/map.jinja" import storage with context %}

include:
  - storage.lvm.install
  - storage.lvm.unmount

{% for lv_name, lv_params in salt['pillar.get']('storage:lvm:absent:lvs', {}).items() %}
lvm_vg_{{lv_params.vg}}_lv_{{lv_name}}_absent:
  lvm.lv_absent:
    - name: {{lv_name}}
    - vgname: {{lv_params.vg}}
    - require:
      - sls: storage.lvm.install
      - sls: storage.lvm.unmount
{% endfor %}
