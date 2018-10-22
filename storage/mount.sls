{%- from "storage/map.jinja" import storage with context %}

include:
  - storage.install

{%- for name, params in storage.mount.get('absent', {}).items() %}
storage_mount_{{name}}_absent:
  mount.unmounted:
    - name: {{name}}
    {%- if params.get('device', False) %}
    - device: {{params.device}}
    {%- endif %}
    - persist: {{ params.get('persist', True) }}
{%- endfor %}

{%- for name, params in storage.mount.get('present', {}).items() %}
storage_mount_{{name}}_present:
  mount.mounted:
    - name: {{name}}
    - device: {{params.device}}
    - fstype: {{params.fs_type}}
    - mkmnt: True
    - persist: {{ params.get('persist', True) }}
    - opts: {{ params.get('opts', ['defaults']) }}
{%- endfor %}
