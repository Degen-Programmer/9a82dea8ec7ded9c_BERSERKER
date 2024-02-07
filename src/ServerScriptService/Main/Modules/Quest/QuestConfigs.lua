-- // all quests:

-- Kill 5 Champions
-- Kill 5 Berserkers
-- Use your abilities 10 times;
-- Win 10 games;
-- Fuse 5 times;
-- Spend 1,000 Bucks in the shop;

export type data_quest = {

    Progress: number;
    Reward: number;
    Currency: string;
    Completed: boolean;

} 

return {

    ["Kill_5_Champions"] = {

        Progress = 0,
        Requirement = 5;
        Reward = 110,
        Currency = "Currency",
        Completed = false,
        Claimed = false;
        Signal = "ChampionKillAchieved";

    } :: data_quest,

    ["Kill_5_Berserkers"] = {

        Progress = 0,
        Requirement = 5;
        Reward = 110,
        Currency = "Currency",
        Completed = false,
        Claimed = false;
        Signal = "BerserkerKillAchieved";

    } :: data_quest,

    ["Use_Abilities_10_Times"] = {

        Progress = 0,
        Requirement = 10;
        Reward = 110,
        Currency = "Currency",
        Claimed = false;
        Completed = false,

        Signal = "AbilityUseAchieved";

    } :: data_quest,

    ["Win_10_games"] = {

        Progress = 0,
        Requirement = 10;
        Reward = 11110,
        Currency = "Currency",
        Claimed = false;
        Completed = false,

        Signal = "WinAchieved";

    } :: data_quest,

    ["Fuse_5_times"] = {

        Progress = 0,
        Requirement = 5;
        Reward = 1110,
        Claimed = false;
        Currency = "Currency",
        Completed = false,

        Signal = "FuseAchieved";

    } :: data_quest,

--[[    ["Spend_1000_Bucks"] = {

        Progress = 0,
        Requirement = 1000;
        Reward = 1110,
        Claimed = true;
        Currency = "Currency",
        Completed = false,

        Signal = "BucksSpentAchieved";

    } :: data_quest,
]]
}