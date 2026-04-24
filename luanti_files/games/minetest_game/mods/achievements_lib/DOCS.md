# Achievements Lib

## 1. Achievements: structure
`achievements` is a big table taking mod names as a key and a table as a value. This table can contain whatever entry you like (`name`, `img`, `idontknow`), because the only thing that matters to it is to check whether something exists at the given index. In fact, the following examples are all correct:
```
local achievements = {
  [1] = "inhale",
  [2] = "exhale"
}

local achievements = {
  [1] = { name = "inhale",	img = "mod_inhale.png" },
  [2] = { name = "exhale",	img = "mod_exhale.png" }
}

-- pretty useless but hey ¯\_(ツ)_/¯
local achievements = {
  [1] = true,
  [2] = true
}
```

The table is _not_ saved into the storage, only players progress is.

## 2. Registering and unlocking achievements
In order to register the achievements of a mod, do:  
`achvmt_lib.register_achievements(mod, mod_achievements)`  
where `mod` is the mod name and `mod_achievements` a table containing whatever value you want.

On the contrary, to unlock an achievement:
`achvmt_lib.unlock_achievement(p_name, mod, achvmt_ID)`

### 2.1 Utils
`achvmt_lib.has_player_achievement(p_name, mod, achvmt_ID)`: check whether a player has unlocked an achievement
`achvmt_lib.is_player_in_storage(p_name, mod)`: check whether a player has connected after a new mod supporting achievements_lib has been added

### 2.2 Getters
`achvmt_lib.get_achievement(mod, achvmt_ID)`: returns the value assigned to the achievement at the corresponding `achvmt_ID`, if any
`achvmt_lib.get_player_achievements(p_name, mod)`: returns a table containing all the achievements unlocked by `p_name`, where entries are in the format `ID = true`

## 3 About the author
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this library spared you a lot of time and you want to support me somehow, please consider donating on [LiberaPay](https://liberapay.com/Zughy/).
