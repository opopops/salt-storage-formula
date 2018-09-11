{% from "storage/map.jinja" import storage with context %}

include:
  - storage.lvm.install

{% for vg_name, vg_params in salt['pillar.get']('storage:lvm:present:vgs', {}).items() %}
storage_lvm_vg_{{vg_name}}:
  lvm.vg_present:
    - name: {{vg_name}}
    - devices: {{ vg_params.devices }}
    - require:
      - sls: storage.lvm.install
{% endfor %}
