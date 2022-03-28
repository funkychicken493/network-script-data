player_crafting_slots_override_events:
  type: world
  debug: false
  data:
    items:
      - "crafting_table[display=<&e>Crafting Table;flag=run_script:player_crafting_slots_open_button;flag=on_drop:cancel;flag=grid_script:open_crafting_grid;flag=no_drop_on_death:true]"
      - "stone[display=<&6>Adriftus Chest;flag=run_script:player_crafting_slots_open_button;flag=on_drop:cancel;flag=grid_script:adriftus_chest_inventory_open;flag=no_drop_on_death:true;custom_model_data=1]"
      - "piston[display=<&b>Menu;flag=run_script:player_crafting_slots_open_button;flag=on_drop:cancel;flag=grid_script:main_menu_inventory_open;flag=no_drop_on_death:true]"
      - "feather[display=<&a>Travel;flag=run_script:player_crafting_slots_open_button;flag=on_drop:cancel;flag=grid_script:travel_menu_open;flag=no_drop_on_death:true]"
  set_inv:
      - define inv <player.open_inventory>
      - repeat 5:
        - inventory set slot:<[value]> o:air d:<[inv]>
      - wait 1t
      - stop if:<player.is_online.not>
      - foreach <script.data_key[data.items]>:
        - inventory set slot:<[loop_index].add[1]> o:<[value].parsed> d:<[inv]>
      - inventory set slot:1 o:air d:<[inv]>
      - take flagged:grid_script quantity:999
      - inventory update
  events:
    on player clicks in PLAYER bukkit_priority:HIGH:
        - determine cancelled if:<context.raw_slot.equals[1]>
    after player joins:
      - inject locally path:set_inv
    on player closes PLAYER:
      - inject locally path:set_inv
    on player dies bukkit_priority:LOWEST:
      - inventory clear d:<player.open_inventory>
    on player teleports:
      - inventory close
      - inject locally path:set_inv
    on player uses recipe book:
      - if <player.open_inventory.slot[3].material.name> == stone:
        - determine cancelled
    on player respawns:
      - inject locally path:set_inv

player_crafting_slots_open_button:
  type: task
  debug: false
  script:
    - determine passively cancelled
    - define script <context.item.flag[grid_script]>
    - wait 2t
    - inject <[script]>
