include "aai/glob.xs";
include "aai/query.xs";
include "aai/utils.xs";
include "aai/diff.xs";
include "aai/comm.xs";
include "aai/hcity.xs";
include "aai/scout.xs";
include "aai/herd.xs";
include "aai/gather.xs";
include "aai/age.xs";
include "aai/base.xs";
include "aai/build.xs";
include "aai/train.xs";
include "aai/tech.xs";
include "aai/trade.xs";
include "aai/defense.xs";
include "aai/offense.xs";
include "aai/micro.xs";
include "aai/resign.xs";
include "aai/monopoly.xs";
include "aai/koth.xs";

include "aai/info.xs";


void main(void)
{
    // Initialize arrays.
    initArrays();

    // Tell the system to break the map into areas and area groups.
    kbAreaCalculate();

    // Initialize the random number generator.
    aiRandSetSeed(-1);

    // We must set handicaps here, otherwise recorded games will not work and multiplayer might potentially desync.
    applyDifficultySettings();

    // Send the informational notes.
    sendInformationalNotes();

    // Create the unique unit picker that will be used in all routines that require algorithmic unit selection.
    gUnitPicker = kbUnitPickCreate("Unit Picker");

    aiSetHandler("onResignRequestResponse", cXSResignHandler);

    aiCommsSetEventHandler("onCommRequest");
    aiSetHandler("onPlayerAgeUp", cXSPlayerAgeHandler);
    aiSetHandler("onNuggetClaim", cXSNuggetHandler);
}


void setCivUnitTypes(void)
{
    /* ==============================================================
        Villagers
    ============================================================== */
    if (isEuropean())
        gUnitTypeVillager = cUnitTypeSettler;
    else if (isNative())
        gUnitTypeVillager = cUnitTypeSettlerNative;
    else if (cMyCulture == cCultureChinese)
        gUnitTypeVillager = cUnitTypeypSettlerAsian;
    else if (cMyCulture == cCultureIndian)
        gUnitTypeVillager = cUnitTypeypSettlerIndian;
    else if (cMyCulture == cCultureJapanese)
        gUnitTypeVillager = cUnitTypeypSettlerJapanese;
    if (cMyCiv == cCivFrench)
        gUnitTypeVillager = cUnitTypeCoureur;
    else if (cMyCiv == cCivDutch)
        gUnitTypeVillager = cUnitTypeSettlerDutch;
    else if (cMyCiv == cCivOttomans)
        gUnitTypeVillager = cUnitTypeSettlerOttoman;
    else if (cMyCiv == cCivUSA)
        gUnitTypeVillager = cUnitTypeSettlerAmerican;
    else if (cMyCiv == cCivColombians)
        gUnitTypeVillager = cUnitTypeSettlerAmerican;
    

    /* ==============================================================
        Houses
    ============================================================== */

    if (cMyCulture == cCultureEasternEurope)
        gUnitTypeHouse = cUnitTypeHouseEast;
    else if (cMyCulture == cCultureMediterranean)
        gUnitTypeHouse = cUnitTypeHouseMed;
    else if (cMyCulture == cCultureWesternEurope)
        gUnitTypeHouse = cUnitTypeHouse;
    else if (cMyCulture == cCultureChinese)
        gUnitTypeHouse = cUnitTypeypVillage;
    else if (cMyCulture == cCultureIndian)
        gUnitTypeHouse = cUnitTypeypHouseIndian;
    else if (cMyCulture == cCultureJapanese)
        gUnitTypeHouse = cUnitTypeypShrineJapanese;
    else if (cMyCulture == cCultureAztec)
        gUnitTypeHouse = cUnitTypeHouseAztec;
    else if (cMyCulture == cCultureIroquois)
        gUnitTypeHouse = cUnitTypeLonghouse;
    if (cMyCiv == cCivBritish)
        gUnitTypeHouse = cUnitTypeManor;
    else if (cMyCiv == cCivItalians)
        gUnitTypeHouse = cUnitTypeHouseVilla;
    else if (cMyCiv == cCivSwedish)
        gUnitTypeHouse = cUnitTypeHouseTorp;
    else if (cMyCiv == cCivMaltese)
        gUnitTypeHouse = cUnitTypeEncampment;
    

    /* ==============================================================
        Markets
    ============================================================== */

    if (isAsian())
        gUnitTypeMarket = cUnitTypeypTradeMarketAsian;
    else if (isEuropean() || isNative())
        gUnitTypeMarket = cUnitTypeMarket;
    

    /* ==============================================================
        Livestock Pens
    ============================================================== */

    if (isAsian() || isEuropean())
        gUnitTypeLivestockPen = gUnitTypeHouse;
    if (cMyCulture == cCultureAztec)
        gUnitTypeLivestockPen = cUnitTypeFarm;
    else if (cMyCulture == cCultureIndian)
        gUnitTypeLivestockPen = cUnitTypeypSacredField;
    

    /* ==============================================================
        Farms
    ============================================================== */

    if (isAsian())
        gUnitTypeFarm = cUnitTypeypRicePaddy;
    else if (isEuropean())
        gUnitTypeFarm = cUnitTypeMill;
    else if (isNative())
        gUnitTypeFarm = cUnitTypeFarm;
    

    /* ==============================================================
        Plantations
    ============================================================== */

    if (isAsian())
        gUnitTypePlantation = cUnitTypeypRicePaddy;
    else if (isEuropean() || isNative())
        gUnitTypePlantation = cUnitTypePlantation;
    

    /* ==============================================================
        Infantry Buildings
    ============================================================== */

    if (isEuropean())
        gUnitTypeInfantryBuilding = cUnitTypeBarracks;
    else if (isNative())
        gUnitTypeInfantryBuilding = cUnitTypeWarHut;
    else if (cMyCulture == cCultureChinese)
        gUnitTypeInfantryBuilding = cUnitTypeypWarAcademy;
    else if (cMyCulture == cCultureIndian)
        gUnitTypeInfantryBuilding = cUnitTypeYPBarracksIndian;
    else if (cMyCulture == cCultureJapanese)
        gUnitTypeInfantryBuilding = cUnitTypeypBarracksJapanese;
    if (cMyCiv == cCivRussians)
        gUnitTypeInfantryBuilding = cUnitTypeBlockhouse;
    

    /* ==============================================================
        Cavalry Buildings
    ============================================================== */

    if (isEuropean())
        gUnitTypeCavalryBuilding = cUnitTypeStable;
    else if (isNative())
        gUnitTypeCavalryBuilding = cUnitTypeCorral;
    else if (cMyCulture == cCultureChinese)
        gUnitTypeCavalryBuilding = cUnitTypeypWarAcademy;
    else if (cMyCulture == cCultureIndian)
        gUnitTypeCavalryBuilding = cUnitTypeypCaravanserai;
    else if (cMyCulture == cCultureJapanese)
        gUnitTypeCavalryBuilding = cUnitTypeypStableJapanese;
    if (cMyCulture == cCultureAztec)
        gUnitTypeCavalryBuilding = cUnitTypeNoblesHut;
    

    /* ==============================================================
        Artillery Buildings
    ============================================================== */

    if (isAsian())
        gUnitTypeArtilleryBuilding = cUnitTypeypCastle;
    else if (isEuropean() || isNative())
        gUnitTypeArtilleryBuilding = cUnitTypeArtilleryDepot;
    if (cMyCulture == cCultureAztec)
        gUnitTypeArtilleryBuilding = cUnitTypeNoblesHut;
    

    /* ==============================================================
        Religious Buildings
    ============================================================== */

    if (isEuropean())
        gUnitTypeReligiousBuilding = cUnitTypeChurch;
    if (cMyCiv == cCivItalians)
        gUnitTypeReligiousBuilding = cUnitTypeBasilicaIt;
    else if (cMyCiv == cCivOttomans)
        gUnitTypeReligiousBuilding = cUnitTypeMosque;
    

    /* ==============================================================
        Mercenary Buildings
    ============================================================== */

    if (isAsian())
        gUnitTypeMercenaryBuilding = cUnitTypeypMonastery;
    else if (isEuropean())
        gUnitTypeMercenaryBuilding = cUnitTypeSaloon;
    else if (isNative())
        gUnitTypeMercenaryBuilding = cUnitTypeNativeEmbassy;


    /* ==============================================================
        Tower Buildings
    ============================================================== */

    if (isAsian())
        gUnitTypeTowerBuilding = cUnitTypeYPOutpostAsian;
    else if (isNative())
        gUnitTypeTowerBuilding = cUnitTypeWarHut;
    else if (isEuropean())
        gUnitTypeTowerBuilding = cUnitTypeOutpost;
    if (cMyCiv == cCivRussians)
        gUnitTypeTowerBuilding = cUnitTypeBlockhouse;
    

    /* ==============================================================
        Naval Buildings
    ============================================================== */
    
    if (isAsian())
        gUnitTypeNavalBuilding = cUnitTypeYPDockAsian;
    else if (isEuropean() || isNative())
        gUnitTypeNavalBuilding = cUnitTypeDock;
}

/*
    TODO: armies
        xsArraySetInt(armies, 0, cUnitTypeSwedishArmy11);
        xsArraySetInt(armies, 1, cUnitTypeSwedishArmy22);
        xsArraySetInt(armies, 2, cUnitTypeSwedishArmy33);
        xsArraySetInt(armies, 3, cUnitTypeCapSwedishArmy11);
        xsArraySetInt(armies, 4, cUnitTypeCapSwedishArmy22);
        xsArraySetInt(armies, 5, cUnitTypeCapSwedishArmy33);
        xsArraySetInt(armies, 6, cUnitTypeSwedishArmy1);
        xsArraySetInt(armies, 7, cUnitTypeSwedishArmy2);
        xsArraySetInt(armies, 8, cUnitTypeSwedishArmy3);
        xsArraySetInt(armies, 9, cUnitTypeMercArmyS);
        xsArraySetInt(armies, 10, cUnitTypeMercArmyP);
        xsArraySetInt(armies, 11, cUnitTypeMercArmyO);
        xsArraySetInt(armies, 12, cUnitTypeMercArmyB);
        xsArraySetInt(armies, 13, cUnitTypeMercArmyD);
        xsArraySetInt(armies, 14, cUnitTypeMercArmyF);
        xsArraySetInt(armies, 15, cUnitTypeMercArmyR);
        xsArraySetInt(armies, 16, cUnitTypeMercArmyG);
*/
