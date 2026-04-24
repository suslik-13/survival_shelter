# Dev Documentation

**Note**: Functions that take `pl_name` as the first argument can also be called using the shorter method `pl_name:[function_name](...)` instead of `skills.[function_name](pl_name, ...)`.

## Table of Contents
1. [Registering a Prefix](#1-registering-a-prefix)
2. [Registering a Skill](#2-registering-a-skill)
    - [2.1 Dynamic properties](#21-dynamic-properties)
3. [Registering a State](#3-registering-a-state)
4. [Skills Based on Other Skills](#4-skills-based-on-other-skills)
5. [Skill Examples](#5-skill-examples)
6. [State Examples](#6-state-examples)
7. [Assigning a Skill](#7-assigning-a-skill)
8. [Using a Skill](#8-using-a-skill)
9. [Utility Functions](#9-utility-functions)
   - [9.1. Skills Functions](#91-skills-functions)
   - [9.2. Player Functions](#92-player-functions)
   - [9.3. Entities Functions](#93-entities-functions)

---

## 1. Registering a Prefix

To register a prefix configuration, you can use the `skills.register_prefix_config(prefix, config)` function. The `prefix` argument is a unique prefix for your skills preceding your skill name (e.g. `myprefix:myskill`). The `config` argument is a definition table that can contain the following properties:
- **`base_layers`** (list of skill names): Optional. A list of base layers that will be applied to all skills registered with this prefix. Layers are special skills that are meant to be inherited by other skills and cannot be unlocked by players - although you can also use normal skills as layers.

Prefix configurations are optional but recommended to organize your skills. They must be declared before any skill or layer that uses them. Also, layers or base skills must be declared before skills using them.

Possible prefix patterns include:
- Simple mod organization: `mymod:skillname`
- Skill type organization: `mymod_passive:skillname`, `mymod_active:skillname`
- Class-based organization: `mymod_warrior:skillname`, `mymod_mage:skillname`
- ...etc

Each prefix can have its own base layers, allowing you to share common functionality between related skills. For example, all warrior skills could inherit combat-related layers, while mage skills inherit -related layers.

## 2. Registering a Skill

To register a skill, you can use the `skills.register_skill(internal_name, def)` function. The `internal_name` argument is the name you will use to refer to the skill in your code and should be formatted as `"unique_prefix:skill_name"` (where the unique prefix could be the name of your mod, for example). The `def` argument is a definition table that contains various properties that define the behavior and appearance of the skill and can contain the following properties:
- **`name`** (string): The skill's name.
- **`description`** (string): The skill's description.
- **`cooldown`** (number): The minimum amount of time (in seconds) to wait before casting the skill again.
- **`cast(self, ...)`**: Contains the skill's logic. It returns `false` if the player is offline or the cooldown has not finished. The `self` parameter is a table containing [properties of the skill](#8-using-a-skill), including `__dtime` (the time in seconds since the last cast call, useful for looped time-dependent skills).
- **`can_cast(self, ...)`**: Returns `true` by default. Must return a boolean indicating whether the skill's `cast` logic can execute *at this moment*. For looped skills, this is checked *before every iteration*. If it returns `false`, the current cast is skipped, and **the loop is stopped**.
- **`can_start(self, ...)`**: Returns `true` by default. Must return a boolean indicating whether a skill can be *started* (for looped) or *cast* (for non-looped) using `skills.start` or `skills.cast`. This is checked only once per use. If it returns `false`, the skill will not start or cast.
- **`loop_params`** (table): If this is defined, the skill will be looped. To cast a looped skill, you need to use the `start(...)` function instead of `cast`. The `start` function simply calls the `cast` function at a rate of `cast_rate` seconds (if `cast_rate` is defined, otherwise the skill's logic will never be executed).
  - **`cast_rate`** (number): The rate at which the skill will be cast (in seconds). Assigning 0 will loop it as fast as possible.
  - **`duration`** (number): The amount of time (in seconds) after which the skill will stop. The `core.after` job that will stop it is stored in `self.__stop_job`.
- **`stop_on_death`** (boolean): `true` by default. If set to `true`, the skill will automatically stop when the player dies.
- **`passive`** (boolean): `false` by default. If `true`, the skill will start automatically once the player has unlocked it.
  - It can be stopped by calling `stop()` or `disable()` and restarted by calling `start()` or `enable()`.
- **`blocks_other_skills`** (table, optional): Defines how this skill blocks other skills while active. The table format is:
  - **`mode`** (string): The blocking mode. Can be:
    - `"all"`: Block all other skills
    - `"whitelist"`: Only allow skills in the `allowed` list
    - `"blacklist"`: Block only skills in the `blocked` list
  - **`allowed`** (table, optional): List of skill prefixes or full skill names that are allowed when mode is `"whitelist"`. For example: `{"mymod", "othermod:specific_skill"}`
  - **`blocked`** (table, optional): List of skill prefixes or full skill names that are blocked when mode is `"blacklist"`. For example: `{"enemymod", "somemod:dangerous_skill"}`
- **`blocks_other_states`** (table, optional): Defines how this skill/state blocks other states while active. Uses the same structure as `blocks_other_skills` but targets states instead of skills.
- **`monoids`** (table): Allows skills to modify global player state through [monoids](https://content.luanti.org/packages/Byakuren/player_monoids/). Define a table where each key is a unique name for a monoid effect, OR the special key `checkout_branch_while_active`.
    - **`checkout_branch_while_active`** (boolean, optional): If `true`, when this skill becomes active, the system will automatically checkout monoids branches, making them the player's active branches. This property affects the *active* branches for the player globally.
    - For monoid effects, each key is a unique name and value is a table containing:
        - **`branch`** (string, optional): The name of the branch on which to apply/remove the monoid change. The mod will create it if it doesn't exist. If not specified, it defaults to `"main"`. 
        - **`ref`** (string): A string path representing the global variable name of the monoid object (e.g., `"player_monoids.jump"`). This allows the system to look up the correct, live monoid object when the skill is applied.
        - **`value`**: the modificator value to apply, structured however the said monoid wants it.

    Example: (using `player_monoids`)
    ```lua
    monoids = {
        checkout_branch_while_active = true,
        jump_boost_main = {
            ref = "player_monoids.jump",
            value = 2  -- Double jump height on the main branch
        },
        speed_on_sprint_branch = {
            branch = "sprint_mode", -- Target a specific branch
            ref = "player_monoids.speed",
            value = 1.5  -- 50% speed boost on the "sprint_mode" branch
        }
    }
    ```
    Example: (using a hypothetical 3rd party monoid `lighting_monoid`)
    ```lua
    monoids = {
        dark_saturation = {
            ref  = "lighting_monoid",
            value = {
                saturation = 2,
                exposure = {
                    luminance_min = 2
                }
            }
        }
    }
    ```
    Requires `player_monoids` mod (or the relevant mod for the specified monoid) to be installed and loaded. Changes are automatically applied on skill start and removed on skill stop. **Beware**, monoids are not meant to be used alongside mods that modify the player state manually: manual modifications will be overwritten.
- **`physics`** (table): This table can contain any of the physics properties in Luanti's documentation and must contain an `operation` field having one of the following values: `add`, `sub`, `multiply` (default), `divide` (e.g., `{operation = "add", speed = 1}` will add 1 to the player's speed). Unlike the monoids approach, when the effect ends, the physics properties will simply be mathematically reverted, meaning that if the player's original physics values were not the default ones, they will be restored correctly, without overriding previous manual modifications. This may be a better approach when interacting with mods that don't use monoids.
- **`sounds`** (table): Sounds can be played at different points in a skill's lifecycle by specifying them in one of the following event subtables:
    - **`cast`**: Played every time the `cast` function is called.
    - **`start`**: Played when the skill starts.
    - **`stop`**: Played when the skill stops.
    - **`bgm`**: Looping sound(s), played while the skill is being used.

    Each event subtable can contain a sound or a list of sounds. Every sound is a table defined as follows:
    - **`name`**: The sound's name.
    - **Optional Parameters**:
        - **`to_player`**: `false` by default. If set to `true`, the value will become the player's name.
        - **`object`**: `true` by default. If set to `true`, the value will become the player's `ObjectRef`.
        - **`exclude_player`**: `false` by default. If set to `true`, the value will exclude the player's `ObjectRef`.
        - **`random_pitch`**: `{min, max}`. A custom property that will choose a random pitch between `min` and `max` every time the sound is played.
        - **`ephemeral`**: `false` by default. Whether the sound is ephemeral. Useful for frequently reproduced short-lived sounds.
        - **Other Sound Parameters/SoundSpec Properties**: You can include additional sound parameters as needed.

    You can also pass a list of sounds; the mod will play them all for the specified event.
- **`hud`** (`{{name = "hud_name", standard hud definition params...}, ...}`): A list of HUD elements that appear while the skill is being used. They are stored in the `self.__hud` table (`{"hud_name" = hud_id}`).
- **`attachments`** (table):
  - **`particles`** (`{ParticleSpawner1, ...}`): A list of particle spawners that are created when the skill starts and destroyed when it stops. They're stored in the `self.__particles` table (`{[i] = handle}`) and are always attached to the player—useful if you want to have something like a particle trail.
  - **`entities`** (`{Entity1, ...}`): A list of entities that are attached to the player as long as the skill is being used. The entities are tables, declared this way:
    - **`pos`**: The player-relative position.
    - **`name`**: The name of the entity.
    - **Optional Parameters**:
      - **`bone`**: The bone to which the entity is attached.
      - **`rotation`**: Rotation of the entity.
      - **`forced_visible`**: Whether the entity is forcibly visible or not.
    - Their behavior is equivalent to [registering the entity as expirable, adding it as soon as the skill starts, and attaching it to the player](#93-entities-functions).
- **`celestial_vault`** (table): Changes the player's view of the sky while the skill is active. Can contain:
  - **`sky`**: Changes the sky appearance
  - **`moon`**: Changes the moon appearance
  - **`sun`**: Changes the sun appearance
  - **`stars`**: Changes the stars appearance
  - **`clouds`**: Changes the clouds appearance
  Each property takes the same parameters as their corresponding Luanti set_* functions (set_sky, set_moon, etc). The original values are automatically restored when the skill stops.
- **`on_start(self, ...)`**: this is called when `start` is called and the vararg `...` is the same value you pass to start;
- **`on_stop(self)`**: this is called when `stop` is called;
- **`data`** (table): this allows you to define custom properties for each player. These properties are stored in the mod storage and will not be reset when the server shuts down unless you change the type of one of them in the registration table (apart from userdata and functions). Be careful to avoid using names for these properties that start with a double underscore (__). Also, userdata and functions can't be saved here;
- **`... any other properties you may need`**: you can also define your own properties, just make sure that they don't exist already and remember that these are shared by all players. For custom user-defined parameters, use the `_param` naming convention (e.g., `_cost`, `_fireball_damage`). Avoid using names that start with a double underscore (`__`), as these are reserved for internal system fields.

### 2.1 Dynamic Properties
When defining a skill, you can make certain properties have dynamic values that update based on the current state. Dynamic values can be used in the following tables of your skill definition:

- `loop_params`
- `sounds`
- `hud`
- `attachments`
- `physics`
- `celestial_vault`

**Dynamic values can be applied to:**
1. **Individual properties within tables**: e.g., `hud[1].text = skills.dynamic_value(...)`
2. **Entire property tables**: e.g., `hud = skills.dynamic_value(...)` - the function should return the entire table

To create a dynamic value, use `skills.dynamic_value(function(skill, ...) end)`. The function receives the current skill as the first argument, followed by the varargs that were passed to `start()` or `cast()`, and should return the desired value.

Example:
```lua
skills.register_skill("example:show_hp", {
    name = "Show HP",
    loop_params = {
        cast_rate = 0.25
    },
    hud = {{
        name = "hp",
        hud_elem_type = "text",
        position = {x = 0.5, y = 0.5},
        scale = {x = 100, y = 100},
        text = skills.dynamic_value(function(skill)
            return "HP: " .. skill.player:get_hp()
        end),
    }},
    redraw_hud = function(self)
        --                                                        vv
        self.player:hud_change(self.__hud.hp, "text", self.hud[1].text)
    end,
    cast = function(self)
        self:redraw_hud()
    end,
})

-- Example using varargs in dynamic values:
skills.register_skill("example:target_info", {
    name = "Target Info",
    hud = {{
        name = "target",
        hud_elem_type = "text",
        position = {x = 0.5, y = 0.3},
        scale = {x = 100, y = 100},
        text = skills.dynamic_value(function(skill, target_name)
            return target_name and ("Target: " .. target_name) or "No Target"
        end),
    }},
    cast = function(self, target_name)
        -- This skill receives a target name and displays it
    end,
})

-- Usage: skills.start(player_skill, "enemy_player_name")
```

**Example with entire property being dynamic:**
```lua
skills.register_skill("example:dynamic_layout", {
    name = "Dynamic Layout",
    hud = skills.dynamic_value(function(skill, mode)
        if mode == "combat" then
            return {
                {name = "health", type = "text", text = "HP: " .. skill.player:get_hp(), position = {x = 0.1, y = 0.1}},
                {name = "combat_timer", type = "text", text = "Combat!", position = {x = 0.9, y = 0.1}}
            }
        else
            return {
                {name = "peaceful", type = "text", text = "Peaceful mode", position = {x = 0.5, y = 0.5}}
            }
        end
    end),
    cast = function(self, mode)
        -- The entire HUD layout changes based on the mode argument
    end,
})

-- Usage: skills.start(player_skill, "combat") or skills.start(player_skill, "peaceful")
```

Notice how you can access the dynamic value by simply accessing the corresponding table field.


## 3. Registering a State

States are looped effects that can be applied to players by external events (other skills, game conditions, etc.) Unlike skills, states are not meant to be actively used by players.

To register a state, you can use the `skills.register_state(internal_name, def)` function. The `internal_name` argument follows the same format as skills (`"unique_prefix:state_name"`). The `def` argument is a definition table that contains most of the same properties as skills, with key differences:
- **`is_state`** (boolean): This is automatically set to `true` for states and distinguishes them from regular skills and layers.
- **`data`** (table): Unlike skills, states should not use persistent `data` properties since states are ephemeral - they are completely removed from players and memory when they stop, and reset to default values when re-added.

### States Based on Other States/Skills

Just like skills, you can create states based on other states, skills, or layers using:
- **`skills.register_state_based_on({"mod:base_state_1", "mod:base_skill_2", ...}, "mod:new_state_name", def)`**

This works exactly like `register_skill_based_on` but ensures the result is always marked as a state. You can base a state on:
- Other states
- Skills (inheriting their behavior but making them passive)
- Layers
- Any combination of the above

The key differences are:
- States don't appear in `skills.get_registered_skills()` or `skills.get_registered_layers()` - they have their own `skills.get_registered_states()` function
- Players don't need to unlock states before they can be applied
- States are applied using `skills.add_state(pl_name, state_name, ...)` (where `...` are the varargs passed to `on_start` and `cast`) and removed with `skills.remove_state(pl_name, state_name)`
- States follow the same lifecycle as skills (calling `on_start`, `on_stop`, handling `loop_params`, etc.)


## 4. Skills Based on Other Skills
[🌐 Visual representation.](https://i.imgur.com/BaZxFsG.jpeg)

A skill based on another skill is a modified version that retains some of the original skill's properties, while keeping others the same. The original skills can be normal ones or layers. A layer is nothing more than a special type of skill that players can't unlock, and that won't be returned by `get_registered_skills()`. You can register one by using:
- **`skills.register_layer(internal_name, def)`**: it works exactly like register_skill.

And then register the skill using:
- **`skills.register_skill_based_on({"mod:base_skill_1", "mod:base_skill_2", ...}, "mod:new_skill_name", def)`**.

The def table of the second function allows you to override any properties of the original skill(s) that you want to change in the new skill (any non-specified properties will be inherited from the original(s)). If you want to override one of the properties with a `nil` value just set it to `"@@nil"`.

Also, when specifying more then one base skill, their functions will be joined together and the first parameter will always be `self`. The same will happen if you define a new function in the def table (e.g. if you're creating a "s3" skill based on "s1" and "s2", and you defined `cast()` in each one of them, the joined cast function will have the following structure: `s1_cast(self, ...); s2_cast(same); s3_cast(same)`). If any of those functions return false, the following ones won't be called (this applies for every function in the skill: they will all be merged, even custom ones!).

Beware, when you combine skills it's up to you to make sure they can work together, so make sure they have the same cast_rate, don't overwrite each other's parameters, etc.

This type of skill can be useful to modularize behavior: a layer can ge checks common to certain types of skills, such as if the players has enough mana, if they can cast an ultimate, etc. It can also be useful to create reusable and extendible skill templates.

## 5. Skill Examples
Here are some examples of skills
<details>
<summary>click to expand...</summary>

#### Example 1: Simple Counter Skill

```lua
skills.register_skill("example_mod:counter", {
    name = "Counter",
    description = "Counts. You can use it every 2 seconds.",
    sounds = {
        cast = {name = "ding", pitch = 2}
    },
    cooldown = 2,
    data = {
        counter = 0
    },
    cast = function(self)
        self.data.counter = self.data.counter + 1
        print(self.pl_name .. " is counting: " .. self.data.counter)
    end
})
```

#### Example 2: Heal Over Time

```lua
skills.register_skill("example_mod:heal_over_time", {
    name = "Heal Over Time",
    description = "Restores a heart every 3 seconds for 30 seconds.",
    loop_params = {
        cast_rate = 3,
        duration = 30
    },
    sounds = {
        cast = {name = "heart_added"},
        bgm = {name = "angelic_music"}
    },
    cast = function(self)
        local player = self.player
        player:set_hp(player:get_hp() + 2)
    end
})
```

#### Example 3: Boost Physics

```lua
skills.register_skill("example_mod:boost_physics", {
    name = "Boost Physics",
    description = "Multiplies the speed and gravity by 1.5 for 3 seconds.",
    loop_params = {
        duration = 3
    },
    sounds = {
        start = {name = "speed_up"},
        stop = {name = "speed_down"}
    },
    physics = {
        operation = "multiply",
        speed = 1.5,
        gravity = 1.5
    }
})
```

#### Example 4: Set Speed (Passive Skill)

```lua
skills.register_skill("example_mod:set_speed", {
    name = "Set Speed",
    description = "Sets speed to 3.",
    passive = true,
    data = {
        original_speed = {}
    },
    on_start = function(self)
        local player = self.player
        self.data.original_speed = player:get_physics_override().speed

        player:set_physics_override({speed = 3})
    end,
    on_stop = function(self)
        self.player:set_physics_override({speed = self.data.original_speed})
    end
})
```

#### Example 5: Iron Skin

```lua
skills.register_skill("example_mod:iron_skin", {
    name = "Iron Skin",
    description = "Take half the damage for 6 seconds.",
    cooldown = 20,
    loop_params = {
        duration = 6,
    },
    sounds = {
        start = {name = "iron_skin_on", max_hear_distance = 6},
        stop = {name = "iron_skin_off", max_hear_distance = 6},
    },
    attachments = {
        entities = {{
            name = "example_mod:iron_skin",
            pos = {x = 0, y = 22, z = 0}
        }}
    },
    hud = {{
        name = "shield",
        hud_elem_type = "image",
        text = "hud_iron_skin.png",
        scale = {x = 3, y = 3},
        position = {x = 0.5, y = 0.82},
    }},
})
```

#### Example 6: Monoids Usage (Player Monoids)

```lua
skills.register_skill("example_mod:super_jump", {
    name = "Super Jump",
    description = "Triple your jump height and 50% speed boost for 10 seconds.",
    cooldown = 30,
    loop_params = {
        duration = 10
    },
    monoids = {
        checkout_branch_while_active = true,
        jump_boost = {
            ref = "player_monoids.jump",
            value = 3  -- Triple jump height
        },
        speed_boost = {
            branch = "enhanced_movement",
            ref = "player_monoids.speed", 
            value = 1.5  -- 50% speed boost
        }
    },
    sounds = {
        start = {name = "power_up", pitch = 1.2},
        stop = {name = "power_down", pitch = 0.8}
    }
})
```

#### Example 7: Celestial Vault and Night Vision Lighting

```lua
skills.register_skill("example_mod:night_vision", {
    name = "Night Vision",
    description = "See clearly in the dark with enhanced lighting and starry night sky.",
    loop_params = {
        duration = 15
    },
    celestial_vault = {
        sky = {
            type = "skybox",
            textures = {
                "night_sky_top.png",    -- Y+ (top)
                "night_sky_bottom.png", -- Y- (bottom) 
                "night_sky_east.png",   -- X+ (east)
                "night_sky_west.png",   -- X- (west)
                "night_sky_south.png",  -- Z- (south)
                "night_sky_north.png"   -- Z+ (north)
            },
            clouds = false
        },
        stars = {
            visible = true,
            count = 2000,
            star_color = "#ffffcc99"  -- Warm white with transparency
        },
        moon = {
            visible = true,
            texture = "bright_moon.png",
            scale = 2
        },
    },
    monoids = {
        night_vision_lighting = {
            ref = "lighting_monoid",
            value = {
                exposure = {
                    luminance_min = 0.8,      -- added
                    luminance_max = 0.3,      -- added
                    speed_dark_bright = 2.0,  -- multiplied
                    speed_bright_dark = 0.5   -- multiplied
                },
                saturation = 1.2,
                shadows = {
                    intensity = 0.3 
                }
            }
        }
    },
    sounds = {
        start = {name = "mystical_activate"},
        bgm = {name = "night_ambiance", volume = 0.3}
    }
})
```

#### Example 8: Skill Blocking System

```lua
skills.register_skill("example_mod:meditation", {
    name = "Meditation",
    description = "Slowly regenerate health but cannot use combat skills.",
    loop_params = {
        cast_rate = 2,
        duration = 20
    },
    blocks_other_skills = {
        mode = "blacklist",
        --          v my prefix    v example external skill
        blocked = { "combat",     "external_mod:fireball"}
    },
    cast = function(self)
        local player = self.player
        local max_hp = player:get_properties().hp_max
        local current_hp = player:get_hp()
        
        if current_hp < max_hp then
            player:set_hp(math.min(current_hp + 1, max_hp))
        end
    end,
    sounds = {
        cast = {name = "healing_pulse", volume = 0.5}
    }
})
```

#### Example 9: Advanced Dynamic Values and Particles

```lua
skills.register_skill("example_mod:mana_shield", {
    name = "Mana Shield",
    description = "Shield strength depends on current mana level.",
    loop_params = {
        cast_rate = 0.1,
        duration = skills.dynamic_value(function(skill)
            -- Duration based on player's current mana (with a hypotethical global get_mana())
            return math.max(5, skill.pl_name:get_mana() / 10)
        end)
    },
    hud = {{
        name = "shield_bar",
        hud_elem_type = "statbar",
        position = {x = 0.5, y = 0.9},
        size = {x = 24, y = 24},
        text = "shield_icon.png",
        number = skills.dynamic_value(function(skill)
            return skill.data.shield_strength
        end),
        item = 20
    }},
    _mana_consumption = 1,
    _shield_strength = 0,

    cast = function(self)
        self.pl_name:decrease_mana(self._mana_consumption)
        self._shield_strength = math.floor(self.pl_name:get_mana() / 10)
        
        -- Update HUD
        self.player:hud_change(self.__hud.shield_bar, "number", self.hud[1].number)
    end
})
```

#### Example 10: Conditional Skills (can_cast/can_start)

```lua
skills.register_skill("example_mod:underwater_breathing", {
    name = "Underwater Breathing",
    description = "Breathe underwater, but only works when submerged.",
    loop_params = {
        cast_rate = 1,
        duration = 30
    },
    _is_underwater = function(self)
        local player = self.player
        local pos = player:get_pos()
        local node = core.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
        return core.get_item_group(node.name, "water") > 0
    end,
    can_start = function(self)
        return self:_is_underwater()
    end,
    can_cast = function(self)
        return self:_is_underwater()
    end,
    cast = function(self)
        local player = self.player
        player:set_breath(player:get_properties().breath_max)
    end,
    sounds = {
        start = {name = "bubbles_start"},
        cast = {name = "bubble_pop", volume = 0.3},
        stop = {name = "surface_gasp"}
    }
})
```

#### Example 11: Multiple Sounds and Complex Audio

```lua
skills.register_skill("example_mod:thunderstorm", {
    name = "Thunderstorm",
    description = "Call down lightning with realistic thunder sounds.",
    cooldown = 45,
    loop_params = {
        cast_rate = 3,
        duration = 15
    },
    sounds = {
        start = {
            {name = "wind_buildup", volume = 0.8},
            {name = "thunder_distant", pitch = 0.9}
        },
        cast = {
            {name = "lightning_crack", random_pitch = {0.8, 1.2}},
            {name = "thunder_boom", random_pitch = {0.7, 1.1}, max_hear_distance = 50}
        },
        bgm = {
            {name = "rain_heavy", volume = 0.6, loop = true},
            {name = "wind_howling", volume = 0.4, loop = true}
        },
        stop = {name = "thunder_fade", volume = 0.5}
    },
    cast = function(self)
        -- Lightning strike logic here...
    end
})
```

#### Example 12: Layers and Skill Inheritance

```lua
-- Register the mana system layer
skills.register_layer("mage:mana_check", {
    _mana_cost = 10,
    
    can_start = function(self)
        return self.pl_name:get_mana() >= self._mana_cost
    end,
    on_start = function(self)
        self.pl_name:decrease_mana(self._mana_cost)
    end
})

-- Register spell components layer
skills.register_layer("mage:spell_components", {
    sounds = {
        start = {name = "spell_chant", volume = 0.7}
    },
    attachments = {
        particles = {{
            amount = 20,
            time = 1,
            texture = "magic_sparkle.png",
            minpos = {x = -0.5, y = 0, z = -0.5},
            maxpos = {x = 0.5, y = 2, z = 0.5}
        }}
    }
})

-- Register a prefix with base layers
skills.register_prefix_config("mage", {
    base_layers = {"mage:mana_check", "mage:spell_components"}
})

-- Now register skills that inherit from these layers
skills.register_skill("mage:fireball", {
    name = "Fireball",
    description = "Launch a magical fireball (costs 30 mana).",
    cooldown = 5,
    _mana_cost = 30, -- overrides inherited value
    _fireball_size = 3,
    _fireball_damage = 5,

    cast = function(self)
        -- Fireball logic here - mana cost already handled by layer
    end,
})

-- Create a skill based on existing skills
skills.register_skill_based_on({"mage:fireball"}, "mage:greater_fireball", {
    name = "Greater Fireball",
    description = "A more powerful fireball (costs 40 mana).",
    cooldown = 8,
    _mana_cost = 40,
    _fireball_size = 5,
    _fireball_damage = 8

    -- cast will be inherited
})
```
</details>


## 6. State Examples
Here are some examples of states
<details>
<summary>click to expand...</summary>

#### Example 1: Frozen State

```lua
skills.register_state("status:frozen", {
    name = "Frozen",
    description = "You are frozen and cannot move.",
    loop_params = {
        duration = 5
    },
    physics = {
        operation = "multiply",
        speed = 0
    },
    sounds = {
        start = {name = "freeze_on"},
        stop = {name = "freeze_off"}
    },
    hud = {{
        name = "freeze_icon",
        hud_elem_type = "image",
        text = "ice_overlay.png",
        position = {x = 0.5, y = 0.8},
        scale = {x = 2, y = 2}
    }}
})
```

#### Example 2: Poison State

```lua
skills.register_state("status:poison", {
    name = "Poisoned",
    description = "You are poisoned and losing health over time.",
    loop_params = {
        cast_rate = 2,
        duration = 20
    },
    sounds = {
        start = {name = "poison_applied"},
        cast = {name = "poison_tick", volume = 0.3},
        stop = {name = "poison_cured"}
    },
    hud = {{
        name = "poison_icon",
        hud_elem_type = "image",
        text = "poison_overlay.png",
        position = {x = 0.1, y = 0.8},
        scale = {x = 1.5, y = 1.5}
    }},
    cast = function(self)
        local player = self.player
        local current_hp = player:get_hp()
        if current_hp > 1 then  -- Don't kill the player
            player:set_hp(current_hp - 1)
        end
    end
})
```

#### Example 3: Skill that Applies a State

```lua
skills.register_skill("wizard:ice_blast", {
    name = "Ice Blast",
    description = "Freeze target for 5 seconds.",
    cooldown = 10,
    cast = function(self, target_name)
        if target_name and core.get_player_by_name(target_name) then
            target_name:add_state("status:frozen")
        end
    end
})
```

#### Example 4: Meditation Blocking Debuffs

```lua
skills.register_skill("monk:meditate", {
    name = "Meditate",
    description = "Enter a state of inner peace, blocking all debuffs.",
    loop_params = {
        duration = 10
    },
    blocks_other_states = {
        mode = "blacklist",
        blocked = {"mymod_status"}  -- blocks all states with "status" prefix
    },
    physics = {
        operation = "multiply",
        speed = 0.1  -- slow movement while meditating
    },
    sounds = {
        start = {name = "zen_start"},
        stop = {name = "zen_end"}
    },
    hud = {{
        name = "meditation_aura",
        hud_elem_type = "image",
        text = "meditation_glow.png",
        position = {x = 0.5, y = 0.5},
        scale = {x = 4, y = 4}
    }}
})
```

#### Example 5: State Based on Another State

```lua
-- Base burning state
skills.register_state("status:burning", {
    name = "Burning",
    description = "You are on fire and losing health.",
    loop_params = {
        cast_rate = 1,
        duration = 10
    },
    sounds = {
        start = {name = "fire_ignite"},
        cast = {name = "fire_crackle", volume = 0.4},
        stop = {name = "fire_extinguish"}
    },
    _damage = 2,
    cast = function(self)
        local player = self.player
        player:set_hp(math.max(1, player:get_hp() - self._damage))
    end
})

-- Enhanced burning state based on the regular one
skills.register_state_based_on({"status:burning"}, "status:hellfire", {
    name = "Hellfire",
    description = "Intense magical fire that burns longer and harder.",
    loop_params = {
        cast_rate = 0.5,  -- Burns twice as fast
        duration = 15     -- Lasts longer
    },
    sounds = {
        start = {name = "hellfire_ignite", pitch = 0.8},
        cast = {name = "hellfire_burn", volume = 0.6}
    },
    _damage = 4
})
```

</details>


## 7. Assigning a Skill

To unlock or remove a skill from a player, use the `skills.unlock_skill(pl_name, skill_name)` or `skills.remove_skill(pl_name, skill_name)` functions.


## 8. Using a Skill

To use a player's skill, you can choose between the short method or the long method.

### Short Method

Use the following functions:

- `pl_name:cast_skill("skill_name", [...])`
- `pl_name:start_skill("skill_name", [...])`
- `pl_name:stop_skill("skill_name")`

If the player can't use the skill (e.g., they haven't unlocked it), these functions will return `false`.

### Long Method

First, get the player's skill table using `skills.get_skill(pl_name, "skill_name")`. If the player can't use the skill, this will return `false`.

The function will return the player's skill table, composed of the [definition properties](#2-registering-a-skill) plus the following new properties:

- **`disable()`**: Disables the skill; when disabled, the `cast` and `start` functions won't work.
- **`enable()`**: Enables the skill.
- **`data.__enabled`** (boolean): `true` if the skill is enabled.
- **`internal_name`** (string): The name used to refer to the skill in the code.
- **`cooldown_timer`** (number): The time left until the end of the cooldown.
- **`is_active`** (boolean): `true` if the skill is active.
- **`pl_name`** (string): The name of the player using this skill.
- **`player`** (ObjectRef): The player using this skill. **Only use this while the skill is being cast!**
- **`__dtime`** (number): The time in seconds since the last `cast` call for this skill instance. Useful for time-dependent logic in looped skills.

Once you have the skill table, you can call:

- `skill_table:cast([...])` or
- `skill_table:start([...])`

to cast the skill. To stop it, use:

- `skill_table:stop()`


## 9. Utility Functions

### 9.1. Skills Functions

- **`skills.register_on_unlock(function(skill_table), [prefix])`**: Called every time a player unlocks a skill with the specified prefix. If the prefix isn't specified, the function will be called every time a player unlocks a skill.
- **`skills.disable_skill(pl_name, skill_name)`**: Short method to disable a skill.
- **`skills.enable_skill(pl_name, skill_name)`**: Short method to enable a skill.
- **`skills.get_def(name)`**: Returns the definition table of anything registered with a `register_` function.
- **`skills.does_skill_exist(skill_name)`**: Checks if a skill exists (not case-sensitive). Always returns `false` for layers and states.
- **`skills.does_layer_exist(skill_name)`**: Checks if a layer exists (not case-sensitive). Always returns `false` for skills and states.
- **`skills.does_state_exist(state_name)`**: Checks if a state exists (not case-sensitive). Returns `true` only for registered states.
- **`skills.get_registered_skills([prefix])`**: Returns the registered non-layer, non-state skills. If a prefix is specified, only the skills with that prefix will be listed (`{"prefix1:skill1" = {def}}`).
- **`skills.get_registered_layers([prefix])`**: Same as above but returns a list of layers.
- **`skills.get_registered_states([prefix])`**: Same as above but returns a list of states.
- **`skills.get_unlocked_skills(pl_name, [prefix])`**: Returns the unlocked skills for a player. If a prefix is specified, only the skills with that prefix will be listed (`{"prefix1:skill1" = {def}}`).
- **`skills.get_active_skills(pl_name, [prefix])`**: Returns a table of all skills currently active for the given player. If a prefix is specified (e.g., "mymod"), only skills with that prefix will be included.
- **`skills.get_active_states(pl_name, [prefix])`**: Returns a table of all states currently active for the given player. If a prefix is specified (e.g., "mymod"), only states with that prefix will be included.
- **`skills.has_skill(pl_name, skill_name)`**: Returns `true` if the player has the skill.
- **`skills.for_each_player_in_db(callback)`**: Calls `callback(pl_name, skills)` for each player in the database. Always use this function if you need to operate on many offline players to avoid performance issues.

### 9.2. Player Functions

- **`skills.add_physics(pl_name, property, value)`**
- **`skills.sub_physics(pl_name, property, value)`**
- **`skills.multiply_physics(pl_name, property, value)`**
- **`skills.divide_physics(pl_name, property, value)`**

These functions modify the specified physics property of the player by adding, subtracting, multiplying, or dividing the given `value`.

**Example:**

```lua
pl_name:add_physics("speed", 1)
```

### 9.3. Entities Functions

- **`skills.register_expiring_entity(name, def)`**: Registers an entity that's meant to exist only while a skill is active.

  Such an entity will have its `static_save` parameter set to `false`, and its Lua table will contain three additional parameters:

  - **`pl_name`** (string)
  - **`player`** (ObjectRef)
  - **`skill`** (table): A reference to the skill that spawned the entity.

  The `staticdata` passed to the entity's `on_activate()` is a serialized `{pl_name = "...", skill_name = "..."}`. When the linked skill stops, the entity will be removed. You can define a custom `on_remove(self)` function in the entity's definition table; if defined, this function will be called when the entity is about to be automatically removed. If your custom `on_remove` function returns `true`, the default removal logic will be skipped. Otherwise, the default removal will proceed after your function finishes.

- **`skills.add_entity(skill, pos, name)`** / **`skill:add_entity(pos, name)`**: Spawns an expiring entity, linking it to the selected skill. It returns the entity's `ObjectRef`.
