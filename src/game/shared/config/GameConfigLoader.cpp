/***
*
*	Copyright (c) 1996-2001, Valve LLC. All rights reserved.
*
*	This product contains software technology licensed from Id
*	Software, Inc. ("Id Technology").  Id Technology (c) 1996 Id Software, Inc.
*	All Rights Reserved.
*
*   Use, distribution, and modification of this source code and/or resulting
*   object code is restricted to non-commercial enhancements to products from
*   Valve LLC.  All other use, distribution, or modification is prohibited
*   without written permission from Valve LLC.
*
****/

#include <fmt/format.h>

#include "cbase.h"

#include "ConditionEvaluator.h"
#include "GameConfigDefinition.h"
#include "GameConfigIncludeStack.h"
#include "GameConfigLoader.h"
#include "GameConfigSection.h"

#include "utils/JSONSystem.h"
#include "utils/string_utils.h"

using namespace std::literals;

//Provides access to the constructor.
struct GameConfigDefinitionImplementation : public GameConfigDefinition
{
	GameConfigDefinitionImplementation(std::string&& name, std::vector<std::unique_ptr<const GameConfigSection>>&& sections)
		: GameConfigDefinition(std::move(name), std::move(sections))
	{
	}
};

GameConfigLoader::GameConfigLoader() = default;
GameConfigLoader::~GameConfigLoader() = default;

bool GameConfigLoader::Initialize()
{
	m_Logger = g_Logging.CreateLogger("gamecfg");

	return true;
}

void GameConfigLoader::Shutdown()
{
	m_Logger.reset();
}

std::shared_ptr<const GameConfigDefinition> GameConfigLoader::CreateDefinition(
	std::string&& name, std::vector<std::unique_ptr<const GameConfigSection>>&& sections)
{
	auto definition = std::make_shared<const GameConfigDefinitionImplementation>(std::move(name), std::move(sections));

	g_JSON.RegisterSchema(std::string{definition->GetName()}, [=]()
		{ return definition->GetSchema(); });

	return definition;
}

bool GameConfigLoader::TryLoad(
	const char* fileName, const GameConfigDefinition& definition, const GameConfigLoadParameters& parameters)
{
	GameConfigIncludeStack includeStack;

	//So you can't get a stack overflow including yourself over and over.
	includeStack.Add(fileName);

	LoadContext loadContext{
		.Definition = definition,
		.Parameters = parameters,
		.IncludeStack = includeStack};

	return TryLoadCore(loadContext, fileName);
}

bool GameConfigLoader::TryLoadCore(LoadContext& loadContext, const char* fileName)
{
	m_Logger->trace("Loading \"{}\" configuration file \"{}\" (depth {})", loadContext.Definition.GetName(), fileName, loadContext.Depth);

	auto result = g_JSON.ParseJSONFile(
		fileName,
		{.SchemaName = loadContext.Definition.GetName(), .PathID = loadContext.Parameters.PathID},
		[&, this](const json& input)
		{
			ParseConfig(loadContext, fileName, input);
			return true; //Just return something so optional doesn't complain.
		});

	if (result.has_value())
	{
		m_Logger->trace("Successfully loaded configuration file");
	}
	else
	{
		m_Logger->trace("Failed to load configuration file");
	}

	return result.has_value();
}

void GameConfigLoader::ParseConfig(LoadContext& loadContext, std::string_view configFileName, const json& input)
{
	if (input.is_object())
	{
		ParseIncludedFiles(loadContext, input);
		ParseSections(loadContext, configFileName, input);
	}
}

void GameConfigLoader::ParseIncludedFiles(LoadContext& loadContext, const json& input)
{
	if (auto includes = input.find("Includes"); includes != input.end())
	{
		if (!includes->is_array())
		{
			return;
		}

		for (const auto& include : *includes)
		{
			if (!include.is_string())
			{
				continue;
			}

			auto includeFileName = include.get<std::string>();

			includeFileName = Trim(includeFileName);

			switch (loadContext.IncludeStack.Add(includeFileName.c_str()))
			{
			case IncludeAddResult::Success:
			{
				m_Logger->trace("Including file \"{}\"", includeFileName);

				++loadContext.Depth;

				TryLoadCore(loadContext, includeFileName.c_str());

				--loadContext.Depth;
				break;
			}

			case IncludeAddResult::AlreadyIncluded:
			{
				m_Logger->debug("Included file \"{}\" already included before", includeFileName);
				break;
			}


			case IncludeAddResult::CouldNotResolvePath:
			{
				m_Logger->error("Couldn't resolve path for included configuration file \"{}\"", includeFileName);
				break;
			}
			}
		}
	}
}

void GameConfigLoader::ParseSections(LoadContext& loadContext, std::string_view configFileName, const json& input)
{
	if (auto sections = input.find("Sections"); sections != input.end())
	{
		if (!sections->is_array())
		{
			return;
		}

		for (const auto& section : *sections)
		{
			if (!section.is_object())
			{
				continue;
			}

			if (const auto name = section.value("Name", ""sv); !name.empty())
			{
				if (const auto sectionObj = loadContext.Definition.FindSection(name); sectionObj)
				{
					if (const auto condition = section.value("Condition", ""sv); !condition.empty())
					{
						m_Logger->trace("Testing section \"{}\" condition \"{}\"", sectionObj->GetName(), condition);

						const auto shouldUseSection = g_ConditionEvaluator.Evaluate(condition);

						if (!shouldUseSection.has_value())
						{
							//Error already reported
							m_Logger->trace("Skipping section because an error occurred while evaluating condition");
							continue;
						}

						if (!shouldUseSection.value())
						{
							m_Logger->trace("Skipping section because condition evaluated false");
							continue;
						}
						else
						{
							m_Logger->trace("Using section because condition evaluated true");
						}
					}

					GameConfigContext context{
						.ConfigFileName = configFileName,
						.Input = section,
						.Definition = loadContext.Definition,
						.Loader = *this,
						.UserData = loadContext.Parameters.UserData};

					if (!sectionObj->TryParse(context))
					{
						m_Logger->error("Error parsing section \"{}\"", sectionObj->GetName());
					}
				}
				else
				{
					m_Logger->warn("Unknown section \"{}\"", name);
				}
			}
		}
	}
}
