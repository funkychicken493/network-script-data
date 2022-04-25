error_response:
  type: task
  debug: false
  definitions: data
  script:
    - define development_guild <discord_group[a_bot,631199819817549825]>
    - define embed <discord_embed>

    # check if channel exists
    - if !<[data.server].advanced_matches_text[<[development_guild].channels.parse[name]>]>:
      - ~discordcreatechannel id:a_bot group:<[development_guild]> name:<[data.server]> "description:Error reporting for <[data.server]>" type:text category:634752968759050270 save:new_channel
      - define channel <entry[new_channel].channel>
    - else:
      - define channel <[development_guild].channel[<[data.server]>]>

    - if <[channel].active_threads.is_empty>:
      # || <[channel].active_threads>
      - ~discordcreatethread id:a_bot name:<util.time_now.format[MMMM-dd-u]> parent:<[channel]> save:new_thread
      - define thread <entry[new_thread].created_thread>
    - else:
      - define thread <[channel].active_threads.highest[id]>

    - define embed_data.color 0,254,255
        #description: "**`[<[script_data].get[name]>]` | `[<[script_data].get[file].after_last[/].if_null[bork]>]` Script Errors**<&co><n><[errors].keys.parse_tag[:warning:**`<[parse_value]>`**<&co><n><&gt> <[errors].get[<[parse_value]>].parse[replace[`].with[<&sq>].proc[error_formatter]].separated_by[<n><&gt> ]>].separated_by[<n><n>].strip_color><n><n>**File Location**: `/<[script_data].get[file].after[web]>`" 

    - if !<[data.rate_limited].exists>:
      - define embed_data "<[embed_data].with[footer].as[Script Error Count (*/hr)<&co> <[data.error_rate]>]>"
    - else:
      - define embed_data "<[embed_data].with[footer].as[<&lb>Rate-limited<&rb> Script error count (*/hr)<&co> <[data.error_rate]>]>"
      - define embed_data <[embed_data].with[footer_icon].as[https://cdn.discordapp.com/emojis/901634983867842610.gif?size=56&quality=lossless]>

    - if <[data.player_data].exists>:
      - define embed_data.author_name "Player Attached<&co> <[data.player_data.name]>"
      - define embed_data.author_icon_url https://crafatar.com/avatars/<[data.player_data.uuid].replace[-]>
      - define embed "<[embed].add_inline_field[player name].value[`<[data.player_data.name]>`]>"
      - define embed "<[embed].add_inline_field[player uuid].value[`<[data.player_data.uuid]>`]>"

    - if <[data.content].exists>:
    #| map@[error_script=map@[Line_82=li@intentional error|]]
      - define description <list>
      - foreach <[data.content]> key:script as:content:
        - define description "<[description].include_single[**`<[script]>`** | **`<&lb><[data.script_data.file]><&rb>`** script errors<&co>]>"
        - foreach <[content]> key:line as:message:
          - define description "<[description].include_single[<&co>warning<&co>`Line <[line]>`<&co>]>"
          - define description <[description].include_single[<[message].parse[strip_color.replace[`].with[<&sq>].proc[error_formatter]].separated_by[<n>]>]>
          #
      - define embed_data.description <[description].separated_by[<n>]>
    - else:
      - define embed_data.description "No context provided"

    - define embed <[embed].with_map[<[embed_data]>]>
    - define embed <[embed].add_field[Definitions<&co>].value[```yml<n><[data.definition_map].proc[object_formatting].strip_color.replace[`].with[<&sq>]><n>```]> if:!<[data.definition_map].is_empty>


    - ~discordmessage id:a_bot channel:<[thread]> <[embed]>

error_formatter:
  type: procedure
  debug: false
  definitions: text
  script:
    - define text <[text].strip_color>

    # % ██ [ ie: Debug.echoError(context, "Tag " + tagStr + " is invalid!"); ] ██
    - if "<[text].starts_with[Tag <&lt>]>" && "<[text].ends_with[<&gt> is invalid!]>":
      - determine "Tag `<[text].after[Tag ].before_last[ is invalid!]>` returned invalid."

    # % ██ [ ie: Debug.echoError(event.getScriptEntry(), "Unfilled or unrecognized sub-tag(s) '<R>" + attribute.unfilledString() + "<W>' for tag <LG><" + attribute.origin + "<LG>><W>!"); ] ██
    - else if "<[text].starts_with[Unfilled or unrecognized sub-tag(s) ']>":
      - define string "<[text].after[sub-tag(s) '].before_last[' for tag <&lt>]>"
      - determine "Unfilled or borked sub-tag(s) `<[string]>` <[text].after[<[string]>].before[' for tag <&lt>]> for tag<&co> `<&lt><[text].after[<[string]>].after[<&lt>].before_last[!]>`."

    # % ██ [ ie: Debug.echoError(event.getScriptEntry(), "The returned value from initial tag fragment '<LG>" + attribute.filledString() + "<W>' was: '<LG>" + attribute.lastValid.debuggable() + "<W>'."); ] ██
    - else if "<[text].starts_with[The returned value from initial tag fragment]>":
      - define tag "<[text].after[fragment '].before[' was<&co> ']>"
      - define parse_value "<[text].after_last[' was<&co> '].before_last['.]>"
      - determine "The returned value from initial tag fragment<&co> `<&lt><[tag]><&gt>` returned<&co> `<[parse_value]>`"

    # % ██ [ ie: Debug.echoError(context, "'ObjectTag' notation is for documentation purposes, and not to be used literally." ] ██
    - else if "<[text].starts_with['ObjectTag' notation is for documentation purposes]>":
      - determine "<&lt><&co>a<&co>901634983867842610<&gt> **<[text]>**"
    # % ██ [ ie: Debug.echoError(event.getScriptEntry(), "Almost matched but failed (missing [context] parameter?): " + almost); ] ██
    # % ██ [ ie: Debug.echoError(event.getScriptEntry(), "Almost matched but failed (possibly bad input?): " + almost); ] ██

    # % ██ [ ie: Debug.echoError(context, "(Initial detection) Tag processing failed: " + ex.getMessage()); ] ██

    # % ██ [ ie: attribute.echoError("Tag-base '" + base + "' returned null."); ] ██

    # % ██ [ ie: Debug.echoError("No tag-base handler for '" + event.getName() + "'."); ] ██
    # % ██ [ ie: Debug.echoError("Tag filling was interrupted!"); ] ██
    # % ██ [ ie: Debug.echoError("Tag filling timed out!"); ] ██

    - else:
      - determine <[text]>
