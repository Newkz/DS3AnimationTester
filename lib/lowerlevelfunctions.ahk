getSharedVar(var, GuiName="SharedVars", UID="UID1")
{
	global
	x := %var%EditNr
	ControlGetText, y, %x%, SharedVars, UID
	return y
}

initVars(vars, GuiName="SharedVars", UID="UID1")
{
	global
	Gui, %GuiName%: new,, %GuiName%
	Gui, %GuiName%: Add, Text,, %UID%
	
	For Index, var in vars
	{
		Gui, %GuiName%: Add, Edit, v%var%, %var%
		%var%EditNr := "Edit" . + Index
	}
	Gui, %GuiName%: Show
}

getSharedEditNr(varname, sharedvarlist)
{
	For Index, var in sharedvarlist
	{
		if (var = varname)
			return Index
	}
}

awaitPlayerTurnable(state)
{
	Loop
	{
		if (isPlayerTurnable() = state)
			break
	}
}

awaitIFrame(state)
{
	Loop
	{
		if (isiFrameActive() = state)
			break
	}
}

awaitPoiseFlag(state)
{
	Loop
	{
		if (isPoiseActive() = state)
			break
	}
}

awaitblockFlag(state)
{
	Loop
	{
		if (isBlockActive() = state)
			break
	}
}

awaitParryFlag(state)
{
	Loop
	{
		if (isParryActive() = state)
			break
	}
}

awaitStamChange(stamina=false)
{
	if (stamina)
		currentStam := stamina
	else
		currentStam := getStamina()
	Loop
	{
		if (getStamina() != currentStam)
			break
	}
}

isPlayerTurnable()
{
	global
	x := getAnimationState(playerTurnableFlagAddr, "UChar")
	return getBit(x, 7)
}

isiFrameActive()
{
	global
	x := getAnimationState(iFrameFlagAddr, "UChar")
	return getBit(x, 1)
}

isPoiseActive()
{
	global
	x := getAnimationState(poiseFlagAddr, "UChar")
	return getBit(x, 0)
}

isBlockActive()
{
	global
	x := getAnimationState(blockFlagAddr, "UChar")
	return getBit(x, 2)
}

isParryActive()
{
	global
	x := getAnimationState(parryFlagAddr, "UChar")
	return getBit(x, 2)
}

isParry2Active()
{
	global
	x := getAnimationState(parry2FlagAddr, "UChar")
	return getBit(x, 2)
}

getpoiseHealth()
{
	global
	x := getAnimationState(poiseHealthAddr, "Float")
	return x
}

getStamina()
{
	global
	x := getAnimationState(currentStaminaAddr, "Int")
	return x
}

getTargetHealth()
{
	global
	x := getAnimationState(enemyHealthAddr, "Int")
	return x
}

setSpeedMod(value)
{
	derivedObject.write(SpeedModAddr, value, "Float")
}

getAnimationState(address, datatype="UChar", debug=false)
{
	global
	lastValue := -1
	if debug
		tooltipMsg := lastValue
	Loop
	{
		newValue := derivedObject.read(address, datatype)
		if (newValue != lastValue)
		{
			validationCount := 0
			Loop, 150
			{
				confirmationValue := derivedObject.read(address, datatype)
				if (newValue = confirmationValue)
					validationCount++
				else
					break
			}
			if (validationCount = 150)
			{
				if debug
				{
					lastValue := newValue
					tooltipMsg := tooltipMsg . + newValue
				}
				else
					return newValue
			}
		}
		if debug
			Tooltip, %tooltipMsg%, 500, 500
	}
}

getBit(input, bit)
{
	return (input >> bit) & 1
}

setBit(input, bit)
{
	return Input |= 1 << bit
}

unsetBit(input, bit)
{
	return Input &= ~(1 << bit)
}

toggleBit(input, bit)
{
	return Input ^= 1 << bit
}

getAddressFromOffsets(object, base, pointerType="Int64", offsets*)
{
	;SetFormat, Integer, Hex
	If offsets.MaxIndex() = 1
	{
		;MsgBox Derp
		pointer := object.Read(base + offsets[1], pointerType)
	}
	Else
	{
		For index, offset in offsets
		{
			If index = 1
				pointer := object.Read(base + offset, pointerType)
			Else If (offsets.MaxIndex() = A_Index)
				pointer += offset
			Else
				pointer := object.Read(pointer + offset, pointerType)
		}
	}
	return pointer
}

AOBScan(Object, hexString, offset1, offset2)
{
	;SetFormat, Integer, Hex
	pattern := Object.hexStringToPattern(hexString)
	addr := Object.modulePatternScan("DarkSoulsIII.exe", pattern*)
	addr := addr + Object.Read(addr + offset1, "Int") + offset2
	return Object.Read(addr, "Int64")
}
