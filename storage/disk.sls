{%- from "storage/map.jinja" import storage with context %}

include:
  - storage.install

{%- for disk_name, disk in storage.disk.items() %}
  {%- set disk_name = disk.name|default(disk_name) %}

storage_disk_label_{{ disk_name }}:
  module.run:
    - partition.mklabel:
      - device: {{ disk_name }}
      - label_type: {{ disk.get('label_type', 'msdos') }}
    - unless: "fdisk -l {{ disk_name }} | grep -i 'Disklabel type: {{ disk.get('label_type', 'dos') }}'"
    - require:
      - pkg: storage_pkgs

storage_disk_probe_partions_{{ disk_name }}:
  module.run:
    - partition.probe:
      - {{ disk_name }}

  {%- for partition in disk.get('partitions', []) %}

    {%- if partition.get('format', False) %}
      {%- if disk_name.startswith('/dev/mmc') %}
        {%- set blockdev_name = disk_name ~ 'p' ~ loop.index %}
      {%- else %}
        {%- set blockdev_name = disk_name ~ loop.index %}
      {%- endif %}

storage_disk_partition_{{ blockdev_name }}:
  module.run:
    - partition.mkpart:
      - device: {{ disk_name }}
      - part_type: {{ partition.get('part_type', 'primary') }}
      {%- if partition.fs_type is defined %}
      - fs_type: {{ partition.fs_type }}
      {%- endif %}
      - start: {{ partition.get('start') }}
      - end: {{ partition.get('end') }}
    - unless: "blkid {{ blockdev_name }}"
    - require:
      - module: storage_disk_label_{{ disk_name }}
      - pkg: storage_pkgs
    - require_in:
      - module: storage_disk_probe_partions_{{ disk_name }}

storage_disk_mkfs_partition_{{ blockdev_name }}:
  blockdev.formatted:
    - name: {{ blockdev_name }}
    - fs_type: {{ partition.format.fs_type }}
    - force: {{ partition.format.get('force', False) }}
    - require:
      - module: storage_disk_probe_partions_{{ disk_name }}
      - module: storage_disk_partition_{{ blockdev_name }}

      {%- if partition.get('mount', False) %}
storage_disk_mount_{{partition.mount.mount_point}}:
  mount.mounted:
    - name: {{partition.mount.mount_point}}
    - device: {{ blockdev_name }}
    - fstype: {{partition.format.fs_type}}
    - mkmnt: True
    - persist: {{ partition.mount.get('persist', True) }}
    - opts: {{ partition.mount.get('opts', ['defaults']) }}
    - require:
      - blockdev: storage_disk_mkfs_partition_{{ blockdev_name }}
      {%- endif %}
    {%- endif %}

  {%- endfor %}

{%- endfor %}
