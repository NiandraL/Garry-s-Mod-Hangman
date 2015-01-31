//Don't touch this!
NiandraMinigames = NiandraMinigames or {}

//Client Con Vars
CreateClientConVar( "Hangman_Enable_WinLose_Sounds", "1", true, false )
CreateClientConVar( "Hangman_Enable_GunShot_Sounds", "1", true, false )

//Enables
NiandraMinigames.UsePointshop = true -- Should this addon encorporate Pointshop-based features/
NiandraMinigames.FastDL = false -- Do you plan to add materials to your FastDL instead of Steam Workshop downloads? (Please do)

//General
NiandraMinigames.ChatCommand = "/hangman"
NiandraMinigames.HangmanAttempts = 7 -- How many bad letters can players enter before they lose? 
NiandraMinigames.HangmanHintsAllowed = 3 -- How many hints is the user allowed?

NiandraMinigames.HangmanBackground = Color(34, 49, 63,255) -- What colour should the Hangman Menu Frame be?
NiandraMinigames.HangmanTriedLettersBackground = Color(75, 119, 190,255) -- What colour should the Hangman In-Game panel be?
NiandraMinigames.HangmanWordBackground2 = Color(244, 179, 80,255) -- What colour should the Hangman In-Game panel be?
NiandraMinigames.HangmanWordBackground = Color(243, 156, 18,255) -- What colour should the Hangman In-Game panel be?
NiandraMinigames.HangmanWordColour = Color(255, 255, 255,255) -- What colour should the guessing word/_ _ _ be?

//Alphabet Buttons
NiandraMinigames.HangmanWordAlphabetEven = Color(187,54,88, 255) -- On the alphabet buttons, what colour should even ones be?
NiandraMinigames.HangmanWordAlphabetOdd = Color(126,54,97, 255) -- On the alphabet buttons, what colour should odd ones be?

//Lower buttons panel
NiandraMinigames.HangmanHintButtonColour = Color(38, 166, 91,255) -- What colour should the Hints button be?
NiandraMinigames.HangmanGiveUpButtonColour = Color(192, 57, 43,255) -- What colour should the Give Up button be?
NiandraMinigames.HangmanSettingsButtonColour = Color(58, 83, 155,255) -- What colour should the Settings Button be?

//Winning and prizes
NiandraMinigames.HangmanWinPoints = 20 -- How many points should the user get when winning a word that's 5 NiandraMinigames.Characters or less? 
NiandraMinigames.HangmanHintCost = 5 -- If the word is over 5 NiandraMinigames.Characters, how many extra points should they get per letter?
NiandraMinigames.HangmanLosePoints = 5 -- How many points should the user lose if they fuck up?
NiandraMinigames.HangmanWinMessage = "You guessed the word correctly!"
NiandraMinigames.HangmanLoseMessage = "You've ran out of tries!"

//Misc
--Psst, don't touch this!
NiandraMinigames.Alphabet = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }

if SERVER then
	if NiandraMinigames.FastDL then
		resource.AddFile("materials/niandralades/minigames/hangman_deco.png")
		resource.AddFile("materials/niandralades/minigames/hangman_gun_left.png")
		resource.AddFile("materials/niandralades/minigames/hangman_gun_right.png")
		resource.AddFile("materials/niandralades/minigames/hangman_lose.png")
		resource.AddFile("materials/niandralades/minigames/hangman_win.png")
		resource.AddFile("materials/niandralades/minigames/hangman_sun_icon.png")
		resource.AddFile("materials/niandralades/minigames/hangman_skull.png")
	end
end