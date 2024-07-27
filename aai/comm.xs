// ============================================================================
// Intros
// ============================================================================
rule AiTauntsIntro active runImmediately priority 100
{
    xsDisableSelf();

    aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyIntro);
    aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyIntro);
}

// ============================================================================
// Ages
// ============================================================================
void onPlayerAgeUp(int player = -1)
{
    static bool everyone_aged_up = false;
    if (everyone_aged_up)
        return;

    if (kbGetAgeForPlayer(player) == cAge2)
    {
        // Case 1: he is the first player to reach age 2
        bool first = true;
        for (i = 0; < cNumberPlayers)
        {
            if (i == player)
                continue;
            if (kbGetAgeForPlayer(i) >= cAge2)
            {
                first = false;
                break;
            }
        }

        if (first)
        {
            if (kbIsPlayerAlly(player) == true)
                aiTaunt(player, cAICommPromptToAllyHeReachesAge2First);
            else
                aiTaunt(player, cAICommPromptToEnemyHeReachesAge2First);
        }

        // Case 2: he is the last player to reach age 2
        bool last = true;
        for (i = 0; < cNumberPlayers)
        {
            if (i == player)
                continue;
            if (kbGetAgeForPlayer(i) <= cAge1)
            {
                last = false;
                break;
            }
        }

        if (last)
        {
            if (kbIsPlayerAlly(player) == true)
                aiTaunt(player, cAICommPromptToAllyHeReachesAge2Last);
            else
                aiTaunt(player, cAICommPromptToEnemyHeReachesAge2Last);

            everyone_aged_up = true;
        }
    }
}

// ============================================================================
// Treasures
// ============================================================================
void onNuggetClaim(int player = -1)
{
    if (kbGetAge() >= cAge3)
        return;

    static int nugget_counts = -1;
    if (nugget_counts == -1)
        nugget_counts = xsArrayCreateInt(12, 0, "Number of nuggets each player has claimed");
    xsArraySetInt(nugget_counts, player, xsArrayGetInt(nugget_counts, player) + 1);

    int count = 0;
    int lowest_count = 1000000;
    int lowest_player = -1;
    int highest_count = 0;
    int highest_player = -1;
    int total_count = 0;
    int average_count = 0;
    for (i = 1; < cNumberPlayers)
    {
        count = xsArrayGetInt(nugget_counts, i);

        if (count < lowest_count)
        {
            lowest_count = count;
            lowest_player = i;
        }

        if (count > highest_count)
        {
            highest_count = count;
            highest_player = i;
        }

        total_count = total_count + count;
    }

    average_count = total_count / (cNumberPlayers - 1);

    if (total_count == 1)
    {
        if (player != cMyID)
        {
            if (kbIsPlayerAlly(player) == true)
                aiTaunt(player, cAICommPromptToAllyWhenHeGathersFirstNugget);
            else
                aiTaunt(player, cAICommPromptToEnemyWhenHeGathersFirstNugget);

            return;
        }
    }

    int his_count = 0;
    int my_count = 0;
    my_count = xsArrayGetInt(nugget_counts, cMyID);
    his_count = xsArrayGetInt(nugget_counts, player);

    if (his_count - my_count >= 2 && his_count >= my_count * 2)
    {
        if (kbIsPlayerAlly(player) == true)
            aiTaunt(player, cAICommPromptToAllyWhenHeGathersNuggetHeIsAhead);
        else
            aiTaunt(player, cAICommPromptToEnemyWhenHeGathersNuggetHeIsAhead);

        return;
    }

    bool taunted = false;
    int their_count = 0;
    if (player == cMyID)
    {
        for (i = 1; < cNumberPlayers)
        {
            their_count = xsArrayGetInt(nugget_counts, i);
            if (my_count - their_count >= 2 && my_count >= their_count * 2)
            {
                if (kbIsPlayerAlly(i) == true)
                    aiTaunt(i, cAICommPromptToAllyWhenIGatherNuggetIAmAhead);
                else
                    aiTaunt(i, cAICommPromptToEnemyWhenIGatherNuggetIAmAhead);

                taunted = true;
            }
        }
    }

    if (taunted)
        return;

    int hero = getUnit1(cUnitTypeHero, player);
    vector hero_pos = cInvalidVector;
    int town_center = -1;
    const float cNuggetDistance = 100.0;
    if (hero >= 0)
    {
        if (kbUnitVisible(hero) == true)
        {
            hero_pos = kbUnitGetPosition(hero);

            if (player == cMyID)
            {
                town_center = getUnitByLocation1(cUnitTypeTownCenter, cPlayerRelationAlly, hero_pos, cNuggetDistance, 0);
                if (town_center >= 0 && kbUnitGetPlayerID(town_center) != cMyID)
                {
                    aiTaunt(kbUnitGetPlayerID(town_center), cAICommPromptToAllyWhenIGatherNuggetHisBase);
                    return;
                }

                town_center = getUnitByLocation1(cUnitTypeTownCenter, cPlayerRelationEnemy, hero_pos, cNuggetDistance, 0);
                if (town_center > 0)
                {
                    aiTaunt(kbUnitGetPlayerID(town_center), cAICommPromptToEnemyWhenIGatherNuggetHisBase);
                    return;
                }
            }
            else
            {
                town_center = getUnitByLocation1(cUnitTypeTownCenter, cMyID, hero_pos, cNuggetDistance, 0);
                if (town_center >= 0)
                {
                    if (kbIsPlayerAlly(player) == true)
                        aiTaunt(player, cAICommPromptToAllyWhenHeGathersNuggetMyBase);
                    else
                        aiTaunt(player, cAICommPromptToEnemyWhenHeGathersNuggetMyBase);

                    return;
                }
            }
        } // Hero is visible
    } // Hero exists

    switch(aiGetLastCollectedNuggetType(player))
    {
        case cNuggetTypeAdjustResource:
        {
            switch(aiGetLastCollectedNuggetEffect(player))
            {
                case cResourceGold:
                {
                    if (player == cMyID)
                    {
                        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenIGatherNuggetCoin);
                        aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenIGatherNuggetCoin);
                    }
                    else
                    {
                        if (kbIsPlayerAlly(player) == true)
                            aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenHeGathersNuggetCoin);
                        else
                            aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenHeGathersNuggetCoin);
                    }
                    break;
                }
                case cResourceWood:
                {
                    if (player == cMyID)
                    {
                        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenIGatherNuggetWood);
                        aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenIGatherNuggetWood);
                    }
                    else
                    {
                        if (kbIsPlayerAlly(player) == true)
                            aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenHeGathersNuggetWood);
                        else
                            aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenHeGathersNuggetWood);
                    }
                    break;
                }
                case cResourceFood:
                {
                    if (player == cMyID)
                    {
                        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenIGatherNuggetFood);
                        aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenIGatherNuggetFood);
                    }
                    else
                    {
                        if (kbIsPlayerAlly(player) == true)
                            aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenHeGathersNuggetFood);
                        else
                            aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenHeGathersNuggetFood);
                    }
                    break;
                }
            }
            break;
        }
        case cNuggetTypeSpawnUnit:
		{
            if (kbProtoUnitIsType(cMyID, aiGetLastCollectedNuggetEffect(player), cUnitTypeAbstractNativeWarrior) == true ||
                aiGetLastCollectedNuggetEffect(player) == cUnitTypeNatMedicineMan)
            {
                if (player == cMyID)
                {
                    aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenIGatherNuggetNatives);
                    aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenIGatherNuggetNatives);
                }
                else
                {
                    if (kbIsPlayerAlly(player) == true)
                        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenHeGathersNuggetNatives);
                    else
                        aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenHeGathersNuggetNatives);
                }
            }

            if (kbProtoUnitIsType(cMyID, aiGetLastCollectedNuggetEffect(player), cUnitTypeAbstractVillager) == true)
            {
                if (player == cMyID)
                {
                    aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenIGatherNuggetSettlers);
                    aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenIGatherNuggetSettlers);
                }
                else
                {
                    if (kbIsPlayerAlly(player) == true)
                        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenHeGathersNuggetSettlers);
                    else
                        aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenHeGathersNuggetSettlers);
                }
            }
			break;
		}
        case cNuggetTypeConvertUnit:
		{
			if (kbProtoUnitIsType(cMyID, aiGetLastCollectedNuggetEffect(player), cUnitTypeAbstractNativeWarrior) == true ||
                aiGetLastCollectedNuggetEffect(player) == cUnitTypeNatMedicineMan)
            {
                if (player == cMyID)
                {
                    aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenIGatherNuggetNatives);
                    aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenIGatherNuggetNatives);
                }
                else
                {
                    if (kbIsPlayerAlly(player) == true)
                        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenHeGathersNuggetNatives);
                    else
                        aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenHeGathersNuggetNatives);
                }
            }

            if (kbProtoUnitIsType(cMyID, aiGetLastCollectedNuggetEffect(player), cUnitTypeAbstractVillager) == true)
            {
                if (player == cMyID)
                {
                    aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenIGatherNuggetSettlers);
                    aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenIGatherNuggetSettlers);
                }
                else
                {
                    if (kbIsPlayerAlly(player) == true)
                        aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyWhenHeGathersNuggetSettlers);
                    else
                        aiTaunt(cPlayerRelationEnemyNotGaia, cAICommPromptToEnemyWhenHeGathersNuggetSettlers);
                }
            }
			break;
		}
    }
}

// ============================================================================
// Pings
// ============================================================================

rule PingUndefendedTown
active
minInterval 5
{
    if (kbGetAge() <= cAge2)
        return;
    
    static int last_ping = 0;
    if (last_ping + 120000 > xsGetTime())
        return;

    int i = 0;
    while(true)
    {
        int enemy_town = getUnit1(cUnitTypeTownCenter, cPlayerRelationEnemy, i);
        if (enemy_town == -1)
            break;
        i++;
        
        vector enemy_town_pos = cInvalidVector;
        if (getUnitCountByLocation(cUnitTypeLogicalTypeScout, cPlayerRelationAlly, enemy_town_pos, 100.0) == 0)
            continue;
        
        if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, enemy_town_pos, 100.0) < 7)
        {
            last_ping = xsGetTime();
            aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyISeeEnemyTCNoArmy, enemy_town_pos);
            break;
        }
        
        if (getUnitCountByLocation(cUnitTypeAbstractBarracks2, cPlayerRelationEnemyNotGaia, enemy_town_pos, 100.0) == 0)
        {
            last_ping = xsGetTime();
            aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyISeeEnemyTCNoBarracks, enemy_town_pos);
            break;
        }
        
        if (getUnitCountByLocation(cUnitTypeAbstractStables, cPlayerRelationEnemyNotGaia, enemy_town_pos, 100.0) == 0)
        {
            last_ping = xsGetTime();
            aiTaunt(cPlayerRelationAlly, cAICommPromptToAllyISeeEnemyTCNoStable, enemy_town_pos);
            break;
        }
    }
}

// ============================================================================
// Requests
// ============================================================================
void onCommRequest(int request = -1)
{
    int from = aiCommsGetSendingPlayer(request);

    if (kbIsPlayerAlly(from) == true)
    {
        if (aiRandInt(100) < 50)
            aiTaunt(from, cAICommPromptToAllyDeclineGeneral);
        else
            aiTaunt(from, cAICommPromptToAllyDeclineProhibited);
    }
    
    xsNotify("This AI does not support that feature yet.");
}
