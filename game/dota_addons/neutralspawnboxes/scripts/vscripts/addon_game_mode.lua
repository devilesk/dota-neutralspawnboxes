-- Generated from template

OverlayState = {
	cbTowerDayVisionRange=true,
	cbTowerNightVisionRange=true,
	cbTowerTrueSightRange=true,
	cbTowerAttackRange=true,
	cbNeutralSpawnBox=true,
	cbDetectNeutrals=false,
	cbSentryVision=true,
	cbWardVision=true,
	cbHeroXPRange=true,
	cbFogOfWar=true,
	btnMinimize=true
}

NeutralCampCoords = {
	{
        name = "neutralcamp_good_5",
        boxes = {
            --[[{
                Vector(-1563.430054, -3872.000000, 480.000000) + Vector(-164.569946, -608.000000, -224.000000),
                Vector(-1563.430054, -3872.000000, 480.000000) + Vector(859.430054, 352.000000, 224.000000)
            }]]
            --{Vector(-1728.0, -4224.0, 128.0), Vector(-1344.0, -3520.0, 576.0)}, {Vector(-1344.0, -4480.0, 128.0), Vector(-704.0, -3520.0, 576.0)}
            --{Vector(-1728.0, -4224.0, 128.0), Vector(-1344.0, -3520.0, 576.0)}
        },
        particles=nil,
        isRed=false
    }
}

if CNeutralSpawnBoxGameMode == nil then
	CNeutralSpawnBoxGameMode = class({})
end

function Precache( context )
	PrecacheResource( "particle", "particles/custom/range_display.vpcf", context )
	PrecacheResource( "particle", "particles/custom/range_display_red.vpcf", context )
	PrecacheResource( "particle", "particles/custom/range_display_box.vpcf", context )
	PrecacheResource( "particle", "particles/custom/range_display_line.vpcf", context )
	PrecacheResource( "particle", "particles/custom/range_display_line_red.vpcf", context )
	PrecacheResource( "particle", "particles/custom/range_display_b.vpcf", context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CNeutralSpawnBoxGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function InitBoxes()
    local boxes = Entities:FindAllByClassname("trigger_multiple")
    for k,ent in pairs(boxes) do
        --if ent:GetName() ~= "neutralcamp_good_5" and string.find(ent:GetName(), "neutralcamp") ~= nil then
        if string.find(ent:GetName(), "neutralcamp") ~= nil then
            local box = {
                name = ent:GetName(),
                boxes = {
                    {
                        ent:GetOrigin() + ent:GetBounds().Mins,
                        ent:GetOrigin() + ent:GetBounds().Maxs
                    }
                },
                particles=nil,
                isRed=false
            }
            table.insert(NeutralCampCoords, box)
        end
    end
    boxes = nil
end


function CNeutralSpawnBoxGameMode:InitGameMode()
	-- print( "Template addon is loaded." )
    InitBoxes()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
 
    CustomGameEventManager:RegisterListener( "toggle_overlay", OnToggleOverlay )

	--[[Convars:RegisterCommand( "cgm_toggle_overlay", function(cmdName, trigger_name, state)
		print("test", cmdName, trigger_name, state)
		--get the player that sent the command
		local cmdPlayer = Convars:GetCommandClient()
		if cmdPlayer then 
			--if the player is valid, execute ToggleOverlay
			return self:ToggleOverlay(cmdName, trigger_name, state) 
		end
	end, "Overlay toggled.", 0 )]]
  self.m_tInitItems = {}
  for i=0,9,1 do
    self.m_tInitItems[i] = false
  end
end

function OnToggleOverlay( eventSourceIndex, args )
	--print( "My event: ( " .. eventSourceIndex .. ", " .. args['trigger_name'] .. args['state'] .. " )" )
    CNeutralSpawnBoxGameMode:ToggleOverlay(args['trigger_name'], args['state']) 
end

function CNeutralSpawnBoxGameMode:ToggleOverlay(trigger_name, state)
	--print(trigger_name, state)
    OverlayState[trigger_name] = state == 1
	if trigger_name == "cbFogOfWar" then
		local mode = GameRules:GetGameModeEntity()      
		mode:SetFogOfWarDisabled(not OverlayState[trigger_name])
	end
end

-- Evaluate the state of the game
function CNeutralSpawnBoxGameMode:OnThink()
  local boxes = Entities:FindAllByClassname("trigger_multiple")
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
    for i=0,9,1 do
      if self.m_tInitItems[i] == false then
        local player = PlayerResource:GetPlayer(i)
        if player ~= nil then
          local hero = player:GetAssignedHero()
          if hero ~= nil then
            local item
            item = CreateItem("item_blink", hero, hero)
            hero:AddItem(item)
            item = CreateItem("item_ward_observer", hero, hero)
            hero:AddItem(item)
            item = CreateItem("item_ward_sentry", hero, hero)
            hero:AddItem(item)
            self.m_tInitItems[i] = true
          end
        else
          self.m_tInitItems[i] = true
        end
      end
    end
		local wards = Entities:FindAllByClassname("npc_dota_ward_base")
		local sentries = Entities:FindAllByClassname("npc_dota_ward_base_truesight")
		local towers = Entities:FindAllByClassname("npc_dota_tower")
		local neutrals = Entities:FindAllByClassname("npc_dota_creep_neutral")
		if towers ~= nil then
			for k,ent in pairs(towers) do
				if ent._Particles == nil then
					ent._Particles = {TowerDayVision=nil, TowerNightVision=nil, TowerTrueSight=nil, TowerAttack=nil}
				end
			end
		end
		if wards ~= nil then
			for k,ent in pairs(wards) do
				if ent:IsAlive() then
					ent:SetHealth(1)
				end
				if ent:GetHealth() <= 0 then
					ent:RemoveSelf()
				end
				if ent._Particles == nil then
					ent._Particles = {WardVision=nil}
				end
			end
		end
		if sentries ~= nil then
			for k,ent in pairs(sentries) do
				if ent:IsAlive() then
					ent:SetHealth(1)
				end
				if ent:GetHealth() <= 0 then
					ent:RemoveSelf()
				end
				if ent._Particles == nil then
					ent._Particles = {WardVision=nil, TrueSightVision=nil}
				end
			end
		end
		for i=0,9,1 do
			local player = PlayerResource:GetPlayer(i)
			if player ~= nil then
				local hero = player:GetAssignedHero()
				if hero ~= nil then
					if hero._Particles == nil then
						hero._Particles = {HeroXPRange=nil}
					
					end
					CheckAndDrawCircle(hero, towers, wards, sentries)
					for k,boxData in pairs(NeutralCampCoords) do
						CreateParticleBoxes(hero, wards, sentries, neutrals, boxData)
					end
				end			
			end
		end
		wards = nil
		sentries = nil
		towers = nil
		neutrals = nil
        boxes = nil
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        boxes = nil
		return nil
	end
	return .01
end

function DeleteParticleBoxes(boxData)
	for k,box_particles in pairs(boxData.particles) do
		for k,particle in pairs(box_particles) do
			ParticleManager:DestroyParticle(particle, true)
		end
	end
	boxData.particles = nil
end

function CreateParticleBoxes(hero, wards, sentries, neutrals, boxData)
	local isRed = IsInBoxes(hero, wards, sentries, neutrals, boxData.boxes, boxData.name)
    --local isRed = false
	if OverlayState["cbNeutralSpawnBox"] == true then
		if boxData.particles == nil or boxData.isRed ~= isRed then
			if boxData.particles ~= nil then
				DeleteParticleBoxes(boxData)
			end
			local box_particles = {}
            for k,box in pairs(boxData.boxes) do
                --[[if boxData.name ~= "neutralcamp_good_5" then
                    table.insert(box_particles, CreateParticleBox(hero, box[1], box[2], isRed))
                else
                    table.insert(box_particles, CreateParticleBox5(hero, box[1], box[2], isRed))
                end]]
                table.insert(box_particles, CreateParticleBox(hero, box[1], box[2], isRed))
            end
			boxData.particles = box_particles
			boxData.isRed = isRed
		end
	else
		if boxData.particles ~= nil then
			DeleteParticleBoxes(boxData)
		end
	end

end

function IsInBoxes(hero, wards, sentries, neutrals, boxes, name)
    local camp_boxes = Entities:FindAllByClassname("trigger_multiple")
    local ward_touching = false
    for j,camp_box in pairs(camp_boxes) do
        if camp_box:GetName() == name then
            if wards ~= nil then
                for k,ent in pairs(wards) do
                    if ent ~= nil and IsValidEntity(ent) then
                        if camp_box:IsTouching(ent) then
                            --camp_boxes = nil
                            ent:SetRenderColor(255, 0, 0)
                            ward_touching = true
                        end
                    end
                end
            end
            if sentries ~= nil then
                for k,ent in pairs(sentries) do
                    if ent ~= nil and IsValidEntity(ent) then
                        if camp_box:IsTouching(ent) then
                            --camp_boxes = nil
                            ent:SetRenderColor(255, 0, 0)
                            ward_touching = true
                        end
                    end
                end
            end
            if ward_touching == true then
              camp_boxes = nil
              return true
            end
            if neutrals ~= nil and OverlayState["cbDetectNeutrals"] == true then
                for k,ent in pairs(neutrals) do
                    if ent ~= nil and IsValidEntity(ent) then
                        if camp_box:IsTouching(ent) then
                            camp_boxes = nil
                            return true
                        end
                    end
                end
            end
            if hero ~= nil then
                if camp_box:IsTouching(hero) then
                    camp_boxes = nil
                    return true
                end
            end
        end
    end
    camp_boxes = nil
	return false
end

function CreateParticleBox5(ent, min_a, max_a, isRed)
    local particles = {}
    local particle

	particle = CreateParticleLine(ent, Vector(-1728, -3520, 0), Vector(-704, -3520, 0), isRed)
	table.insert(particles, particle)

	particle = CreateParticleLine(ent, Vector(-704, -3520, 0), Vector(-704, -4480, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-704, -4480, 0), Vector(-1344, -4480, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-1344, -4480, 0), Vector(-1344, -4224, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-1344, -4224, 0), Vector(-1728, -4224, 0), isRed)
	table.insert(particles, particle)
    
	particle = CreateParticleLine(ent, Vector(-1728, -4224, 0), Vector(-1728, -3520, 0), isRed)
	table.insert(particles, particle)
    
    return particles
end

function CreateParticleBox(ent, min_a, max_a, isRed)
	local particles = {}
	local particle
	particle = CreateParticleLine(ent, Vector(min_a.x, min_a.y, 0), Vector(min_a.x, max_a.y, 0), isRed)
	table.insert(particles, particle)
	particle = CreateParticleLine(ent, Vector(min_a.x, min_a.y, 0), Vector(max_a.x, min_a.y, 0), isRed)
	table.insert(particles, particle)
	particle = CreateParticleLine(ent, Vector(max_a.x, min_a.y, 0), Vector(max_a.x, max_a.y, 0), isRed)
	table.insert(particles, particle)
	particle = CreateParticleLine(ent, Vector(max_a.x, max_a.y, 0), Vector(min_a.x, max_a.y, 0), isRed)
	table.insert(particles, particle)
	return particles
end

function CreateParticleLine(ent, a, b, isRed)
	local particle
	if isRed then
		particle = ParticleManager:CreateParticle("particles/custom/range_display_line_red.vpcf", PATTACH_WORLDORIGIN, ent)
	else
		particle = ParticleManager:CreateParticle("particles/custom/range_display_line.vpcf", PATTACH_WORLDORIGIN, ent)
	end
	ParticleManager:SetParticleControl(particle, 0, a)
	ParticleManager:SetParticleControl(particle, 1, b)
	return particle
end

function CreateRangeParticle(ent, radius, isRed)
	local particle
	if isRed then
		particle = ParticleManager:CreateParticle("particles/custom/range_display_red.vpcf", PATTACH_ABSORIGIN_FOLLOW, ent)
	else
		particle = ParticleManager:CreateParticle("particles/custom/range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, ent)
	end
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 100, 100))
	return {particle, isRed}
end

function CheckAndDrawCircle(hero, towers, wards, sentries)
	CircleParticle(hero, "cbHeroXPRange", "HeroXPRange", 1300, false)
	if towers ~= nil then
		for k,ent in pairs(towers) do
			if ent ~= nil and IsValidEntity(ent) then
				CircleParticle(ent, "cbTowerDayVisionRange", "TowerDayVision", 1800, (hero:GetCenter() - ent:GetCenter()):Length2D() < 1800)
				CircleParticle(ent, "cbTowerTrueSightRange", "TowerTrueSight", 700, (hero:GetCenter() - ent:GetCenter()):Length2D() < 700)
				CircleParticle(ent, "cbTowerNightVisionRange", "TowerNightVision", 800, (hero:GetCenter() - ent:GetCenter()):Length2D() < 800)
				CircleParticle(ent, "cbTowerAttackRange", "TowerAttack", 700 + ent:GetHullRadius(), CalcDistanceBetweenEntityOBB(hero, ent) < 700)
			end
		end
	end
	if wards ~= nil then
		for k,ent in pairs(wards) do
			if ent ~= nil and IsValidEntity(ent) then
				CircleParticle(ent, "cbWardVision", "WardVision", 1600, false)
			end
		end
	end
	if sentries ~= nil then
		for k,ent in pairs(sentries) do
			if ent ~= nil and IsValidEntity(ent) then
				CircleParticle(ent, "cbSentryVision", "WardVision", 150, false)
				CircleParticle(ent, "cbSentryVision", "TrueSightVision", 850, false)
			end
		end
	end
end

function CircleParticle(ent, overlayName, particleName, radius, isRed)
	if OverlayState[overlayName] == true then
		if ent._Particles[particleName] ~= nil then
			if ent._Particles[particleName][2] ~= isRed then
				ParticleManager:DestroyParticle(ent._Particles[particleName][1], true)
				ent._Particles[particleName] = CreateRangeParticle(ent, radius, isRed)
			end
		else
			ent._Particles[particleName] = CreateRangeParticle(ent, radius, isRed)
		end
	else
		if ent._Particles[particleName] ~= nil then
			ParticleManager:DestroyParticle(ent._Particles[particleName][1], true)
			ent._Particles[particleName] = nil
		end
	end
end

function BoxesIntersect(a_min, a_max, b_min, b_max)
	if a_max.x < b_min.x then return false end -- a is left of b
    if a_min.x > b_max.x then return false end -- a is right of b
    if a_max.y < b_min.y then return false end -- a is above b
    if a_min.y > b_max.y then return false end -- a is below b
    if a_max.z < b_min.z then return false end -- a is above b
    if a_min.z > b_max.z then return false end -- a is below b
	return true
end