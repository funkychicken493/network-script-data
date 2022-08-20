mob_spawner_armor_stand_once:
  type: entity
  entity_type: armor_stand
  mechanisms:
    visible: false
    marker: true
  flags:
    on_entity_added: mob_spawner_armor_stand_spawn_mob
    mob_to_spawn: zombie

mob_spawner_armor_stand_spawn_mob:
  type: task
  debug: false
  script:
    - if <context.entity.has_flag[mob_to_spawn]>:
      - spawn <context.entity.flag[mob_to_spawn]> <context.entity.location>

mob_spawner_armor_stand_repeating:
  type: entity
  entity_type: armor_stand
  mechanisms:
    visible: false
    marker: true
  flags:
    on_entity_added: mob_spawner_armor_stand_spawn_mob_repeat
    mob_to_spawn: zombie
    mob_spawn_delay: 8s

mob_spawner_armor_stand_spawn_mob_repeat:
  type: task
  debug: false
  script:
    - while <context.entity.is_spawned> && <context.entity.has_flag[mob_to_spawn]>:
      - if <context.entity.has_flag[entities]> && !<context.flag[entities].is_empty>:
        - flag <context.entity> entities:<context.entity.flag[entities].filter[is_spawned]>
      - if <context.entity.flag[entities]> < 5:
        - spawn <context.entity.flag[mob_to_spawn]> <context.entity.location> save:ent
        - flag <context.entity> entities:<entry[ent].spawned_entity>
      - wait <context.entity.flag[mob_spawn_delay]>
