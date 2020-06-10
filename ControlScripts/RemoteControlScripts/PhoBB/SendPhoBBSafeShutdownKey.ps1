# Copied from https://stackoverflow.com/questions/17849522/how-to-perform-keystroke-inside-powershell

# Sends a keypress event to the phoBehavioralBoxLabjackController software
function Send-PhoBB-Key()
{
    Param($key_letter)
    $wshell = New-Object -ComObject wscript.shell;
    $wshell.AppActivate('phoBehavioralBoxLabjackController')
    Sleep 1
    $wshell.SendKeys($key_letter)
    
}

function Send-PhoBB-Key-Quit()
{
    Send-PhoBB-Key -key_letter 'q'    
}



