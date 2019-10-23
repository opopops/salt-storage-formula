{%- from "storage/map.jinja" import storage with context %}

{%- for swap_name, swap in storage.get('swap', {}).items() %}

  {%- if swap.engine == 'partition' %}

storage_create_swap_partition_{{ swap.device }}:
  cmd.run:
  - name: 'mkswap {{ swap.device }}'
  - unless: file -L -s {{ swap.device }} | grep -q 'swap file'

storage_set_swap_partition_{{ swap.device }}:
  cmd.run:
  - name: 'swapon {{ swap.device }}'
  - unless: grep $(readlink -f {{ swap.device }}) /proc/swaps
  - require:
    - cmd: storage_create_swap_partition_{{ swap.device }}

{{ swap.device }}:
  mount.swap:
  - persist: True
  - require:
    - cmd: storage_set_swap_partition_{{ swap.device }}

  {%- elif swap.engine == 'file' %}

storage_create_swap_file_{{ swap.device }}:
  cmd.run:
  - name: 'dd if=/dev/zero of={{ swap.device }} bs=1048576 count={{ swap.size }} oflag=direct && chmod 0600 {{ swap.device }}'
  - creates: {{ swap.device }}

storage_set_swap_file_{{ swap.device }}:
  cmd.wait:
  - name: 'mkswap {{ swap.device }}'
  - watch:
    - cmd: storage_create_swap_file_{{ swap.device }}

storage_set_swap_file_status_{{ swap.device }}:
  cmd.run:
  - name: 'swapon {{ swap.device }}'
  - unless: grep {{ swap.device }} /proc/swaps
  - require:
    - cmd: storage_set_swap_file_{{ swap.device }}

{{ swap.device }}:
  mount.swap:
  - persist: True
  - require:
    - cmd: storage_set_swap_file_{{ swap.device }}

  {%- endif %}

{%- endfor %}
