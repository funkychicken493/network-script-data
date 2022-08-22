generate_item:
    type: procedure
    definitions: input
    script:

    - if <[input].object_type> != Map:
        - determine ERROR_NOT_MAP
    - else if <[input].get[base].exists.not>:
        - determine ERROR_BASE_NOT_FOUND
    - define base <[input].get[base]>
    - define result <[base].as[item]>

    - define random_name <[input].get[random_name].if_null[<list[]>]>
    - define random_name_formatted <empty>
    - foreach <[random_name]> as:name_list:
        - define random_name_formatted "<[random_name_formatted]> <[name_list].random>"
    - define random_color <[input].get[random_color]||<&f>>
    - define random_name_formatted <[random_color]><[random_name_formatted]>
    - define result <[result].with[display=<[random_name_formatted]>]>

    - define random_enchants <[input].get[random_enchants].if_null[<list[]>]>
    #map:
    #   5:
    #       SHARPNESS: 1-5
    #       LOOTING: 1-3
    #   10:
    #       KNOCKBACK: 1-3
    #
    - define enchants <map[]>
    - foreach <[random_enchants]> as:chance:
        - foreach <[random_enchants].get[<[chance]>]> as:enchant:
            - if <util.random_chance[<[chance]>]>:
                - define level_min <[random_enchants].get[<[chance]>].get[<[enchant]>].before[-]>
                - define level_max <[random_enchants].get[<[chance]>].get[<[enchant]>].after[-]>
                - define level <util.random.int[<[level_min]>].to[<[level_max]>]>
                - define enchants <[enchants].default[<[enchant]>].as[<[level]>]>
    - define result <[result].with[enchantments=<[enchants]>]>

    - define random_lore <[input].get[random_lore].if_null[<list[]>]>

    - determine <[result]>
