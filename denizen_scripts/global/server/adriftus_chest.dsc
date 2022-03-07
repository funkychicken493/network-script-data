adriftus_chest_inventory_open:
  type: task
  debug: false
  script:
    - define inventory <inventory[adriftus_chest_inventory]>
    - adjust def:inventory size:<yaml[global.player.<player.uuid>].read[adriftus.chest.size]||9>
    - foreach <yaml[global.player.<player.uuid>].read[adriftus.chest.contents_map]||<map>>:
      - inventory set slot:<[key]> o:<[value]> d:<[inventory]>
    - inventory open d:<[inventory]>

adriftus_chest_inventory:
  type: inventory
  inventory: chest
  title: <&6>Adriftus Chest
  size: 9

adriftus_chest_inventory_events:
  type: world
  debug: true
  events:
    on player closes adriftus_chest_inventory:
      - define contents <context.inventory.map_slots>
      - define map <map>
      - foreach <[contents]> key:slot as:item:
        - if <[item].has_flag[adriftus.chest.bypass]>:
          - define map <[map].with[<[slot]>].as[<[item]>]>
        - else if !<[item].has_flag[adriftus.chest.server]>:
          - define server_name <server.flag[display_name]||<&6><bungee.server.replace[_].with[<&sp>].to_titlecase>>
          - define lore <[item].lore.include[<[server_name]>]||<[server_name]>>
          - define map <[map].with[<[slot]>].as[<[item].with[lore=<[lore]>;flag=adriftus.chest.server:<bungee.server>;flag=run_script:adriftus_chest_validate]>]>
        - else:
          - define map <[map].with[<[slot]>].as[<[item]>]>
      - run global_player_data_modify def:<player.uuid>|adriftus.chest.contents_map|<[map]>

adriftus_chest_validate:
  type: task
  debug: false
  script:
    - if <context.item.has_flag[adriftus.chest.server]> && <context.item.flag[adriftus.chest.server]> != <bungee.server>:
      - determine cancelled
    - else:
      - define lore <context.item.lore.exclude[last]>
      - determine <context.item.with[lore=<[lore]>;flag=run_script:!;flag=adriftus.chest.server:!]>