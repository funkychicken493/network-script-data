# -- MISSIONS GUI
missions_inv:
  type: inventory
  debug: false
  title: <&f><&font[adriftus:missions]><&chr[1001]>
  inventory: CHEST
  gui: true
  size: 45
  definitions:
    daily: <item[feather].with[display_name=<&a>Daily;lore=<list[<&6>Resets<&sp>in<&co><&sp><&e><server.flag[next_reset_daily].from_now.formatted.if_null[<util.time_now.next_hour_of_day[11].from_now.formatted>]>]>;flag=timeframe:daily;custom_model_data=3;flag=run_script:missions_inv_run]>
    weekly: <item[feather].with[display_name=<&e>Weekly;lore=<list[<&6>Resets<&sp>in<&co><&sp><&e><server.flag[next_reset_weekly].from_now.formatted.if_null[<util.time_now.next_day_of_week[TUESDAY].add[11h].from_now.formatted>]>]>;flag=timeframe:weekly;custom_model_data=3;flag=run_script:missions_inv_run]>
    monthly: <item[feather].with[display_name=<&6>Monthly;lore=<list[<&6>Resets<&sp>in<&co><&sp><&e><server.flag[next_reset_monthly].from_now.formatted.if_null[<util.time_now.next_day_of_month[1].add[11h].from_now.formatted>]>]>;flag=timeframe:monthly;custom_model_data=3;flag=run_script:missions_inv_run]>
    herocraft: <item[feather].with[display_name=<&b>HeroCraft;lore=<list[<&6>Resets<&sp>in<&co><&sp><&e><server.flag[next_reset_monthly].from_now.formatted.if_null[<util.time_now.next_day_of_month[1].add[11h].from_now.formatted>]>]>;flag=timeframe:persistent;custom_model_data=3;flag=run_script:missions_inv_run]>
    none: <item[barrier].with[display_name=<&c>No<&sp>Missions]>
    close: <item[feather].with[display_name=<&c><&l>χ<&sp>Close;custom_model_data=3;flag=run_script:missions_inv_close]>
  slots:
    - [] [daily] [daily] [weekly] [weekly] [monthly] [monthly] [herocraft] []
    - [] [] [] [] [] [] [] [] []
    - [] [none] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [close] [] [] [] [] [] [] [] []

missions_inv_open:
  type: task
  debug: false
  definitions: timeframe
  data:
    slot_data:
      slots_used: 20|21|22|23|24|25|26
    titles:
      daily: <&chr[1002]><&chr[F602]><&r><&4><&l>Done<&co><&font[adriftus:font_downshift2]><player.flag[missions.total.daily].if_null[0]>
      weekly: <&chr[1003]><&chr[F602]><&r><&4><&l>Done<&co><&font[adriftus:font_downshift2]><player.flag[missions.total.weekly].if_null[0]>
      monthly: <&chr[1004]><&chr[F602]><&r><&4><&l>Done<&co><&font[adriftus:font_downshift2]><player.flag[missions.total.monthly].if_null[0]>
      persistent: <&chr[1005]><&chr[F602]><&r><&4><&l>Done<&co><&font[adriftus:font_downshift2]><player.flag[missions.total.global].if_null[0]>
  script:
    # Set definitions
    - define timeframe daily if:<[timeframe].exists.not>
    - define inventory <inventory[missions_inv]>
    - define slots <list[<script.parsed_key[data.slot_data.slots_used]>]>
    - define missions <proc[missions_get_timeframe].context[<[timeframe]>]>
    # Loop over missions with the currently viewed timeframe
    - adjust <[inventory]> title:<&f><&font[adriftus:missions]><&chr[F808]><&chr[1001]><&chr[F601]><script.parsed_key[data.titles.<[timeframe]>]>
    - define items <list>
    - foreach <[missions]> as:mission:
      # Match item display name and lore to information about the mission
      - define id <player.flag[<[mission]>].get[id]>
      - define name <player.flag[<[mission]>].get[name]>
      - define description <player.flag[<[mission]>].get[description]>
      - define progress <&f>(<&b><player.flag[<[mission]>].get[progress]><&f>/<&f><&b><player.flag[<[mission]>].get[max]>)
      # Mission is not complete
      - if <player.flag[<[mission]>].get[done].not>:
        - define material <script[mission_<[id]>].data_key[icon]>
        - define cmd <script[mission_<[id]>].data_key[cmd]>
      # Mission is complete
      - else:
        - define material paper
        - define cmd 1
      # Build the final item
      - define item <item[<[material]>].with[display_name=<[name]><&sp><[progress]>;lore=<[description].separated_by[<&nl>]>;custom_model_data=<[cmd]>;hides=ALL]>
      # Add item to list
      - define items:->:<[item]>
    - foreach <[items]> as:item:
      - inventory set slot:<[slots].get[<[loop_index]>]> o:<[item]> d:<[inventory]>
    # Add Reset Missions button if weekly/monthly
    #- if <list[weekly|monthly].contains[<[timeframe]>]>:
    #  - inventory set slot:45 o:<item[lime_stained_glass_pane].with[display_name=<&a><&l>Reset<&sp>Missions;lore=<list[<&e>Complete<&sp>all<&sp>missions<&sp>to<&sp>reset]>;flag=timeframe:<[timeframe]>]> d:<[inventory]>
    # Open inventory
    - inventory open d:<[inventory]>

missions_inv_run:
  type: task
  debug: false
  script:
    - run missions_inv_open def:<context.item.flag[timeframe]>

missions_inv_close:
  type: task
  debug: false
  script:
    - inventory close

missions_inv_events:
  type: world
  debug: false
  events:

    on player clicks lime_stained_glass_pane in missions_inv:
      - define timeframe <context.item.flag[timeframe]>
      - define required <script[missions_config].data_key[<[timeframe]>]>
      - define missions <proc[missions_get_timeframe].context[<[timeframe]>]>
      - define completed 0
      # Loop over missions with the currently viewed timeframe
      - foreach <[missions]> as:mission:
        - if <player.flag[<[mission]>].get[done]>:
          - define completed:+:1
      - if <[completed]> == <[required]>:
        - run missions_reset def:<[timeframe]>
        - run missions_generate def:<[timeframe]>
        - narrate "<&a>Your <[timeframe]> missions have been reset."
      - else:
        - narrate "<&c>You must complete your <[timeframe]> missions before you can reset them."
