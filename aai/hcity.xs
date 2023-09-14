rule UnlockAllCards
active
runImmediately
{
    xsDisableSelf();
    xsEnableRule("BuyCards");
    aiCheatAddResources(cResourceSkillPoints, 150);
}

rule BuyCards
inactive
{
    xsDisableSelf();
    xsEnableRule("CreateDeck");
    for(attempt = 0; < 7)
    {
        for(card = 0; < aiHCCardsGetTotal())
            aiHCCardsBuyCard(card);
    }
}


void addCardToDeck(string card_tech_name = "")
{
    for(card = 0; < aiHCCardsGetTotal())
    {
        if (kbGetTechName(aiHCCardsGetCardTechID(card)) == card_tech_name)
        {
            aiHCDeckAddCardToDeck(cDefaultDeckID, card);
            aiQVSet(cFlagAddedCard + card_tech_name, 1);
            break;
        }
    }
}


rule CreateDeck
inactive
{
    xsDisableSelf();

    // Cards to always add in all games.

    for(card = 0; < aiHCCardsGetTotal())
    {
        string card_name = kbGetTechName(aiHCCardsGetCardTechID(card));
        if (
            (cMyCiv == cCivSpanish && (
                card_name == "HCRoyalDecreeSpanish" || 
                card_name == "HCHandCavalryCombatSpanish" || 
                card_name == "HCHandInfantryHitpointsSpanish" || 
                card_name == "HCHandInfantryCombatSpanish")
            ) || (cMyCiv == cCivBritish && (
                card_name == "HCRoyalDecreeBritish" || 
                card_name == "HCCavalryCombatBritish" || 
                card_name == "HCMusketeerGrenadierCombatBritish" || 
                card_name == "HCMusketeerGrenadierHitpointsBritishTeam")
            ) || (cMyCiv == cCivFrench && (
                card_name == "HCRoyalDecreeFrench" || 
                card_name == "HCHandCavalryDamageFrenchTeam" || 
                card_name == "HCCavalryCombatFrench" || 
                card_name == "HCRangedInfantryDamageFrenchTeam" || 
                card_name == "HCHandCavalryHitpointsFrench")
            ) || (cMyCiv == cCivPortuguese && (
                card_name == "HCRoyalDecreePortuguese" || 
                card_name == "HCDragoonCombatPortuguese" || 
                card_name == "HCRangedInfantryCombatPortuguese" || 
                card_name == "HCRangedInfantryHitpointsPortugueseTeam" || 
                card_name == "HCRangedInfantryDamagePortuguese")
            ) || (cMyCiv == cCivDutch && (
                card_name == "HCRoyalDecreeDutch" || 
                card_name == "HCInfantryCombatDutch" || 
                card_name == "HCCavalryCombatDutch" || 
                card_name == "HCInfantryHitpointsDutchTeam" || 
                card_name == "HCBetterBanks")
            ) || (cMyCiv == cCivRussians && (
                card_name == "HCRoyalDecreeRussian" || 
                card_name == "HCCavalryCombatRussian" || 
                card_name == "HCStreletsCombatRussian" || 
                card_name == "HCRansack")
            ) || (cMyCiv == cCivGermans && (
                card_name == "HCRoyalDecreeGerman" || 
                card_name == "HCAdvancedArsenalGerman" || 
                card_name == "HCUnlockFactoryGerman" || 
                card_name == "HCRobberBaronsGerman" || 
                card_name == "HCImprovedBuildingsGerman" || 
                card_name == "HCHandInfantryCombatGerman" || 
                card_name == "HCCavalryDamageGermanTeam" || 
                card_name == "HCCavalryCombatGerman" || 
                card_name == "HCRefrigerationGerman" || 
                card_name == "HCRoyalMintGerman" || 
                card_name == "HCFencingSchoolGerman" || 
                card_name == "HCRidingSchoolGerman" || 
                card_name == "HCGermanTownFarmers" || 
                card_name == "HCTeamTeutonTownCenter" || 
                card_name == "HCUhlanCombatGerman" || 
                card_name == "HCShipFoodCrates3German" || 
                card_name == "HCShipWoodCrates3German" || 
                card_name == "HCShipCoinCrates3German")
            ) || (cMyCiv == cCivOttomans && (
                card_name == "HCRoyalDecreeOttoman" || 
                card_name == "HCJanissaryCombatOttoman" || 
                card_name == "HCLightArtilleryHitpointsOttoman" || 
                card_name == "HCArtilleryDamageOttoman" || 
                card_name == "HCArtilleryHitpointsOttomanTeam" || 
                card_name == "HCCavalryCombatOttoman" || 
                card_name == "HCJanissaryCost")
            ) || (cMyCiv == cCivItalians && (
                card_name == "HCRoyalDecreeItalians")
            ) || (cMyCiv == cCivSwedish && (
                card_name == "HCRoyalDecreeSwedish")
            ) || (cMyCiv == cCivUSA && (
                card_name == "HCRoyalDecreeUS")
            ) || ( card_name == "HCAdvancedArsenal"
            ) || (cMyCulture == cCultureIroquois && (
                card_name == "HCXPNewWaysIroquois" || 
                card_name == "HCXPInfantryCombatIroquois" || 
                card_name == "HCXPInfantryHitpointsIroquois")
            ) || (cMyCulture == cCultureSioux && (
                card_name == "HCXPNewWaysSioux" || 
                card_name == "HCXPCavalryDamageSioux" || 
                card_name == "HCXPCavalryHitpointsSioux" || 
                card_name == "HCXPCavalryCombatSioux" || 
                card_name == "HCXPSiouxTwoKettleSupport" || 
                card_name == "HCXPSiouxSanteeSupport" || 
                card_name == "HCXPSiouxYanktonSupport")
            ) || (cMyCiv != cCivGermans && 
                    ((cMyCulture != cCultureIndian && (
                    card_name == "HCExtensiveFort" || 
                    card_name == "HCImprovedBuildings" || 
                    card_name == "HCUnlockFactory" || 
                    card_name == "HCRobberBarons" || 
                    card_name == "HCXPIndustrialRevolution" || 
                    card_name == "HCRefrigeration" || 
                    card_name == "HCRoyalMint" || 
                    card_name == "HCFencingSchool" || 
                    card_name == "HCRidingSchool" || 
                    card_name == "HCShipFoodCrates3" || 
                    card_name == "HCShipWoodCrates3" || 
                    card_name == "HCShipCoinCrates3"))
                || ((cMyCulture == cCultureIndian && (
                    card_name == "YPHCGurkhaAid" || 
                    card_name == "YPHCMughalArchitecture" || 
                    card_name == "YPHCRoyalMintIndians" || 
                    card_name == "YPHCFencingSchoolIndians" || 
                    card_name == "YPHCRidingSchoolIndians" || 
                    card_name == "YPHCElephantTrampling" || 
                    card_name == "YPHCElephantLimit" || 
                    card_name == "YPHCCamelDamageIndians" || 
                    card_name == "YPHCElephantCombatIndians" || 
                    card_name == "YPHCShipWoodCratesInf4Indians")
                )))
            ) || (cMyCulture == cCultureJapanese && (
                card_name == "YPHCShipShogunate" || 
                card_name == "YPHCSamuraiDamage" || 
                card_name == "YPHCNobleCombat" || 
                card_name == "YPHCNaginataHitpoints" || 
                card_name == "YPHCNaginataAntiInfantryDamage" || 
                card_name == "YPHCYumiDamage" || 
                card_name == "YPHCYumiRange" || 
                card_name == "YPHCAshigaruDamage" || 
                card_name == "YPHCSamuraiSpeed")
            ) || (cMyCulture == cCultureChinese && (
                card_name == "YPHCHanAntiCavalryBonus" || 
                card_name == "YPHCAccupuncture" || 
                card_name == "YPHCBannerSchool" || 
                card_name == "YPHCForbiddenArmyArmor" || 
                card_name == "YPHCTerritorialArmyCombat" || 
                card_name == "YPHCMongolianScourge" || 
                card_name == "YPHCStandardArmyHitpoints" || 
                card_name == "YPHCArtilleryCombatChinese")
            ) || ( card_name == "HCFrontierDefenses2" || 
                card_name == "HCXPUnlockFort2"
            ) || (aiTreatyActive() && (
                card_name == "HCExoticHardwoods" || 
                card_name == "HCRumDistillery" || 
                card_name == "HCSustainableAgriculture" || 
                card_name == "YPHCSustainableAgricultureIndians" || 
                card_name == "YPHCAgrarianism" || 
                card_name == "HCGrainMarket" || 
                card_name == "HCTextileMills" || 
                card_name == "HCGuildArtisans" || 
                card_name == "HCFoodSilos" || 
                card_name == "HCXPMedicineTeam" || 
                card_name == "HCSpiceTrade" || 
                card_name == "HCXPExoticHardwoodsTeam" || 
                card_name == "HCMedicine" || 
                card_name == "HCPioneers" || 
                card_name == "HCXPAdoption")
            ) || (false && (
                card_name == "HCNativeCombat" || 
                card_name == "HCNativeWarriors")
            ) || (isNative() && (
                card_name == "YPHCIncreasedTribute" || 
                card_name == "YPHCEastIndiaCompany" || 
                card_name == "HCXPCoyoteCombat" || 
                card_name == "HCXPKnightDamage" || 
                card_name == "HCXPKnightHitpoints" || 
                card_name == "HCXPKnightCombat" || 
                card_name == "HCXPMustangs" || 
                card_name == "HCXPEarthBounty" || 
                card_name == "HCXPWindRunner" || 
                card_name == "HCXPChinampa1" || 
                card_name == "HCXPChinampa2" || 
                card_name == "HCXPTempleCenteotl" || 
                card_name == "HCXPTempleXipeTotec" || 
                card_name == "HCXPTempleXolotl" || 
                card_name == "HCXPTempleCoatlicue" || 
                card_name == "HCXPTempleTlaloc" || 
                card_name == "HCXPGreatTempleQuetzalcoatl")
            ) || (isAsian() && (
                card_name == "YPHCCamelFrightening" || 
                card_name == "YPHCImprovedBuildingsTeam")
            ) || ( card_name == "HCXPSiegeCombat" || 
                card_name == "HCXPConservativeTactics" || 
                card_name == "HCXPCommandSkill" || 
                card_name == "HCXPNomadicExpansion" || 
                card_name == "HCCaballeros" || 
                card_name == "HCWildernessWarfare" || 
                card_name == "HCImprovedLongbows" || 
                card_name == "HCXPWarHutTraining")
            )
        {
            aiHCDeckAddCardToDeck(cDefaultDeckID, card);
            aiQVSet(cFlagAddedCard + card_name, 1);
        }
    }
    
    int best_card = -1;
    int highest_count = 0;
    for(card = 0; < aiHCCardsGetTotal())
    {
        if (aiHCCardsGetCardAgePrereq(card) != cAge1)
            continue;
        
        if (aiHCCardsGetCardUnitType(card) != gUnitTypeVillager)
            continue;
        
        if (highest_count < aiHCCardsGetCardUnitCount(card))
        {
            highest_count = aiHCCardsGetCardUnitCount(card);
            best_card = card;
        }
    }

    aiHCDeckAddCardToDeck(cDefaultDeckID, best_card);
    aiQVSet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(best_card)), 1);
    


    for(i = 0; < 2 + aiRandInt(3))
    {
        best_card = -1;
        highest_count = 0;
        for(card = 0; < aiHCCardsGetTotal())
        {
            int is_added = aiQVGet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(card)));
            if (is_added == 1)
                continue;
                
            if (aiHCCardsGetCardAgePrereq(card) != cAge3)
                continue;
        
            if (kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeLogicalTypeLandMilitary) == false)
                continue;
        
            if ((kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeMercenary) == true || 
                kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeMercType1) == true) && aiRandInt(100) < 80)
                continue;
            
            if (aiHCCardsGetCardUnitType(card) == cUnitTypeSaloonOutlawPistol)
                continue;
            if (aiHCCardsGetCardUnitType(card) == cUnitTypeSaloonOutlawRider)
                continue;
            if (aiHCCardsGetCardUnitType(card) == cUnitTypeSaloonOutlawRifleman)
                continue;
        
            if (highest_count < aiHCCardsGetCardUnitCount(card))
            {
                highest_count = aiHCCardsGetCardUnitCount(card);
                best_card = card;
            }
        }

        aiHCDeckAddCardToDeck(cDefaultDeckID, best_card);
        aiQVSet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(best_card)), 1);
    }



    for(i = 0; < 2 + aiRandInt(2))
    {
        best_card = -1;
        highest_count = 0;
        for(card = 0; < aiHCCardsGetTotal())
        {
            is_added = aiQVGet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(card)));
            if (is_added == 1)
                continue;
                
            if (aiHCCardsGetCardAgePrereq(card) != cAge4)
                continue;
        
            if (kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeLogicalTypeLandMilitary) == false)
                continue;
        
            if ((kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeMercenary) == true || 
                kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeMercType1) == true) && aiRandInt(100) < 70)
                continue;
            
            if (aiHCCardsGetCardUnitType(card) == cUnitTypeSaloonOutlawPistol)
                continue;
            if (aiHCCardsGetCardUnitType(card) == cUnitTypeSaloonOutlawRider)
                continue;
            if (aiHCCardsGetCardUnitType(card) == cUnitTypeSaloonOutlawRifleman)
                continue;
        
            if (highest_count < aiHCCardsGetCardUnitCount(card))
            {
                highest_count = aiHCCardsGetCardUnitCount(card);
                best_card = card;
            }
        }

        aiHCDeckAddCardToDeck(cDefaultDeckID, best_card);
        aiQVSet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(best_card)), 1);
    }



    if (gStrategy == cStrategyRush)
    {
        for(i = 0; < 3 + aiRandInt(3))
        {
            best_card = -1;
            highest_count = 0;
            for(card = 0; < aiHCCardsGetTotal())
            {
                is_added = aiQVGet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(card)));
                if (is_added == 1)
                    continue;
                
                if (aiHCCardsGetCardAgePrereq(card) != cAge2)
                    continue;
        
                if (kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeLogicalTypeLandMilitary) == false)
                    continue;
        
                if (highest_count < aiHCCardsGetCardUnitCount(card))
                {
                    highest_count = aiHCCardsGetCardUnitCount(card);
                    best_card = card;
                }
            }

            aiHCDeckAddCardToDeck(cDefaultDeckID, best_card);
            aiQVSet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(best_card)), 1);
        }
    }
    else
    {
        for(i = 0; < 2)
        {
            best_card = -1;
            highest_count = 0;
            for(card = 0; < aiHCCardsGetTotal())
            {
                is_added = aiQVGet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(card)));
                if (is_added == 1)
                    continue;
                
                if (aiHCCardsGetCardAgePrereq(card) != cAge2)
                    continue;
        
                if (kbProtoUnitIsType(cMyID, aiHCCardsGetCardUnitType(card), cUnitTypeLogicalTypeLandMilitary) == false)
                    continue;
        
                if (highest_count < aiHCCardsGetCardUnitCount(card))
                {
                    highest_count = aiHCCardsGetCardUnitCount(card);
                    best_card = card;
                }
            }

            aiHCDeckAddCardToDeck(cDefaultDeckID, best_card);
            aiQVSet(cFlagAddedCard + kbGetTechName(aiHCCardsGetCardTechID(best_card)), 1);
        }
    }



    static int available_cards = -1;
    int number_available_cards = 0;
    if (available_cards == -1)
        available_cards = xsArrayCreateInt(300, -1, "List of available cards");
    
    for(card = 0; < aiHCCardsGetTotal())
    {
        int card_tech = aiHCCardsGetCardTechID(card);
        card_name = kbGetTechName(card_tech);
        if (aiHCCardIsBanned(card_name) == true)
            continue;
        
        is_added = aiQVGet(cFlagAddedCard + card_name);
        if (is_added == 1)
            continue;
        
        xsArraySetInt(available_cards, number_available_cards, card);
        number_available_cards++;
    }

    for(attempt = 0; < 10)
        aiHCDeckAddCardToDeck(cDefaultDeckID, xsArrayGetInt(available_cards, aiRandInt(number_available_cards)));

    aiHCDeckActivate(cDefaultDeckID);
}


rule UseShipments
active
minInterval 0
{
    if (kbResourceGet(cResourceShips) < 1)
        return;
    
    if (ageingUp())
        return;
    
    bool unsafe_base = kbBaseGetUnderAttack(cMyID, kbBaseGetMainID(cMyID));
    
    if (unsafe_base)
    {
        int best_card = -1;
        int highest_count = 0;
        for(card = 0; < aiHCDeckGetNumberCards(cDefaultDeckID))
        {
            if (aiHCDeckCanPlayCard(card) == false)
                continue;
            
            if (kbProtoUnitIsType(cMyID, aiHCDeckGetCardUnitType(cDefaultDeckID, card), cUnitTypeLogicalTypeLandMilitary) == false)
                continue;
            
            int count = aiHCDeckGetCardUnitCount(cDefaultDeckID, card);
            if (count > highest_count)
            {
                highest_count = count;
                best_card = card;
            }
        }

        if (best_card >= 0)
        {
            aiHCDeckPlayCard(best_card);
            return;
        }

        for(card = 0; < aiHCDeckGetNumberCards(cDefaultDeckID))
        {
            if (aiHCDeckCanPlayCard(card) == false)
                continue;
            
            if (aiHCDeckGetCardUnitCount(cDefaultDeckID, card) >= 1)
                continue;
            
            aiHCDeckPlayCard(best_card);
            return;
        }

        for(card = 0; < aiHCDeckGetNumberCards(cDefaultDeckID))
        {
            if (aiHCDeckCanPlayCard(card) == false)
                continue;
            
            aiHCDeckPlayCard(best_card);
            return;
        }

        return;
    }

    float highest_score = -1.0;
    best_card = -1;

    for(card = 0; < aiHCDeckGetNumberCards(cDefaultDeckID))
    {
        if (aiHCDeckCanPlayCard(card) == false)
            continue;
        
        int unit_type = aiHCDeckGetCardUnitType(cDefaultDeckID, card);
        int unit_count = aiHCDeckGetCardUnitCount(cDefaultDeckID, card);
        int age_prereq = aiHCDeckGetCardAgePrereq(cDefaultDeckID, card);
        int card_tech = aiHCDeckGetCardTechID(cDefaultDeckID, card);
        string card_name = kbGetTechName(card_tech);
        float score = 0.0;

        switch (unit_type)
        {
            case cUnitTypeSettler:
            {
                score = 165.0 * unit_count;
                if (gStrategy == cStrategyRush)
                    score = score * .75;
                else
                    score = score * 1.25;
                break;
            }
            case cUnitTypeSettlerNative:
            {
                score = 165.0 * unit_count;
                if (gStrategy == cStrategyRush)
                    score = score * .75;
                else
                    score = score * 1.25;
                break;
            }
            case cUnitTypeSettlerSwedish:
            {
                score = 165.0 * unit_count;
                if (gStrategy == cStrategyRush)
                    score = score * .75;
                else
                    score = score * 1.25;
                break;
            }
            case cUnitTypeypSettlerAsian:
            {
                score = 165.0 * unit_count;
                if (gStrategy == cStrategyRush)
                    score = score * .75;
                else
                    score = score * 1.25;
                break;
            }
            case cUnitTypeypSettlerJapanese:
            {
                score = 165.0 * unit_count;
                if (gStrategy == cStrategyRush)
                    score = score * .75;
                else
                    score = score * 1.25;
                break;
            }
            case cUnitTypeCoureur:
            {
                score = 190.0 * unit_count;
                if (gStrategy == cStrategyRush)
                    score = score * .75;
                else
                    score = score * 1.25;
                break;
            }
            case cUnitTypeSettlerWagon:
            {
                score = 270.0 * unit_count;
                if (gStrategy == cStrategyRush)
                    score = score * .75;
                else
                    score = score * 1.25;
                break;
            }
            case cUnitTypeCoveredWagon:
            {
                if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) < kbGetBuildLimit(cMyID, cUnitTypeTownCenter))
                {
                    if (gStrategy == cStrategyBoom)
                        score = 1600.0 * unit_count;
                }

                if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) == 0)
                    score = 1000000.0;
                
                break;
            }
            case cUnitTypeFortWagon:
            {
                score = 100000.0;
                if (kbUnitCount(cMyID, cUnitTypeFortFrontier, cUnitStateABQ) >= kbGetBuildLimit(cMyID, cUnitTypeFortFrontier))
                    score = 0.0;
                break;
            }
            case cUnitTypeFactoryWagon:
            {
                score = 2000.0;
                if (kbUnitCount(cMyID, cUnitTypeFactory, cUnitStateABQ) >= kbGetBuildLimit(cMyID, cUnitTypeFactory))
                    score = 0.0;
                break;
            }
            case cUnitTypeYPDojoWagon:
            {
                score = 1500.0;
                break;
            }
            case cUnitTypeOutpostWagon:
            {
                score = 600.0 * unit_count;
                int number_outpost_wagons = kbUnitCount(cMyID, cUnitTypeOutpostWagon, cUnitStateABQ);
                int number_outposts = kbUnitCount(cMyID, cUnitTypeOutpost, cUnitStateABQ);
                if ((number_outpost_wagons + number_outposts) >= kbGetBuildLimit(cMyID, cUnitTypeOutpost))
                    score = 0.0;
                break;
            }
            case cUnitTypeYPCastleWagon:
            {
                score = 600.0 * unit_count;
                int number_castle_wagons = kbUnitCount(cMyID, cUnitTypeYPCastleWagon, cUnitStateABQ);
                int number_castles = kbUnitCount(cMyID, cUnitTypeypCastle, cUnitStateABQ);
                if ((number_castle_wagons + number_castles) >= kbGetBuildLimit(cMyID, cUnitTypeypCastle))
                    score = 0.0;
                break;
            }
            case cUnitTypeBankWagon:
            {
                score = 600.0 * unit_count;
                int number_bank_wagons = kbUnitCount(cMyID, cUnitTypeBankWagon, cUnitStateABQ);
                int number_banks = kbUnitCount(cMyID, cUnitTypeBank, cUnitStateABQ);
                if ((number_bank_wagons + number_banks) >= kbGetBuildLimit(cMyID, cUnitTypeBank))
                    score = 0.0;
                break;
            }
            case cUnitTypeCrateofCoin:
            {
                if (age_prereq == cAge2)
                    unit_count = 6;
                else if (age_prereq == cAge3)
                    unit_count = 10;
                else if (age_prereq >= cAge4)
                    unit_count = 15;
                
                score = 90.0 * unit_count;
                if (kbGetAge() == cAge1)
                    score = score * 0.5;
                break;
            }
            case cUnitTypeCrateofWood:
            {
                if (age_prereq == cAge2)
                    unit_count = 6;
                else if (age_prereq == cAge3)
                    unit_count = 10;
                else if (age_prereq >= cAge4)
                    unit_count = 15;
                
                score = 90.0 * unit_count;
                if (kbGetAge() == cAge1)
                    score = score * 0.5;
                break;
            }
            case cUnitTypeCrateofFood:
            {
                if (age_prereq == cAge2)
                    unit_count = 6;
                else if (age_prereq == cAge3)
                    unit_count = 10;
                else if (age_prereq >= cAge4)
                    unit_count = 15;
                
                score = 90.0 * unit_count;
                if (kbGetAge() == cAge1)
                    score = score * 0.5;
                break;
            }
            case cUnitTypeCrateofCoinLarge:
            {
                if (age_prereq == cAge2)
                    unit_count = 6;
                else if (age_prereq == cAge3)
                    unit_count = 10;
                else if (age_prereq >= cAge4)
                    unit_count = 15;
                
                score = 90.0 * unit_count;
                if (kbGetAge() == cAge1)
                    score = score * 0.5;
                break;
            }
            case cUnitTypeCrateofWoodLarge:
            {
                if (age_prereq == cAge2)
                    unit_count = 6;
                else if (age_prereq == cAge3)
                    unit_count = 10;
                else if (age_prereq >= cAge4)
                    unit_count = 15;
                
                score = 90.0 * unit_count;
                if (kbGetAge() == cAge1)
                    score = score * 0.5;
                break;
            }
            case cUnitTypeCrateofFoodLarge:
            {
                if (age_prereq == cAge2)
                    unit_count = 6;
                else if (age_prereq == cAge3)
                    unit_count = 10;
                else if (age_prereq >= cAge4)
                    unit_count = 15;
                
                score = 90.0 * unit_count;
                if (kbGetAge() == cAge1)
                    score = score * 0.5;
                break;
            }
            case cUnitTypeCow:
            {
                score = 80.0 * unit_count;
                break;
            }
            case cUnitTypeSheep:
            {
                score = 50.0 * unit_count;
                break;
            }
            default:
            {
                if (unit_type >= 0 && kbUnitGetMovementType(unit_type) != cMovementTypeLand)
                    score = 0.0;
                
                if (card_name == "HCRoyalDecreeSpanish" ||
                    card_name == "HCRoyalDecreeBritish" ||
                    card_name == "HCRoyalDecreeFrench" ||
                    card_name == "HCRoyalDecreePortuguese" ||
                    card_name == "HCRoyalDecreeDutch" ||
                    card_name == "HCRoyalDecreeRussian" ||
                    card_name == "HCRoyalDecreeGerman" ||
                    card_name == "HCRoyalDecreeOttoman" ||
                    card_name == "HCRoyalDecreeSwedish" ||
                    card_name == "HCRoyalDecreeItalians" ||
                    card_name == "HCRoyalDecreeUS")
                {
                    score = 1510.0;
                    if (cMyCiv == cCivGermans)
                        score = 6010.0;
                }
                
                if (card_name == "HCAdvancedArsenal" ||
                    card_name == "HCAdvancedArsenalGerman" ||
                    card_name == "HCXPNewWaysIroquois" ||
                    card_name == "HCXPNewWaysSioux")
                {
                    score = 1505.0;
                    if (cMyCiv == cCivGermans)
                        score = 6005.0;
                }

                if (card_name == "YPHCAgrarianism")
                {
                    score = 10000.0;
                    if (kbGetAge() == cAge1 || cMyCiv != cCivIndians)
                        score = 1.0;
                }

                if (card_name == "YPHCShipGroveWagonIndians2")
                {
                    if (gStrategy == cStrategyRush)
                        score = 495.0;
                    else
                        score = 825.0;
                }

                if (card_name == "YPHCShipShogunate")
                    score = 1000.0 + (aiRandInt(6) * 300.0);
                
                if (score < 1.0 && age_prereq >= cAge1)
                {
                    switch (age_prereq)
                    {
                        case cAge1:
                        {
                            score = 200.0;
                            break;
                        }
                        case cAge2:
                        {
                            score = 500.0;
                            break;
                        }
                        case cAge3:
                        {
                            score = 900.0;
                            break;
                        }
                        default:
                        {
                            score = 1300.0;
                            break;
                        }
                    }
                }

                break;
            }
        }

        if (kbProtoUnitIsType(cMyID, unit_type, cUnitTypeCountsTowardMilitaryScore))
        {
            if (kbGetAge() == cAge2)
            {
                if (gStrategy == cStrategyRush)
                    score = score / 0.75;
                else
                    score = score / 1.25;
            }

            if (kbGetAge() == cAge1)
                score = 0.0;
            
            if (aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, unit_type, true) >= 0)
                score = score * 1.5;
        }

        if (score > highest_score)
    {
        highest_score = score;
        best_card = card;
    }
    }

    if (best_card >= 0)
        aiHCDeckPlayCard(best_card);
}