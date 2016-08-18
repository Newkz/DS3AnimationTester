#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
#Persistent
Detecthiddenwindows,On
;############################## SETTINGS ##############################

; AOB Scans
derivedObject := new _ClassMemory("ahk_exe DarkSoulsIII.exe")
addr_01 := AOBScan(derivedObject, "48 8B 1D ?? ?? ?? 04 48 8B F9 48 85 DB 74 76  8B 11 85 D2 78 70", 3, 7)
;addr_02 := AOBScan(derivedObject, "48 8B 05 ?? ?? ?? ?? 48 85 C0 74 ?? 48 8B 40 50", 3, 7)
;addr_03 := AOBScan(derivedObject, "48 8B 05 ?? ?? ?? ?? 48 8B 80 58 0C 00 00", 3, 7)
;fpsmod := AOBScan(derivedObject, "48 8B 0D ?? ?? ?? ?? 48 85 C9 74 26 44 8B", 3, 7)
;param_ptr := AOBScan(derivedObject, "48 89 5C 24 48 8B FA 48 8b d9 c7 44 24 20 00 00 00 00 48", 0x15, 25)

; Addresses
playerTurnableFlagAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x0, 0x59)
iFrameFlagAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x0, 0x58)
blockFlagAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x0, 0x58)
poiseFlagAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x48, 0x40)
poiseHealthAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x48, 0x20)
currentStaminaAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x18, 0xf0)
parry2FlagAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x0, 0x58)
parryFlagAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x0, 0x5d)
SpeedModAddr := getAddressFromOffsets(derivedObject, addr_01,, 0x80, 0x1f80, 0x28, 0xa38)
enemyHealthAddr := 0x7FF5AEED1278

;################################ MAIN #################################
;InitGUI()
PoisetestingGUI()
;############################### HOTKEYS ###############################
F3::
{
	Reload
}
return
;############################# SUBROUTINES #############################
Loop
	Sleep 1
#Include %A_ScriptDir%\lib\subroutines.ahk
;############################## FUNCTIONS ##############################

measureAttack2(AttackNr, press="o", charge=false, press2=false, chargeTime=0, mainKey="F8", testparry=false, testiFrame=false)
{
	global
	gosub, SubmitSharedVars
	_poise := 0, _block := 0, _parry := 0, _noTurn := 0, _poiseHealth := "", _iFrame := 0, _targetHealth := 0
	_poiseData := Array(), _blockData := Array(), _parryData := Array(), _noTurnData := Array(), _stamConsData := Array(), _iFrameData := Array(), _targetHealthData := Array()
	;_exeData := ""
	
	KeyWait, %mainKey%, D
	_stamina := getStamina()
	if (charge && AttackNr = 1)
		derivedObject.write(SpeedModAddr, 0.1000000015, "Float")
	Send {%press% down}
	Sleep 5
	if (charge)
	{
		if (AttackNr = 1)
			Sleep %chargeTime%
		KeyWait, %mainKey%
	}
	Send {%press% up}	
	
	if (AttackNr > 1)
	{
		AttackNr := AttackNr - 1
		Loop, %AttackNr%
		{
			awaitPoiseFlag(true)
			if (A_Index = AttackNr)
				derivedObject.write(SpeedModAddr, 0.1000000015, "Float")
			awaitPoiseFlag(false)
			_stamina := getStamina()
		}
		if (press2 != false and press2 != "")
		{
			Send {%press2% Down}
			Sleep 5
			if (charge)
				Sleep %chargeTime%
			Send {%press2% Up}
		}
	}
	derivedObject.write(SpeedModAddr, 0.1000000015, "Float")
	timeStart := A_TickCount
	
	tif := testiFrame
	while (isiFrameActive() = false || tif = true)
	{
		;exeStart := A_TickCount
		
		if (testiFrame)
		{
			iFrame := isiFrameActive()
			if (_iFrame != iFrame)
			{
				_iFrame := iFrame
				time := A_TickCount - timeStart
				_iFrameData.Insert(time)
				if (_iFrameData.MaxIndex() >= 2)
				{
					testiFrame := false
					tif := false
				}
				
			}
		}
		
		Poise := isPoiseActive()
		if (_poise != Poise)
		{
			_poise := Poise
			time := A_TickCount - timeStart
			_poiseData.Insert(time)
		}
		
		if (Poise)
		{
			PoiseHealth := getpoiseHealth()
			if (PoiseHealth > _poiseHealth)
				_poiseHealth := PoiseHealth
		}
		
		Block := isBlockActive()
		if (_block != Block)
		{
			_block := Block
			time := A_TickCount - timeStart
			_blockData.Insert(time)
		}
		Parry := isParryActive()
		if (_parry != Parry)
		{
			_parry := Parry
			time := A_TickCount - timeStart
			_parryData.Insert(time)
		}
		
		NoTurn := isPlayerTurnable()
		if (_noTurn != NoTurn)
		{
			_noTurn := NoTurn
			time := A_TickCount - timeStart
			_noTurnData.Insert(time)
		}
		
		Stamina := getStamina()
		if (_stamina > Stamina)
		{
			_stamina := Stamina
			time := A_TickCount - timeStart
			_stamConsData.Insert(time)
		}
		else if (_stamina < Stamina)
		{
			_stamina := Stamina
		}
		
		TargetHealth := getTargetHealth()
		if (_targetHealth > TargetHealth)
		{
			_targetHealth := TargetHealth
			time := A_TickCount - timeStart
			_targetHealthData.Insert(time)
		}
		else if (_targetHealth < TargetHealth)
		{
			_targetHealth := TargetHealth
		}
		
		
		;iFrame := isiFrameActive()
			
		;exeEnd := A_TickCount - exeStart
		;_exeData := _exeData . + exeEnd . + ", "
	}
	recoveryEnd := A_TickCount - timeStart
	derivedObject.write(SpeedModAddr, 1, "Float")
	
	if (Mod(_poiseData.MaxIndex(), 2) = 1)
		_poiseData.Insert(recoveryEnd)
	
	recoveryStart := _poiseData[_poiseData.MaxIndex()]
	if (testparry)
		recoveryStart := _parryData[_parryData.MaxIndex()]
	startupEnd := _stamConsData[1]
	recovery := recoveryEnd-recoveryStart
	poiseMult := _poiseHealth / 100
	
	if (Mod(_noTurnData.MaxIndex(), 2) = 1)
		_noTurnData.Insert(recoveryEnd)	
	if (_stamConsData[_stamConsData.MaxIndex] + 35 >= recoveryEnd)
		_stamConsData.Pop()
		
	
	PoiseData := DataOutput("Poise", _poiseData, 1)
	poiseMsg := PoiseData[1], addpoiseMsg := PoiseData[2], poiseStart := PoiseData[3], poiseEnd := PoiseData[4]
	
	BlockData := DataOutput("Block", _blockData, 1)
	blockMsg := BlockData[1], addblockMsg := BlockData[2], blockStart := BlockData[3], blockEnd := BlockData[4]
	
	ParryData := DataOutput("Parry", _parryData, 1)
	parryMsg := ParryData[1], addparryMsg := ParryData[2], parryStart := ParryData[3], parryEnd := ParryData[4]
	
	NoTurnData := DataOutput("NoTurn", _noTurnData, 1)
	noTurnMsg := NoTurnData[1], addnoTurnMsg := NoTurnData[2], noTurnStart := NoTurnData[3], noTurnEnd := NoTurnData[4]
	
	StamConsData := DataOutput("StamCons", _stamConsData, 1)
	stamConsMsg := StamConsData[1], addstamConsMsg := StamConsData[2], stamConsStart := StamConsData[3], stamConsEnd := StamConsData[4]
	
	TargetHealthData := DataOutput("StamCons", _targetHealthData, 1)
	targetHealthMsg := TargetHealthData[1], addtargetHealthMsg := TargetHealthData[2], targetHealthStart := TargetHealthData[3], targetHealthEnd := TargetHealthData[4]
	
	IFrameData := DataOutput("IFrame", _iFrameData, 1)
	iFrameMsg := IFrameData[1], addiFrameMsg := IFrameData[2], iFrameStart := IFrameData[3], iFrameEnd := IFrameData[4]
	
	clipboard = =%startupEnd%/10	=%poiseStart%/10	=%poiseEnd%/10	=(%recoveryEnd%-%recoveryStart%)/10	=%poiseMult%	%addPoiseMsg%	%noTurnMsg%	%stamConsMsg%	%blockMsg%	%parryMsg%	%iFrameMsg%	%targetHealthMsg%
	;MsgBox Poise: %poiseMsg% `r`nPoiseMult: %poiseMult% `r`nBlock: %blockMsg% `r`nParry: %parryMsg% `r`nNoTurn: %noTurnMsg% `r`nStamConsume: %stamConsMsg% `r`nRecovery: %recoveryStart%-%recoveryEnd% -> %recovery% ;`r`nExecution Times: %_exeData%
	x:= "Poise:" . + poiseMsg . + "`r`nPoiseMult: " . + poiseMult . + "`r`nBlock: " . + blockMsg . + "`r`nParry: " . + parryMsg . + "`r`nNoTurn: " . + noTurnMsg . + "`r`nStamConsume: " . + stamConsMsg . + "`r`nRecovery: " . + recoveryStart . + "-" . + recoveryEnd . + "->" . + recovery . + "`r`niFrames: " . + iFrameMsg . + "`r`nExecutionTime: " . + _exeData . + "`r`nTargetHealth: " . + targetHealthMsg
	GuiControl, PoiseTesting:, MyEdit, %x%
}

DataOutput(DataType, Data, startIndex=1)
{
	scnd := false, scnd2 := false, Msg := ""
	SetFormat, Float, 0.1
	For Index, tm in Data
	{
		if (Index = startIndex)
			DataTypeStart := tm
		else if (Index = startIndex + 1)
			DataTypeEnd := tm
		
		if (Index < startIndex || Index > startIndex + 1)
		{
			addMsg := addMsg . + tm / 10
			if (!scnd)
			{
				addMsg := addMsg . + "-"
			}
			else if (scnd and Index != Data.MaxIndex() and Index != startIndex - 1)
			{
				addMsg := addMsg . + ", "
			}
			scnd := !scnd
		}
		
		Msg := Msg . + tm / 10
		if (scnd2 = false and DataType != "StamCons")
		{
			Msg := Msg . + "-"
		}
		else if ((scnd2 and Index != Data.MaxIndex()) or (Datatype = "StamCons") and Index != Data.MaxIndex())
		{
			Msg := Msg . + ", "
		}
		scnd2 := !scnd2
	}
	return Array(Msg, addMsg, DataTypeStart, DataTypeEnd)
}

measureRoll(recovery, msg, attack=0) ; Old
{
	;WinWaitActive DARK SOULS III
	KeyWait, F8, D
	
	Send {LCtrl down}
	Sleep 1
	Send {LCtrl up}	
	
	timeStart := A_TickCount
	
	; Start of Roll
	awaitIFrame(true)
	rollStart := A_TickCount - timeStart	
	
	; End of Roll
	awaitIFrame(false)
	rollEnd :=	A_TickCount - timeStart
	
	; Start of Hyper Armor
	awaitpoiseFlag(true)
	haStart := A_TickCount - timeStart
	
	; End of Hyper Armor
	awaitpoiseFlag(false)
	haEnd := A_TickCount - timeStart
	
	; Attack Startup
	if (Attack != 0)
	{
		HyperArmorAttack(true, true)
	}
	
	; Recovery
	if (recovery)
	{
		recoveryStart := A_TickCount - timeStart
		awaitIFrame(true)
		recoveryEnd := A_TickCount - timeStart
	}
	
	if (msg)
    {
        x := "iFrames: " rollStart "-" rollEnd "`r`n" "HyperArmor: " haStart "-" haEnd "`r`n" "Recovery: " recoveryStart "-" recoveryEnd
        GuiControl, PoiseTesting:, MyEdit, %x%
    }
}

measureAttack(MoveSet, press="o", charge=false, stamina=false, AllHA=false) ; Old
{
	global
    ;WinWaitActive DARK SOULS III
	KeyWait, F8, D
	
	Send {%press% down}
	Sleep 5
	if (charge = true)
    {
        KeyWait, F8
        ;Sleep 8000
    }
	Send {%press% up}	
	
	if (Moveset = 1)
	{
		HyperArmorAttack(true, true, stamina)
	}
	if (Moveset = 2)
	{
		HyperArmorAttack(false, false, stamina)
		
		; For 100% Hyper Armor between attack
		if (AllHA)
        {
            awaitPoiseFlag(false)
            Send {e down}
            Sleep 5
            Send {e up}
        }
        
		if (charge)
		{
			KeyWait, F8, D
			Send {%press% down}
			Sleep 8000
			KeyWait, F8
			Send {%press% up}
		}
		
		HyperArmorAttack(true, true)
	}
	if (Moveset = 3)
	{
		HyperArmorAttack(false, false, stamina)
		HyperArmorAttack(false, false)
		HyperArmorAttack(true, true)
	}
}

checkBlockFrames(press="o")
{
	;WinWaitActive DARK SOULS III
	KeyWait, F8, D
	
	Send {%press% down}
	Sleep 1
	Send {%press% up}
	
	timeStart := A_TickCount
	
	awaitblockFlag(true)
	blockStart := A_TickCount - timeStart
	awaitblockFlag(false)
	blockStop := A_TickCount - timeStart
	
	clipboard = =%blockStart%/10	=%blockStop%/10
	x := "Block: " blockStart "-" blockStop
    GuiControl, PoiseTesting:, MyEdit, %x%
}

checkPoiseFrames(press="o")
{
	;WinWaitActive DARK SOULS III
	KeyWait, F8, D
	
	Send {%press% down}
	Sleep 1
	Send {%press% up}
	
	timeStart := A_TickCount
	
	awaitPoiseFlag(true)
	poiseStart := A_TickCount - timeStart
	awaitPoiseFlag(false)
	poiseStop := A_TickCount - timeStart
	
	clipboard = =%poiseStart%/10	=%poiseStop%/10
	x := "Poise: " poiseStart "-" poiseStop
    GuiControl, PoiseTesting:, MyEdit, %x%
}

checkParryFrames(press="q")
{
	;WinWaitActive DARK SOULS III
	KeyWait, F8, D
	
	Send {%press% down}
	Sleep 1
	Send {%press% up}
	
	timeStart := A_TickCount
	
	awaitParryFlag(true)
	poiseStart := A_TickCount - timeStart
	awaitParryFlag(false)
	poiseStop := A_TickCount - timeStart
    recoveryStart := A_TickCount - timeStart
    awaitIFrame(true)
    recoveryEnd := A_TickCount - timeStart
	
	clipboard = =%poiseStart%/10	=%poiseStop%/10 =(%recoveryEnd%-%recoveryStart%)/10
	x := "Poise: " poiseStart "-" poiseStop "`r`n" "Recovery: " recoveryStart "-" recoveryEnd
    GuiControl, PoiseTesting:, MyEdit, %x%
}

checkStartupFrames(press="o")
{
	;WinWaitActive DARK SOULS III
	KeyWait, F8, D
	
	Send {%press% down}
	Sleep 1
	Send {%press% up}
	
	timeStart := A_TickCount
	
	awaitStamChange()
	stamChange := A_TickCount - timeStart
	
	clipboard = =%stamChange%/10
	x := "Startup: " stamChange
    GuiControl, PoiseTesting:, MyEdit, %x%
}

HyperArmorAttack(recovery, msg, stamina=false, stamfirst=false) ; Old
{
	; Start of Startup
	timeStart := A_TickCount
	if (stamina)
		temp_stam := stamina
	else
		temp_stam := getStamina()
	
	; End of Startup (Stamina Consumed, stamfirst)
	if (stamfirst)
    {
        Loop
        {
            if (getStamina() != temp_stam)
                break
        }
        startupEnd := A_TickCount - timeStart
    }
	
    
    ; Start of Hyper Armor
	awaitPoiseFlag(true)
	haStart := A_TickCount - timeStart
    
    ; End of Startup (Stamina Consumed)
	if (stamfirst = false)
    {
        Loop
        {
            if (getStamina() != temp_stam)
                break
        }
        startupEnd := A_TickCount - timeStart
    }
	
	; End of Hyper Armor
	awaitPoiseFlag(false)
	haEnd := A_TickCount - timeStart
	
	
	; Start of Recovery
	if (recovery)
	{
		recoveryStart := A_TickCount - timeStart
		awaitIFrame(true)
		recoveryEnd := A_TickCount - timeStart
		result := recoveryEnd
	}
	; End of Recovery
	
	if (msg)
	{
		clipboard = =%startupEnd%/10	=%haStart%/10	=%haEnd%/10	=(%recoveryEnd%-%recoveryStart%)/10
        x := "Startup: " startupEnd "`r`n" "HyperArmor: " haStart "-" haEnd "`r`n" "Recovery: " recoveryStart "-" recoveryEnd
        GuiControl, PoiseTesting:, MyEdit, %x%
	}
}

PoiseTestingGUI()
{
    global
    Filename := "settings.ini"
    gui_x := 1930
    gui_y := 98
    
    IniRead, gui_x, %Filename%, Positions, gui_x, %gui_x%	
    IniWrite, %gui_x%, %Filename%, Positions, gui_x
    
    IniRead, gui_y, %Filename%, Positions, gui_y, %gui_y%	
    IniWrite, %gui_y%, %Filename%, Positions, gui_y
	
	IniRead, mainkeyGui, %Filename%, CustomKey, mainkey, F8
	IniRead, pressGui, %Filename%, CustomKey, press
	IniRead, press2Gui, %Filename%, CustomKey, press2
	IniRead, chargeGUI, %Filename%, CustomKey, charge
	IniRead, chargeTimeGui, %Filename%, CustomKey, chargeTime, 0
	IniRead, attackNrGui, %Filename%, CustomKey, attackNr, 1
    
    Gui, PoiseTesting: New,, PoiseTesting
    Gui, PoiseTesting: Add, Button, x2 y-1 w100 h30 gReloadPTGui, Reload
	
	Gui, PoiseTesting: Add, Text, x112 y0, Main Key
	Gui, PoiseTesting: Add, Hotkey, x112 y13 w100 h20 vmainkeyGui, %mainkeyGui%
	
    Gui, PoiseTesting: Add, Button, x2 y39 w100 h30 gR11, R1 1
    Gui, PoiseTesting: Add, Button, x2 y79 w100 h30 gR12, R1 2
    Gui, PoiseTesting: Add, Button, x2 y119 w100 h30 gR13, R1 3
    Gui, PoiseTesting: Add, Button, x2 y159 w100 h30 gR21, R2 1
    Gui, PoiseTesting: Add, Button, x2 y199 w100 h30 gR22, R2 2
    Gui, PoiseTesting: Add, Button, x2 y239 w100 h30 gR2OnRelease, R2 On Release
    Gui, PoiseTesting: Add, Button, x112 y39 w100 h30 gR22OnRelease, R2 2 On Release
    Gui, PoiseTesting: Add, Button, x2 y279 w100 h30 gFwdR2, Fwd+R2
    Gui, PoiseTesting: Add, Button, x112 y79 w100 h30 gRollR1, Roll R1
    Gui, PoiseTesting: Add, Button, x112 y119 w100 h30 gRollR2, Roll R2
    Gui, PoiseTesting: Add, Button, x112 y159 w100 h30 gSprintR1, Sprint R1
    Gui, PoiseTesting: Add, Button, x112 y199 w100 h30 gL2, L2
    Gui, PoiseTesting: Add, Button, x112 y239 w100 h30 gL2R1, L2 -> R1
    Gui, PoiseTesting: Add, Button, x112 y279 w100 h30 gL2R2, L2 -> R2
	Gui, PoiseTesting: Add, Button, x2 y319 w100 h30 gL2Parry, Parry
	Gui, PoiseTesting: Add, Button, x112 y319 w100 h30 gRoll, Roll
    ;Gui, PoiseTesting: Add, Checkbox, x112 y309 w100 h30 vAllHA, Hyper Armor AllTheWay
    Gui, PoiseTesting: Add, Button, x2 y349 w100 h30 gL21OH, L2 1 (Offhand)
    Gui, PoiseTesting: Add, Button, x2 y389 w100 h30 gL22OH, L2 2 (Offhand)
    Gui, PoiseTesting: Add, Button, x2 y429 w100 h30 gL23OH, L2 3 (Offhand)
    Gui, PoiseTesting: Add, Button, x112 y349 w100 h30 gL11, L1 1
    Gui, PoiseTesting: Add, Button, x112 y389 w100 h30 gL12, L1 2
    Gui, PoiseTesting: Add, Button, x112 y429 w100 h30 gL13, L1 3
	
	Gui, PoiseTesting: Add, Button, x2 y469 w100 h30 gCustomAttack, Custom Attack
	Gui, PoiseTesting: Add, CheckBox, x112 y469 w100 h20 vchargeGUI Checked%chargeGui%, Charge
	
	Gui, PoiseTesting: Add, Text, x112 y504, Charge Timer
	Gui, PoiseTesting: Add, Edit, x112 y519 w100 h20 vchargeTimeGui, %chargeTimeGui%
	
	Gui, PoiseTesting: Add, Text, x112 y544, Attack Nr
	Gui, PoiseTesting: Add, DropDownList, x112 y559 w100 h140 Choose%attackNrGui% vattackNrGui, 1|2|3|4|5|6|8|9
	
	
	Gui, PoiseTesting: Add, Text, x2 y504, Press
	Gui, PoiseTesting: Add, Hotkey, x2 y519 w100 h20 vpressGui, %pressGui%
	Gui, PoiseTesting: Add, Text, x2 y544, Press2
	Gui, PoiseTesting: Add, Hotkey, x2 y559 w100 h20 vpress2Gui, %press2Gui%
	
	
    Gui, PoiseTesting: Add, Edit, x2 y600 w275 h148 vMyEdit,
    
	Gui, PoiseTesting: Show, NA w280 h753 x%gui_x% y%gui_y%
    Gui, PoiseTesting: +AlwaysOnTop
	WinActivate, PoiseTesting
}

SavePoiseTestingGUIPos()
{
    global
	Gui, PoiseTesting: Submit, NoHide
    Filename := "settings.ini"
    WinGetPos, X, Y, Width, Height, PoiseTesting
	IniWrite, %mainkeyGui%, %Filename%, CustomKey, mainKey
	IniWrite, %X%, %Filename%, Positions, gui_x
    IniWrite, %Y%, %Filename%, Positions, gui_y 
	IniWrite, %pressGui%, %Filename%, CustomKey, press
	IniWrite, %press2Gui%, %Filename%, CustomKey, press2
	IniWrite, %chargeGUI%, %Filename%, CustomKey, charge
	IniWrite, %chargetimeGui%, %Filename%, CustomKey, chargeTime
	IniWrite, %attackNrGui%, %Filename%, CustomKey, attackNr
}

InitIniFile()
{
	global
	Filename := "settings.ini"
	sColors := (Bar_Bg, Bar_noPoise, Bar_Poise, Bar_Border, fontColor)
	sSettings := (bgTransparancy, bar_range)
	sPositions := (barPos_x, barPos_y, bar_width, bar_height)
	
	; Color
	Bar_Bg := "525252"
	Bar_noPoise := "ff8400"
	Bar_Poise := "ff5400"
	Bar_Border := "98988b"
	fontColor := "ffffff"
	
	; Settings
	bgTransparancy := 150
	bar_range := 100
	
	; Positions
	barPos_x := 195
	barPos_y := 58
	bar_width := 420
	bar_height := 14
	
	; Read
	IniRead, bgTransparancy, %Filename%, Settings, bgTransparancy, %bgTransparancy%	
	IniRead, bar_range, %Filename%, Settings, bar_range, %bar_range%
	
	IniRead, Bar_Bg, %Filename%, Colors, Bar_Bg, %Bar_Bg%
	IniRead, Bar_noPoise, %Filename%, Colors, Bar_noPoise, %Bar_noPoise%
	IniRead, Bar_Poise, %Filename%, Colors, Bar_Poise, %Bar_Poise%
	IniRead, Bar_Border, %Filename%, Colors, Bar_Border, %Bar_Border%
	IniRead, fontColor, %Filename%, Colors, fontColor, %fontColor%
	
	IniRead, barPos_x, %Filename%, Positions, barPos_x, %barPos_x%
	IniRead, barPos_y, %Filename%, Positions, barPos_y, %barPos_y%
	IniRead, bar_width, %Filename%, Positions, bar_width, %bar_width%
	IniRead, bar_height, %Filename%, Positions, bar_height, %bar_height%
	
	; Write	
	IniWrite, %bgTransparancy%, %Filename%, Settings, bgTransparancy
	IniWrite, %bar_range%, %Filename%, Settings, bar_range
	
	IniWrite, %Bar_Bg%, %Filename%, Colors, Bar_Bg
	IniWrite, %Bar_noPoise%, %Filename%, Colors, Bar_noPoise
	IniWrite, %Bar_Poise%, %Filename%, Colors, Bar_Poise
	IniWrite, %Bar_Border%, %Filename%, Colors, Bar_Border
	IniWrite, %fontColor%, %Filename%, Colors, fontColor
	
	IniWrite, %barPos_x%, %Filename%, Positions, barPos_x
	IniWrite, %barPos_y%, %Filename%, Positions, barPos_y
	IniWrite, %bar_width%, %Filename%, Positions, bar_width
	IniWrite, %bar_height%, %Filename%, Positions, bar_height
}

InitGUI()
{
	global
	DetectHiddenWindows, On
	InitIniFile()
	
	; Don't Touch
	TColor := "f0f0f0"
	border_height := bar_height+2
	
	; PoiseBar Background
	Gui, PoiseBarBG: New,, PoiseGuiBG
	WinSet, TransColor, %TColor%, PoiseGuiBG
	WinSet, Transparent, %bgTransparancy%, PoiseGuiBG
	WinGet, dsHandle, ID, DARK SOULS III
	Gui, PoiseBarBG: +Owner%dsHandle%
	Gui, PoiseBarBG: Add, Progress,x0 y1 w%bar_width% h%bar_height% c%Bar_Bg% Background%Bar_Bg% Range0-%bar_range% vPoiseBar2 ;, PoiseBar2
	Gui, PoiseBarBG: Color, %Bar_Bg%
	Gui, PoiseBarBG: Margin, 0, 0
	Gui, PoiseBarBG: -Caption +ToolWindow
	Gui, PoiseBarBG: +AlwaysOnTop
	
	; PoiseBar
	Gui, PoiseBar: New,, PoiseGui
	WinSet, TransColor, %TColor%, PoiseGui
	WinGet, bgHandle, ID, PoiseGuiBG
	Gui, PoiseBar: +Owner%bgHandle%
	Gui, PoiseBar: Add, Progress,x0 y1 w%bar_width% h%bar_height% c%Bar_noPoise% BackGround%TColor% Range0-%bar_range% vPoiseBar ;, PoiseBar
	Gui, PoiseBar: Color, %Bar_Border%
	Gui, PoiseBar: Margin, 0, 0
	Gui, PoiseBar: -Caption +ToolWindow
	Gui, PoiseBar: +AlwaysOnTop
	
	; PoiseBar Text
	Gui, PoiseText: New,, PoiseTextGui
	WinSet, TransColor, %TColor%, PoiseTextGui
	WinGet, poiseHandle, ID, PoiseGui
	Gui, PoiseText: +Owner%poiseHandle%
	Gui, PoiseText: Font, s10 q5, Trajan Pro
	Gui, PoiseText: Add, Text, x2 y0 w%bar_width% h%bar_height% c%fontColor% +Left vPoiseText, Poise: 
	Gui, PoiseText: Color, %TColor%
	Gui, PoiseText: Margin, 0, 0
	Gui, PoiseText: -Caption +ToolWindow
	Gui, PoiseText: +AlwaysOnTop
	
	SetTimer, GuiOn, 300
}

#Include %A_ScriptDir%\lib\lowerlevelfunctions.ahk
#Include %A_ScriptDir%\lib\classMemory.ahk