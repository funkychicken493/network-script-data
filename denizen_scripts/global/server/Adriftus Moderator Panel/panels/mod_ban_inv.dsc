# -- BAN PANEL
mod_ban_inv:
  type: inventory
  debug: false
  title: <&f><&font[adriftus:mod_tools]><&chr[F808]><&chr[1001]>
  inventory: CHEST
  gui: true
  size: 54
  definitions:
    x: <item[feather].with[display_name=<&sp>;custom_model_data=3]>
    back: <item[feather].with[display_name=<&c><&l>↩<&sp>Actions<&sp>panel;custom_model_data=3].with_flag[to:actions]>
    head: <item[mod_player_item]>
  slots:
    - [x] [x] [x] [x] [x] [x] [x] [x] [x]
    - [x] [x] [] [] [] [x] [x] [x] [x]
    - [x] [x] [] [] [] [] [] [x] [x]
    - [x] [x] [] [] [] [x] [x] [x] [x]
    - [x] [x] [x] [x] [x] [x] [x] [x] [x]
    - [back] [x] [x] [x] [head] [x] [x] [x] [x]

mod_ban_inv_events:
  type: world
  debug: false
  events:
    on player right clicks mod_level*_item in mod_ban_inv:
      - run mod_log_action def:<player.uuid>|<player.flag[amp_map].get[uuid]>|<context.item.flag[LEVEL]>|<context.item.flag[INFRACTION]>|Ban|<context.item.flag[LENGTH]>
      - run mod_log_ban def:<player.uuid>|<player.flag[amp_map].get[uuid]>|<context.item.flag[LEVEL]>|<context.item.flag[INFRACTION]>|<context.item.flag[LENGTH]>
      - run mod_message_discord def:<player.uuid>|<player.flag[amp_map].get[uuid]>|<context.item.flag[LEVEL]>|<context.item.flag[INFRACTION]>|Ban|<context.item.flag[LENGTH]>
      - run mod_chat_notifier def:<player.uuid>|<player.flag[amp_map].get[uuid]>|<context.item.flag[LEVEL]>|<context.item.flag[INFRACTION]>|Ban|<context.item.flag[LENGTH]>
      - run mod_ban_player def:<player.uuid>|<player.flag[amp_map].get[uuid]>|<context.item.flag[LEVEL]>|<context.item.flag[INFRACTION]>|<context.item.flag[LENGTH]>
      - inventory close

mod_ban_inv_open:
  type: task
  debug: false
  script:
    - define items <list>
    - define inventory <inventory[mod_ban_inv]>
    - foreach <list[1|2|3]> as:level:
      - foreach <script[mod_ban_infractions].list_keys[<[level]>]> as:infraction:
        - define item <item[mod_level<[level]>_item]>
        - define name <[item].flag[tag].parsed><&sp><[infraction]>
        - define lore <list[<&b>Level<&co><&sp><[item].flag[colour].parsed><[level]>]>
        - define lore:->:<&c>Right<&sp>Click<&sp>to<&sp>ban<&co>
        - define lore:->:<&r><player.flag[amp_map].get[uuid].as_player.name>
        - flag <[item]> LEVEL:<[level]>
        - flag <[item]> INFRACTION:<[infraction]>
        - flag <[item]> LENGTH:<script[mod_ban_infractions].data_key[<[level]>.<[infraction]>.length]>
        - define item <[item].with[display_name=<[name]>;lore=<[lore]>]>
        - define items:->:<[item]>
    - give <[items]> to:<[inventory]>
    - inventory open d:<[inventory]>
