{% from "storage/map.jinja" import storage with context %}

include:
  - storage.lvm.install
  - storage.lvm.vg

{%- for vg_name, vg_params in salt['pillar.get']('storage:lvm:present:vgs', {}).items() %}
  {%- for lv_name, lv_params in vg_params.get('lvs', {}).items() %}
storage_lvm_vg_{{vg_name}}_lv_{{lv_name}}:
  lvm.lv_present:
    - name: {{lv_name}}
    - vgname: {{vg_name}}
    {%- if lv_params.size is defined %}
    - size: {{lv_params.size}}
    {%- elif lv_params.extents is defined %}
    - extents: {{lv_params.extents}}
    {%- endif %}
    {%- if lv_params.thinvolume is defined %}
    - thinvolume: {{lv_params.thinvolume}}
    {%- endif %}
    {%- if lv_params.thinpool is defined %}
    - thinpool: {{lv_params.thinpool}}
    {%- endif %}
    - require:
      - sls: storage.lvm.vg

    {%- if lv_params.get('resize', False) %}
      {%- set lv_path = storage.blockdev_root_path|path_join(vg_name) ~ '-' ~ lv_name %}
        {%- if lv_params.size is defined %}
storage_lvm_vg_{{vg_name}}_lv_{{lv_name}}_resize:
  module.run:
    - lvm.lvresize:
      - size: {{lv_params.size}}
      - lvpath: {{lv_path}}
    - watch_in:
      - module: storage_lvm_vg_{{vg_name}}_lv_{{lv_name}}_resize2fs
    - require:
      - lvm: storage_lvm_vg_{{vg_name}}_lv_{{lv_name}}
        {%- endif %}

storage_lvm_vg_{{vg_name}}_lv_{{lv_name}}_resize2fs:
  module.wait:
    - disk.resize2fs:
      - device: {{lv_path}}
    - watch:
      - lvm: storage_lvm_vg_{{vg_name}}_lv_{{lv_name}}
    {%- endif %}
  {%- endfor %}
{%- endfor %}
