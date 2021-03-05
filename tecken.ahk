; {Text} is needed for ahk not to convert æø to äö.
; I have no idea how to combine this with the function calls alt/shift yet.
AppsKey & ä::send {Text}æ 
AppsKey & ö::send {Text}ø
; uUŭŬ∪∩⊂⊆
;AppsKey & u::send % alt(shift("∪","∩"),shift("⊂","⊆"))
AppsKey & u::
{
    ; The above version has the bug that all paths are called.
    ; "Lazy" version, just to see if it's possible; Only calls shift once.
    s := Func("shift")
    send % alt(s.bind("∪","∩"),s.bind("⊂","⊆"))
    return
}


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

; Return different thing depending on the state of one of the buttons
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
        ; for now: If b can be run as a function reference, and returns a value, assume that that is what we wanted and return the value. 
        ; Otherwise assume b is a thing we want to return.
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
    RunState(whenUp,whenDown)
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

AppsKey & o::
{
/*
    f := Func("lul")
    x := isFunc(f)
    g := f.bind("a3")
    y := isFunc(g)
    z := "∪"
    try {
        a := %z%("trej")
        b := z.("u")
        c := z.Call("u")
        MsgBox %x%.%y%.%f%.%g%.%a%.%b%.%c%
    } catch e {
        MsgBox %e%
    }
    return
*/
    a := new ShiftExecutive
    MsgBox % a.RunState("upp","ner")
    MsgBox % a.IsDown
    return
}
