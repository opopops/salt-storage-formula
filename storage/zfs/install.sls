{% from "storage/map.jinja" import storage with context %}

storage_zfs_kernel_package:
  pkg.installed:
    - name: {{ storage.zfs_kernel_pkg  }}
    - unless: lsmod | grep zfs

storage_zfs_packages:
  pkg.installed:
    - pkgs: {{ storage.zfs_pkgs  }}
    - require:
      - pkg: storage_zfs_kernel_package

storage_zfs_modprobe:
  cmd.run:
    - name: modprobe zfs
    - unless: lsmod | grep zfs
    - require:
      - pkg: storage_zfs_packages
