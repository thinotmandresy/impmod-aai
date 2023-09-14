void eWhenKOTHStarts(int team_id = -1)
{
    if (team_id == -1)
        return;
    
    gKOTHActive = true;
    gKOTHTeam = team_id;
}


void eWhenKOTHEnds(int team_id = -1)
{
    if (team_id == -1)
        return;
    
    gKOTHActive = false;
    gKOTHTeam = -1;
}