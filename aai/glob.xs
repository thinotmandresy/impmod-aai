extern const float     PI = 3.141592;
extern const float     cDegToRad = 0.01745329252;

extern const int       cActionInvalid = -1;
extern const int       cActionIdle = 7;
extern const int       cActionMove = 9;
extern const int       cActionBuild = 0;
extern const int       cActionDecay = 1;
extern const int       cActionWander = 8;
extern const int       cActionAttack = 15;
extern const int       cActionGatherEasy = 3;
extern const int       cActionGatherHunt = 6;
extern const int       cActionGatherNugget = 31;

extern const float     cDifficultySandboxHandicap = .5;
extern const float     cDifficultyEasyHandicap = .75;
extern const float     cDifficultyHandicapModerate = 1.0;
extern const float     cDifficultyHardHandicap = 1.25;
extern const float     cDifficultyExpertHandicap = 1.5;

extern const int       cDefaultDeckID = 0;

extern const float     cMainBaseRadius = 70.0;

extern const int       cNuggetGatheringTimeout = 300000;

extern const float     cNaturalResourceDistance = 100.0;
extern const float     cHuntHerdingMaxDistance = 120.0;
extern const float     cHuntHerdingMinDistance = 30.0;
extern const int       cFleeingHuntableTimeout = 15000;

extern const float     cResourceAvoidBuildings = 60.0;
extern const float     cResourceAvoidLandUnits = 30.0;

// If our base is this close to an ally's base, we'll allow ourselves to invade theirs when we gather resources.
extern const float     cSameBaseThreshold = 60.0;
// If a resource is this close to an ally's base, ignore it (except when we're within the 'SameBase' threshold).
extern const float     cAllyResourceDistance = 30.0;

extern const float     cAutoConvertRange = 16.0;
extern const float     cMinFullHerdableSpace = 6.0;

extern const int       cMaxNumberCrateGatherers = 2;

extern bool            gTimeToFarm = false;
extern bool            gTimeForPlantation = false;
extern bool            gNoMoreTree = false;

extern bool            gStartup = false;
extern bool            gLandExploration = false;
extern bool            gMainBase = false;
extern bool            rGatherResourcesFailsafe = false;

extern int             gShepherd = -1;

extern const string    cFlagTownBell = "TownBell";
extern const string    cFlagTracked = "Tracked";
extern const string    cFlagGathererCount = "GathererCount";
extern const string    cFlagAddedCard = "AddedCard";
extern const string    cFlagLastUnderAttackTime = "LastUnderAttackTime";
extern const string    cFlagLastSpookedTime = "LastSpookedTime";
extern const string    cFlagVPLastOccupiedTime = "VPLastOccupiedTime";

extern const int       cVPUnoccupiedTimeout = 20000;

extern const int       cVillagerRetreatTimeout = 7000;
extern const int       cVillagerSpookedTimeout = 10000;

extern const int       cStrategyBoom = 0;
extern const int       cStrategyRush = 1;
extern int             gStrategy = cStrategyBoom;

extern const int       cMilitaryBiasNone = -1;
extern const int       cMilitaryBiasInf = 0;
extern const int       cMilitaryBiasCav = 1;
extern const int       cMilitaryBiasArt = 2;
extern int             gMilitaryBias = cMilitaryBiasNone;
extern int             gMilitaryLine1 = cUnitTypeAbstractHeavyInfantry;
extern int             gMilitaryLine2 = cUnitTypeAbstractHeavyCavalry;
extern int             gUnitPicker = -1;

extern bool            gMonopolyActive = false;
extern int             gMonopolyTeam = -1;
extern bool            gKOTHActive = false;
extern int             gKOTHTeam = -1;

extern int             gUnitTypeVillager = -1;
extern int             gUnitTypeHouse = -1;
extern int             gUnitTypeMarket = -1;
extern int             gUnitTypeLivestockPen = -1;
extern int             gUnitTypeFarm = -1;
extern int             gUnitTypePlantation = -1;
extern int             gUnitTypeInfantryBuilding = -1;
extern int             gUnitTypeCavalryBuilding = -1;
extern int             gUnitTypeArtilleryBuilding = -1;
extern int             gUnitTypeReligiousBuilding = -1;
extern int             gUnitTypeMercenaryBuilding = -1;
extern int             gUnitTypeTowerBuilding = -1;
extern int             gUnitTypeNavalBuilding = -1;
mutable void           setCivUnitTypes(void) {}
mutable void           sendInformationalNotes(void) {}
