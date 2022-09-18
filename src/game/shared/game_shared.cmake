function(add_game_shared_sources target)
	target_sources(${target}
		PRIVATE
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/GameLibrary.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/GameLibrary.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/palette.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/voice_common.h
			
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/ConditionEvaluator.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/ConditionEvaluator.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/GameConfigIncludeStack.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/GameConfig.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/GameConfig.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/sections/CommandsSection.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/sections/EchoSection.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/sections/GlobalModelReplacementSection.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/sections/GlobalSentenceReplacementSection.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/sections/GlobalSoundReplacementSection.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/sections/HudColorSection.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config/sections/SuitLightTypeSection.h
			
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/ehandle.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/ehandle.h
			
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CDisplacer.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CDisplacer.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CEagle.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CEagle.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CGrapple.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CGrapple.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CKnife.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CKnife.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CM249.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CM249.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CPenguin.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CPenguin.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CPipewrench.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CPipewrench.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/crossbow.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/crowbar.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CShockRifle.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CShockRifle.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CSniperRifle.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CSniperRifle.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CSporeLauncher.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/CSporeLauncher.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/egon.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/gauss.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/glock.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/handgrenade.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/hornetgun.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/mp5.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/python.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/rpg.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/satchel.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/shotgun.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/squeakgrenade.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/tripmine.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/weapons_shared.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/entities/items/weapons/weapons.h
			
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_debug.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_debug.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_defs.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_info.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_materials.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_math.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_movevars.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_shared.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/player_movement/pm_shared.h
			
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripting/AS/as_addons.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripting/AS/as_utils.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripting/AS/as_utils.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripting/AS/ASManager.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripting/AS/ASManager.h
			
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/sound/sentence_utils.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/sound/sentence_utils.h
			
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/ConCommandSystem.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/ConCommandSystem.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/filesystem_utils.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/filesystem_utils.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/GameSystem.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/GameSystem.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/heterogeneous_lookup.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/json_fwd.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/JSONSystem.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/JSONSystem.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/LogSystem.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/LogSystem.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/ReplacementMaps.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/ReplacementMaps.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/shared_utils.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/shared_utils.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/string_utils.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/string_utils.h
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/StringPool.cpp
			${CMAKE_CURRENT_FUNCTION_LIST_DIR}/utils/StringPool.h)
endfunction()
