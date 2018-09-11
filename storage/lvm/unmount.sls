{% from "storage/map.jinja" import storage with context %}

{% for lv_name, lv_params in salt['pillar.get']('storage:lvm:absent:lvs', {}).items() %}
storage_lvm_vg_{{lv_params.vg}}_lv_{{lv_name}}_unmount:
  mount.unmounted:
    - name: {{lv_params.mount_point}}
    - device: {{storage.blockdev_root_path|path_join(lv_params.vg) ~ '-' ~ lv_name}}
    - persist: True
{% endfor %}
