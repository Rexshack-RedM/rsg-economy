Config = {}

-- Tables are created automatically on start. Set to false to import install.sql manually.
Config.AutoDatabase = true

-- While the NUI is open, block game controls but allow push-to-talk.
Config.AllowPushToTalkWhileOpen = true
Config.PushToTalkControls = {
    0x4BC9DABB, -- INPUT_PUSH_TO_TALK
}

-- Chat command that opens the economy panel ('' to disable)
Config.Command = 'economy'

-- Permission level needed for the admin commands
Config.AdminPermission = 'admin'

-- Seconds between database saves of changed treasuries, rates and prices
Config.SaveInterval = 30

-- Money type used for deposits and withdrawals ('cash' or 'bank')
Config.MoneyType = 'cash'

-- Use rsg-reputation price modifiers (disliked players pay more, respected players less) when it is running
Config.UseReputation = true

------------------------------------------
-- Regions: each has a treasury, its own tax rates and its own officials.
-- Ids match rsg-reputation. label = plain text or locale key.
-- officials: players holding one of these jobs at minGrade or higher may change taxes and spend the treasury.
-- Defaults: the town's law job (Sheriff grade) and the 'government' job (rsg-townhall's manager job).
-- Raise the government minGrade if not every government worker should be an official.
------------------------------------------
Config.RequireOnDuty = false

local function officials(lawJob)
    local list = {}
    if lawJob then list[#list + 1] = { job = lawJob, minGrade = 2 } end
    list[#list + 1] = { job = 'government', minGrade = 0 }
    return list
end

Config.Regions = {
    valentine   = { label = 'Valentine',   order = 1, officials = officials('vallaw') },
    rhodes      = { label = 'Rhodes',      order = 2, officials = officials('rholaw') },
    saint_denis = { label = 'Saint Denis', order = 3, officials = officials('stdenlaw') },
    strawberry  = { label = 'Strawberry',  order = 4, officials = officials('strlaw') },
    blackwater  = { label = 'Blackwater',  order = 5, officials = officials('blklaw') },
    annesburg   = { label = 'Annesburg',   order = 6, officials = officials(nil) },
    van_horn    = { label = 'Van Horn',    order = 7, officials = officials(nil) },
    armadillo   = { label = 'Armadillo',   order = 8, officials = officials(nil) },
    tumbleweed  = { label = 'Tumbleweed',  order = 9, officials = officials(nil) },
}

------------------------------------------
-- Taxes. Rates are fractions (0.05 = 5%). Officials can change a rate within min / max, in steps of Step.
-- label = locale key (cat_*) or plain text.
------------------------------------------
Config.Tax = {
    Step = 0.005,
    -- seconds an official must wait before changing the same rate again in the same region
    ChangeCooldown = 300,
    Categories = {
        sales    = { label = 'cat_sales',    default = 0.05, min = 0.0, max = 0.20, order = 1 }, -- shop purchases (added to the price)
        trade    = { label = 'cat_trade',    default = 0.03, min = 0.0, max = 0.15, order = 2 }, -- goods sold to shops (taken from the payout)
        property = { label = 'cat_property', default = 0.04, min = 0.0, max = 0.15, order = 3 }, -- rent, deeds, land
        license  = { label = 'cat_license',  default = 0.02, min = 0.0, max = 0.10, order = 4 }, -- permits and licences
    },
}

------------------------------------------
-- Treasury
------------------------------------------
Config.Treasury = {
    PublicBalance = true,           -- everyone can see the balance (false = officials only)
    AllowPublicDonations = true,    -- any player can donate to a town
    DonationAction = 'donation',    -- rsg-reputation action applied to a donor (nil to disable)
    MaxAmount = 1000000,            -- largest single deposit or withdrawal
    Withdraw = {
        Enabled = true,             -- officials can take money out through the panel
        DailyLimit = 2000,          -- per region and UTC day, across all officials
    },
    Ledger = {
        KeepDays = 30,              -- older entries are deleted
        PageSize = 20,              -- entries shown in the panel
        LogTax = true,              -- one entry per taxed sale (turn off on busy servers)
    },
}

------------------------------------------
-- Dynamic prices. Every item has a pressure per region from -1 (heavy demand) to +1 (oversupply).
-- Selling to shops raises it (prices fall), buying lowers it (prices rise). It fades back to 0 over time.
-- price multiplier = 1 - pressure * sensitivity, kept between min and max.
------------------------------------------
Config.Market = {
    Enabled = true,
    PressurePerUnit = 0.02,   -- pressure change per unit traded
    HalfLifeHours = 12,       -- hours for the pressure to halve
    Sensitivity = 0.5,        -- default
    MinMultiplier = 0.5,
    MaxMultiplier = 1.5,
    -- per-item overrides: { sensitivity, min, max, perUnit }
    Items = {
        -- ['venison'] = { sensitivity = 0.8, min = 0.4, max = 1.6, perUnit = 0.03 },
    },
}

------------------------------------------
-- Town projects: officials spend treasury money; the effect is up to other scripts, which read HasProject(region, id)
-- or listen to the rsg-economy:server:projectFunded event. days = 0 means permanent.
-- label = plain text or locale key.
------------------------------------------
Config.Projects = {
    { id = 'street_lamps',  label = 'Street lamps',  cost = 2000, days = 14 },
    { id = 'extra_deputies', label = 'Extra deputies', cost = 3000, days = 14 },
    { id = 'road_repairs',  label = 'Road repairs',  cost = 2500, days = 30 },
    { id = 'town_festival', label = 'Town festival', cost = 1500, days = 3 },
}
