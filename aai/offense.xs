rule ChooseEnemyToHate
active
minInterval 1
runImmediately
{
    static int current_most_hated_enemy = -1;
    static int alive_enemies = -1;
    int number_alive_enemies = 0;

    if (alive_enemies == -1)
    {
        alive_enemies = xsArrayCreateInt(cNumberPlayers, -1, "List of enemies that still haven't resigned.");
        aiSetMostHatedPlayerID(0);
    }

    if (current_most_hated_enemy <= 0 || kbHasPlayerLost(current_most_hated_enemy) == true)
    {
        for(player = 1; < cNumberPlayers)
        {
            if (kbHasPlayerLost(player) == true)
                continue;
            
            if (kbIsPlayerAlly(player) == true)
                continue;
            
            if (isObserver(player) == true)
                continue;
            
            xsArraySetInt(alive_enemies, number_alive_enemies, player);
            number_alive_enemies++;
        }

        for(i = 0; < aiPlanGetNumber(cPlanAttack))
        {
            int i_attack_plan = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (aiPlanGetVariableInt(i_attack_plan, cAttackPlanPlayerID, 0) == current_most_hated_enemy)
                aiPlanDestroy(i_attack_plan);
        }

        current_most_hated_enemy = xsArrayGetInt(alive_enemies, aiRandInt(number_alive_enemies));
        aiSetMostHatedPlayerID(current_most_hated_enemy);
    }
}


void ManageAttackWaves(void)
{
    static int last_call = -1;
    if (xsGetTime() < last_call + 5000)
        return;
    last_call = xsGetTime();

    if (kbBaseGetMainID(cMyID) == -1)
        return;

    if (aiTreatyActive())
        return;
    if (kbGetAge() <= cAge1)
        return;
    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom)
        return;
    if (kbBaseGetUnderAttack(cMyID, kbBaseGetMainID(cMyID)) == true)
        return;
    
    for(i = 0; < aiPlanGetNumber(cPlanAttack))
    {
        int i_attack_plan = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
        
        vector i_attack_plan_point = aiPlanGetVariableVector(i_attack_plan, cAttackPlanAttackPoint, 0);
        if (i_attack_plan_point != cInvalidVector && 
            getUnitCountByLocation(cUnitTypeHasBountyValue, cPlayerRelationEnemyNotGaia, i_attack_plan_point, 40.0) >= 1)
        {
            continue;
        }

        vector i_attack_plan_location = aiPlanGetLocation(i_attack_plan);
        if (i_attack_plan_location != cInvalidVector)
        {
            if (getUnitCountByLocation(cUnitTypeHasBountyValue, cPlayerRelationEnemyNotGaia, i_attack_plan_location, 40.0) >= 1)
            {
                int t = 0;
                for(j = 0; < getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cMyID, i_attack_plan_location, 40.0))
                {
                    if (getUnitByLocation1(cUnitTypeAbstractArtillery, cPlayerRelationEnemyNotGaia, i_attack_plan_location, 40.0, 0) == -1)
                        break;
                    
                    int j_military_unit = getUnitByLocation2(cUnitTypeLogicalTypeLandMilitary, cMyID, i_attack_plan_location, 40.0, j);
                    if (kbUnitIsType(j_military_unit, cUnitTypeAbstractInfantry) == true)
                        continue;
                    
                    t++;
                    int k = t / 7;
                    aiTaskUnitWork(j_military_unit, 
                                    getUnitByLocation3(cUnitTypeAbstractArtillery, cPlayerRelationEnemyNotGaia, i_attack_plan_location, 40.0, k));
                }
                
                continue;
            }
            
            float highest_score = -1.0;
            vector best_position = cInvalidVector;
            int target_unit = -1;
            int target_player = -1;
            for(j = 0; < 50)
            {
                int j_enemy_unit = getUnitByLocation1(cUnitTypeHasBountyValue, cPlayerRelationEnemyNotGaia, i_attack_plan_location, 5000.0, j);
                if (j_enemy_unit == -1)
                    break;
                
                if (kbHasPlayerLost(kbUnitGetPlayerID(j_enemy_unit)) == true)
                    continue;
                
                if (kbUnitGetMovementType(kbUnitGetProtoUnitID(j_enemy_unit)) != cMovementTypeLand)
                    continue;
                
                vector j_enemy_unit_position = kbUnitGetPosition(j_enemy_unit);
                float score = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationEnemyNotGaia, j_enemy_unit_position, 40.0);
                score = score + getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, j_enemy_unit_position, 40.0);
                score = score + score;
                score = score + getUnitCountByLocation(cUnitTypeLogicalTypeBuildingsNotWalls, cPlayerRelationEnemyNotGaia, j_enemy_unit_position, 40.0);
                score = score / xsVectorLength(i_attack_plan_location - j_enemy_unit_position);
                
                if (score > highest_score)
                {
                    highest_score = score;
                    best_position = j_enemy_unit_position;
                    target_unit = j_enemy_unit;
                    target_player = kbUnitGetPlayerID(target_unit);
                }
            }

            if (target_player == -1)
            {
                target_player = aiGetMostHatedPlayerID();
                if (target_player <= 0 || kbHasPlayerLost(target_player) == true)
                    return;
                best_position = kbBaseGetLocation(target_player, kbBaseGetMainID(target_player));
            }

            if (best_position == cInvalidVector)
                best_position = kbUnitGetPosition(getUnit1(cUnitTypeHasBountyValue, target_player));
            
            if (best_position == cInvalidVector)
            {
                aiPlanDestroy(i_attack_plan);
                continue;
            }

            aiPlanSetVariableVector(i_attack_plan, cAttackPlanAttackPoint, 0, best_position);
            aiPlanSetVariableInt(i_attack_plan, cAttackPlanPlayerID, 0, target_player);
            aiPlanSetVariableInt(i_attack_plan, cAttackPlanSpecificTargetID,0, target_unit);
            continue;
        }
    }

    if (gMonopolyTeam == kbGetPlayerTeam(cMyID) || gKOTHTeam == kbGetPlayerTeam(cMyID))
        return;

    highest_score = -1.0;
    best_position = cInvalidVector;
    target_unit = -1;
    target_player = -1;
    for(i = 0; < 50)
    {
        int i_enemy_unit = getUnitByLocation1(cUnitTypeAll, cPlayerRelationEnemyNotGaia, getMainBaseLocation(), 5000.0, i);
        if (i_enemy_unit == -1)
            break;
        
        if (kbHasPlayerLost(kbUnitGetPlayerID(i_enemy_unit)) == true)
            continue;
        if (kbUnitGetMovementType(kbUnitGetProtoUnitID(i_enemy_unit)) != cMovementTypeLand)
            continue;
        if (kbUnitIsType(i_enemy_unit, cUnitTypeAbstractResourceCrate) == true)
            continue;
        if (kbUnitIsType(i_enemy_unit, cUnitTypeAnimalPrey) == true)
            continue;
        if (kbUnitIsType(i_enemy_unit, cUnitTypeHuntable) == true)
            continue;
        if (kbUnitIsType(i_enemy_unit, cUnitTypeHerdable) == true)
            continue;
        if (kbUnitIsType(i_enemy_unit, cUnitTypeAbstractWall) == true)
            continue;
        
        vector i_enemy_unit_position = kbUnitGetPosition(i_enemy_unit);
        score = getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationEnemyNotGaia, i_enemy_unit_position, 40.0);
        score = score + getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, i_enemy_unit_position, 40.0);
        score = score + score;
        score = score + getUnitCountByLocation(cUnitTypeLogicalTypeBuildingsNotWalls, cPlayerRelationEnemyNotGaia, i_enemy_unit_position, 40.0);
        score = score / xsVectorLength(getMainBaseLocation() - i_enemy_unit_position);
        
        if (score > highest_score)
        {
            highest_score = score;
            best_position = i_enemy_unit_position;
            target_unit = i_enemy_unit;
            target_player = kbUnitGetPlayerID(target_unit);
        }
    }

    if (target_player == -1)
    {
        target_player = aiGetMostHatedPlayerID();
        if (target_player <= 0 || kbHasPlayerLost(target_player) == true)
            return;
        best_position = kbBaseGetLocation(target_player, kbBaseGetMainID(target_player));
    }
    
    if (best_position == cInvalidVector)
        best_position = kbUnitGetPosition(getUnit1(cUnitTypeHasBountyValue, target_player));
    
    int number_unassigned_units = 0;
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive))
    {
        int i_military_unit = getUnit1(cUnitTypeLogicalTypeLandMilitary, cMyID, i);
        if (kbUnitGetPlanID(i_military_unit) >= 0)
            continue;
        
        vector i_military_unit_position = kbUnitGetPosition(i_military_unit);
        if (kbCanPath2(i_military_unit_position, best_position, kbUnitGetProtoUnitID(i_military_unit)) == false)
            continue;
        
        number_unassigned_units++;
    }

    static int current_wave = 0;
    
    if (number_unassigned_units < 10 + 10 * kbGetAge())
        return;
    
    current_wave++;

    int attack_plan = aiPlanCreate("Attack Wave " + current_wave, cPlanAttack);
    aiPlanSetDesiredPriority(attack_plan, 80);
    aiPlanSetUnitStance(attack_plan, cUnitStanceAggressive);
    aiPlanSetAllowUnderAttackResponse(attack_plan, true);
    
    // aiPlanSetInitialPosition(attack_plan, getMainBaseLocation());
    // aiPlanSetVariableVector(attack_plan, cAttackPlanGatherPoint, 0, getMainBaseLocation());
    // aiPlanSetVariableFloat(attack_plan, cAttackPlanGatherDistance, 0, 100.0);
    // aiPlanSetVariableInt(attack_plan, cAttackPlanGatherWaitTime, 0, 0);
    
    aiPlanSetVariableInt(attack_plan, cAttackPlanPlayerID, 0, target_player);
    
    aiPlanSetVariableVector(attack_plan, cAttackPlanAttackPoint, 0, best_position);
    aiPlanSetVariableFloat(attack_plan, cAttackPlanAttackPointEngageRange, 0, 60.0);
    aiPlanSetVariableBool(attack_plan, cAttackPlanMoveAttack, 0, true);

    aiPlanSetNumberVariableValues(attack_plan, cAttackPlanTargetTypeID, 3, true);
    aiPlanSetVariableInt(attack_plan, cAttackPlanTargetTypeID, 0, cUnitTypeAbstractVillager);
    aiPlanSetVariableInt(attack_plan, cAttackPlanTargetTypeID, 1, cUnitTypeLogicalTypeBuildingsNotWalls);
    aiPlanSetVariableInt(attack_plan, cAttackPlanTargetTypeID, 2, cUnitTypeLogicalTypeLandMilitary);

    aiPlanSetVariableInt(attack_plan, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
    aiPlanSetVariableInt(attack_plan, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeRandom);
    aiPlanSetVariableInt(attack_plan, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
    
    aiPlanSetVariableInt(attack_plan, cAttackPlanRefreshFrequency, 0, 5);
    aiPlanSetVariableInt(attack_plan, cAttackPlanHandleDamageFrequency, 0, 5);

    aiPlanAddUnitType(attack_plan, cUnitTypeLogicalTypeLandMilitary, 0, 0, number_unassigned_units);
    aiPlanAddUnitType(attack_plan, cUnitTypePriest, 0, 0, aiNumberUnassignedUnits(cUnitTypePriest));
    aiPlanAddUnitType(attack_plan, cUnitTypeMissionary, 0, 0, aiNumberUnassignedUnits(cUnitTypeMissionary));
    aiPlanAddUnitType(attack_plan, cUnitTypexpSpy, 0, 0, aiNumberUnassignedUnits(cUnitTypexpSpy));
    aiPlanAddUnitType(attack_plan, cUnitTypeInquisitor, 0, 0, aiNumberUnassignedUnits(cUnitTypeInquisitor));
    
    for(i = 0; < kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive))
    {
        i_military_unit = getUnit1(cUnitTypeLogicalTypeLandMilitary, cMyID, i);
        
        if (kbUnitIsType(i_military_unit, cUnitTypeHero) == true)
            continue;
        
        if (kbUnitGetPlanID(i_military_unit) >= 0)
            continue;
        
        i_military_unit_position = kbUnitGetPosition(i_military_unit);
        
        if (kbCanPath2(i_military_unit_position, best_position, kbUnitGetProtoUnitID(i_military_unit)) == false)
            continue;
        
        aiPlanAddUnit(attack_plan, i_military_unit);
    }

    for (i = 0; < kbUnitCount(cMyID, cUnitTypePriest, cUnitStateAlive))
    {
        int i_priest = getUnit1(cUnitTypePriest, cMyID, i);
        if (kbUnitGetPlanID(i_priest) >= 0)
            continue;
        
        vector i_priest_position = kbUnitGetPosition(i_priest);
        if (kbCanPath2(i_priest_position, best_position, kbUnitGetProtoUnitID(i_priest)) == false)
            continue;
        
        aiPlanAddUnit(attack_plan, i_priest);
    }

    for (i = 0; < kbUnitCount(cMyID, cUnitTypeMissionary, cUnitStateAlive))
    {
        int i_missionary = getUnit1(cUnitTypeMissionary, cMyID, i);
        if (kbUnitGetPlanID(i_missionary) >= 0)
            continue;
        
        vector i_missionary_position = kbUnitGetPosition(i_missionary);
        if (kbCanPath2(i_missionary_position, best_position, kbUnitGetProtoUnitID(i_missionary)) == false)
            continue;
        
        aiPlanAddUnit(attack_plan, i_missionary);
    }

    for (i = 0; < kbUnitCount(cMyID, cUnitTypexpSpy, cUnitStateAlive))
    {
        int i_spy = getUnit1(cUnitTypexpSpy, cMyID, i);
        if (kbUnitGetPlanID(i_spy) >= 0)
            continue;
        
        vector i_spy_position = kbUnitGetPosition(i_spy);
        if (kbCanPath2(i_spy_position, best_position, kbUnitGetProtoUnitID(i_spy)) == false)
            continue;
        
        aiPlanAddUnit(attack_plan, i_spy);
    }

    for (i = 0; < kbUnitCount(cMyID, cUnitTypeInquisitor, cUnitStateAlive))
    {
        int i_inquisitor = getUnit1(cUnitTypeInquisitor, cMyID, i);
        if (kbUnitGetPlanID(i_inquisitor) >= 0)
            continue;
        
        vector i_inquisitor_position = kbUnitGetPosition(i_inquisitor);
        if (kbCanPath2(i_inquisitor_position, best_position, kbUnitGetProtoUnitID(i_inquisitor)) == false)
            continue;
        
        aiPlanAddUnit(attack_plan, i_inquisitor);
    }

    aiPlanSetNoMoreUnits(attack_plan, true);

    aiPlanSetEventHandler(attack_plan, cPlanEventStateChange, "eWhenAttackPlanStateChanges");
    
    aiPlanSetActive(attack_plan, true);
}


void eWhenAttackPlanStateChanges(int plan_id = -1)
{
    const int chat_interval = 120000;
    static int last_chat_time = -120000;
    vector attack_position = aiPlanGetVariableVector(plan_id, cAttackPlanAttackPoint, 0);
    
    if (aiPlanGetState(plan_id) == cPlanStateAttack && 
        attack_position != cInvalidVector && 
        xsGetTime() > last_chat_time + chat_interval)
    {
        last_chat_time = xsGetTime();
        
        int chat_id = -1;
        if (getUnitCountByLocation(cUnitTypeTownCenter, cPlayerRelationEnemyNotGaia, attack_position, 40.0) >= 1)
            chat_id = cAICommPromptToAllyIWillAttackEnemyTown;
        if (chat_id == -1 && getUnitCountByLocation(cUnitTypeAbstractVillager, cPlayerRelationEnemyNotGaia, attack_position, 40.0) >= 5)
            chat_id = cAICommPromptToAllyIWillAttackEnemySettlers;
        if (chat_id == -1 && getUnitCountByLocation(cUnitTypeTradingPost, cPlayerRelationEnemyNotGaia, attack_position, 40.0) >= 1)
            chat_id = cAICommPromptToAllyIWillAttackTradeSite;
        
        for(player = 1; < cNumberPlayers)
        {
            if (kbHasPlayerLost(player) == true)
                continue;
            if (kbIsPlayerEnemy(player) == true)
                continue;
            aiCommsSendStatementWithVector(player, chat_id, attack_position);
        }
    }
}
