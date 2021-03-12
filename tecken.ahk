; {Text} is needed for ahk not to convert æø to äö.
; I have no idea how to combine this with the function calls alt/shift yet.
AppsKey & ä::send {Text}æ 
AppsKey & ö::send {Text}ø
; uUŭŬ∪∩⊂⊆
AppsKey & u::send % alt(shift("∪","∩"),shift("⊂","⊆"))
/*
    ; The above version has the bug that all paths are called.
    ; This is a "Lazy" version, just to see if it's possible; Only calls shift once.
    ; It's wordy enough not to use unless I send in functions rather than text to be evaluated.
AppsKey & u::
{
    s := Func("shift")
    send % alt(s.bind("∪","∩"),s.bind("⊂","⊆"))
    return
}
*/


; eEéÉ∃∄
AppsKey & e::send % shift("∃","∄")
; iI  ∈∉
AppsKey & i::send % shift("∈","∉")
; aAáÁ∀
AppsKey & a::send ∀
; =+  ≈∓
AppsKey & =::send % shift("≈","∓")


lul(x,y){
    MsgBox %x%.%y%
    return "s"
}

; "paste without newline" on menu+v, actually modify clipboard newlines on ctrl+menu+v
AppsKey & v:: 
{
    ; replaceClip := Func("RegexReplace").Bind(Clipboard,"[\r\n]+")
    ; nonl := shift(replaceClip.bind(" "), replaceClip.bind(", "))
    nonl :=  RegexReplace(Clipboard,"[\r\n]+",shift(" ",", "))
    GetKeyState, l, LCtrl
    GetKeyState, r, RCtrl
    if (l="D" || r="D"){
        Clipboard=
        Clipboard:=nonl
        ClipWait
    }
    else
        ; sendinput quicker than send
        sendinput %nonl%
}

; Return different thing depending on whether on of the two buttons are down
; whenUp/whenDown can be a string or a function(reference)
state2(whenUp,whenDown,lbt,rbt){
    GetKeyState, l, %lbt%
    GetKeyState, r, %rbt%
    ; does NOT catch unicode chars
    ;if a not in integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space,time
    ;    Msgbox "u"
    ; THis does NOT recognize bound funcs. WTF.
    ; x := IsFunc(a)
    ; y := IsFunc(b)
    ; Debug
    ; MsgBox %a%.%ar%.%b%.%br%.%lbt%
    
    if (l="D" || r="D"){
        ; for now: If whenDown can be run as a function reference, and returns a value, assume that that is what we wanted and return the value. 
        ; Otherwise assume whenDown is a thing we want to return.
        downVal := %whenDown%()
        return downVal?downVal:whenDown
    }
    else{
        upVal := %whenUp%()
        return upVal?upVal:whenUp
    }
}

; unshifted shifted
shift(a,b) {
    return state2(a,b,"RShift","LShift")
}

alt(a,b) {
    return state2(a,b,"LAlt","RAlt")
}

altGr(a,b) {
    ; Maybe create a state1 for this
    return state2(a,b,"RAlt","RAlt")
}

ctl(a,b) {
    return state2(a,b,"LCtrl","RCtrl")
}


class StateExecutive {
    stateButtons := []
    choose(whenUp,whenDown)
    {
        for key, val in this.stateButtons
        {
            GetKeyState, st, %val%
            if (st="D") {
                downVal := %whenDown%()
                return downVal?downVal:whenDown
            }
        }
        upVal := %whenUp%()
        return upVal?upVal:whenUp
    }
    IsDown[]
    {
        get {
            for key, val in this.stateButtons
            {
                GetKeyState, st, %val%
                if (st="D") {
                    return 1
                }
            }
            return 0
        }
    }
}

class ShiftExecutive extends StateExecutive {
    stateButtons := ["LShift","RShift"]
}

class CtrlExecutive extends StateExecutive {
    stateButtons := ["LCtrl","RCtrl"]
}

; Export a table in SQL Developer while hovering over its name and having the export file name in the clipboard
AppsKey & x::
{
    ;a := new ShiftExecutive
    ;MsgBox % a.choose("upp","ner")
    ;MsgBox % a.IsDown
    ;send {AppsKey}
    send {Click, Right}
    sleep 100
    send !x ; choose export
    WinWaitActive,Export Wizard - Steg 1 av 3,,2
    if ErrorLevel
        return
    send !e ; do not export definition
    send !i{Tab} ; get to the name field
    ;remove the export.sql part of the name
    send {Backspace}{Backspace}{Backspace}{Backspace}{Backspace}{Backspace}{Backspace}{Backspace}{Backspace}{Backspace} 
    send ^v ; paste whatever is in the clipboard
    send !n ; go to next window or bail out
    WinWaitActive,Export Wizard - Steg 2 av 3,,2
    if ErrorLevel
        return
    send !n ; go to next window or bail out
    WinWaitActive,Export Wizard - Steg 3 av 3,,2
    if ErrorLevel
        return
    send !s ; save
    return
}
