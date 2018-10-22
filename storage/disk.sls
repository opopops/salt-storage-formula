{%- from "storage/map.jinja" import storage with context %}

include:
  - storage.install

{%- for device, params in storage.disk.items() %}
  {%- set device = params.device|default(device) %}

storage_disk_label_{{ device }}:
  module.run:
    - partition.mklabel:
      - device: {{ device }}
      - label_type: {{ params.get('label_type', 'msdos') }}
    - unless: "fdisk -l {{ device }} | grep -i 'Disklabel type: {{ params.get('label_type', 'dos') }}'"
    - require:
      - pkg: storage_pkgs

storage_disk_probe_partions_{{ device }}:
  module.run:
    - partition.probe:
      - {{ device }}

  {%- for partition in params.get('partitions', []) %}

    {%- if partition.get('format', False) %}
      {%- if device.startswith('/dev/mmc') %}
        {%- set blockdev_name = device ~ 'p' ~ loop.index %}
      {%- else %}
        {%- set blockdev_name = device ~ loop.index %}
      {%- endif %}

storage_disk_partition_{{ blockdev_name }}:
  module.run:
    - partition.mkpart:
      - device: {{ device }}
      - part_type: {{ partition.get('part_type', 'primary') }}
      {%- if partition.fs_type is defined %}
      - fs_type: {{ partition.fs_type }}
      {%- endif %}
      - start: {{ partition.get('start') }}
      - end: {{ partition.get('end') }}
    - unless: "blkid {{ blockdev_name }}"
    - require:
      - module: storage_disk_label_{{ device }}
      - pkg: storage_pkgs
    - require_in:
      - module: storage_disk_probe_partions_{{ device }}

storage_disk_mkfs_partition_{{ blockdev_name }}:
  blockdev.formatted:
    - name: {{ blockdev_name }}
    - fs_type: {{ partition.format.fs_type }}
    - force: {{ partition.format.get('force', False) }}
    - require:
      - module: storage_disk_probe_partions_{{ device }}
      - module: storage_disk_partition_{{ blockdev_name }}

      {%- if partition.get('mount', False) %}
storage_disk_mount_{{partition.mount.name}}:
  mount.mounted:
    - name: {{ partition.mount.name }}
    - device: {{ partition.mount.get('device', blockdev_name) }}
    - fstype: {{ partition.format.fs_type }}
    - mkmnt: True
    - persist: {{ partition.mount.get('persist', True) }}
    - opts: {{ partition.mount.get('opts', ['defaults']) }}
    - require:
      - blockdev: storage_disk_mkfs_partition_{{ blockdev_name }}
      {%- endif %}
    {%- endif %}

  {%- endfor %}

{%- endfor %}
