// Calculate the percentages of gatherers to task on each resource type.
void UpdateGathererAllocation(void)
{
    if (gStartup == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 10000)
        return;
    last_call = xsGetTime();

    xsSetRuleMinIntervalSelf(10);

    // ========================================================================
    // 1. Setting up for the allocation.
    // ========================================================================

    // Set the gatherer allocation to be controlled entirely by this script:
    aiSetResourceGathererPercentageWeight(cRGPScript, 1.0);
    // Ignore all gatherer allocations calculated by the internal AI:
    aiSetResourceGathererPercentageWeight(cRGPCost, 0.0);
    // Normalizes all of the resource gatherer percentages weights to 1.0.
    aiNormalizeResourceGathererPercentageWeights();

    // Get the amounts of resources we currently have.
    float inventory_gold = kbResourceGet(cResourceGold);
    float inventory_wood = kbResourceGet(cResourceWood);
    float inventory_food = kbResourceGet(cResourceFood);
    float inventory_total = inventory_gold + inventory_wood + inventory_food;
    // Store the total as an integer value so we can use '==' comparison.
    int int_inventory_total = inventory_total;

    int i_plan = -1;
    // Calculate the amounts of resources we're planning to spend.
    float planned_gold = 0.0;
    float planned_wood = 0.0;
    float planned_food = 0.0;

    for(i = 0; < aiPlanGetNumber())
    {
        i_plan = aiPlanGetIDByIndex(-1, -1, true, i);
        if (aiPlanGetState(i_plan) == cPlanStateResearch || aiPlanGetState(i_plan) == cPlanStateBuild)
            continue;
        
        if (aiPlanGetType(i_plan) == cPlanBuild && kbUnitIsType(aiPlanGetVariableInt(i_plan, cBuildPlanBuildUnitID, 0), cUnitTypeAbstractWagon))
            continue;

        switch(aiPlanGetType(i_plan))
        {
            case cPlanResearch:
            {
                planned_gold = planned_gold + kbTechCostPerResource(aiPlanGetVariableInt(i_plan, cResearchPlanTechID, 0), cResourceGold);
                planned_wood = planned_wood + kbTechCostPerResource(aiPlanGetVariableInt(i_plan, cResearchPlanTechID, 0), cResourceWood);
                planned_food = planned_food + kbTechCostPerResource(aiPlanGetVariableInt(i_plan, cResearchPlanTechID, 0), cResourceFood);
                break;
            }
            case cPlanBuild:
            {
                planned_gold = planned_gold + kbUnitCostPerResource(aiPlanGetVariableInt(i_plan, cBuildPlanBuildingTypeID, 0), cResourceGold);
                planned_wood = planned_wood + kbUnitCostPerResource(aiPlanGetVariableInt(i_plan, cBuildPlanBuildingTypeID, 0), cResourceWood);
                planned_food = planned_food + kbUnitCostPerResource(aiPlanGetVariableInt(i_plan, cBuildPlanBuildingTypeID, 0), cResourceFood);
                break;
            }
            case cPlanTrain:
            {
                int protounit_to_maintain = aiPlanGetVariableInt(i_plan, cTrainPlanUnitType, 0);
                int current_count = kbUnitCount(cMyID, protounit_to_maintain, cUnitStateABQ);
                int number_to_maintain = aiPlanGetVariableInt(i_plan, cTrainPlanNumberToMaintain, 0);
                int shortfall = xsMax(0, number_to_maintain - current_count);

                if (kbProtoUnitIsType(cMyID, protounit_to_maintain, cUnitTypeAbstractVillager))
                    shortfall = xsMax(3, kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateAlive));
                
                if (kbProtoUnitIsType(cMyID, protounit_to_maintain, cUnitTypeLogicalTypeLandMilitary))
                {
                    shortfall = 6 + kbGetAge();
                    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom)
                        shortfall = 0;
                }
                
                planned_gold = planned_gold + kbUnitCostPerResource(protounit_to_maintain, cResourceGold) * shortfall;
                planned_wood = planned_wood + kbUnitCostPerResource(protounit_to_maintain, cResourceWood) * shortfall;
                planned_food = planned_food + kbUnitCostPerResource(protounit_to_maintain, cResourceFood) * shortfall;
                break;
            }
        }
    }

    float planned_total = planned_gold + planned_wood + planned_food;
    // Store the total as an integer value so we can use '==' comparison.
    int int_planned_total = planned_total;

    // Calculate shortfalls (i.e. the amounts by which the inventories are behind/ahead of the planned expenditures)
    float shortfall_gold = xsMax(0.0, planned_gold - inventory_gold);
    float shortfall_wood = xsMax(0.0, planned_wood - inventory_wood);
    float shortfall_food = xsMax(0.0, planned_food - inventory_food);
    float shortfall_total = shortfall_gold + shortfall_wood + shortfall_food;
    // Store the total as an integer value so we can use '==' comparison.
    int int_shortfall_total = shortfall_total;

    float gatherer_percentage_gold = 0.34;
    float gatherer_percentage_wood = 0.33;
    float gatherer_percentage_food = 0.33;


    // ========================================================================
    // 2. Preliminary gatherer allocation.
    // ========================================================================

    if (int_shortfall_total == 0)
    {
        // Special case: we're not planning to spend resources OR we have enough resources for everything we're planning.

        if (int_inventory_total == 0)
        {
            // If there's nothing in inventory, just distribute gatherers equally.
            gatherer_percentage_gold = 0.34;
            gatherer_percentage_wood = 0.33;
            gatherer_percentage_food = 0.33;
        }
        else
        {
            // Otherwise, make resources catch up on each other.
            gatherer_percentage_gold = 1.0 - inventory_gold / inventory_total;
            gatherer_percentage_wood = 1.0 - inventory_wood / inventory_total;
            gatherer_percentage_food = 1.0 - inventory_food / inventory_total;
        }
    }
    else
    {
        // Normal case: we still need to gather resources.

        // Gather the most needed resources.
        // TODO -- We need to find a math that is smarter than this.
        gatherer_percentage_gold = shortfall_gold / shortfall_total;
        gatherer_percentage_wood = shortfall_wood / shortfall_total;
        gatherer_percentage_food = shortfall_food / shortfall_total;
    }


    // ========================================================================
    // 3. Adjustments based on different situations.
    // ========================================================================

    // If we're running out of trees, just disable wood gathering.
    int planned_number_of_wood_gatherers = gatherer_percentage_wood * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    float amount_of_valid_wood = kbGetAmountValidResources(kbBaseGetMainID(cMyID), cResourceWood, cAIResourceSubTypeEasy, cNaturalResourceDistance);
    float valid_wood_per_gatherer = amount_of_valid_wood / planned_number_of_wood_gatherers;
    if (valid_wood_per_gatherer < 100.0 || gNoMoreTree)
        gatherer_percentage_wood = 0.0;
    

    // ========================================================================
    // 4. Overrides for special situations.
    // ========================================================================

    if (kbGetAge() == cAge1 && ageingUp() == false)
    {
        // In Age1, everyone goes full on food.
        gatherer_percentage_gold = 0.0;
        gatherer_percentage_wood = 0.0;
        gatherer_percentage_food = 1.0;

        // In Age1, Dutch need at least 15 settlers before going full on food.
        if (cMyCiv == cCivDutch)
        {
            float gold_so_far = 600.0 + kbTotalResourceGet(cResourceGold);
            if (gold_so_far < 1700.0)
            {
                gatherer_percentage_gold = 1.0;
                gatherer_percentage_wood = 0.0;
                gatherer_percentage_food = 0.0;
            }
        }
    }

    if (kbGetAge() == cAge1 && ageingUp() == true)
    {
        if (gStrategy == cStrategyBoom)
        {
            // TODO -- Take decks into account
            gatherer_percentage_gold = 0.45;
            gatherer_percentage_wood = 0.1;
            gatherer_percentage_food = 0.45;
        }
        else
        {
            gatherer_percentage_gold = 0.1;
            gatherer_percentage_wood = 0.8;
            gatherer_percentage_food = 0.1;
        }
    }

    // ========================================================================
    // 5. Final gatherer allocation.
    // ========================================================================

    aiSetResourceGathererPercentage(cResourceGold, gatherer_percentage_gold);
    aiSetResourceGathererPercentage(cResourceWood, gatherer_percentage_wood);
    aiSetResourceGathererPercentage(cResourceFood, gatherer_percentage_food);
    // Normalizes all of the resource gatherer percentages to 1.0.
    aiNormalizeResourceGathererPercentages();
}


// ============================================================================
// Special rule for gathering crates regardless of any gatherer allocation.
// ============================================================================
void GatherCrates()
{
    if (gStartup == false)
        return;

    static int last_call = -1;
    if (xsGetTime() < last_call + 5000)
        return;
    last_call = xsGetTime();

    int number_crate_gatherers = cMaxNumberCrateGatherers;
    for(i = 0; < getUnitCountByLocation(cUnitTypeAbstractResourceCrate, cPlayerRelationAny, kbGetMapCenter(), 5000.0))
    {
        int i_crate = getUnit1(cUnitTypeAbstractResourceCrate, cPlayerRelationAny, i);
        if (kbUnitGetPlayerID(i_crate) != 0 && kbUnitGetPlayerID(i_crate) != cMyID)
            continue;
        
        if (kbUnitGetPlayerID(i_crate) == 0 && kbBaseGetOwner(kbUnitGetBaseID(i_crate)) != cMyID)
            continue;
        
        vector i_crate_position = kbUnitGetPosition(i_crate);
        for(j = 0; < kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive))
        {
            if (number_crate_gatherers <= 0)
                return;
            
            int j_villager = getUnitByLocation1(cUnitTypeAbstractVillager, cMyID, i_crate_position, 5000.0, j);
            if (kbUnitIsType(kbUnitGetTargetUnitID(j_villager), cUnitTypeAbstractResourceCrate))
            {
                number_crate_gatherers--;
                if (kbUnitIsType(j_villager, cUnitTypeSettlerWagon))
                    number_crate_gatherers--;
                continue;
            }

            if (kbUnitIsType(j_villager, cUnitTypeAbstractWagon))
                continue;
            
            if (kbUnitGetPlanID(j_villager) >= 0)
                continue;
            
            if (j_villager == gShepherd)
                continue;
            
            vector j_villager_position = kbUnitGetPosition(j_villager);
            if (kbCanPath2(j_villager_position, i_crate_position, kbUnitGetProtoUnitID(j_villager)) == false)
                continue;
            
            aiTaskUnitWork(j_villager, i_crate);
            number_crate_gatherers--;
            if (kbUnitIsType(j_villager, cUnitTypeSettlerWagon))
                number_crate_gatherers--;
        }
    }
}


// ============================================================================
// Prevent AIs from calling the rule 'GatherResources' all at the same time.
// Don't allow more than 2 "simultaneous" calls.
// ============================================================================

rule DelayResourceGatheringActivation
group rgStartup
inactive
minInterval 1
{
    static int player = 1;
    if (kbIsPlayerValid(player) == false)
    {
        xsDisableSelf();
        return;
    }

    if (kbIsPlayerHuman(player) == true)
    {
        player++;
        xsEnableRule("RunImmediatelyDelayResourceGatheringActivation");
        return;
    }

    if (player != cMyID)
    {
        player++;
        return;
    }
    
    xsDisableSelf();

    xsEnableRule("GatherResources");
}

rule RunImmediatelyDelayResourceGatheringActivation
inactive
runImmediately
priority 100
{
    xsDisableSelf();
    DelayResourceGatheringActivation();
}


rule GatherResources
inactive
minInterval 5
{
    rGatherResourcesFailsafe = kbGetAge() >= cAge3;

    if (kbBaseGetMainID(cMyID) == -1)
        return;
    
    int number_gatherers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    // 1 Settler Wagon = 2 Settlers
    number_gatherers = number_gatherers + kbUnitCount(cMyID, cUnitTypeSettlerWagon, cUnitStateAlive);

    int number_gold_gatherers = number_gatherers * aiGetResourceGathererPercentage(cResourceGold);
    int number_wood_gatherers = number_gatherers * aiGetResourceGathererPercentage(cResourceWood);
    int number_food_gatherers = number_gatherers - number_gold_gatherers - number_wood_gatherers;
    int number_crate_gatherers = cMaxNumberCrateGatherers;

    bool need_house = false;
    for(i = 0; < aiPlanGetNumber(cPlanBuild))
    {
        int i_build_plan = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
        if (aiPlanGetState(i_build_plan) == cPlanStateBuild)
            continue;
        if (gUnitTypeHouse >= 0 && aiPlanGetVariableInt(i_build_plan, cBuildPlanBuildingTypeID, 0) == gUnitTypeHouse)
        {
            need_house = true;
            break;
        }
    }

    if (kbGetAge() == cAge1 && ageingUp() == false)
        need_house = false;

    // Force wood gathering when we need a house
    // TODO -- We need to take food and coin cost into account
    if (need_house && kbUnitCostPerResource(gUnitTypeHouse, cResourceWood) > 0.0 && 
        kbResourceGet(cResourceWood) < kbUnitCostPerResource(gUnitTypeHouse, cResourceWood))
    {
        number_wood_gatherers = xsMax(number_wood_gatherers, xsMin(5, number_gatherers));
    }

    int i_gatherer = -1;
    int i_gatherer_target = -1;
    vector i_gatherer_position = cInvalidVector;
    int j_resource = -1;
    vector j_resource_position = cInvalidVector;
    vector closest_ally_town_center_position = cInvalidVector;
    int closest_town_center = -1;
    vector closest_town_center_position = cInvalidVector;

    // Make the query distance very big so the gatherer always finds the main base.
    const float resource_query_distance = 5000.0;
    // List of tracked resources.
    static int tracked_resource_list = -1;
    int number_tracked_resources = 0;

    if (tracked_resource_list == -1)
        tracked_resource_list = xsArrayCreateInt(1000, -1, "List of tracked resources");

    int scratch = 0;

    static int mbq_dead_animals = -1;
    static int mbq_alive_animals = -1;
    static int mbq_fruits = -1;
    static int mbq_farms = -1;
    static int mbq_trees = -1;
    static int mbq_mines = -1;
    static int mbq_plantations = -1;

    if (mbq_dead_animals == -1)
    {
        mbq_dead_animals = kbGaiaUnitQueryCreate("Find dead animals around the main base");
        kbGaiaUnitQuerySetUnitType(mbq_dead_animals, cUnitTypeAnimalPrey);
        kbGaiaUnitQuerySetPlayerRelation(mbq_dead_animals, -1);
        kbGaiaUnitQuerySetPlayerID(mbq_dead_animals, 0, false);
        kbGaiaUnitQuerySetActionType(mbq_dead_animals, cActionDecay);
        kbGaiaUnitQuerySetAscendingSort(mbq_dead_animals, true);
        
        mbq_alive_animals = kbUnitQueryCreate("Find alive animals around the main base");
        kbUnitQuerySetUnitType(mbq_alive_animals, cUnitTypeAnimalPrey);
        kbUnitQuerySetPlayerID(mbq_alive_animals, -1, false);
        kbUnitQuerySetPlayerRelation(mbq_alive_animals, cPlayerRelationAny);
        kbUnitQuerySetState(mbq_alive_animals, cUnitStateAlive);
        kbUnitQuerySetIgnoreKnockedOutUnits(mbq_alive_animals, true);
        kbUnitQuerySetAscendingSort(mbq_alive_animals, true);
        
        mbq_fruits = kbUnitQueryCreate("Find alive fruits around the main base");
        kbUnitQuerySetUnitType(mbq_fruits, cUnitTypeAbstractFruit);
        kbUnitQuerySetPlayerID(mbq_fruits, -1, false);
        kbUnitQuerySetPlayerRelation(mbq_fruits, cPlayerRelationAny);
        kbUnitQuerySetState(mbq_fruits, cUnitStateAlive);
        kbUnitQuerySetIgnoreKnockedOutUnits(mbq_fruits, true);
        kbUnitQuerySetAscendingSort(mbq_alive_animals, true);
        
        mbq_farms = kbUnitQueryCreate("Find alive farms around the main base");
        kbUnitQuerySetUnitType(mbq_farms, cUnitTypeAbstractFarm);
        kbUnitQuerySetPlayerRelation(mbq_farms, -1);
        kbUnitQuerySetPlayerID(mbq_farms, cMyID, false);
        kbUnitQuerySetState(mbq_farms, cUnitStateAlive);
        kbUnitQuerySetIgnoreKnockedOutUnits(mbq_farms, true);
        kbUnitQuerySetAscendingSort(mbq_alive_animals, true);
        
        mbq_trees = kbUnitQueryCreate("Find alive trees around the main base");
        kbUnitQuerySetUnitType(mbq_trees, cUnitTypeTree);
        kbUnitQuerySetPlayerRelation(mbq_trees, -1);
        kbUnitQuerySetPlayerID(mbq_trees, 0, false);
        kbUnitQuerySetState(mbq_trees, cUnitStateAlive);
        kbUnitQuerySetIgnoreKnockedOutUnits(mbq_trees, true);
        kbUnitQuerySetAscendingSort(mbq_alive_animals, true);
        
        mbq_mines = kbUnitQueryCreate("Find alive mines around the main base");
        kbUnitQuerySetUnitType(mbq_mines, cUnitTypeMinedResource);
        kbUnitQuerySetPlayerRelation(mbq_mines, -1);
        kbUnitQuerySetPlayerID(mbq_mines, 0, false);
        kbUnitQuerySetState(mbq_mines, cUnitStateAlive);
        kbUnitQuerySetIgnoreKnockedOutUnits(mbq_mines, true);
        kbUnitQuerySetAscendingSort(mbq_alive_animals, true);
        
        mbq_plantations = kbUnitQueryCreate("Find alive plantations around the main base");
        kbUnitQuerySetUnitType(mbq_plantations, cUnitTypeLogicalTypeBuildingsNotWalls);
        kbUnitQuerySetPlayerRelation(mbq_plantations, -1);
        kbUnitQuerySetPlayerID(mbq_plantations, cMyID, false);
        kbUnitQuerySetState(mbq_plantations, cUnitStateAlive);
        kbUnitQuerySetIgnoreKnockedOutUnits(mbq_plantations, true);
        kbUnitQuerySetAscendingSort(mbq_alive_animals, true);
    }

    kbGaiaUnitQueryResetResults(mbq_dead_animals);
    kbGaiaUnitQuerySetPosition(mbq_dead_animals, getMainBaseLocation());
    kbGaiaUnitQuerySetMaximumDistance(mbq_dead_animals, cNaturalResourceDistance);
    int mbq_dead_animals_count = kbGaiaUnitQueryExecute(mbq_dead_animals);

    kbUnitQueryResetResults(mbq_alive_animals);
    kbUnitQuerySetPosition(mbq_alive_animals, getMainBaseLocation());
    kbUnitQuerySetMaximumDistance(mbq_alive_animals, cNaturalResourceDistance);
    int mbq_alive_animals_count = kbUnitQueryExecute(mbq_alive_animals);

    kbUnitQueryResetResults(mbq_fruits);
    kbUnitQuerySetPosition(mbq_fruits, getMainBaseLocation());
    kbUnitQuerySetMaximumDistance(mbq_fruits, cNaturalResourceDistance);
    int mbq_fruits_count = kbUnitQueryExecute(mbq_fruits);

    kbUnitQueryResetResults(mbq_farms);
    kbUnitQuerySetPosition(mbq_farms, getMainBaseLocation());
    int mbq_farms_count = kbUnitQueryExecute(mbq_farms);

    kbUnitQueryResetResults(mbq_trees);
    kbUnitQuerySetPosition(mbq_trees, getMainBaseLocation());
    kbUnitQuerySetMaximumDistance(mbq_trees, cNaturalResourceDistance);
    int mbq_trees_count = kbUnitQueryExecute(mbq_trees);
    
    kbUnitQueryResetResults(mbq_mines);
    kbUnitQuerySetPosition(mbq_mines, getMainBaseLocation());
    kbUnitQuerySetMaximumDistance(mbq_mines, cNaturalResourceDistance);
    int mbq_mines_count = kbUnitQueryExecute(mbq_mines);

    kbUnitQueryResetResults(mbq_plantations);
    kbUnitQuerySetPosition(mbq_plantations, getMainBaseLocation());
    int mbq_plantations_count = kbUnitQueryExecute(mbq_plantations);

    for(i = 0; < number_gatherers)
    {
        i_gatherer = getUnit1(cUnitTypeAbstractVillager, cMyID, i);
        
        if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_gatherer)) != cMovementTypeLand)
        {
            continue;
        }
        
        i_gatherer_target = kbUnitGetTargetUnitID(i_gatherer);

        if (kbUnitIsType(i_gatherer_target, cUnitTypeAbstractResourceCrate) && number_crate_gatherers >= 1)
        {
            number_crate_gatherers--;
            if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                number_crate_gatherers--;
            
            continue;
        }

        if (kbUnitGetCurrentInventory(i_gatherer_target, cResourceGold) > 0.1 && number_gold_gatherers >= 1)
        {
            number_gold_gatherers--;
            if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                number_gold_gatherers--;
            
            continue;
        }
        
        if (kbUnitGetCurrentInventory(i_gatherer_target, cResourceWood) > 0.1 && number_wood_gatherers >= 1)
        {
            number_wood_gatherers--;
            if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                number_wood_gatherers--;
            
            continue;
        }
        
        if (kbUnitGetCurrentInventory(i_gatherer_target, cResourceFood) > 0.1 && number_food_gatherers >= 1)
        {
            number_food_gatherers--;
            if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                number_food_gatherers--;
            
            continue;
        }

        if (kbUnitIsType(i_gatherer, cUnitTypeAbstractWagon))
        {
            continue;
        }
        
        if (kbUnitGetPlanID(i_gatherer) >= 0)
        {
            continue;
        }
        
        if (kbUnitGetActionType(i_gatherer) == cActionBuild)
        {
            continue;
        }
        
        if (kbUnitGetActionType(i_gatherer) == cActionMove)
        {
            continue;
        }
        
        if (i_gatherer == gShepherd)
        {
            continue;
        }
        
        if (isFlagged(i_gatherer, cFlagTownBell))
        {
            continue;
        }
        
        i_gatherer_position = kbUnitGetPosition(i_gatherer);

        int food_to_gather = -1;
        int wood_to_gather = -1;
        int gold_to_gather = -1;

        if (number_food_gatherers >= 1 && cMyCulture != cCultureJapanese)
        {
            scratch = 0;

            for(j = 0; < mbq_dead_animals_count)
            {
                j_resource = kbGaiaUnitQueryGetResult(mbq_dead_animals, j);
                j_resource_position = kbUnitGetPosition(j_resource);

                closest_ally_town_center_position = findClosestAllyTCPos(j_resource_position);
                if (closest_ally_town_center_position != cInvalidVector)
                {
                    closest_town_center = getUnitByLocation1(cUnitTypeTownCenter, cMyID, closest_ally_town_center_position, 5000.0, 0);
                    closest_town_center_position = kbUnitGetPosition(closest_town_center);
                    
                    if (xsVectorLength(closest_town_center_position - closest_ally_town_center_position) > cSameBaseThreshold)
                    {
                        if (xsVectorLength(j_resource_position - closest_ally_town_center_position) < cAllyResourceDistance)
                        {
                            continue;
                        }
                    }
                }
                
                if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                {
                    continue;
                }
                
                if (kbUnitGetCurrentInventory(j_resource, cResourceFood) < 0.1)
                {
                    continue;
                }
                
                if (isFlagged(j_resource, cFlagTracked) == false)
                {
                    setFlag(j_resource, cFlagTracked);
                    scratch = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationAny, j_resource_position, 6.0);
                    scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                    aiQVSet(cFlagGathererCount + j_resource, scratch);
                    xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                    number_tracked_resources++;
                }

                if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                {
                    continue;
                }
                
                food_to_gather = j_resource;
                goto lbPrioritizeDecayingAnimal;
                break;
            }
        }

        if (number_food_gatherers >= 1 && cMyCulture != cCultureJapanese)
        {
            if (mbq_alive_animals_count <= 3)
                gTimeToFarm = true;
            
            for(j = 0; < mbq_alive_animals_count)
            {
                j_resource = kbUnitQueryGetResult(mbq_alive_animals, j);
                j_resource_position = kbUnitGetPosition(j_resource);

                closest_ally_town_center_position = findClosestAllyTCPos(j_resource_position);
                if (closest_ally_town_center_position != cInvalidVector)
                {
                    closest_town_center = getUnitByLocation1(cUnitTypeTownCenter, cMyID, closest_ally_town_center_position, 5000.0, 0);
                    closest_town_center_position = kbUnitGetPosition(closest_town_center);
                    
                    if (xsVectorLength(closest_town_center_position - closest_ally_town_center_position) > cSameBaseThreshold)
                    {
                        if (xsVectorLength(j_resource_position - closest_ally_town_center_position) < cAllyResourceDistance)
                        {
                            continue;
                        }
                    }
                }

                if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                {
                    continue;
                }
                
                if (isResourceGoodToGather(j_resource) == false)
                {
                    continue;
                }
                
                if (isFlagged(j_resource, cFlagTracked) == false)
                {
                    setFlag(j_resource, cFlagTracked);
                    if (kbUnitGetPlayerID(j_resource) != cMyID)
                        scratch = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationAny, j_resource_position, 6.0);
                    else
                        scratch = kbUnitGetNumberWorkersIfSeeable(j_resource);
                    scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                    aiQVSet(cFlagGathererCount + j_resource, scratch);
                    xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                    number_tracked_resources++;
                }

                if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                {
                    continue;
                }
                
                food_to_gather = j_resource;
                goto lbPrioritizeAliveAnimal;
                break;
            }
        }

        if (number_food_gatherers >= 1)
        {
            for(j = 0; < mbq_fruits_count)
            {
                j_resource = kbUnitQueryGetResult(mbq_fruits, j);
                j_resource_position = kbUnitGetPosition(j_resource);

                closest_ally_town_center_position = findClosestAllyTCPos(j_resource_position);
                if (closest_ally_town_center_position != cInvalidVector)
                {
                    closest_town_center = getUnitByLocation1(cUnitTypeTownCenter, cMyID, closest_ally_town_center_position, 5000.0, 0);
                    closest_town_center_position = kbUnitGetPosition(closest_town_center);
                    
                    if (xsVectorLength(closest_town_center_position - closest_ally_town_center_position) > cSameBaseThreshold)
                    {
                        if (xsVectorLength(j_resource_position - closest_ally_town_center_position) < cAllyResourceDistance)
                        {
                            continue;
                        }
                    }
                }

                if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                {
                    continue;
                }
                
                if (isResourceGoodToGather(j_resource) == false)
                {
                    continue;
                }
                
                if (isFlagged(j_resource, cFlagTracked) == false)
                {
                    setFlag(j_resource, cFlagTracked);
                    if (kbUnitGetPlayerID(j_resource) != cMyID)
                        scratch = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationAny, j_resource_position, 6.0);
                    else
                        scratch = kbUnitGetNumberWorkersIfSeeable(j_resource);
                    scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                    aiQVSet(cFlagGathererCount + j_resource, scratch);
                    xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                    number_tracked_resources++;
                }

                if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                {
                    continue;
                }
                
                food_to_gather = j_resource;
                goto lbPrioritizeAbstractFruit;
                break;
            }
        }

        if (number_food_gatherers >= 1)
        {
            for(j = 0; < mbq_farms_count)
            {
                j_resource = kbUnitQueryGetResult(mbq_farms, j);
                j_resource_position = kbUnitGetPosition(j_resource);

                if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                {
                    continue;
                }
                
                if (isResourceGoodToGather(j_resource) == false)
                {
                    continue;
                }
                
                if (isFlagged(j_resource, cFlagTracked) == false)
                {
                    setFlag(j_resource, cFlagTracked);
                    scratch = kbUnitGetNumberWorkersIfSeeable(j_resource);
                    scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                    aiQVSet(cFlagGathererCount + j_resource, scratch);
                    xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                    number_tracked_resources++;
                }

                if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                {
                    continue;
                }
                
                food_to_gather = j_resource;
                break;
            }
        }

        label lbPrioritizeDecayingAnimal;
        label lbPrioritizeAliveAnimal;
        label lbPrioritizeAbstractFruit;

        if (number_wood_gatherers >= 1)
        {
            for(j = 0; < mbq_trees_count)
            {
                j_resource = kbUnitQueryGetResult(mbq_trees, j);
                j_resource_position = kbUnitGetPosition(j_resource);

                if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                {
                    continue;
                }
                
                if (isResourceGoodToGather(j_resource) == false)
                {
                    continue;
                }
                
                if (isFlagged(j_resource, cFlagTracked) == false)
                {
                    setFlag(j_resource, cFlagTracked);
                    scratch = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationAny, j_resource_position, 6.0);
                    scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                    aiQVSet(cFlagGathererCount + j_resource, scratch);
                    xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                    number_tracked_resources++;
                }

                if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                {
                    continue;
                }
                
                wood_to_gather = j_resource;
                break;
            }

            if (wood_to_gather == -1)
            {
                gNoMoreTree = true;
            }
        }

        if (number_gold_gatherers >= 1)
        {
            if (mbq_mines_count * 20 < kbUnitCount(cMyID, cUnitTypeAffectedByTownBell, cUnitStateAlive) * aiGetResourceGathererPercentage(cResourceGold))
                gTimeForPlantation = true;
            
            for(j = 0; < mbq_mines_count)
            {
                j_resource = kbUnitQueryGetResult(mbq_mines, j);
                j_resource_position = kbUnitGetPosition(j_resource);

                closest_ally_town_center_position = findClosestAllyTCPos(j_resource_position);
                if (closest_ally_town_center_position != cInvalidVector)
                {
                    closest_town_center = getUnitByLocation1(cUnitTypeTownCenter, cMyID, closest_ally_town_center_position, 5000.0, 0);
                    closest_town_center_position = kbUnitGetPosition(closest_town_center);
                    
                    if (xsVectorLength(closest_town_center_position - closest_ally_town_center_position) > cSameBaseThreshold)
                    {
                        if (xsVectorLength(j_resource_position - closest_ally_town_center_position) < cAllyResourceDistance)
                        {
                            continue;
                        }
                    }
                }

                if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                {
                    continue;
                }
                
                if (isResourceGoodToGather(j_resource) == false)
                {
                    continue;
                }
                
                if (isFlagged(j_resource, cFlagTracked) == false)
                {
                    setFlag(j_resource, cFlagTracked);
                    scratch = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationAny, j_resource_position, 7.5);
                    scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                    aiQVSet(cFlagGathererCount + j_resource, scratch);
                    xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                    number_tracked_resources++;
                }

                if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                {
                    continue;
                }
                
                gold_to_gather = j_resource;
                goto lbPrioritizeMine;
                break;
            }
        }

        if (number_gold_gatherers >= 1)
        {
            for(j = 0; < mbq_plantations_count)
            {
                j_resource = kbUnitQueryGetResult(mbq_plantations, j);
                j_resource_position = kbUnitGetPosition(j_resource);

                if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                {
                    continue;
                }
                
                if (isResourceGoodToGather(j_resource) == false)
                {
                    continue;
                }
                
                if (kbUnitGetCurrentInventory(j_resource, cResourceGold) < 0.1)
                {
                    continue;
                }
                
                if (isFlagged(j_resource, cFlagTracked) == false)
                {
                    setFlag(j_resource, cFlagTracked);
                    scratch = kbUnitGetNumberWorkersIfSeeable(j_resource);
                    scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                    aiQVSet(cFlagGathererCount + j_resource, scratch);
                    xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                    number_tracked_resources++;
                }

                if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                {
                    continue;
                }
                
                gold_to_gather = j_resource;
                break;
            }
        }

        label lbPrioritizeMine;

        float distance_to_food = xsVectorLength(i_gatherer_position - kbUnitGetPosition(food_to_gather));
        float distance_to_wood = xsVectorLength(i_gatherer_position - kbUnitGetPosition(wood_to_gather));
        float distance_to_gold = xsVectorLength(i_gatherer_position - kbUnitGetPosition(gold_to_gather));

        if (distance_to_food < distance_to_wood)
        {
            if (distance_to_food < distance_to_gold)
            {
                aiTaskUnitWork(i_gatherer, food_to_gather);
                number_food_gatherers--;
                if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                    number_food_gatherers--;
                aiQVSet(cFlagGathererCount + food_to_gather, aiQVGet(cFlagGathererCount + food_to_gather) + 1);
            }
            else
            {
                aiTaskUnitWork(i_gatherer, gold_to_gather);
                number_gold_gatherers--;
                if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                    number_gold_gatherers--;
                aiQVSet(cFlagGathererCount + gold_to_gather, aiQVGet(cFlagGathererCount + gold_to_gather) + 1);
            }
        }
        else if (distance_to_wood < distance_to_gold)
        {
            aiTaskUnitWork(i_gatherer, wood_to_gather);
            number_wood_gatherers--;
            if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                number_wood_gatherers--;
            aiQVSet(cFlagGathererCount + wood_to_gather, aiQVGet(cFlagGathererCount + wood_to_gather) + 1);
        }
        else
        {
            aiTaskUnitWork(i_gatherer, gold_to_gather);
            number_gold_gatherers--;
            if (kbUnitIsType(i_gatherer, cUnitTypeSettlerWagon))
                number_gold_gatherers--;
            aiQVSet(cFlagGathererCount + gold_to_gather, aiQVGet(cFlagGathererCount + gold_to_gather) + 1);
        }
    }

    for(i = 0; < number_tracked_resources)
        unsetFlag(xsArrayGetInt(tracked_resource_list, i), cFlagTracked);
}


void GatherResourcesFailsafe(void)
{
    if (rGatherResourcesFailsafe == false)
        return;
    
    static int last_call = -1;
    if (xsGetTime() < last_call + 5000)
        return;
    last_call = xsGetTime();

    if (kbBaseGetMainID(cMyID) == -1)
        return;

    // List of tracked resources.
    static int tracked_resource_list = -1;
    int number_tracked_resources = 0;

    if (tracked_resource_list == -1)
        tracked_resource_list = xsArrayCreateInt(1000, -1, "List of tracked resources");

    int scratch = 0;

    static int idle_gatherer_query = -1;
    if (idle_gatherer_query == -1)
    {
        idle_gatherer_query = kbUnitQueryCreate("Find idle gatherers for GatherResourcesFailsafe");
        kbUnitQuerySetUnitType(idle_gatherer_query, cUnitTypeAbstractVillager);
        kbUnitQuerySetPlayerRelation(idle_gatherer_query, -1);
        kbUnitQuerySetPlayerID(idle_gatherer_query, cMyID, false);
        kbUnitQuerySetState(idle_gatherer_query, cUnitStateAlive);
        kbUnitQuerySetIgnoreKnockedOutUnits(idle_gatherer_query, true);
        kbUnitQuerySetActionType(idle_gatherer_query, cActionIdle);
    }

    kbUnitQueryResetResults(idle_gatherer_query);
    for(i = 0; < kbUnitQueryExecute(idle_gatherer_query))
    {
        int i_gatherer = kbUnitQueryGetResult(idle_gatherer_query, i);
        
        if (kbUnitIsType(i_gatherer, cUnitTypeAbstractWagon))
            continue;
        
        if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_gatherer)) != cMovementTypeLand)
            continue;
        
        if (kbUnitGetPlanID(i_gatherer) >= 0)
            continue;
        
        if (i_gatherer == gShepherd)
            continue;
        
        if (isFlagged(i_gatherer, cFlagTownBell))
            continue;
        
        vector i_gatherer_position = kbUnitGetPosition(i_gatherer);

        for(j = 0; < 50)
        {
            int j_resource = getUnitByLocation1(cUnitTypeResource, cPlayerRelationAny, i_gatherer_position, 1000.0, j);
            vector j_resource_position = kbUnitGetPosition(j_resource);

            if (kbCanPath2(i_gatherer_position, j_resource_position, kbUnitGetProtoUnitID(i_gatherer)) == false)
                continue;
            
            if (kbUnitGetCurrentInventory(j_resource, cResourceGold) < 0.1 && 
                kbUnitGetCurrentInventory(j_resource, cResourceWood) < 0.1 && 
                kbUnitGetCurrentInventory(j_resource, cResourceFood) < 0.1)
            {
                continue;
            }
            
            if (kbUnitGetPlayerID(j_resource) != 0 && kbUnitGetPlayerID(j_resource) != cMyID)
                continue;
            
            // Don't slaughter animals even if we don't have anything to do.
            // TODO -- Handle the case where we literally have nothing else to do.
            if (kbUnitIsType(j_resource, cUnitTypeHuntable) == true)
                continue;
            if (kbUnitIsType(j_resource, cUnitTypeHerdable) == true)
                continue;
            
            if (getUnitCountByLocation(cUnitTypeMilitaryBuilding, cPlayerRelationEnemyNotGaia, j_resource_position, cResourceAvoidBuildings) >= 1)
                continue;
                
            if (getUnitCountByLocation(cUnitTypeLogicalTypeNavalMilitary, cPlayerRelationEnemyNotGaia, j_resource_position, cResourceAvoidBuildings) >= 1)
                continue;
                
            if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, j_resource_position, cResourceAvoidLandUnits) >= 3)
                continue;
                
            if (isFlagged(j_resource, cFlagTracked) == false)
            {
                setFlag(j_resource, cFlagTracked);
                if (kbUnitGetPlayerID(j_resource) != cMyID)
                    scratch = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationAny, j_resource_position, 6.0);
                else
                    scratch = kbUnitGetNumberWorkersIfSeeable(j_resource);
                scratch = scratch + kbUnitGetNumberTargeters(j_resource);
                aiQVSet(cFlagGathererCount + j_resource, scratch);
                xsArraySetInt(tracked_resource_list, number_tracked_resources, j_resource);
                number_tracked_resources++;
            }
            
            if (aiQVGet(cFlagGathererCount + j_resource) > kbProtoUnitGetBaseGathererLimit(kbUnitGetProtoUnitID(j_resource)) - 1)
                continue;
                
            aiTaskUnitWork(i_gatherer, j_resource);
            aiQVSet(cFlagGathererCount + j_resource, aiQVGet(cFlagGathererCount + j_resource) + 1);
            break;
        }
    }

    for(i = 0; < number_tracked_resources)
        unsetFlag(xsArrayGetInt(tracked_resource_list, i), cFlagTracked);
}


void ManageRicePaddyTactics(void)
{
    static int last_call = -1;
    if (xsGetTime() < last_call + 3000)
        return;
    last_call = xsGetTime();

    int number_gatherers = 0;
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive))
    {
        int i_villager = getUnit1(cUnitTypeAbstractVillager, cMyID, i);
        if (kbUnitIsType(i_villager, cUnitTypeAbstractWagon))
            continue;
        
        if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_villager)) != cMovementTypeLand)
            continue;
        
        number_gatherers++;
    }

    int number_food_gatherers = number_gatherers * aiGetResourceGathererPercentage(cResourceFood);
    int number_wanted_food_paddies = 0;
    while(number_food_gatherers >= 1)
    {
        number_wanted_food_paddies++;
        number_food_gatherers = number_food_gatherers - 10;
    }

    i = -1;
    while(number_wanted_food_paddies >= 1)
    {
        i++;
        int i_paddy = getUnit1(cUnitTypeypRicePaddy, cMyID, i);
        if (i_paddy == -1)
            break;
        aiUnitSetTactic(i_paddy, cTacticPaddyFood);
        number_wanted_food_paddies--;
    }

    while(true)
    {
        i++;
        i_paddy = getUnit1(cUnitTypeypRicePaddy, cMyID, i);
        if (i_paddy == -1)
            break;
        aiUnitSetTactic(i_paddy, cTacticPaddyCoin);
    }
}


rule ManageFactoryTactics
active
minInterval 5
{
    // This rule is TODO
}
