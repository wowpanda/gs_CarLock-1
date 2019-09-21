Config = {}
Config.CarLock = { 
    ControlKey          = 217,       -- CAPSLOCK , voor andere keybinds kijk : https://docs.fivem.net/game-references/controls/
    NotCarOwner         = "Je bezit ~b~niet~w~ over de sleutels van dit voertuig..",
    CarLocked           = "Je voertuig zit ~r~op slot~s~.",
    CarOpen             = "Je voertuig is ~g~open~s~.",
    BlinkingLighstON    = true,     -- Knipperende Koplampen bij Openen en Sluiten voertuig
    CarBleepOnOpen      = true,     -- Bleep bij Openen van voertuig
    CarBleepOnClose     = true,     -- Bleep bij Sluiten van voertuig
    CarBleepDistance    = 5.0,      -- Radius hoe ver het geluid hoorbaar is voor andere spelers
    CarBleepVolume      = 0.5,      -- Volume van het geluid / MAX = 1.0 / MIN = 0.1
    TextBovenVoertuig   = true,     -- Bij true zie je of het voertuig "Open" of "Gesloten" is boven je voertuig
    BegrenzerAAN        = true,     -- Optie om een begrenzer aan of uit te zetten
    BegrenzerKey        = 314,      -- Welke knop voor de begrenzer? standaard: 314= NUMPAD + , voor andere keybinds kijk : https://docs.fivem.net/game-references/controls/
    -- Uitzetten Begrenzer : LEFT SHIT + BegrenzerKey
}

