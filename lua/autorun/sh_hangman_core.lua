if SERVER then

	 util.AddNetworkString( "Hangman_HintReduction" )
	 util.AddNetworkString( "Hangman_Win" )
	 util.AddNetworkString( "Hangman_GiveUp" )
	 util.AddNetworkString( "Hangman_StartGame" )

	net.Receive("Hangman_HintReduction", function(len, ply)
		ply:PS_TakePoints(5)
	end)
	
	net.Receive("Hangman_Win", function(len, ply)
		if NiandraMinigames.UsePointshop then
			ply:PS_GivePoints(5)
		end
		for k, v in pairs(player.GetAll()) do
			v:ChatPrint(""..ply:Nick().." just won "..NiandraMinigames.HangmanWinPoints.." points from Hangman! Type "..NiandraMinigames.ChatCommand.." to do the same.")
		end
	end)
	
	net.Receive("Hangman_GiveUp", function(len, ply)
		ply:PS_TakePoints(5)
	end)
	
	hook.Add("PlayerSay", "Hangman_Chat", function(ply, text, uselessvariable)
		if (text == NiandraMinigames.ChatCommand) then
			net.Start("Hangman_StartGame")
			net.Send(ply)
		end
	end)
	
end

if CLIENT then
function NiandraMinigames:StartHangman()
		
	//When the client starts Hangman, a random word is picked from one big table.
	NiandraMinigames.HangmanWord = table.Random(NiandraMinigames.TableOfWords)
	
	//Important client stuff!
	NiandraMinigames.Characters = string.ToTable(NiandraMinigames.HangmanWord)
	NiandraMinigames.DisplayedWord = {}
	NiandraMinigames.TriedLetters = {}
	NiandraMinigames.Fuckups = 0
	NiandraMinigames.HintsGiven = 0
	
	//We loop through the chosen word; if a letter is inside the table of tried letters, we display it. Otherwise we want to display it as _ instead.
	for char=1, string.len(NiandraMinigames.HangmanWord) do
		if table.HasValue(NiandraMinigames.TriedLetters, NiandraMinigames.Characters[char]) then
			NiandraMinigames.DisplayedWord[char] = NiandraMinigames.Characters[char]
		else
			NiandraMinigames.DisplayedWord[char] = "_ "
		end
	end	
	
	//Once above has finished, we use table.concat to essentially connect it into a string.
	NiandraMinigames.WordToDisplay = table.concat(NiandraMinigames.DisplayedWord)
end

function NiandraMinigames:UpdateHangman()
	//When a user presses a button, we insert that letter into a table.
	table.insert(NiandraMinigames.TriedLetters, NiandraMinigames.LetterToInsert)
	
	//If that letter isn't found in the string, i.e the handman word, then they've messed up, which we want to keep count of.
	if not string.find(NiandraMinigames.HangmanWord, NiandraMinigames.LetterToInsert) then
		NiandraMinigames.Fuckups = NiandraMinigames.Fuckups + 1
		local hangman_triesleft = (NiandraMinigames.HangmanAttempts - NiandraMinigames.Fuckups)
		chat.AddText( Color(100,100,255), "[HANGMAN]", Color(255, 255, 255), " "..NiandraMinigames.LetterToInsert.." is not in the word! You have "..hangman_triesleft.." tries left.")
		if GetConVar("Hangman_Enable_GunShot_Sounds"):GetBool() then
			surface.PlaySound("weapons/fx/rics/ric2.wav")
		end	
	else
		if GetConVar("Hangman_Enable_GunShot_Sounds"):GetBool() then
			surface.PlaySound("weapons/357_fire2.wav")
		end	
	end
	
	//Just like when we start the hangman, we loop once again.
	for char=1, string.len(NiandraMinigames.HangmanWord) do
		if table.HasValue(NiandraMinigames.TriedLetters, NiandraMinigames.Characters[char]) then
			NiandraMinigames.DisplayedWord[char] = ""..NiandraMinigames.Characters[char].." "
		else
			NiandraMinigames.DisplayedWord[char] = "_ "
		end
	end	

	//...and update the word so derma displays it correctly.
	NiandraMinigames.WordToDisplay = table.concat(NiandraMinigames.DisplayedWord)
	
	//If we don't add a space onto the end of the hangman word, it looks super messy within the menu, however it means we have to remove it again!
	local remove_space_from_word = string.Replace(NiandraMinigames.WordToDisplay, " ", "")
	if remove_space_from_word == NiandraMinigames.HangmanWord then
		NiandraMinigames:CloseMainHangmanMenu()
		LocalPlayer():SetNWBool("HangmanStatus", true)
		NiandraMinigames:HangmanResult()
		net.Start("Hangman_Win")		
		net.SendToServer()
		
	end
	
	//If the user enters too many wrong letters, then they lose!
	if NiandraMinigames.Fuckups == NiandraMinigames.HangmanAttempts then
		NiandraMinigames:CloseMainHangmanMenu()
		LocalPlayer():SetNWBool("HangmanStatus", false)
		NiandraMinigames:HangmanResult()
	end
	
end

net.Receive("Hangman_StartGame", function(len)

	//Main Hangman Frame
	function NiandraMinigames:HangmanMenu()
	NiandraMinigames:StartHangman()
	local frame = vgui.Create("DFrame")
	frame:SetSize(650, 700)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(true)
	frame:SetBackgroundBlur(true)
	frame:MakePopup()
	frame:ShowCloseButton(false)
	frame.Paint = function()
			draw.RoundedBox(0, 0, 0, 650, 700, NiandraMinigames.HangmanBackground)	
	end
	
	//Function to close the main menu
	function NiandraMinigames:CloseMainHangmanMenu()
		frame:Remove()
	end

	local Hangman_Word_Background_Panel = vgui.Create("DPanel", frame)
	Hangman_Word_Background_Panel:SetSize(550, 310-50)
	Hangman_Word_Background_Panel:SetPos(50, 50)
	Hangman_Word_Background_Panel.Paint = function()
			draw.RoundedBox(0, 0, 0, 550, 250, NiandraMinigames.HangmanWordBackground)	
	end
	
	local Hangman_Word_Background_Panel_2 = vgui.Create("DPanel", Hangman_Word_Background_Panel)
	Hangman_Word_Background_Panel_2:SetSize(550, 150)
	Hangman_Word_Background_Panel_2:SetPos(0, 0)
	Hangman_Word_Background_Panel_2.Paint = function()
			draw.RoundedBox(0, 0, 0, 550, 250, NiandraMinigames.HangmanWordBackground2)	
	end
	
	local Hangman_Buttons_Background_Panel = vgui.Create("DPanel", frame)
	Hangman_Buttons_Background_Panel:SetSize(550, 150)
	Hangman_Buttons_Background_Panel:SetPos(50, 380+40)
	Hangman_Buttons_Background_Panel.Paint = function()
			draw.RoundedBox(0, 0, 0, 550, 250, NiandraMinigames.HangmanTriedLettersBackground)	
	end
	
	local Hangman_Left_Bracket = vgui.Create("DLabel", Hangman_Word_Background_Panel)
	Hangman_Left_Bracket:SetText("[")
	Hangman_Left_Bracket:SetPos(20, 150)
	Hangman_Left_Bracket:SetFont("Coolvetica90")
	Hangman_Left_Bracket:SizeToContents()
	Hangman_Left_Bracket:SetColor(Color(255,255, 255, 255))
	
	local Hangman_Right_Bracket = vgui.Create("DLabel", Hangman_Word_Background_Panel)
	Hangman_Right_Bracket:SetText("]")
	Hangman_Right_Bracket:SetPos(510, 150)
	Hangman_Right_Bracket:SetFont("Coolvetica90")
	Hangman_Right_Bracket:SizeToContents()
	Hangman_Right_Bracket:SetColor(Color(255,255, 255, 255))
	
	local Hangman_Sun = vgui.Create("DImage", Hangman_Word_Background_Panel_2)
	Hangman_Sun:SetImage("materials/niandralades/minigames/hangman_sun_icon.png")
	Hangman_Sun:SetSize(64, 64)
	Hangman_Sun:SetPos(450, 20)
	
	local Hangman_Gun_Left = vgui.Create("DImage", frame)
	Hangman_Gun_Left:SetImage("materials/niandralades/minigames/hangman_gun_left.png")
	Hangman_Gun_Left:SetSize(128, 128)
	Hangman_Gun_Left:SetPos(650/2-70, 300+20)
	
	local Hangman_Gun_Right = vgui.Create("DImage", frame)
	Hangman_Gun_Right:SetImage("materials/niandralades/minigames/hangman_gun_right.png")
	Hangman_Gun_Right:SetSize(128, 128)
	Hangman_Gun_Right:SetPos(650/2+9, 300+20)
	
	local Hangman_Skull = vgui.Create("DImage", frame)
	Hangman_Skull:SetImage("materials/niandralades/minigames/hangman_skull.png")
	Hangman_Skull:SetSize(64, 64)
	Hangman_Skull:SetPos(650/2-32, 310+20)
	
	local Hangman_Decor_1 = vgui.Create("DImage", frame)
	Hangman_Decor_1:SetImage("materials/niandralades/minigames/hangman_deco.png")
	Hangman_Decor_1:SetSize(128, 128)
	Hangman_Decor_1:SetPos(650/2+64, 330+20)
	
	local Hangman_Decor_2 = vgui.Create("DImage", frame)
	Hangman_Decor_2:SetImage("materials/niandralades/minigames/hangman_deco.png")
	Hangman_Decor_2:SetSize(128, 128)
	Hangman_Decor_2:SetPos(650/2-128-64, 330+20)
	
	local Hangman_StringLength = string.len(NiandraMinigames.WordToDisplay)
	local Hangman_DisplayStrng = vgui.Create("DLabel", Hangman_Word_Background_Panel)
	Hangman_DisplayStrng:SetText(NiandraMinigames.WordToDisplay)
	Hangman_DisplayStrng:SetPos(550/2-Hangman_StringLength*11, 160)
	Hangman_DisplayStrng:SetFont("Hangman1")
	Hangman_DisplayStrng:SizeToContents()
	Hangman_DisplayStrng:SetColor(NiandraMinigames.HangmanWordColour)
	
	local Hangman_TriedLetters_Label = vgui.Create("DLabel", Hangman_Buttons_Background_Panel)
	Hangman_TriedLetters_Label:SetText("Tried letters:")
	Hangman_TriedLetters_Label:SetFont("Coolvetica30")
	Hangman_TriedLetters_Label:SetColor(Color(255, 255, 255, 255))
	Hangman_TriedLetters_Label:SizeToContents()
	Hangman_TriedLetters_Label:SetPos(210, 110)
	
	local Hangman_Hidden_Options_Buttons = vgui.Create("DPanel", frame)
	Hangman_Hidden_Options_Buttons:SetSize(550, 50)
	Hangman_Hidden_Options_Buttons:SetPos(50, 530+40+40)
	Hangman_Hidden_Options_Buttons.Paint = function()
			draw.RoundedBox(0, 0, 0, 550, 50, Color(255, 255, 255, 255))	
	end	
	
	local Hangman_Hidden_Options_Hint = vgui.Create("DButton", Hangman_Hidden_Options_Buttons)
	Hangman_Hidden_Options_Hint:SetPos(0, 0)
	Hangman_Hidden_Options_Hint:SetSize(184, 50)
	Hangman_Hidden_Options_Hint:SetText("Hint")
	Hangman_Hidden_Options_Hint:SetFont("Coolvetica30")
	Hangman_Hidden_Options_Hint:SetColor(Color(255, 255, 255, 255))
	Hangman_Hidden_Options_Hint.Paint = function()
		draw.RoundedBox(0, 0, 0, 300, 50, NiandraMinigames.HangmanHintButtonColour)
	end
	Hangman_Hidden_Options_Hint.DoClick = function()
		if NiandraMinigames.HintsGiven < NiandraMinigames.HangmanHintsAllowed then
		local Hangman_Hints_Table = string.ToTable(NiandraMinigames.HangmanWord)
			NiandraMinigames.LetterToInsert = table.Random(Hangman_Hints_Table)
			NiandraMinigames:UpdateTriedLetters()
			NiandraMinigames:UpdateHangman()
			Hangman_DisplayStrng:SetText(NiandraMinigames.WordToDisplay)
			if NiandraMinigames.UsePointshop then
				net.Start("Hangman_HintReduction")		
				net.SendToServer()
			end
			chat.AddText( Color(100,100,255), "[HANGMAN]", Color(255, 255, 255), " You were given "..NiandraMinigames.LetterToInsert.."! "..NiandraMinigames.HangmanHintCost.." points taken away.")
			NiandraMinigames.HintsGiven = NiandraMinigames.HintsGiven + 1
		else
			chat.AddText( Color(100,100,255), "[HANGMAN]", Color(255, 255, 255), " Sorry! You've been given the max amount of hints.")	
			surface.PlaySound("buttons/weapon_cant_buy.wav")
		end
	end
	
	local Hangman_Hidden_Options_GiveUp = vgui.Create("DButton", Hangman_Hidden_Options_Buttons)
	Hangman_Hidden_Options_GiveUp:SetPos(0+184, 0)
	Hangman_Hidden_Options_GiveUp:SetSize(183, 50)
	Hangman_Hidden_Options_GiveUp:SetText("Give up")
	Hangman_Hidden_Options_GiveUp:SetFont("Coolvetica30")
	Hangman_Hidden_Options_GiveUp:SetColor(Color(255, 255, 255, 255))
	Hangman_Hidden_Options_GiveUp.Paint = function()
		draw.RoundedBox(0, 0, 0, 300, 50, NiandraMinigames.HangmanGiveUpButtonColour)
	end
	Hangman_Hidden_Options_GiveUp.DoClick = function()
		LocalPlayer():SetNWBool("HangmanStatus", false) 
		NiandraMinigames:CloseMainHangmanMenu()
		NiandraMinigames:HangmanResult()
		if NiandraMinigames.UsePointshop then
			net.Start("Hangman_GiveUp")		
			net.SendToServer()
		end
	end
	
	NiandraMinigames.HangmanOpenSettings = false
	local Hangman_Hidden_Options_Settings = vgui.Create("DButton", Hangman_Hidden_Options_Buttons)
	Hangman_Hidden_Options_Settings:SetPos(0+183+184, 0)
	Hangman_Hidden_Options_Settings:SetSize(183, 50)
	Hangman_Hidden_Options_Settings:SetText("Settings")
	Hangman_Hidden_Options_Settings:SetFont("Coolvetica30")
	Hangman_Hidden_Options_Settings:SetColor(Color(255, 255, 255, 255))
	Hangman_Hidden_Options_Settings.Paint = function()
		draw.RoundedBox(0, 0, 0, 300, 50, NiandraMinigames.HangmanSettingsButtonColour)
	end
	Hangman_Hidden_Options_Settings.DoClick = function()
		if not NiandraMinigames.HangmanOpenSettings then
			NiandraMinigames:Hangman_Settings()
			NiandraMinigames.HangmanOpenSettings = true
		else
			NiandraMinigames:CloseSettingsMenu()
			NiandraMinigames.HangmanOpenSettings = false
		end
	end
	
	//Updating the Tried Letters
	--This is disgustingly sloppy and awful to look at, but trying to get the positioning right on row 2 with 1 loop was annoying the shit out of me.
	function NiandraMinigames:UpdateTriedLetters()
	
	local twtbl = table.ToString(NiandraMinigames.TriedLetters)
	
	local attempts_row1 = 0
	local attempts_row2 = 0
	
	for k, v in pairs(NiandraMinigames.TriedLetters) do
	if attempts_row1 < 7 then
	local Hangman_TriedLetters_Table = vgui.Create("DLabel", Hangman_Buttons_Background_Panel)
	Hangman_TriedLetters_Table:SetText(v)
	Hangman_TriedLetters_Table:SetFont("Coolvetica20")
	if string.find(twtbl, v) then
		Hangman_TriedLetters_Table:SetColor(Color(255, 255, 255, 255))
	else
		Hangman_TriedLetters_Table:SetColor(Color(207, 0, 15, 255))
	end
	Hangman_TriedLetters_Table:SizeToContents()
	if attempts_row1 >= 0 and attempts_row1 <= 7 then
		Hangman_TriedLetters_Table:SetPos(360+attempts_row1*25, 105)
	end
	attempts_row1 = attempts_row1 + 1
	
	else
	
	local Hangman_TriedLetters_Table_2 = vgui.Create("DLabel", Hangman_Buttons_Background_Panel)
	Hangman_TriedLetters_Table_2:SetText(v)
	Hangman_TriedLetters_Table_2:SetFont("Coolvetica20")
	if string.find(twtbl, v) then
		Hangman_TriedLetters_Table_2:SetColor(Color(255, 255, 255, 255))
	else
		Hangman_TriedLetters_Table_2:SetColor(Color(207, 0, 15, 255))
	end
	Hangman_TriedLetters_Table_2:SizeToContents()
	if attempts_row2 >= 0 and attempts_row2 <= 7 then
		Hangman_TriedLetters_Table_2:SetPos(360+attempts_row2*25, 125)
	end
	attempts_row2 = attempts_row2 + 1
	end
	
	end
	end
	
	//ALPHABET BUTTONS
	--Basically, we loop through a table of the alphabet and keep count of the loop. Every time, we add one to a number, so they can all be displayed. 
	local buttons = 0
	for k, v in pairs(NiandraMinigames.Alphabet) do
	local Hangman_Alphabet_Table = vgui.Create("DButton", Hangman_Buttons_Background_Panel)
	Hangman_Alphabet_Table:SetSize(50, 50)
	if buttons <= 10 then
		Hangman_Alphabet_Table:SetPos(0 + buttons * 50, 0)
	end
	if buttons >= 11 and buttons <= 21 then
		Hangman_Alphabet_Table:SetPos(-550 + buttons * 50, 50)
	end
	if buttons > 21 then
		Hangman_Alphabet_Table:SetPos(-1100 + buttons * 50, 100)
	end
	
	Hangman_Alphabet_Table:SetText(v)
	Hangman_Alphabet_Table:SetColor(Color(255, 255, 255, 255))
	Hangman_Alphabet_Table:SetFont("Coolvetica30")
	
	if math.fmod(buttons, 2) == 0 then
		Hangman_Alphabet_Table.Paint = function()
			draw.RoundedBox(0, 0, 0, 50, 50, NiandraMinigames.HangmanWordAlphabetEven)
		end	
	else
		Hangman_Alphabet_Table.Paint = function()
			draw.RoundedBox(0, 0, 0, 50, 50, NiandraMinigames.HangmanWordAlphabetOdd)
			draw.RoundedBox(0, 0, 0, 50, 50, NiandraMinigames.HangmanWordAlphabetOdd)
		end	
	end
	
	Hangman_Alphabet_Table.DoClick = function()
		if table.HasValue(NiandraMinigames.TriedLetters, v) then
			chat.AddText( Color(100,100,255), "[HANGMAN]", Color(255, 255, 255), " Error! Letter already entered.")
			surface.PlaySound("buttons/weapon_cant_buy.wav")
		else
			NiandraMinigames.LetterToInsert = v
			NiandraMinigames:UpdateHangman()
			Hangman_DisplayStrng:SetText(NiandraMinigames.WordToDisplay)
			NiandraMinigames:UpdateTriedLetters()
			Hangman_DisplayStrng:SetPos(550/2-Hangman_StringLength*11, 150)
		end
	end
	buttons = buttons + 1
	end
	
	end
	
	
	chat.AddText( Color(100,100,255), "[HANGMAN]", Color(255, 255, 255), " Starting game!")
	NiandraMinigames:HangmanMenu()

end)

function NiandraMinigames:HangmanResult()

	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 200)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame.Paint = function()
			draw.RoundedBox(0, 0, 0, 500, 170, NiandraMinigames.HangmanBackground)	
	end
	gui.EnableScreenClicker(true)
	
	frame:SetPos(-400, (ScrH()/2)-50)
	frame:MoveTo(400, (ScrH()/2)-50, 0.5, 0, 0.5)
	
	function NiandraMinigames:CloseResultMenu()
		frame:SetVisible(false)
		gui.EnableScreenClicker(false)
	end
	
	local Hangman_PlayAgain = vgui.Create("DButton", frame)
	Hangman_PlayAgain:SetSize(250, 25)
	Hangman_PlayAgain:SetPos(0, 170-25)
	Hangman_PlayAgain:SetText("Play again!")
	Hangman_PlayAgain:SetColor(color_white)
	Hangman_PlayAgain.Paint = function()
			draw.RoundedBox(0, 0, 0, 250, 25, Color(27, 188, 155))	
	end
	Hangman_PlayAgain.DoClick = function()
		NiandraMinigames:CloseResultMenu()
		NiandraMinigames:HangmanMenu()
	end
	
	local Hangman_Quit = vgui.Create("DButton", frame)
	Hangman_Quit:SetSize(250, 25)
	Hangman_Quit:SetPos(250, 170-25)
	Hangman_Quit:SetText("Quit")
	Hangman_Quit:SetColor(color_white)
	Hangman_Quit.Paint = function()
			draw.RoundedBox(0, 0, 0, 250, 25, Color(231, 76, 60))	
	end
	Hangman_Quit.DoClick = function()
		NiandraMinigames:CloseResultMenu()
		if NiandraMinigames.HangmanOpenSettings then
			NiandraMinigames:CloseSettingsMenu()
		end	
	end
	
	//Instead of doing a seperate menu, let's just use a boolean check and else statements.
	local Hangman_Outcome_Image = vgui.Create("DImage", frame)
	Hangman_Outcome_Image:SetSize(128, 128)
	if LocalPlayer():GetNWBool("HangmanStatus", true) then
		Hangman_Outcome_Image:SetImage("materials/niandralades/minigames/hangman_win.png")
	else
		Hangman_Outcome_Image:SetImage("materials/niandralades/minigames/hangman_lose.png")
	end
	Hangman_Outcome_Image:SetPos(10, 10)
	
	local Hangman_Outcome_Text = vgui.Create("DLabel", frame)
	if LocalPlayer():GetNWBool("HangmanStatus", true) then
		Hangman_Outcome_Text:SetText("You win, "..LocalPlayer():Nick().."!")
	else
		Hangman_Outcome_Text:SetText("You lose, "..LocalPlayer():Nick().."!")
	end
	Hangman_Outcome_Text:SetFont("Coolvetica30")
	Hangman_Outcome_Text:SizeToContents()
	Hangman_Outcome_Text:SetColor(Color(255, 255, 255, 255))
	Hangman_Outcome_Text:SetPos(128 + 15, 10)
	
	local chosenword = NiandraMinigames.HangmanWord or "NO WORD FOUND"
	local Hangman_Outcome_Reveal = vgui.Create("DLabel", frame)
	if LocalPlayer():GetNWBool("HangmanStatus", true) then
		Hangman_Outcome_Reveal:SetText(""..NiandraMinigames.HangmanWinMessage.." It was "..chosenword..". As a reward, you \nget "..NiandraMinigames.HangmanWinPoints.." points.")
		if GetConVar("Hangman_Enable_WinLose_Sounds"):GetBool() then
			surface.PlaySound("misc/your_team_won.wav")
		end	
	else
		Hangman_Outcome_Reveal:SetText(""..NiandraMinigames.HangmanLoseMessage.." It was "..chosenword..". As punishment, you \nlose "..NiandraMinigames.HangmanLosePoints.." points.")
		if GetConVar("Hangman_Enable_WinLose_Sounds"):GetBool() then
			surface.PlaySound("misc/your_team_lost.wav")
		end	
	end
	Hangman_Outcome_Reveal:SizeToContents()
	Hangman_Outcome_Reveal:SetColor(Color(255, 255, 255, 255))
	Hangman_Outcome_Reveal:SetPos(128 + 15, 40)
end

function NiandraMinigames:Hangman_Settings()
	local frame = vgui.Create("DFrame")
	frame:SetPos(-200, ScrH()/2-150)
	frame:SetSize(200, 300)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame.Paint = function()
			draw.RoundedBox(0, 0, 0, 200, 300, NiandraMinigames.HangmanBackground)	
	end
	
	frame:SetPos(-200, ScrH()/2-150)
	frame:MoveTo(0, ScrH()/2-150, 0.5, 0, 0.5)
	
	local Hangman_Settings_Label = vgui.Create("DLabel", frame)
	Hangman_Settings_Label:SetText("Settings")
	Hangman_Settings_Label:SetFont("Coolvetica30")
	Hangman_Settings_Label:SizeToContents()
	Hangman_Settings_Label:SetColor(Color(255, 255, 255, 255))
	Hangman_Settings_Label:SetPos(50, 15)
	
	local Hangman_Settings_Panel = vgui.Create("DPanel", frame)
	Hangman_Settings_Panel:SetSize(130+50, 150)
	Hangman_Settings_Panel:SetPos(10, 50)
	
	//Feel free to change one of these but please leave in the other or some form of credit to me, thanks!
	local Hangman_Settings_Workshop = vgui.Create("DButton", frame)
	Hangman_Settings_Workshop:SetPos(10, 260)
	Hangman_Settings_Workshop:SetText("Contact Me")
	Hangman_Settings_Workshop:SetSize(130+50, 25)
	Hangman_Settings_Workshop.Paint = function()
			draw.RoundedBox(0, 0, 0, 130+50, 25, Color(27, 188, 155))
	end
	Hangman_Settings_Workshop.DoClick = function()
		gui.OpenURL("http://steamcommunity.com/id/NiandraLades")
	end
	
	local Hangman_Settings_Contact = vgui.Create("DButton", frame)
	Hangman_Settings_Contact:SetPos(10, 260-25)
	Hangman_Settings_Contact:SetText("Workshop")
	Hangman_Settings_Contact:SetSize(130+50, 25)
	Hangman_Settings_Contact.Paint = function()
			draw.RoundedBox(0, 0, 0, 130+50, 25, Color(231, 76, 60))	
	end
	Hangman_Settings_Contact.DoClick = function()
		gui.OpenURL("http://steamcommunity.com/id/NiandraLades")
	end
	
	//I split this into 
	local Hangman_Settings_Gun_Sounds = vgui.Create("DCheckBox", Hangman_Settings_Panel)
	Hangman_Settings_Gun_Sounds:SetPos(10, 10)
	Hangman_Settings_Gun_Sounds:SetSize(16,16)
	Hangman_Settings_Gun_Sounds:SetToolTip("Enable/Disable gun shot sounds when pressing buttons.")
	Hangman_Settings_Gun_Sounds:SetChecked(GetConVar("Hangman_Enable_GunShot_Sounds"):GetBool())
	Hangman_Settings_Gun_Sounds.OnChange = function()
		if Hangman_Settings_Gun_Sounds:GetChecked() then
			RunConsoleCommand("Hangman_Enable_GunShot_Sounds", "1")
				else
			RunConsoleCommand("Hangman_Enable_GunShot_Sounds", "0")
		end
	end
	Hangman_Settings_Gun_Sounds:SetVisible(true)
	
	local Hangman_Settings_Gun_Label = vgui.Create("DLabel", Hangman_Settings_Panel)
	Hangman_Settings_Gun_Label:SetText("Enable gun sound effects.")
	Hangman_Settings_Gun_Label:SizeToContents()
	Hangman_Settings_Gun_Label:SetColor(Color(255, 255, 255, 255))
	Hangman_Settings_Gun_Label:SetPos(30, 11)
	Hangman_Settings_Gun_Label:SetColor(Color(0, 0, 0))

	local Hangman_Settings_WinLose_Sounds = vgui.Create("DCheckBox", Hangman_Settings_Panel)
	Hangman_Settings_WinLose_Sounds:SetPos(10, 40)
	Hangman_Settings_WinLose_Sounds:SetSize(16,16)
	Hangman_Settings_WinLose_Sounds:SetToolTip("Enable/Disable TF2 sound effects when losing/winning.")
	Hangman_Settings_WinLose_Sounds:SetChecked(GetConVar("Hangman_Enable_GunShot_Sounds"):GetBool())
	Hangman_Settings_WinLose_Sounds.OnChange = function()
		if Hangman_Settings_Gun_Sounds:GetChecked() then
			RunConsoleCommand("Hangman_Enable_GunShot_Sounds", "1")
				else
			RunConsoleCommand("Hangman_Enable_GunShot_Sounds", "0")
		end
	end
	Hangman_Settings_WinLose_Sounds:SetVisible(true)	
	
	local Hangman_Settings_WinLose_Label = vgui.Create("DLabel", Hangman_Settings_Panel)
	Hangman_Settings_WinLose_Label:SetText("Enable win/lose effects.")
	Hangman_Settings_WinLose_Label:SizeToContents()
	Hangman_Settings_WinLose_Label:SetColor(Color(255, 255, 255, 255))
	Hangman_Settings_WinLose_Label:SetPos(30, 41)
	Hangman_Settings_WinLose_Label:SetColor(Color(0, 0, 0))
	
	function NiandraMinigames:CloseSettingsMenu()
		frame:MoveTo(-200, ScrH()/2-150, 0.5, 0, 0.5)
		timer.Simple(0.5, function()
			frame:Remove()
		end)
	end
	
	
end




end
