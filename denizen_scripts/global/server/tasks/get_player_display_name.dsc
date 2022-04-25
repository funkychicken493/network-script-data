get_player_display_name:
  type: procedure
  debug: false
  definitions: player
  script:
    - define player <player> if:<[player].exists.not>
    - if <server.has_flag[player_map.uuids.<[player].uuid.if_null[invalid]>.display_name]>:
      - determine <server.flag[player_map.uuids.<[player].uuid.if_null[invalid]>.display_name]>
    - else if <server.has_flag[player_map.uuids.<[player].uuid.if_null[invalid]>.display_color]>:
      - determine <server.flag[player_map.uuids.<[player].uuid.if_null[invalid]>.display_color]><player.name>
    - else:
      - determine <[player].name.if_null[invalid]>
