Config = {}

-- Debugmodes
Config.Debugmode = false -- General debugging, shows what seats/beds you can sit/lay on and the direction you will be facing, also enables debugging commands. (Only shows seats nearby)
Config.DebugPoly = false -- This is not advised unless you have set your PolyZone script set to only render polys nearby, the prefeered way is to go into list.lua and set the debug on the polyzone group instead! (see gabz_atom)

-- For those who use the TMC framework
Config.UseTMCFramework = false

-- Teleport to the last position before getting seated when we found no way to get to the seat
Config.TeleportToLastPosWhenNoRoute = false

-- Always teleport in/out of the seat
Config.AlwaysTeleportToSeat = false
Config.AlwaysTeleportOutOfSeat = false

-- Tthe interaction and prompts distance, used for max distance the 3rd eye can see, how far the /sit command will look for entites and how close you have to be for a prompt to be showed if you use those.
Config.MaxInteractionDist = 2.0
Config.MaxPromptDist = 1.8

-- The maximum amount of tilt a object can have before it is rendered unsuitable to sit on
Config.MaxTilt = 20.0

-- These will be the default keys/buttons
Config.DefaultKeybinds = {
    GetUp = {
        Keyboard = 'X',
        PadAnalog = 'RRIGHT_INDEX'
    },

    -- Only used in the prompts system
    SitDown = {
        SitKeyboard = 'E',
        LayKeyboard = 'G',
        SitPadAnalog = 'LLEFT_INDEX',
        LayPadAnalog = 'LRIGHT_INDEX'
    }
}

-- Whether or not to add chat suggestion.
Config.AddChatSuggestions = true

-- Whether or not to use the prompt system. NOTE: this uses extra resources.
Config.UsePrompts = true

-- If true, instructions on how to get up form the seat/bed will be displayed in the top left corner of your screen
Config.ShowHelpText = false

-- The script will ATTEMPT (no guarantee) to prevent showing help text when other scripts are allready showing help texts, this will stop some of the annoying pling sounds.
Config.PreventHelpTextOverwrites = true

-- Whether or not trigger an reduce stress event/export when sitting/laying down. You wil have to add a event/export yourself for this to work.
Config.ReduceStress = false

-- Invalidates the idle cam while you are seated/laying down.
Config.InvalidateIdleCam = true

-- Force first person view while sitting/laying down.
Config.FirstPerson = true

-- The targeting solution (3rd eye) to use.
-- false       = don't use any targeting solution. ('false' will NOT work, false NEEDS to be a boolean.)
-- 'qb-target' = qb-target by BerkieBb and its many other contributors. (https://github.com/BerkieBb/qb-target)
-- 'qtarget'   = qTarget by Linden (thelindat), Noms (OfficialNoms) and its many other contributors. (https://github.com/overextended/qtarget)
-- 'ox_target' = ox_target by Linden (thelindat) and its many other contributors. (https://github.com/overextended/ox_target)
Config.Target = 'ox_target'

-- Use the coords of where the 3rd eye intersects with the object to find the closest seat. If set to false the coords of the player ped will be used instead.
Config.UseTargetingCoords = true

-- These are the icons/labels if we use a targeting solution.
Config.Targeting = {
    SitIcon = "fas fa-chair",
    LayIcon = "fas fa-bed",
    SitLabel = "Sit Down",
    LayLabel = "Lay Down",
}

-- The localization for the notifications, chat suggestions and keymapping.
Config.Lang = {
    -- Notifications
    Notification = {
        OccupiedSit = "This seat is already occupied!",
        OccupiedLay = "You can't lay down here!",
        NoAvailable = "No seat is avalible!",
        NoFound = "No seats were found!",
        NoBedFound = "Nothing to lay down on was found!",
        TooTilted = "This seat is too tilted!",
        CannotReachSeat = "You can't reach this seat!",
        CannotSitInSeat = "You can't sit in this seat!",
        CannotReachBed = "You can't reach this bed/bench!",
        AlreadyAttemptingToSit = "You are already attempting to sit down!",
        AlreadyAttemptingToLay = "You are already attempting to lay down!"
    },

    -- Chat Suggestions
    ChatSuggestions = {
        Sit = "Sit down on the closest seat",
        Lay = "Lay down on the closest bed/bench"
    },

    -- Key Mapping
    KeyMapping = {
        -- %s is automatically replaced with the key they need to press.
        SitDown = "Press %s to sit down",
        LayDown = "Press %s to lay down",
        GetUp = "Press %s to get up"
    },

    -- Description in Settings>Key Bindings>Fivem
    KeyBindingDesc = {
        Keyboard = {
            SitDown = "Sit - Sit Down (Seat)",
            LayDown = "Sit - Lay Down (Bed/Bench)",
            GetUp = "Sit - Get Up"
        },
        PadAnalog = {
            SitDown = "Sit - Sit Down (Seat) - Controller",
            LayDown = "Sit - Lay Down (Bed/Bench) - Controller",
            GetUp = "Sit - Get Up - Controller"
        }
    }
}

-- The diffrent sitting settings, don't touch unless you know what you are doing.
Config.SitTypes = {
    ['default'] = { -- Default settings, if non has been spesified
        skipGoStraightTask = false,
        teleportIn = false,
        teleportOut = false,
        timeout = 8,
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vector4(0.0, 0.0, 0.0, 0.0) }
        }
        -- animation = { dict = "timetable@jimmy@mics3_ig_15@", name = "idle_a_jimmy", offset = vector4(0.0, 0.0, 0.0, 0.0), flag = 1 }
    },
    ['chair'] = {
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" }
        }
    },
    ['chair2'] = {
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" },
            [2] = { name = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vector4(0.0, 0.05, 0.0, 0.0) }
        }
    },
    ['chair3'] = {
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" },
            [2] = { name = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vector4(0.0, 0.05, 0.0, 0.0) },
            [3] = { name = "PROP_HUMAN_SEAT_DECKCHAIR" }
        }
    },
    ['barstool'] = {
        teleportIn = true,
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_BAR" }
        }
    },
    ['stool'] = {
        teleportIn = true,
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" }
        },
    },
    ['deck'] = {
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_DECKCHAIR" }
        }
    },
    ['sunlounger'] = {
        skipGoStraightTask = true,
        timeout = 12,
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_SUNLOUNGER" }
        }
    },
    ['tattoo'] = {
        animation = { dict = "misstattoo_parlour@shop_ig_4", name = "customer_loop",
            offset = vector4(0.0, 0.0, -0.75, 0.0) }
    },
    ['strip_watch'] = {
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_STRIP_WATCH" }
        }
    },
    ['diner_booth'] = {
        teleportIn = true,
        teleportOut = true,
        scenarios = {
            [1] = { name = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" }
        }
    },
    ['laysit'] = {
        animation = { dict = "timetable@jimmy@mics3_ig_15@", name = "idle_a_jimmy", offset = vector4(0.0, 0.0, 0.0, 0.0) }
    },
    ['wall'] = {
        scenarios = {
            [1] = { name = "WORLD_HUMAN_SEAT_WALL" }
        }
    },
    ['steps'] = {
        scenarios = {
            [1] = { name = "WORLD_HUMAN_SEAT_STEPS" }
        }
    },
    ['ledge'] = {
        scenarios = {
            [1] = { name = "WORLD_HUMAN_SEAT_LEDGE" }
        }
    },
    ['director'] = {
        animation = { dict = "misscarsteal4@director_grip", name = "beginning_loop_director",
            offset = vector4(0.0, 0.0, -1.16, 0.0) },
        teleportOut = true
    },
}

-- The diffrent laying settings, don't touch unless you know what you are doing.
Config.LayTypes = {
    ['default'] = { -- Default settings, if non has been spesified
        animation = { dict = "misslamar1dead_body", name = "dead_idle" },
        exitAnimType = 0, -- 0 = relative to camera | 1 = to the right | 2 = to the left
        exitAnim = true
    },
    ['bed'] = {
        animation = { dict = "misslamar1dead_body", name = "dead_idle" }
    },
    ['lay'] = {
        animation = { dict = "savecouch@", name = "t_sleep_loop_couch", offset = vector4(-0.1, 0.1, -0.5, 270.0) }
    },
    ['layside'] = {
        animation = { dict = "savecouch@", name = "t_sleep_loop_couch", offset = vector4(-0.1, 0.1, -0.5, 270.0) },
        exitAnimType = 2
    },
    ['layside_reverse'] = {
        animation = { dict = "savecouch@", name = "t_sleep_loop_couch", offset = vector4(0.1, 0.1, -0.5, 90.0) },
        exitAnimType = 1
    },
    ['busstop'] = {
        animation = { dict = "savecouch@", name = "t_sleep_loop_couch", offset = vector4(0.0, 0.0, -0.5, 270.0) }
    },
    ['medical'] = {
        animation = { dict = "anim@gangops@morgue@table@", name = "body_search" }
    },
    ['tattoo'] = {
        animation = { dict = "amb@world_human_sunbathe@male@front@base", name = "base",
            offset = vector4(0.0, 0.0, 0.0, 180.0) },
        exitAnim = false
    }
}

-- Which preset (poly) locations that should be loaded. (disable/enable those you use!)
Config.PresetLocations = {
    -- Vanilla Interiors
    coroner = true,
    lscustoms = false,
    mrpd = false,
    pacific_standard = false,
    paleto_bank = false,
    paleto_so = false,
    pdm = false,
    sandy_so = false,
    tattoo_shops = true,
    tequilala = true,
    trevors_trailer = true,
    vanilla_unicorn = false,

    -- Other Interiors
    uniqx_burgershot = false,

    -- Gabz Team Interiors
    gabz_altruists = false,
    gabz_atom = false,
    gabz_aztecas = false,
    gabz_bahama = false, -- Bahama Mamas
    gabz_ballas = false,
    gabz_bennys = false,
    gabz_burgershot = false,
    gabz_catcafe = false,
    gabz_bobcat = false,
    gabz_diner = false, -- Pop's Dinner
    gabz_families = false,
    gabz_firedept = false, -- El Burro & Davis
    gabz_harmony = false,
    gabz_haters = false,
    gabz_hayes = false,
    gabz_hornys = false,
    gabz_import = false,
    gabz_koi = false,
    gabz_lamesa_pd = false,
    gabz_lostsc = false,
    gabz_lscustoms = false, -- This is NOT mutually exclusive with the regular lscustoms, just an add-on if you have gabz-lscustoms
    gabz_marabunta = false,
    gabz_mba = false, -- Maze Bank Arena
    gabz_mrpd = false, -- Mission Row Police Deparment
    gabz_paletocamp = false,
    gabz_ottos = false,
    gabz_pacific_standard = false, -- This is the new pacific standard from the gabz team.
    gabz_pacific_standard_old = false, -- This is the old gabz pacific standard, it's a retexure of (+ some changes to) the base game version.
    gabz_paleto_bank = false,
    gabz_paleto_so = false,
    gabz_park_ranger = false,
    gabz_pdm = false,
    gabz_pillbox = false,
    gabz_pizzeria = false,
    gabz_prison = false,
    gabz_records = false, -- Records A Studios
    gabz_sandy_so = false,
    gabz_townhall = false,
    gabz_triads = false,
    gabz_tuners = false,
    gabz_vagos = false,
    gabz_vanilla_unicorn = false,
    gabz_weedcamp = false,

    -- These are just proofs of concept.
    ledge = true,
    steps = true,
    wall = true,
}
