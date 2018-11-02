{% from "storage/map.jinja" import storage with context %}

include:
  - storage.zfs.install

{%- for pool, params in storage.zfs.get('pools', {}).items() %}
storage_zfs_pool_{{pool}}:
  zpool.present:
    - name: {{pool}}
    - layout: {{params.get('layout', None)}}
    - properties: {{params.get('properties', None)}}
    - filesystem_properties: {{params.get('filesystem_properties', None)}}
    - config: {{params.get('config', None)}}
    - require:
      - sls: storage.zfs.install
{%- endfor %}
