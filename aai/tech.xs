void ResearchEconomicTechs(void)
{
    if (gMainBase == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 1000)
        return;
    last_call = xsGetTime();

    static int resource_units = -1;
    if (resource_units == -1)
    {
        resource_units = xsArrayCreateInt(23, -1, "List of resource units to improve");
        if (cMyCulture != cCultureJapanese)
            xsArraySetInt(resource_units, 0, cUnitTypeHuntable);
        xsArraySetInt(resource_units, 1, cUnitTypeAbstractFruit);
        xsArraySetInt(resource_units, 2, cUnitTypeBerryBush);
        xsArraySetInt(resource_units, 3, cUnitTypeBerryBushNative);
        xsArraySetInt(resource_units, 4, cUnitTypeypBerryBuilding);
        xsArraySetInt(resource_units, 5, cUnitTypeypGroveBuilding);
        if (kbUnitCount(0, cUnitTypeAbstractFish, cUnitStateAlive) >= 8)
            xsArraySetInt(resource_units, 6, cUnitTypeAbstractFish);
        if (kbUnitCount(0, cUnitTypeAbstractWhale, cUnitStateAlive) >= 2)
            xsArraySetInt(resource_units, 7, cUnitTypeAbstractWhale);
        xsArraySetInt(resource_units, 8, cUnitTypeAbstractFarm);
        xsArraySetInt(resource_units, 9, cUnitTypeMill);
        xsArraySetInt(resource_units, 10, cUnitTypeFarm);
        xsArraySetInt(resource_units, 11, cUnitTypeypRicePaddy);
        xsArraySetInt(resource_units, 12, cUnitTypeTree);
        xsArraySetInt(resource_units, 13, cUnitTypeWood);
        xsArraySetInt(resource_units, 14, cUnitTypeMinedResource);
        xsArraySetInt(resource_units, 15, cUnitTypeAbstractMine);
        xsArraySetInt(resource_units, 16, cUnitTypeAnimalPrey);
        xsArraySetInt(resource_units, 17, cUnitTypeHuntable);
        xsArraySetInt(resource_units, 18, cUnitTypeHerdable);
        xsArraySetInt(resource_units, 19, cUnitTypePlantation);
        xsArraySetInt(resource_units, 20, cUnitTypeFood);
        xsArraySetInt(resource_units, 21, cUnitTypeGold);
        xsArraySetInt(resource_units, 22, cUnitTypeHerdable);
    }

    float lowest_cost = 999999.9;
    int cheapest_tech = -1;
    for(i = 0; < xsArrayGetSize(resource_units))
    {
        int i_resource_unit = xsArrayGetInt(resource_units, i);
        int i_tech = kbTechTreeGetCheapestEconUpgrade(i_resource_unit);
        if (i_tech == -1)
            continue;
        if (kbTechGetStatus(i_tech) != cTechStatusObtainable)
            continue;
        if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, i_tech, true) >= 0)
            continue;
        if (findBuildingToResearchTech(i_tech) == -1)
            continue;
        float i_tech_cost = kbGetTechAICost(i_tech);
        if (i_tech_cost < lowest_cost)
        {
            lowest_cost = i_tech_cost;
            cheapest_tech = i_tech;
        }
    }

    if (cheapest_tech == -1)
        return;
    
    int building_to_use = findBuildingToResearchTech(cheapest_tech);
    if (building_to_use == -1)
        return;

    int economic_tech_research_plan = aiPlanCreate("Research Economic Tech (" + kbGetTechName(cheapest_tech) + ")", cPlanResearch);
    aiPlanSetDesiredPriority(economic_tech_research_plan, 100);
    aiPlanSetEscrowID(economic_tech_research_plan, cRootEscrowID);
    aiPlanSetVariableInt(economic_tech_research_plan, cResearchPlanBuildingID, 0, building_to_use);
    aiPlanSetVariableInt(economic_tech_research_plan, cResearchPlanTechID, 0, cheapest_tech);
    aiPlanSetEventHandler(economic_tech_research_plan, cPlanEventStateChange, "onEconomicResearchPlanStateChange");
    aiPlanSetActive(economic_tech_research_plan, true);
}


void ResearchUnitUpgrades(void)
{
    if (gMainBase == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 5000)
        return;
    last_call = xsGetTime();

    int villager_upgrade = kbTechTreeGetCheapestUnitUpgrade(gUnitTypeVillager);
    if (kbGetAge() >= cAge2 && villager_upgrade >= 0 && 
        kbTechGetStatus(villager_upgrade) == cTechStatusObtainable && 
        aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, villager_upgrade, true) == -1)
    {
        int villager_upgrade_plan = aiPlanCreate("Research Villager Upgrade (" + kbGetTechName(villager_upgrade) + ")", cPlanResearch);
        aiPlanSetDesiredPriority(villager_upgrade_plan, 100);
        aiPlanSetEscrowID(villager_upgrade_plan, cRootEscrowID);
        aiPlanSetVariableInt(villager_upgrade_plan, cResearchPlanTechID, 0, villager_upgrade);
        aiPlanSetEventHandler(villager_upgrade_plan, cPlanEventStateChange, "onUpgradePlanStateChange");
        aiPlanSetActive(villager_upgrade_plan, true);
    }

    int military_line1_upgrade = kbTechTreeGetCheapestUnitUpgrade(gMilitaryLine1);
    if (kbGetAge() >= cAge2 && military_line1_upgrade >= 0 
        && kbTechGetStatus(military_line1_upgrade) == cTechStatusObtainable 
        && aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, military_line1_upgrade, true) == -1)
    {
        int building_to_use = findBuildingToResearchTech(military_line1_upgrade);
        if (building_to_use >= 0)
        {
            int military_line1_upgrade_plan = aiPlanCreate("Research Line 1 Upgrade (" + kbGetTechName(military_line1_upgrade) + ")", cPlanResearch);
            aiPlanSetDesiredPriority(military_line1_upgrade_plan, 100);
            aiPlanSetEscrowID(military_line1_upgrade_plan, cRootEscrowID);
            aiPlanSetVariableInt(military_line1_upgrade_plan, cResearchPlanBuildingID, 0, building_to_use);
            aiPlanSetVariableInt(military_line1_upgrade_plan, cResearchPlanTechID, 0, military_line1_upgrade);
            aiPlanSetEventHandler(military_line1_upgrade_plan, cPlanEventStateChange, "onUpgradePlanStateChange");
            aiPlanSetActive(military_line1_upgrade_plan, true);

            return;
        }
    }

    int military_line2_upgrade = kbTechTreeGetCheapestUnitUpgrade(gMilitaryLine2);
    if (kbGetAge() >= cAge2 && military_line2_upgrade >= 0 
        && kbTechGetStatus(military_line2_upgrade) == cTechStatusObtainable 
        && aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, military_line2_upgrade, true) == -1)
    {
        building_to_use = findBuildingToResearchTech(military_line2_upgrade);
        if (building_to_use >= 0)
        {
            int military_line2_upgrade_plan = aiPlanCreate("Research Line 2 Upgrade (" + kbGetTechName(military_line2_upgrade) + ")", cPlanResearch);
            aiPlanSetDesiredPriority(military_line2_upgrade_plan, 100);
            aiPlanSetEscrowID(military_line2_upgrade_plan, cRootEscrowID);
            aiPlanSetVariableInt(military_line2_upgrade_plan, cResearchPlanBuildingID, 0, building_to_use);
            aiPlanSetVariableInt(military_line2_upgrade_plan, cResearchPlanTechID, 0, military_line2_upgrade);
            aiPlanSetEventHandler(military_line2_upgrade_plan, cPlanEventStateChange, "onUpgradePlanStateChange");
            aiPlanSetActive(military_line2_upgrade_plan, true);

            return;
        }
    }

    float lowest_upgrade_cost = 999999.9;
    int cheapest_upgrade = -1;
    for(unit_type = cUnitTypeUnit; <= cUnitTypeAbstractTrainLimitOne)
    {
        int i_upgrade = kbTechTreeGetCheapestUnitUpgrade(unit_type);
        if (i_upgrade == -1)
            continue;
        if (kbTechGetStatus(i_upgrade) != cTechStatusObtainable)
            continue;
        if (kbGetTechPercentComplete(i_upgrade) > 0.01)
            continue;
        if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, i_upgrade, true) >= 0)
            continue;
        if (findBuildingToResearchTech(i_upgrade) == -1)
            continue;
        float i_upgrade_cost = kbGetTechAICost(i_upgrade);
        if (i_upgrade_cost < lowest_upgrade_cost)
        {
            lowest_upgrade_cost = i_upgrade_cost;
            cheapest_upgrade = i_upgrade;
        }
    }

    float lowest_building_upgrade_cost = 999999.9;
    int cheapest_building_upgrade = -1;
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive))
    {
        int i_building = getUnit1(cUnitTypeLogicalTypeBuildingsNotWalls, cMyID, i);
        int i_building_protounit = kbUnitGetProtoUnitID(i_building);
        int i_building_upgrade = kbTechTreeGetCheapestUnitUpgrade(i_building_protounit);
        if (i_building_upgrade == -1)
            continue;
        if (kbTechGetStatus(i_building_upgrade) != cTechStatusObtainable)
            continue;
        if (kbGetTechPercentComplete(i_building_upgrade) > 0.01)
            continue;
        if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, i_building_upgrade, true) >= 0)
            continue;
        if (findBuildingToResearchTech(i_building_upgrade) == -1)
            continue;
        float i_building_upgrade_cost = kbGetTechAICost(i_building_upgrade);
        if (i_building_upgrade_cost < lowest_building_upgrade_cost)
        {
            lowest_building_upgrade_cost = i_building_upgrade_cost;
            cheapest_building_upgrade = i_building_upgrade;
        }
    }

    if (cheapest_upgrade >= 0)
    {
        building_to_use = findBuildingToResearchTech(cheapest_upgrade);
        if (building_to_use >= 0)
        {
            int unit_upgrade_plan = aiPlanCreate("Research Unit Upgrade (" + kbGetTechName(cheapest_upgrade) + ")", cPlanResearch);
            aiPlanSetDesiredPriority(unit_upgrade_plan, 100);
            aiPlanSetEscrowID(unit_upgrade_plan, cRootEscrowID);
            aiPlanSetVariableInt(unit_upgrade_plan, cResearchPlanBuildingID, 0, building_to_use);
            aiPlanSetVariableInt(unit_upgrade_plan, cResearchPlanTechID, 0, cheapest_upgrade);
            aiPlanSetEventHandler(unit_upgrade_plan, cPlanEventStateChange, "onUpgradePlanStateChange");
            aiPlanSetActive(unit_upgrade_plan, true);
        }
    }

    if (cheapest_building_upgrade >= 0)
    {
        building_to_use = findBuildingToResearchTech(cheapest_building_upgrade);
        if (building_to_use >= 0)
        {
            int building_upgrade_plan = aiPlanCreate("Research Building Upgrade (" + kbGetTechName(cheapest_building_upgrade) + ")", cPlanResearch);
            aiPlanSetDesiredPriority(building_upgrade_plan, 100);
            aiPlanSetEscrowID(building_upgrade_plan, cRootEscrowID);
            aiPlanSetVariableInt(building_upgrade_plan, cResearchPlanBuildingID, 0, building_to_use);
            aiPlanSetVariableInt(building_upgrade_plan, cResearchPlanTechID, 0, cheapest_building_upgrade);
            aiPlanSetEventHandler(building_upgrade_plan, cPlanEventStateChange, "onUpgradePlanStateChange");
            aiPlanSetActive(building_upgrade_plan, true);
        }
    }
}


rule DestroyResearchPlans
inactive
minInterval 30
{
    for(i = 0; < aiPlanGetNumber(cPlanResearch))
        aiPlanDestroy(aiPlanGetIDByIndex(cPlanResearch, -1, true, i));
}


void onUpgradePlanStateChange(int upgrade_plan = -1)
{
    UpdateGathererAllocation();
}


void onEconomicResearchPlanStateChange(int economic_tech_research_plan = -1)
{
    UpdateGathererAllocation();
}
