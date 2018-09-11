{% from "storage/map.jinja" import storage with context %}

storage_lvm_packages:
  pkg.installed:
    - pkgs: {{ storage.lvm_pkgs  }}
