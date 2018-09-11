{% from "storage/map.jinja" import storage with context %}

include:
  - storage.lvm.install
  - storage.lvm.vg
  - storage.lvm.lv
  - storage.lvm.format

{%- for vg_name, vg_params in salt['pillar.get']('storage:lvm:present:vgs', {}).items() %}
  {%- for lv_name, lv_params in vg_params.get('lvs', {}).items() %}
    {%- if lv_params.get('format', False) and lv_params.get('mount', False) %}

storage_lvm_vg_{{vg_name}}_lv_{{lv_name}}_mount:
  mount.mounted:
    - name: {{lv_params.mount.mount_point}}
    - device: {{storage.blockdev_root_path|path_join(vg_name) ~ '-' ~ lv_name}}
    - fstype: {{lv_params.format.fs_type}}
    - mkmnt: True
    - persist: {{ lv_params.mount.get('persist', True) }}
    - opts: {{ lv_params.mount.get('opts', ['defaults']) }}
    - require:
      - sls: storage.lvm.format

    {%- endif %}
  {%- endfor %}
{%- endfor %}
