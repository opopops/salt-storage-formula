{% from "storage/map.jinja" import storage with context %}

include:
  - storage.lvm.install
  - storage.lvm.vg
  - storage.lvm.lv

{%- for vg_name, vg_params in salt['pillar.get']('storage:lvm:present:vgs', {}).items() %}
  {%- for lv_name, lv_params in vg_params.get('lvs', {}).items() %}
    {%- if lv_params.get('format', False) %}
storage.lvm_vg_{{vg_name}}_lv_{{lv_name}}_format:
  blockdev.formatted:
    - name: {{storage.blockdev_root_path|path_join(vg_name) ~ '-' ~ lv_name}}
    - fs_type: {{lv_params.format.fs_type}}
    - force: {{lv_params.format.get('force', False)}}
    - require:
      - sls: storage.lvm.lv
    {%- endif %}
  {%- endfor %}
{%- endfor %}
