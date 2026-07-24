#Requires AutoHotkey v2.0

#HotIf WinActive("ahk_exe ghostty.exe") && (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))

*c::Send "^+c"
*v::Send "^+v"

#HotIf

*Tab::
{
    if GetKeyState("LWin", "P") || GetKeyState("RWin", "P")
    {
        if !GetKeyState("Alt")
            Send "{Alt Down}{Tab}"
        else
            Send "{Tab}"
    }
    else
    {
        Send "{Blind}{Tab}"
    }
}

*LWin::
{
    Send "{Blind}{LCtrl DownR}"
}

*LWin up::
{
    Send "{Blind}{LCtrl Up}"

    if GetKeyState("Alt")
        Send "{Alt Up}"

    if (A_PriorKey = "LWin")
        SendEvent "{vk1D}"
}

*RWin::
{
    Send "{Blind}{RCtrl DownR}"
}

*RWin up::
{
    Send "{Blind}{RCtrl Up}"

    if GetKeyState("Alt")
        Send "{Alt Up}"

    if (A_PriorKey = "RWin")
        SendEvent "{vk1C}"
}


WheelUp::Send "{WheelDown}"
WheelDown::Send "{WheelUp}"
