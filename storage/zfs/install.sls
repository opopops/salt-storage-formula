{% from "storage/map.jinja" import storage with context %}

storage_zfs_packages:
  pkg.installed:
    - pkgs: {{ storage.zfs_pkgs  }}

storage_zfs_modprobe:
  cmd.run:
    - name: modprobe zfs
    - unless: lsmod|grep zfs
    - require:
      - pkg: storage_zfs_packages
