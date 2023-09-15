// ================================================================================
// Keep training villagers until we reach the build limit.
// ================================================================================
rule MaintainVillagers
group rgMainBase
inactive
minInterval 5
{
    if (cMyCiv == cCivOttomans)
    {
        xsSetRuleMinIntervalSelf(20);

        int mosque = getUnit1(gUnitTypeReligiousBuilding);
        if (mosque == -1)
            return;
        
        float villager_count = kbUnitCount(cMyID, cUnitTypeSettlerOttoman, cUnitStateAlive);
        float villager_limit = kbGetBuildLimit(cMyID, cUnitTypeSettlerOttoman);
        float villager_ratio = villager_count / villager_limit;

        int tech_to_research = -1;
        int research_plan = -1;

        if (villager_ratio > 0.8)
        {
            if (kbTechGetStatus(cTechChurchTanzimat) == cTechStatusObtainable)
                tech_to_research = cTechChurchTanzimat;
            if (kbTechGetStatus(cTechChurchTopkapi) == cTechStatusObtainable)
                tech_to_research = cTechChurchTopkapi;
            if (kbTechGetStatus(cTechChurchGalataTowerDistrict) == cTechStatusObtainable)
                tech_to_research = cTechChurchGalataTowerDistrict;
            
            if (tech_to_research >= 0)
            {
                research_plan = aiPlanCreate("Research Ottoman Limit Tech " + kbGetTechName(tech_to_research), cPlanResearch);
                aiPlanSetDesiredPriority(research_plan, 100);
                aiPlanSetEscrowID(research_plan, cRootEscrowID);
                aiPlanSetVariableInt(research_plan, cResearchPlanTechID, 0, tech_to_research);
                aiPlanSetVariableInt(research_plan, cResearchPlanBuildingID, 0, mosque);
                aiPlanSetActive(research_plan, true);
            }
        }

        tech_to_research = -1;

        if (kbTechGetStatus(cTechChurchAbbassidMarket) == cTechStatusObtainable)
            tech_to_research = cTechChurchAbbassidMarket;
        if (kbTechGetStatus(cTechChurchKopruluViziers) == cTechStatusObtainable)
            tech_to_research = cTechChurchKopruluViziers;
        if (kbTechGetStatus(cTechChurchMilletSystem) == cTechStatusObtainable)
            tech_to_research = cTechChurchMilletSystem;
            
        if (tech_to_research >= 0)
        {
            research_plan = aiPlanCreate("Research Ottoman Speed Tech " + kbGetTechName(tech_to_research), cPlanResearch);
            aiPlanSetDesiredPriority(research_plan, 100);
            aiPlanSetEscrowID(research_plan, cRootEscrowID);
            aiPlanSetVariableInt(research_plan, cResearchPlanTechID, 0, tech_to_research);
            aiPlanSetVariableInt(research_plan, cResearchPlanBuildingID, 0, mosque);
            aiPlanSetActive(research_plan, true);
        }

        return;
    }
    
    if (gUnitTypeVillager == -1)
        return;
    
    xsDisableSelf();

    // Use static variable for good measure.
    static int villager_maintain_plan = -1;

    if (villager_maintain_plan == -1)
        villager_maintain_plan = aiPlanCreate("Maintain Villagers", cPlanTrain);
    
    int number_to_maintain = kbGetBuildLimit(cMyID, gUnitTypeVillager);
    number_to_maintain = xsMin(number_to_maintain, 10 + number_to_maintain / kbGetPlayerHandicap(cMyID));
    
    aiPlanSetDesiredPriority(villager_maintain_plan, 10);
    aiPlanSetEscrowID(villager_maintain_plan, cRootEscrowID);
    aiPlanSetVariableInt(villager_maintain_plan, cTrainPlanUnitType, 0, gUnitTypeVillager);
    aiPlanSetVariableInt(villager_maintain_plan, cTrainPlanNumberToMaintain, 0, number_to_maintain);
    aiPlanSetVariableBool(villager_maintain_plan, cTrainPlanUseMultipleBuildings, 0, true);
    aiPlanSetVariableInt(villager_maintain_plan, cTrainPlanBatchSize, 0, 1);
    aiPlanSetActive(villager_maintain_plan, true);
}


// ================================================================================
// Keep training the main military units endlessly (unless it interferes with 
// TownCenter build plans).
// ================================================================================
rule MaintainMainMilitaryUnits
group rgMainBase
inactive
minInterval 2
{
    if (kbGetAge() <= cAge1)
        return;
    
    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom)
        return;

    static int age2_units = -1;
    static int age3_units = -1;
    static int available_units = -1;
    static int last_reset = -2000;
    static int age2_time = -2000;
    const int cResetCDN = 180000;

    if (kbGetAge() >= cAge2)
        age2_time = xsGetTime();

    if ((xsGetTime() < last_reset + cResetCDN) && (xsGetTime() < age2_time + cResetCDN))
        last_reset = last_reset - cResetCDN - 900;

    int available_count = 0;

    if (available_units == -1)
    {
        available_units = xsArrayCreateInt(74, -1, "List of military units that are enabled in the techtree");

        age2_units = xsArrayCreateInt(36, -1, "List of Age2 military units");
        xsArraySetInt(age2_units, 0, cUnitTypePikeman);
        xsArraySetInt(age2_units, 1, cUnitTypeCrossbowman);
        xsArraySetInt(age2_units, 2, cUnitTypeMusketeer);
        xsArraySetInt(age2_units, 3, cUnitTypeHussar);
        xsArraySetInt(age2_units, 4, cUnitTypeLongbowman);
        xsArraySetInt(age2_units, 5, cUnitTypeSchutze);
        xsArraySetInt(age2_units, 6, cUnitTypeCossack);
        xsArraySetInt(age2_units, 7, cUnitTypeStrelet);
        xsArraySetInt(age2_units, 8, cUnitTypeUhlan);
        xsArraySetInt(age2_units, 9, cUnitTypeDopplesoldner);
        xsArraySetInt(age2_units, 10, cUnitTypeypOldHanArmy);
        xsArraySetInt(age2_units, 11, cUnitTypeypStandardArmy);
        xsArraySetInt(age2_units, 12, cUnitTypeypMingArmy);
        xsArraySetInt(age2_units, 13, cUnitTypeypYumi);
        xsArraySetInt(age2_units, 14, cUnitTypeypKensei);
        xsArraySetInt(age2_units, 15, cUnitTypeypAshigaru);
        xsArraySetInt(age2_units, 16, cUnitTypeSohei);
        xsArraySetInt(age2_units, 17, cUnitTypeypNaginataRider);
        xsArraySetInt(age2_units, 18, cUnitTypeypSowar);
        xsArraySetInt(age2_units, 19, cUnitTypeypZamburak);
        xsArraySetInt(age2_units, 20, cUnitTypeypUrumi);
        xsArraySetInt(age2_units, 21, cUnitTypeypRajput);
        xsArraySetInt(age2_units, 22, cUnitTypeypSepoy);
        xsArraySetInt(age2_units, 23, cUnitTypeGrenadier);
        xsArraySetInt(age2_units, 24, cUnitTypeAbusGun);
        xsArraySetInt(age2_units, 25, cUnitTypexpWarBow);
        xsArraySetInt(age2_units, 26, cUnitTypexpWarClub);
        xsArraySetInt(age2_units, 27, cUnitTypexpAenna);
        xsArraySetInt(age2_units, 28, cUnitTypexpTomahawk);
        xsArraySetInt(age2_units, 29, cUnitTypexpCoyoteMan);
        xsArraySetInt(age2_units, 30, cUnitTypexpMacehualtin);
        xsArraySetInt(age2_units, 31, cUnitTypexpPumaMan);
        xsArraySetInt(age2_units, 32, cUnitTypexpColonialMilitia);
        xsArraySetInt(age2_units, 33, cUnitTypexpHorseman);
        xsArraySetInt(age2_units, 34, cUnitTypexpAxeRider);
        xsArraySetInt(age2_units, 35, cUnitTypexpBowRider);

        age3_units = xsArrayCreateInt(39, -1, "List of Age3 military units");
        xsArraySetInt(age3_units, 0, cUnitTypeHalberdier);
        xsArraySetInt(age3_units, 1, cUnitTypeCavalryArcher);
        xsArraySetInt(age3_units, 2, cUnitTypeSkirmisher);
        xsArraySetInt(age3_units, 3, cUnitTypeDragoon);
        xsArraySetInt(age3_units, 4, cUnitTypeCuirassier);
        xsArraySetInt(age3_units, 5, cUnitTypeSpahi);
        xsArraySetInt(age3_units, 6, cUnitTypeRuyter);
        xsArraySetInt(age3_units, 7, cUnitTypeCacadore);
        xsArraySetInt(age3_units, 8, cUnitTypeWarWagon);
        xsArraySetInt(age3_units, 9, cUnitTypeOprichnik);
        xsArraySetInt(age3_units, 10, cUnitTypeLancer);
        xsArraySetInt(age3_units, 11, cUnitTypexpMusketWarrior);
        xsArraySetInt(age3_units, 12, cUnitTypexpMusketRider);
        xsArraySetInt(age3_units, 13, cUnitTypexpRifleRider);
        xsArraySetInt(age3_units, 14, cUnitTypexpWarRifle);
        xsArraySetInt(age3_units, 15, cUnitTypexpEagleKnight);
        xsArraySetInt(age3_units, 16, cUnitTypexpJaguarKnight);
        xsArraySetInt(age3_units, 17, cUnitTypexpArrowKnight);
        xsArraySetInt(age3_units, 18, cUnitTypexpCoupRider);
        xsArraySetInt(age3_units, 19, cUnitTypeUSRiflemenRegiment);
        xsArraySetInt(age3_units, 20, cUnitTypeUSSaberSquad);
        xsArraySetInt(age3_units, 21, cUnitTypeypYabusame);
        xsArraySetInt(age3_units, 22, cUnitTypeypMahout);
        xsArraySetInt(age3_units, 23, cUnitTypeypHowdah);
        xsArraySetInt(age3_units, 24, cUnitTypeypNatMercGurkha);
        xsArraySetInt(age3_units, 25, cUnitTypeypImperialArmy);
        xsArraySetInt(age3_units, 26, cUnitTypeypForbiddenArmy);
        xsArraySetInt(age3_units, 27, cUnitTypeypHandMortar);
        xsArraySetInt(age3_units, 28, cUnitTypeypTerritorialArmy);
        xsArraySetInt(age3_units, 29, cUnitTypeUSSaberSquad2);
        xsArraySetInt(age3_units, 30, cUnitTypeMountedRifleman);
        xsArraySetInt(age3_units, 31, cUnitTypeMountedRiflemanJ);
        xsArraySetInt(age3_units, 32, cUnitTypeCavalaria);
        xsArraySetInt(age3_units, 33, cUnitTypeRiflemanUS);
        xsArraySetInt(age3_units, 34, cUnitTypeRiflemanUSJ);
        xsArraySetInt(age3_units, 35, cUnitTypeMountedCrossbowman);
        xsArraySetInt(age3_units, 36, cUnitTypeShinobiHorse);
        xsArraySetInt(age3_units, 37, cUnitTypeypBlackFlagArmy);
        xsArraySetInt(age3_units, 38, cUnitTypeypMongolianArmy);
    }

    int i_unit = -1;
    int age3_index = -1;
    int line1 = -1;
    int line2 = -1;

    for(i = 0; < xsArrayGetSize(age2_units))
    {
        i_unit = xsArrayGetInt(age2_units, i);
        if (kbProtoUnitAvailable(i_unit) == true)
        {
            xsArraySetInt(available_units, available_count, i_unit);
            available_count++;
        }
    }

    age3_index = available_count;
    for(i = 0; < xsArrayGetSize(age3_units))
    {
        i_unit = xsArrayGetInt(age3_units, i);
        if (kbProtoUnitAvailable(i_unit) == true)
        {
            xsArraySetInt(available_units, available_count, i_unit);
            available_count++;
        }
    }

    if (available_count >= 1 && xsGetTime() > last_reset + cResetCDN)
    {
        last_reset = xsGetTime();

        int randomizer = aiRandInt(100);

        // Pick two protounits from all available
        if (randomizer < 100)
        {
            line1 = xsArrayGetInt(available_units, aiRandInt(available_count));
            line2 = xsArrayGetInt(available_units, aiRandInt(available_count));
        }
        
        // Pick two protounits from Age3 only
        if (randomizer < 70)
        {
            line1 = xsArrayGetInt(available_units, age3_index + aiRandInt(available_count - age3_index));
            line2 = xsArrayGetInt(available_units, age3_index + aiRandInt(available_count - age3_index));
        }
        
        // Pick two protounits from a mix of Age2 and Age3
        if (randomizer < 25)
        {
            line1 = xsArrayGetInt(available_units, aiRandInt(age3_index));
            line2 = xsArrayGetInt(available_units, age3_index + aiRandInt(available_count - age3_index));
        }

        // In Age2, pick from Age2 only
        if (kbGetAge() == cAge2)
        {
            line1 = xsArrayGetInt(available_units, aiRandInt(age3_index));
            line2 = xsArrayGetInt(available_units, aiRandInt(age3_index));
        }

        gMilitaryLine1 = line1;
        gMilitaryLine2 = line2;
    }

    static int line1_maintain_plan = -1;
    static int line2_maintain_plan = -1;

    if (line1_maintain_plan == -1)
    {
        line1_maintain_plan = aiPlanCreate("Maintain Main Military Line 1", cPlanTrain);
        aiPlanSetDesiredPriority(line1_maintain_plan, 10);
        aiPlanSetEscrowID(line1_maintain_plan, cRootEscrowID);
        aiPlanSetVariableInt(line1_maintain_plan, cTrainPlanFrequency, 0, 1);
        aiPlanSetVariableInt(line1_maintain_plan, cTrainPlanUnitType, 0, line1);
        aiPlanSetVariableInt(line1_maintain_plan, cTrainPlanNumberToMaintain, 0, 10);
        aiPlanSetVariableBool(line1_maintain_plan, cTrainPlanUseMultipleBuildings, 0, true);
        aiPlanSetVariableInt(line1_maintain_plan, cTrainPlanBatchSize, 0, 5);
        aiPlanSetActive(line1_maintain_plan, true);
        
        line2_maintain_plan = aiPlanCreate("Maintain Main Military Line 2", cPlanTrain);
        aiPlanSetDesiredPriority(line2_maintain_plan, 10);
        aiPlanSetEscrowID(line2_maintain_plan, cRootEscrowID);
        aiPlanSetVariableInt(line2_maintain_plan, cTrainPlanFrequency, 0, 1);
        aiPlanSetVariableInt(line2_maintain_plan, cTrainPlanUnitType, 0, line2);
        aiPlanSetVariableInt(line2_maintain_plan, cTrainPlanNumberToMaintain, 0, 10);
        aiPlanSetVariableBool(line2_maintain_plan, cTrainPlanUseMultipleBuildings, 0, true);
        aiPlanSetVariableInt(line2_maintain_plan, cTrainPlanBatchSize, 0, 5);
        aiPlanSetActive(line2_maintain_plan, true);
    }

    int current_line1_count = kbUnitCount(cMyID, line1, cUnitStateABQ);
    int current_line2_count = kbUnitCount(cMyID, line2, cUnitStateABQ);

    if (aiRandInt(2) == 1)
    {
        aiPlanSetDesiredPriority(line1_maintain_plan, 10);
        aiPlanSetDesiredPriority(line2_maintain_plan, 1);
    }
    else
    {
        aiPlanSetDesiredPriority(line1_maintain_plan, 1);
        aiPlanSetDesiredPriority(line2_maintain_plan, 10);
    }

    aiPlanSetVariableInt(line1_maintain_plan, cTrainPlanUnitType, 0, line1);
    aiPlanSetVariableInt(line2_maintain_plan, cTrainPlanUnitType, 0, line2);
    
    if (kbUnitCostPerResource(line1, cResourceWood) > 0.1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        aiPlanSetVariableInt(line1_maintain_plan, cTrainPlanNumberToMaintain, 0, 0);
    else
        aiPlanSetVariableInt(line1_maintain_plan, cTrainPlanNumberToMaintain, 0, current_line1_count + 5 * kbGetAge());
    
    if (kbUnitCostPerResource(line2, cResourceWood) > 0.1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        aiPlanSetVariableInt(line2_maintain_plan, cTrainPlanNumberToMaintain, 0, 0);
    else
        aiPlanSetVariableInt(line2_maintain_plan, cTrainPlanNumberToMaintain, 0, current_line2_count + 5 * kbGetAge());
}


// ================================================================================
// Train artillery units to fill our lines.
// ================================================================================
rule MaintainArtilleryUnits
group rgMainBase
inactive
minInterval 2
{
    if (kbGetAge() <= cAge2)
        return;
    
    // Allocate a maximum of 20 slots for artillery units. It doesn't matter how much pop one individual
    // artillery unit takes: the cap will remain at 20.
    int artillery_pop = 20;
    
    int anti_infantry = -1;
    int anti_building = -1;

    if (isEuropean() == true)
    {
        anti_infantry = cUnitTypeFalconet;
        anti_building = cUnitTypeMortar;
    }

    if (isEuropean() == false && kbProtoUnitAvailable(cUnitTypeypHandMortar) == true)
    {
        anti_infantry = cUnitTypeypFlameThrower;
        anti_building = cUnitTypeypHandMortar;
    }

    static int anti_infantry_maintain_plan = -1;
    static int anti_building_maintain_plan = -1;

    if (anti_infantry_maintain_plan == -1 && kbProtoUnitAvailable(anti_infantry) == true)
    {
        anti_infantry_maintain_plan = aiPlanCreate("Maintain Main Military Line 1", cPlanTrain);
        aiPlanSetDesiredPriority(anti_infantry_maintain_plan, 10);
        aiPlanSetEscrowID(anti_infantry_maintain_plan, cRootEscrowID);
        aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanFrequency, 0, 1);
        aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanUnitType, 0, anti_infantry);
        aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanNumberToMaintain, 0, 10);
        aiPlanSetVariableBool(anti_infantry_maintain_plan, cTrainPlanUseMultipleBuildings, 0, true);
        aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanBatchSize, 0, 5);
        aiPlanSetActive(anti_infantry_maintain_plan, true);
    }
    
    if (anti_building_maintain_plan == -1 && kbProtoUnitAvailable(anti_building) == true)
    {
        anti_building_maintain_plan = aiPlanCreate("Maintain Main Military Line 2", cPlanTrain);
        aiPlanSetDesiredPriority(anti_building_maintain_plan, 10);
        aiPlanSetEscrowID(anti_building_maintain_plan, cRootEscrowID);
        aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanFrequency, 0, 1);
        aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanUnitType, 0, anti_building);
        aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanNumberToMaintain, 0, 10);
        aiPlanSetVariableBool(anti_building_maintain_plan, cTrainPlanUseMultipleBuildings, 0, true);
        aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanBatchSize, 0, 5);
        aiPlanSetActive(anti_building_maintain_plan, true);
    }

    int current_anti_infantry_count = kbUnitCount(cMyID, anti_infantry, cUnitStateABQ);
    int current_anti_building_count = kbUnitCount(cMyID, anti_building, cUnitStateABQ);

    if ((current_anti_infantry_count * kbGetPopSlots(cMyID, anti_infantry) + 
        current_anti_building_count * kbGetPopSlots(cMyID, anti_building)) >= artillery_pop)
    {
        aiPlanSetDesiredPriority(anti_infantry_maintain_plan, 0);
        aiPlanSetDesiredPriority(anti_building_maintain_plan, 0);
        aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanNumberToMaintain, 0, 0);
        aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanNumberToMaintain, 0, 0);
        return;
    }

    if (aiRandInt(2) == 1)
    {
        aiPlanSetDesiredPriority(anti_infantry_maintain_plan, 10);
        aiPlanSetDesiredPriority(anti_building_maintain_plan, 1);
    }
    else
    {
        aiPlanSetDesiredPriority(anti_infantry_maintain_plan, 1);
        aiPlanSetDesiredPriority(anti_building_maintain_plan, 10);
    }

    aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanUnitType, 0, anti_infantry);
    aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanUnitType, 0, anti_building);
    
    if (kbUnitCostPerResource(anti_infantry, cResourceWood) > 0.1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanNumberToMaintain, 0, 0);
    else
        aiPlanSetVariableInt(anti_infantry_maintain_plan, cTrainPlanNumberToMaintain, 0, current_anti_infantry_count + 5);
    
    if (kbUnitCostPerResource(anti_building, cResourceWood) > 0.1 && kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
        aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanNumberToMaintain, 0, 0);
    else
        aiPlanSetVariableInt(anti_building_maintain_plan, cTrainPlanNumberToMaintain, 0, current_anti_building_count + 5);
}


// ================================================================================
// Keep training consulate units endlessly (TODO: do it only after all consulate 
// techs are researched).
// ================================================================================
rule MaintainConsulateArmies
group rgMainBase
inactive
minInterval 60
{
    if (isAsian() == false && cMyCiv != cCivOttomans)
    {
        xsDisableSelf();
        return;
    }

    if (kbGetAge() <= cAge1)
        return;
    
    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom)
        return;
    
    // First of all, let's choose an ally
    static int consulate_allies = -1;
    static int available_allies = -1;
    static int chosen_ally = -1; // TODO: make it possible to change ally
    int available_allies_count = 0;

    if (consulate_allies == -1)
    {
        available_allies = xsArrayCreateInt(11, -1, "List of available consulate allies");
        consulate_allies = xsArrayCreateInt(11, -1, "List of consulate allies");

        xsArraySetInt(consulate_allies, 0, cTechypBigConsulateDutch);
        xsArraySetInt(consulate_allies, 1, cTechypBigConsulatePortuguese);
        xsArraySetInt(consulate_allies, 2, cTechypBigConsulateSpanish);
        xsArraySetInt(consulate_allies, 3, cTechypBigConsulateRussians);
        xsArraySetInt(consulate_allies, 4, cTechypBigConsulateBritish);
        xsArraySetInt(consulate_allies, 5, cTechypBigConsulateGermans);
        xsArraySetInt(consulate_allies, 6, cTechypBigConsulateFrench);
        xsArraySetInt(consulate_allies, 7, cTechypBigConsulateOttomans);
        xsArraySetInt(consulate_allies, 8, cTechypBigConsulateJapanese);
        xsArraySetInt(consulate_allies, 9, cTechypBigConsulateSPCDutch);
        xsArraySetInt(consulate_allies, 10, cTechypBigConsulateSPCPortuguese);
    }

    if (chosen_ally == -1)
    {
        int i_ally = -1;

        for(i = 0; < xsArrayGetSize(consulate_allies))
        {
            i_ally = xsArrayGetInt(consulate_allies, i);
            if (kbTechGetStatus(i_ally) == cTechStatusObtainable)
            {
                xsArraySetInt(available_allies, available_allies_count, i_ally);
                available_allies_count++;
            }
        }

        if (available_allies_count == 0)
            return;

        chosen_ally = xsArrayGetInt(available_allies, aiRandInt(available_allies_count));
    }

    if (kbTechGetStatus(chosen_ally) != cTechStatusActive)
    {
        if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, chosen_ally, true) == -1)
        {
            int ally_research_plan = aiPlanCreate("Research Consulate Ally (" + kbGetTechName(chosen_ally) + ")", cPlanResearch);
            aiPlanSetDesiredPriority(ally_research_plan, 100);
            aiPlanSetEscrowID(ally_research_plan, cRootEscrowID);
            aiPlanSetVariableInt(ally_research_plan, cResearchPlanTechID, 0, chosen_ally);
            aiPlanSetActive(ally_research_plan, true);
        }

        return;
    }

    static int consulate_armies = -1;
    static int available_armies = -1;
    static int last_reset = -2000;
    static int age2_time = -2000;
    const int cResetCDN = 180000;

    if (kbGetAge() >= cAge2)
        age2_time = xsGetTime();

    if ((xsGetTime() < last_reset + cResetCDN) && (xsGetTime() < age2_time + cResetCDN))
        last_reset = last_reset - cResetCDN - 900;

    int available_count = 0;

    if (available_armies == -1)
    {
        available_armies = xsArrayCreateInt(74, -1, "List of consulate armies that are enabled in the techtree");

        consulate_armies = xsArrayCreateInt(36, -1, "List of consulate armies");
        xsArraySetInt(consulate_armies, 0, cUnitTypeypConsulateJinete);
        xsArraySetInt(consulate_armies, 1, cUnitTypeypConsulateGuerreiros);
        xsArraySetInt(consulate_armies, 2, cUnitTypeypConsulateGarrochista);
        xsArraySetInt(consulate_armies, 3, cUnitTypeypConsulateCarabineer);
        xsArraySetInt(consulate_armies, 4, cUnitTypeypConsulateGendarmes);
        xsArraySetInt(consulate_armies, 5, cUnitTypeypConsulateRogersRanger);
        xsArraySetInt(consulate_armies, 6, cUnitTypeypConsulateArmyOttoman2);
        xsArraySetInt(consulate_armies, 7, cUnitTypeypConsulateArmyOttoman3);
        xsArraySetInt(consulate_armies, 8, cUnitTypeypConsulateArmyOttoman22);
        xsArraySetInt(consulate_armies, 9, cUnitTypeypConsulateArmyOttoman33);
        xsArraySetInt(consulate_armies, 10, cUnitTypeypConsulateArmyPortuguese2);
        xsArraySetInt(consulate_armies, 11, cUnitTypeypConsulateArmyPortuguese3);
        xsArraySetInt(consulate_armies, 12, cUnitTypeypConsulateArmyPortuguese22);
        xsArraySetInt(consulate_armies, 13, cUnitTypeypConsulateArmyPortuguese33);
        xsArraySetInt(consulate_armies, 14, cUnitTypeypConsulateArmyDutch2);
        xsArraySetInt(consulate_armies, 15, cUnitTypeypConsulateArmyDutch2US);
        xsArraySetInt(consulate_armies, 16, cUnitTypeypConsulateArmyDutch3);
        xsArraySetInt(consulate_armies, 17, cUnitTypeypConsulateArmyDutch22);
        xsArraySetInt(consulate_armies, 18, cUnitTypeypConsulateArmyDutch33);
        xsArraySetInt(consulate_armies, 19, cUnitTypeypConsulateArmyRussian2);
        xsArraySetInt(consulate_armies, 20, cUnitTypeypConsulateArmyRussian3);
        xsArraySetInt(consulate_armies, 21, cUnitTypeypConsulateArmyRussian22);
        xsArraySetInt(consulate_armies, 22, cUnitTypeypConsulateArmyRussian33);
        xsArraySetInt(consulate_armies, 23, cUnitTypeypConsulateArmyBritish2);
        xsArraySetInt(consulate_armies, 24, cUnitTypeypConsulateArmyBritish3);
        xsArraySetInt(consulate_armies, 25, cUnitTypeypConsulateArmyBritish22);
        xsArraySetInt(consulate_armies, 26, cUnitTypeypConsulateArmyBritish33);
        xsArraySetInt(consulate_armies, 27, cUnitTypeypConsulateArmySpanish2);
        xsArraySetInt(consulate_armies, 28, cUnitTypeypConsulateArmySpanish22);
        xsArraySetInt(consulate_armies, 29, cUnitTypeypConsulateArmySpanish3);
        xsArraySetInt(consulate_armies, 30, cUnitTypeypConsulateArmySpanish33);
        xsArraySetInt(consulate_armies, 31, cUnitTypeypConsulateArmyFrench2);
        xsArraySetInt(consulate_armies, 32, cUnitTypeypConsulateArmyFrench3);
        xsArraySetInt(consulate_armies, 33, cUnitTypeypConsulateArmyFrench3US);
        xsArraySetInt(consulate_armies, 34, cUnitTypeypConsulateArmyFrench22);
        xsArraySetInt(consulate_armies, 35, cUnitTypeypConsulateArmyFrench33);
        xsArraySetInt(consulate_armies, 36, cUnitTypeypConsulateArmyGerman2);
        xsArraySetInt(consulate_armies, 37, cUnitTypeypConsulateArmyGerman3);
        xsArraySetInt(consulate_armies, 38, cUnitTypeypConsulateArmyGerman22);
        xsArraySetInt(consulate_armies, 39, cUnitTypeypConsulateArmyGerman33);
        xsArraySetInt(consulate_armies, 40, cUnitTypeypConsulateKalmuck);
        xsArraySetInt(consulate_armies, 41, cUnitTypeypConsulatePrussianNeedleGun);
        xsArraySetInt(consulate_armies, 42, cUnitTypeypConsulateArmyItalians2);
        xsArraySetInt(consulate_armies, 43, cUnitTypeypConsulateArmyItalians3);
        xsArraySetInt(consulate_armies, 44, cUnitTypeypConsulateCulverin2);
        xsArraySetInt(consulate_armies, 45, cUnitTypeypConsulateArmyItalians22);
        xsArraySetInt(consulate_armies, 46, cUnitTypeypConsulateArmyItalians33);
    }

    int i_unit = -1;

    for(i = 0; < xsArrayGetSize(consulate_armies))
    {
        i_unit = xsArrayGetInt(consulate_armies, i);
        if (kbProtoUnitAvailable(i_unit) == true)
        {
            xsArraySetInt(available_armies, available_count, i_unit);
            available_count++;
        }
    }

    if (available_count == 0 || xsGetTime() < last_reset + cResetCDN)
        return;
    last_reset = xsGetTime();

    int army = xsArrayGetInt(available_armies, available_count);

    static int army_maintain_plan = -1;

    if (army_maintain_plan == -1)
    {
        army_maintain_plan = aiPlanCreate("Maintain Consulate Army", cPlanTrain);
        aiPlanSetDesiredPriority(army_maintain_plan, 10);
        aiPlanSetEscrowID(army_maintain_plan, cRootEscrowID);
        aiPlanSetVariableInt(army_maintain_plan, cTrainPlanFrequency, 0, 1);
        aiPlanSetVariableInt(army_maintain_plan, cTrainPlanUnitType, 0, army);
        aiPlanSetVariableInt(army_maintain_plan, cTrainPlanNumberToMaintain, 0, 1);
        aiPlanSetVariableBool(army_maintain_plan, cTrainPlanUseMultipleBuildings, 0, true);
        aiPlanSetVariableInt(army_maintain_plan, cTrainPlanBatchSize, 0, 5);
        aiPlanSetActive(army_maintain_plan, true);
    }

    aiPlanSetVariableInt(army_maintain_plan, cTrainPlanUnitType, 0, army);
    aiPlanSetVariableInt(army_maintain_plan, cTrainPlanNumberToMaintain, 0, 1);
}


// ================================================================================
// Use the fame resource.
// ================================================================================
rule MaintainFameUnits
group rgMainBase
inactive
minInterval 10
{
    if (kbGetAge() <= cAge1)
        return;
    
    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom)
        return;
    
    static int primary_fame_units = -1;
    static int secondary_fame_units = -1;
    static int available_primary_fame_units = -1;
    static int available_secondary_fame_units = -1;
    int available_primary_count = 0;
    int available_secondary_count = 0;

    if (primary_fame_units == -1)
    {
        primary_fame_units = xsArrayCreateInt(12, -1, "List of primary fame units.");
        xsArraySetInt(primary_fame_units, 0, cUnitTypeGeneral);
        xsArraySetInt(primary_fame_units, 1, cUnitTypeGeneralAlain);
        xsArraySetInt(primary_fame_units, 2, cUnitTypeGeneralSahin);
        xsArraySetInt(primary_fame_units, 3, cUnitTypeGeneralMorgan);
        xsArraySetInt(primary_fame_units, 4, cUnitTypeGeneralWarwick);
        xsArraySetInt(primary_fame_units, 5, cUnitTypeGeneralCuster);
        xsArraySetInt(primary_fame_units, 6, cUnitTypeGeneralBr);
        xsArraySetInt(primary_fame_units, 7, cUnitTypeGeneralJohn);
        xsArraySetInt(primary_fame_units, 8, cUnitTypeGeneralBolivar);
        xsArraySetInt(primary_fame_units, 9, cUnitTypeGeneralCrazy);
        xsArraySetInt(primary_fame_units, 10, cUnitTypeFlagBearer);
        xsArraySetInt(primary_fame_units, 11, cUnitTypeDrummerEu);

        secondary_fame_units = xsArrayCreateInt(4, -1, "List of secondary fame units.");
        xsArraySetInt(secondary_fame_units, 0, cUnitTypePriest);
        xsArraySetInt(secondary_fame_units, 1, cUnitTypeMissionary);
        xsArraySetInt(secondary_fame_units, 2, cUnitTypexpSpy);
        xsArraySetInt(secondary_fame_units, 3, cUnitTypeInquisitor);

        available_primary_fame_units = xsArrayCreateInt(11, -1, "List of primary fame units that are enabled in the tech tree.");
        available_secondary_fame_units = xsArrayCreateInt(4, -1, "List of secondary fame units that are enabled in the tech tree.");
    }

    // Check for available primary fame units.
    for(i = 0; < xsArrayGetSize(primary_fame_units))
    {
        if (kbProtoUnitAvailable(xsArrayGetInt(primary_fame_units, i)) == true)
        {
            xsArraySetInt(available_primary_fame_units, available_primary_count, xsArrayGetInt(primary_fame_units, i));
            available_primary_count++;
        }
    }

    // Check for available secondary fame units.
    for(i = 0; < xsArrayGetSize(secondary_fame_units))
    {
        if (kbProtoUnitAvailable(xsArrayGetInt(secondary_fame_units, i)) == true)
        {
            xsArraySetInt(available_secondary_fame_units, available_secondary_count, xsArrayGetInt(secondary_fame_units, i));
            available_secondary_count++;
        }
    }

    // Create a dummy plan for all fame units.
    for(i = 0; < xsArrayGetSize(available_primary_fame_units))
    {
        int primary_fame_unit = xsArrayGetInt(available_primary_fame_units, i);
        if (aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, primary_fame_unit, true) == -1)
        {
            int primary_fame_unit_plan = aiPlanCreate("Maintain Primary Fame Unit (" + kbGetProtoUnitName(primary_fame_unit) + ")", cPlanTrain);
            aiPlanSetDesiredPriority(primary_fame_unit_plan, 1);
            aiPlanSetEscrowID(primary_fame_unit_plan, cRootEscrowID);
            aiPlanSetVariableInt(primary_fame_unit_plan, cTrainPlanFrequency, 0, 1);
            aiPlanSetVariableInt(primary_fame_unit_plan, cTrainPlanUnitType, 0, primary_fame_unit);
            aiPlanSetVariableInt(primary_fame_unit_plan, cTrainPlanNumberToMaintain, 0, 1);
            aiPlanSetVariableBool(primary_fame_unit_plan, cTrainPlanUseMultipleBuildings, 0, true);
            aiPlanSetVariableInt(primary_fame_unit_plan, cTrainPlanBatchSize, 0, 5);
            aiPlanSetActive(primary_fame_unit_plan, true);
        }

        int secondary_fame_unit = xsArrayGetInt(available_secondary_fame_units, i);
        if (aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, secondary_fame_unit, true) == -1)
        {
            int secondary_fame_unit_plan = aiPlanCreate("Maintain Secondary Fame Unit (" + kbGetProtoUnitName(secondary_fame_unit) + ")", cPlanTrain);
            aiPlanSetDesiredPriority(secondary_fame_unit_plan, 1);
            aiPlanSetEscrowID(secondary_fame_unit_plan, cRootEscrowID);
            aiPlanSetVariableInt(secondary_fame_unit_plan, cTrainPlanFrequency, 0, 1);
            aiPlanSetVariableInt(secondary_fame_unit_plan, cTrainPlanUnitType, 0, secondary_fame_unit);
            aiPlanSetVariableInt(secondary_fame_unit_plan, cTrainPlanNumberToMaintain, 0, 1);
            aiPlanSetVariableBool(secondary_fame_unit_plan, cTrainPlanUseMultipleBuildings, 0, true);
            aiPlanSetVariableInt(secondary_fame_unit_plan, cTrainPlanBatchSize, 0, 5);
            aiPlanSetActive(secondary_fame_unit_plan, true);
        }
    }

    // We must get all primary fame units before we can get any secondary fame units.
    bool primary_fame_units_complete = true;
    for(i = 0; < xsArrayGetSize(available_primary_fame_units))
    {
        primary_fame_unit = xsArrayGetInt(available_primary_fame_units, i);
        if (kbUnitCount(cMyID, primary_fame_unit, cUnitStateABQ) < kbGetBuildLimit(cMyID, primary_fame_unit))
        {
            primary_fame_units_complete = false;
            break;
        }
    }

    // Shut all secondary fame units down if we don't have all primary fame units.
    if (primary_fame_units_complete == false)
    {
        // Shut down all secondary fame units plans.
        for(i = 0; < xsArrayGetSize(available_secondary_fame_units))
        {
            secondary_fame_unit = xsArrayGetInt(available_secondary_fame_units, i);
            secondary_fame_unit_plan = aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, secondary_fame_unit, true);
            if (secondary_fame_unit_plan != -1)
            {
                aiPlanSetDesiredPriority(secondary_fame_unit_plan, 1);
                aiPlanSetVariableInt(secondary_fame_unit_plan, cTrainPlanNumberToMaintain, 0, 0);
            }
        }

        // Bump up the priority of all primary fame units plans and set the number to maintain to the build limit.
        for(i = 0; < xsArrayGetSize(available_primary_fame_units))
        {
            primary_fame_unit = xsArrayGetInt(available_primary_fame_units, i);
            primary_fame_unit_plan = aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, primary_fame_unit, true);
            if (primary_fame_unit_plan != -1)
            {
                aiPlanSetDesiredPriority(primary_fame_unit_plan, 10);
                aiPlanSetVariableInt(primary_fame_unit_plan, cTrainPlanNumberToMaintain, 0, kbGetBuildLimit(cMyID, primary_fame_unit));
            }
        }
    }
    else
    {
        // Bump up the priority of all secondary fame units plans and set the number to maintain to the build limit.
        for(i = 0; < xsArrayGetSize(available_secondary_fame_units))
        {
            secondary_fame_unit = xsArrayGetInt(available_secondary_fame_units, i);
            secondary_fame_unit_plan = aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, secondary_fame_unit, true);
            if (secondary_fame_unit_plan != -1)
            {
                aiPlanSetDesiredPriority(secondary_fame_unit_plan, 10);
                aiPlanSetVariableInt(secondary_fame_unit_plan, cTrainPlanNumberToMaintain, 0, kbGetBuildLimit(cMyID, secondary_fame_unit));
            }
        }

        // Shut down all primary fame units plans.
        for(i = 0; < xsArrayGetSize(available_primary_fame_units))
        {
            primary_fame_unit = xsArrayGetInt(available_primary_fame_units, i);
            primary_fame_unit_plan = aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, primary_fame_unit, true);
            if (primary_fame_unit_plan != -1)
            {
                aiPlanSetDesiredPriority(primary_fame_unit_plan, 1);
                aiPlanSetVariableInt(primary_fame_unit_plan, cTrainPlanNumberToMaintain, 0, 0);
            }
        }
    }
}


// ================================================================================
// Keep training native warriors endlessly (TODO: do it only after all native techs
// are researched).
// ================================================================================
rule MaintainNativeWarriors
group rgMainBase
inactive
minInterval 5
{
    if (kbGetAge() <= cAge1)
        return;
    
    if (kbGetAge() <= cAge2 && gStrategy == cStrategyBoom)
        return;
    
    static int current_researh_plan = -1;
    if (aiPlanGetState(current_researh_plan) == -1)
    {
        aiPlanDestroy(current_researh_plan);
        current_researh_plan = -1;
    }
    
    kbUnitPickResetAll(gUnitPicker);
    kbUnitPickSetPreferenceWeight(gUnitPicker, 1.0);
    kbUnitPickSetCombatEfficiencyWeight(gUnitPicker, 0.0);
    kbUnitPickSetCostWeight(gUnitPicker, 0.0);
    kbUnitPickSetPreferenceFactor(gUnitPicker, cUnitTypeAll, 1.0);
    for(i = 0; < kbUnitPickRun(gUnitPicker))
    {
        int i_protounit = kbUnitPickGetResult(gUnitPicker, i);
        if (kbProtoUnitIsType(cMyID, i_protounit, cUnitTypeAbstractNativeWarrior) == false)
            continue;
        
        int i_protounit_limit = kbGetBuildLimit(cMyID, i_protounit);
        if (i_protounit_limit <= 0)
            continue;
        
        if (current_researh_plan == -1)
        {
            int i_protounit_upgrade = kbTechTreeGetCheapestUnitUpgrade(i_protounit);
            if (i_protounit_upgrade >= 0)
            {
                current_researh_plan = aiPlanCreate("Research Native Warrior Upgrade (" + kbGetTechName(i_protounit_upgrade) + ")", cPlanResearch);
                aiPlanSetDesiredPriority(current_researh_plan, 100);
                aiPlanSetEscrowID(current_researh_plan, cRootEscrowID);
                aiPlanSetVariableInt(current_researh_plan, cResearchPlanTechID, 0, i_protounit_upgrade);
                aiPlanSetEventHandler(current_researh_plan, cPlanEventStateChange, "eWhenUnitUpgradePlanStateChanges");
                aiPlanSetActive(current_researh_plan, true);
            }
        }
        
        int native_warrior_maintain_plan = aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, i_protounit, true);
        if (native_warrior_maintain_plan >= 0)
        {
            aiPlanSetVariableInt(native_warrior_maintain_plan, cTrainPlanNumberToMaintain, 0, i_protounit_limit);
            continue;
        }
        else
        {
            native_warrior_maintain_plan = aiPlanCreate("Maintain Native Warriors", cPlanTrain);
            aiPlanSetDesiredPriority(native_warrior_maintain_plan, 10);
            aiPlanSetEscrowID(native_warrior_maintain_plan, cRootEscrowID);
            aiPlanSetVariableInt(native_warrior_maintain_plan, cTrainPlanFrequency, 0, 1);
            aiPlanSetVariableInt(native_warrior_maintain_plan, cTrainPlanUnitType, 0, i_protounit);
            aiPlanSetVariableInt(native_warrior_maintain_plan, cTrainPlanNumberToMaintain, 0, i_protounit_limit);
            aiPlanSetVariableBool(native_warrior_maintain_plan, cTrainPlanUseMultipleBuildings, 0, true);
            aiPlanSetVariableInt(native_warrior_maintain_plan, cTrainPlanBatchSize, 0, 5);
            aiPlanSetActive(native_warrior_maintain_plan, true);
        }
    }
}
