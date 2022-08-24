basic_lock:
    type: item
    material: lever
    display name: <green>Basic Lock
    mechanisms:
        hides: all
    enchantments:
        - UNBREAKING:1
    flags:
        on_placed: cancel
        right_click_script: lock_apply
        locks:
            level: basic

imprint_key:
    type: item
    material: tripwire_hook
    display name: <&c>Disambiguous Imprint Key
    mechanisms:
        hides: all
    enchantments:
        - UNBREAKING:1

imprint_key_manage_players:
    type: world
    debug: false
    events:
        on player right clicks entity with:item_flagged:locks.location:
            - ratelimit <player> 1t
            - stop if:<context.entity.is_player.not>
            - determine passively cancelled
            - if <context.item.flag[locks.location].flag[locks.allowed].size> >= 27:
                - narrate "<&c>Can't add anyone else to that container! :(" targets:<player>
                - log "<player.name> maxed out perm'd players at <context.location.simple> (<context.location.material.name>)." info file:logs/locks.log
                - stop
            - if <context.item.flag[locks.location].flag[locks.allowed].contains[<context.entity>]||false>:
                - flag <context.item.flag[locks.location]> <context.item.flag[locks.allowed]>:<-:<context.entity>
                - narrate "<green>Removed access from <context.entity.name>." targets:<player>
                - log "<player.name> removed perms of <context.location.simple> (<context.location.material.name>) from <context.entity.name>." info file:logs/locks.log
                - stop
            - flag <context.item.flag[locks.location]> locks.allowed:->:<context.entity>
            - log "<player.name> granted perms of <context.location.simple> (<context.location.material.name>) to <context.entity.name>." info file:logs/locks.log
            - narrate "<green>Granted access to <context.entity.name>." targets:<player>
        on player right clicks block with:item_flagged:locks.location:
            - ratelimit <player> 1t
            - stop if:<context.item.flag[locks.location].equals[<context.location>].not>
            - determine passively cancelled
            - define inv <inventory[lock_permissions].include[<item[air]>]>
            - inventory open d:<[inv]>
            - foreach <context.location.flag[locks.allowed].exclude[<player>]> as:target:
                - give to:<[inv]> "player_head[skull_skin=<[target].skull_skin>;custom_model_data=1;display=<[target].proc[get_player_display_name]>;flag=run_script:lock_remove_access;flag=person:<[target]>;flag=location:<context.location>;lore=<list_single[<white>Left click to remove.]>]"
            - log "<player.name> began editing perms of <context.location.simple> (<context.location.material.name>)." info file:logs/locks.log

lock_remove_access:
    type: task
    debug: false
    script:
        - take item:<context.item> from:<context.inventory>
        - flag <context.item.flag[location]> locks.allowed:<-:<context.item.flag[person]>
        - narrate "<green>Removed access from <context.item.flag[person].name||ERROR>."
        - define ls <context.item.flag[location].round_down>
        - narrate "You got your access removed from <context.item.flag[location].material.name.to_lowercase> at <[ls].x> <[ls].y> <[ls].z>." targets:<context.item.flag[person]> if:<context.item.flag[person].is_online>
        - log "<player.name> removed perms of <context.item.flag[location].simple> (<context.item.flag[location].material.name>) from <context.item.flag[person].name>." info file:logs/locks.log

lock_permissions:
    type: inventory
    inventory: chest
    title: Allowed Players
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

lock_apply:
    type: task
    debug: false
    script:
        - stop if:<player.is_sneaking>
        # If location is a town and the player is not a resident in the town, stop
        - stop if:<context.location.town.residents.contains[<player>].not||false>
        - if <context.location.material.name> == trapped_chest:
            - log "<player.name> was denied a lock and hurt at <context.location.simple> because it was a trapped chest. ROFL." info file:logs/locks.log
            - hurt 5 <player> cause:MAGIC source:<player>
            - playsound <player> sound:entity_ghast_scream
            - stop
        # Only for blocks with an inventory
        - stop if:<context.location.inventory.exists.not>
        # No double chests
        - if <context.location.half.is_in[LEFT|RIGHT]||false>:
            - log "<player.name> was denied a lock at <context.location.simple> because it was a double chest." info file:logs/locks.log
            - narrate "<&c>You cannot apply a lock to a double chest!"
            - playsound <player> sound:entity_villager_no
            - stop
        - determine passively cancelled
        - take item:<context.item> quantity:1 from:<player.inventory>
        - define uuid <util.random_uuid>
        - flag <context.location> locks.level:<context.item.flag[locks.level]||basic>
        - flag <context.location> locks.allowed:<list_single[<player>]>
        - flag <context.location> locks.uuid:<[uuid]>
        - define ls <context.location.round_down>
        - narrate "<context.item.display||<context.item.material.name.to_titlecase||Basic> Lock><&r> applied to <context.location.material.name.to_titlecase> at <[ls].x> <[ls].y> <[ls].z>!"
        - define key "<item[imprint_key].with_single[display_name=<context.location.material.name.to_titlecase> Imprint Key]>"
        - define key "<[key].with[lore=<&f><bold>Location: <[ls].x> <[ls].y> <[ls].z>]>"
        - define key "<[key].with[lore=<[key].lore.include[<&f>Left click another player to grant them access!]>]>"
        - define key "<[key].with[lore=<[key].lore.include[<&f>Right click the container to manage who can access it.]>]>"
        - define key <[key].with[lore=<[key].lore.include[<empty>]>]>
        - define key "<[key].with[lore=<[key].lore.include[<&f><underline>You do not need this key to open the container.]>]>"
        - define key <[key].with_flag[locks.location:<context.location>]>
        - define key <[key].with_flag[locks.original_owner:<player>]>
        - define key <[key].with_flag[locks.uuid:<[uuid]>]>
        - give <[key]> quantity:1 to:<player> slot:<player.held_item_slot>
