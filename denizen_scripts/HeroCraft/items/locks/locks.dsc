cancel_dummy:
    type: task
    debug: false
    script:
        - determine cancelled

basic_lock:
    type: item
    material: lever
    display name: <green>Basic Lock
    mechanisms:
        hides: all
    enchantments:
        - UNBREAKING:1
    flags:
        on_placed: cancel_dummy
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
    flags:
        left_click_script: imprint_key_left_click

imprint_key_left_click:
    type: task
    debug: false
    script:
        - stop if:<context.item.has_flag[locks.location].not>
        - define target <player.eye_location.ray_trace[ignore=<player>;entities=player].find_players_within[1].exclude[<player>].first>

lock_apply:
    type: task
    debug: false
    script:
        - stop if:<player.is_sneaking>
        # If location is a town and the player is not a resident in the town, stop
        - stop if:<context.location.town.residents.contains[<player>].not||false>
        # Only for blocks with an inventory
        - stop if:<context.location.inventory.exists.not>
        # No double chests
        - if <context.location.half.is_in[LEFT|RIGHT]||false>:
            - narrate "<&c>You cannot apply a lock to a double chest!"
            - playsound <player> sound:entity_villager_no
            - stop
        - determine passively cancelled
        - take item:<context.item> quantity:1 from:<player.inventory>
        - flag <context.location> locks.level:<context.item.flag[locks.level]||basic>
        - flag <context.location> locks.allowed:<list_single[<player>]>
        - define ls <context.location.round_down>
        - narrate "<context.item.display||<context.item.material.name.to_titlecase> Lock><&r> applied to <context.location.material.name.to_titlecase> at <[ls].x> <[ls].y> <[ls].z>!"
        - define key "<item[imprint_key].with_single[display_name=<context.location.material.name.to_titlecase> Imprint Key]>"
        - define key "<[key].with[lore=<&f><bold>Location: <[ls].x> <[ls].y> <[ls].z>]>"
        - define key "<[key].with[lore=<[key].lore.include[<&f>Left click another player to grant them access!]>]>"
        - define key "<[key].with[lore=<[key].lore.include[<&f>Right click another player to remove their access!]>]>"
        - define key <[key].with[lore=<[key].lore.include[<empty>]>]>
        - define key "<[key].with[lore=<[key].lore.include[<&f><underline>You do not need this key to open the container.]>]>"
        - define key <[key].with_flag[locks.location:<context.location>]>
        - define key <[key].with_flag[locks.original_owner:<player>]>
        - give <[key]> quantity:1 to:<player> slot:<player.held_item_slot>
