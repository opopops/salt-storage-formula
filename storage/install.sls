{%- from "storage/map.jinja" import storage with context %}

storage_pkgs:
  pkg.installed:
    - pkgs: {{ storage.pkgs }}
