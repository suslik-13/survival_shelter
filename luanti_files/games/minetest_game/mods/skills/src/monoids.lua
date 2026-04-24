-- Helper to resolve string path to object
local function resolve_monoid_ref(ref_string)
   skills.assert(ref_string and type(ref_string) == "string", "Invalid ref_string type: " .. type(ref_string))

   local parts = {}
   for part in string.gmatch(ref_string, "[^.]+") do
      table.insert(parts, part)
   end
   skills.assert(#parts > 0, "Empty ref_string")

   local obj = _G[parts[1]]
   skills.assert(obj, "Global '" .. parts[1] .. "' not found for monoid ref '" .. ref_string .. "'")

   for i = 2, #parts do
      skills.assert(type(obj) == "table", "Cannot index non-table '" .. parts[i - 1] .. "' in monoid ref '" .. ref_string .. "'")
      obj = obj[parts[i]]
      skills.assert(obj, "Key '" .. parts[i] .. "' not found in path for monoid ref '" .. ref_string .. "'")
   end

   return obj
end

local function ensure_player_monoids_loaded(skill_internal_name_requiring_it)
   skills.assert(core.get_modpath("player_monoids"),
      "Skill '" .. skill_internal_name_requiring_it ..
      "' requires 'player_monoids' mod for its monoid operations, but the mod is not loaded. Please install or enable 'player_monoids'.")
end



function skills.foreach_monoid(skill, func)
   if not (skill and skill.monoids) then return end

   for monoid_name, value_def in pairs(skill.monoids) do
      if monoid_name ~= "checkout_branch_while_active" and type(value_def) == "table" then
         local monoid_obj = resolve_monoid_ref(value_def.ref)

         if not monoid_obj then
            skills.log("error", "Skill '" .. skill.internal_name .. "': monoid_obj for ref '" .. tostring(value_def.ref) .. "' is nil. Ensure the monoid is registered and the ref string is correct.")
         else
            func(monoid_name, value_def, monoid_obj)
         end
      end
   end
end



function skills.apply_monoids(skill)
   if skill.monoids then
      ensure_player_monoids_loaded(skill.internal_name)

      skills.foreach_monoid(skill, function(monoid_name, value_def, monoid_obj)
         local modificator = value_def.value
         local monoid_id = skill.internal_name .. "." .. monoid_name -- Unique ID for this skill's effect
         local target_branch_for_effect = value_def.branch or "main"

         skill.__monoids = skill.__monoids or {}
         -- API: monoid:add_change(player, value[, id, branch_name])
         monoid_obj:add_change(skill.player, modificator, monoid_id, target_branch_for_effect)
         skill.__monoids[monoid_id] = {monoid = monoid_obj, branch = target_branch_for_effect} -- Store for removal
      end)
   end
end



function skills.remove_monoids(skill)
   if skill.__monoids then
      ensure_player_monoids_loaded(skill.internal_name)

      for monoid_id, data in pairs(skill.__monoids) do
         if data.monoid and data.branch then
            -- API: monoid:del_change(player, id[, branch_name])
            data.monoid:del_change(skill.player, monoid_id, data.branch)
         end
         skill.__monoids[monoid_id] = nil
      end
   end
end



function skills.checkout_skills_monoids(skill)
   if skill.monoids and skill.monoids.checkout_branch_while_active then
      ensure_player_monoids_loaded(skill.internal_name)

      skills.foreach_monoid(skill, function(monoid_name, value_def, monoid_obj)
         skills.assert(type(monoid_obj.checkout_branch) == "function",
            "Skill '" .. skill.internal_name .. "' tries to use 'checkout_branch' for monoid '" .. monoid_name ..
            "' (ref: " .. tostring(value_def.ref) .. "), but the function is missing on the monoid object. " ..
            "Ensure 'player_monoids' mod is up-to-date and supports branch operations.")

         local target_branch_for_effect = value_def.branch or "main"
         -- API: monoid:checkout_branch(player, branch_name)
         monoid_obj:checkout_branch(skill.player, target_branch_for_effect)
      end)
   end
end



function skills.update_player_monoids_branches(old_skill, pl_name)  
   if not core.get_player_by_name(pl_name) then return end

   -- initialize unused_branches with the branches of the skill that is stopping
   local unused_branches = {}
   if old_skill.monoids and old_skill.monoids.checkout_branch_while_active then
      skills.foreach_monoid(old_skill, function(monoid_name, value_def, monoid_obj)
         local branch = monoid_name .. "|" .. (value_def.branch or "main")
         unused_branches[branch] = monoid_obj
      end)
   end

   local monoids_stack = skills.get_active_skills_stack(pl_name, nil, function(skill)
      return skill.monoids and skill.monoids.checkout_branch_while_active and skill.internal_name ~= old_skill.internal_name
   end)

   -- checkout branches on the stack (bottom -> top)
   for i, skill in ipairs(monoids_stack) do
      -- for each skill find its checked out branches and remove them from unused_branches
      skills.foreach_monoid(skill, function(monoid_name, value_def, monoid_obj)
         local branch = monoid_name .. "|" .. (value_def.branch or "main")
         unused_branches[branch] = nil
      end)
      skills.checkout_skills_monoids(skill)
   end 

   -- delete unused branches
   for branch_name, monoid_obj in pairs(unused_branches) do
      ensure_player_monoids_loaded(old_skill.internal_name or "skills_system_branch_cleanup")
      
      skills.assert(type(monoid_obj.get_branch) == "function",
         "Skill system attempts to delete unused branch '" .. branch_name ..
         "' for monoid (ref from stopping skill: " .. (old_skill.internal_name or "unknown") ..
         "), but 'get_branch' function is missing on the monoid object. " ..
         "Ensure 'player_monoids' mod is up-to-date and supports this branch operation.")

      local actual = branch_name:match("|(.+)$")
      if monoid_obj:get_branch(actual) then
         monoid_obj:get_branch(actual):delete(core.get_player_by_name(pl_name))
      else
         skills.log("error", "Skill system tried to delete branch '" .. actual ..
            "' for monoid via skill '" .. (old_skill.internal_name or "unknown") ..
            "', but the branch was not found on the monoid object.")
      end
   end
end
