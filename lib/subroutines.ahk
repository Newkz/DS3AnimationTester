SubmitSharedVars:
{
	Gui, SharedVars: Submit, NoHide
}
return

GuiOn:
{
	ifWinActive, DARK SOULS III
	{
		Gui, PoiseBar: Show, NA x%barPos_x% y%barPos_y% w%bar_width% h%border_height%
		Gui, PoiseText: Show, NA x%barPos_x% y%barPos_y% w%bar_width% h%border_height%
		Gui, PoiseBarBG: Show, NA x%barPos_x% y%barPos_y% w%bar_width% h%border_height%
		WinSet, TransColor, %TColor%, PoiseGuiBG
		WinSet, TransColor, %TColor%, PoiseGui
		WinSet, TransColor, %TColor%, PoiseTextGui
		WinSet, Transparent, %bgTransparancy%, PoiseGuiBG
		SetTimer, GuiOn, Off
		SetTimer, GuiOff, 50		
	}
}
return

GuiOff:
{
	ifWinNotActive, DARK SOULS III
	{
		Gui, PoiseBar: Hide
		Gui, PoiseText: Hide
		Gui, PoiseBarBG: Hide
		SetTimer, GuiOff, Off
		SetTimer, GuiOn, 300
	}
	else ifWinActive, DARK SOULS III
	{
		x := getpoiseHealth()
		x := Round(x)
		GuiControl, PoiseBar: , PoiseBar, %x%
		GuiControl, PoiseText:, PoiseText, Poise: %x%
		
		if isPoiseActive()
			GuiControl,PoiseBar: +c%Bar_Poise%, PoiseBar
		else
			GuiControl,PoiseBar: +c%Bar_noPoise%, PoiseBar
			
	}
}
return

PoiseTestingGuiClose:
	SavePoiseTestingGUIPos()
	ExitApp
return

ReloadPTGui:
	derivedObject.write(SpeedModAddr, 1, "Float")
	SavePoiseTestingGUIPos()
	Reload
return

R11:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "p", false, false, 0, mainkeyGui, false, false)
return

R12:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "p", false, false, 0, mainkeyGui)
return

R13:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(3, "p", false, false, 0, mainkeyGui)
return

R21:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "e", false, false, 0, mainkeyGui)
return

R22:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "e", false, false, 0, mainkeyGui)
return

R2OnRelease:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "e", true, false, chargeTimeGui, mainkeyGui)
return

R22OnRelease:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "e", true, "e", chargeTimeGui, mainkeyGui)
return

FwdR2:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "e", false, false, 0, mainkeyGui)
return

RollR1:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "LCtrl", false, false, 0, mainkeyGui)
return

RollR2:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "LCtrl", false, false, 0, mainkeyGui)
return

SprintR1:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "p", false, false, 0, mainkeyGui)
return

L2:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "q", false, false, 0, mainkeyGui)
return

L2R1:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "q", false, false, 0, mainkeyGui)
return

L2R2:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "q", false, false, 0, mainkeyGui)
return

L21OH:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "q", false, false, 0, mainkeyGui)
return

L22OH:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "q", false, false, 0, mainkeyGui)
return

L23OH:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(3, "q", false, false, 0, mainkeyGui)
return

L11:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "o", false, false, 0, mainkeyGui)
return

L12:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(2, "o", false, false, 0, mainkeyGui)
return

L13:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(3, "o", false, false, 0, mainkeyGui)
return

L2Parry:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "q", false, false, 0, mainkeyGui, true)
return

Roll:
	Gui, PoiseTesting: Submit, NoHide
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(1, "q", false, false, 0, mainkeyGui, false, true)
return

CustomAttack:
	Gui, PoiseTesting: Submit, NoHide
	;MsgBox %attackNrGui%, %pressGui%, %chargeGUI%, %press2Gui%, %chargeTimeGui%
	WinActivate, DARK SOULS III
	Sleep 100
	WinActivate, DARK SOULS III
	measureAttack2(attackNrGui, pressGui, chargeGUI, press2Gui, chargeTimeGui, mainkeyGui)
return

