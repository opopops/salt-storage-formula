{%- from "storage/map.jinja" import storage with context %}

include:
  - storage.install

{%- for mount_point, params in storage.mount.get('absent', {}).items() %}
storage_mount_{{mount_point}}_absent:
  mount.unmounted:
    - name: {{mount_point}}
    {%- if params.get('device', False) %}
    - device: {{params.device}}
    {%- endif %}
    - persist: {{ params.get('persist', True) }}
{%- endfor %}

{%- for mount_point, params in storage.mount.get('present', {}).items() %}
storage_mount_{{mount_point}}_present:
  mount.mounted:
    - name: {{mount_point}}
    - device: {{params.device}}
    - fstype: {{params.fs_type}}
    - mkmnt: True
    - persist: {{ params.get('persist', True) }}
    - opts: {{ params.get('opts', ['defaults']) }}
{%- endfor %}
