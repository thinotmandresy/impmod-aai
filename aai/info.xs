void sendInformationalNotes(void)
{
    string note = "Alternative ImpMod AI v1.10d\n\n";
    switch(aiGetWorldDifficulty())
    {
        case cDifficultySandbox:
        {
            note = note + "Sandbox difficulty: AIs are slowed down by 50%.";
            break;
        }
        case cDifficultyEasy:
        {
            note = note + "Easy difficulty: AIs are slowed down by 25%.";
            break;
        }
        case cDifficultyModerate:
        {
            note = note + "Moderate difficulty: all players are equal.";
            break;
        }
        case cDifficultyHard:
        {
            note = note + "Hard difficulty: AIs are sped up by 25% and are given a small resource tricle.";
            break;
        }
        case cDifficultyExpert:
        {
            note = note + "Expert difficulty: AIs are sped up by 50% and are given a small resource tricle.";
            break;
        }
        default:
        {
            break;
        }
    }

    bool isColombiaPresent = false;
    bool isMaltaPresent = false;
    for(i = 0; < cNumberPlayers)
    {
        if (kbGetCivForPlayer(i) == cCivColombians)
            isColombiaPresent = true;
        if (kbGetCivForPlayer(i) == cCivMaltese)
            isMaltaPresent = true;
    }

    if (isColombiaPresent && isMaltaPresent)
        note = note + "\nPlease note that Colombians and Maltese are still under development and may not work properly.";
    else if (isColombiaPresent)
        note = note + "\nPlease note that Colombians are still under development and may not work properly.";
    else if (isMaltaPresent)
        note = note + "\nPlease note that Maltese are still under development and may not work properly.";

    notifyAsFirstAI(note);
}
