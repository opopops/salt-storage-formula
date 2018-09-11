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

  {%- for partition in disk.get('partitions', []) %}

storage_disk_partition_{{ disk_name }}{{ loop.index }}:
  module.run:
    - partition.mkpart:
      - device: {{ disk_name }}
      - part_type: {{ partition.get('part_type', 'primary') }}
      {%- if partition.fs_type is defined %}
      - fs_type: {{ partition.fs_type }}
      {%- endif %}
      - start: {{ partition.get('start') }}
      - end: {{ partition.get('end') }}
    - unless: "blkid {{ disk_name }}{{ loop.index }} {{ disk_name }}p{{ loop.index }}"
    - require:
      - module: storage_disk_label_{{ disk_name }}
      - pkg: storage_pkgs

  {%- endfor %}

storage_disk_probe_partions_{{ disk_name }}:
  module.run:
    - partition.probe:
      - {{ disk_name }}

  {%- for partition in disk.get('partitions', []) %}

    {%- if partition.get('format', False) %}
storage_disk_mkfs_partition_{{ disk_name }}{{ loop.index }}:
  blockdev.formatted:
    - name: {{ disk_name }}{{ loop.index }}
    - fs_type: {{ partition.format.fs_type }}
    - force: {{ partition.format.get('force', False) }}
    - require:
      - module: storage_disk_probe_partions_{{ disk_name }}
      - module: storage_disk_partition_{{ disk_name }}{{ loop.index }}

      {%- if partition.get('mount', False) %}
storage_disk_mount_{{partition.mount.mount_point}}:
  mount.mounted:
    - name: {{partition.mount.mount_point}}
    - device: {{disk_name}}{{ loop.index }}
    - fstype: {{partition.format.fs_type}}
    - mkmnt: True
    - persist: {{ partition.mount.get('persist', True) }}
    - opts: {{ partition.mount.get('opts', ['defaults']) }}
    - require:
      - blockdev: storage_disk_mkfs_partition_{{ disk_name }}{{ loop.index }}
      {%- endif %}
    {%- endif %}

  {%- endfor %}

{%- endfor %}
