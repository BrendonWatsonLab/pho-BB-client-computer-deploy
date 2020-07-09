ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
REM SETLOCAL ENABLEDELAYEDEXPANSION is required to SET variables in the FOR loop using the double ! notation. See https://stackoverflow.com/questions/13805187/how-to-set-a-variable-inside-a-loop-for-f

echo "Enabling NETBIOS over TCP:"
REM https://social.technet.microsoft.com/Forums/en-US/4658180d-f4c0-4c7b-ab5d-13db08703252/how-to-set-netbios-over-tcpip-enabled-or-disabled-from-command-line-?forum=winserverDS
REM wmic nicconfig get caption,index,TcpipNetbiosOptions
wmic nicconfig where index=1 call SetTcpipNetbios 1


echo "Opening Firewall Ports..."

netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=No  
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

REM TCP Ports:
echo "TCP Ports..."

REM THESE LOOPS ARE EXTREMELY BROKEN! They add the ports 135, 274, and 413
REM for /l %%x in (135, 139, 445) do (
REM     set PORT=%%x
REM     REM echo Opening port !PORT!...
REM     set RULE_NAME="Open NetBIOS TCP Port !PORT!"
REM     REM echo Proposed Rule: !RULE_NAME!
REM     netsh advfirewall firewall show rule name=!RULE_NAME! >nul
REM     if not ERRORLEVEL 1 (
REM         echo Rule !RULE_NAME! already exists. Skipping.
REM     ) else (
REM         echo Rule !RULE_NAME! does not exist. Creating...
REM         netsh advfirewall firewall add rule name=!RULE_NAME! dir=in action=allow protocol=TCP localport=!PORT!
REM         netsh advfirewall firewall add rule name=!RULE_NAME! dir=out action=allow protocol=TCP localport=!PORT!
REM     )
REM )

set PORT=135
set RULE_NAME="Open NetBIOS TCP Port !PORT!"
netsh advfirewall firewall show rule name=!RULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo Rule !RULE_NAME! already exists. Skipping.
) else (
    echo Rule !RULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!RULE_NAME! dir=in action=allow protocol=TCP localport=!PORT!
    netsh advfirewall firewall add rule name=!RULE_NAME! dir=out action=allow protocol=TCP localport=!PORT!
)

set PORT=139
set RULE_NAME="Open NetBIOS TCP Port !PORT!"
netsh advfirewall firewall show rule name=!RULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo Rule !RULE_NAME! already exists. Skipping.
) else (
    echo Rule !RULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!RULE_NAME! dir=in action=allow protocol=TCP localport=!PORT!
    netsh advfirewall firewall add rule name=!RULE_NAME! dir=out action=allow protocol=TCP localport=!PORT!
)

set PORT=445
set RULE_NAME="Open NetBIOS TCP Port !PORT!"
netsh advfirewall firewall show rule name=!RULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo Rule !RULE_NAME! already exists. Skipping.
) else (
    echo Rule !RULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!RULE_NAME! dir=in action=allow protocol=TCP localport=!PORT!
    netsh advfirewall firewall add rule name=!RULE_NAME! dir=out action=allow protocol=TCP localport=!PORT!
)


set udpPORT=137
set udpRULE_NAME="Open NetBIOS UDP Port !udpPORT!"
echo Proposed Rule: !udpRULE_NAME!
netsh advfirewall firewall show rule name=!udpRULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo Rule !udpRULE_NAME! already exists. Skipping.
) else (
    echo Rule !udpRULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!udpRULE_NAME! dir=in action=allow protocol=UDP localport=!udpPORT!
    netsh advfirewall firewall add rule name=!udpRULE_NAME! dir=out action=allow protocol=UDP localport=!udpPORT!
)

set udpPORT=138
set udpRULE_NAME="Open NetBIOS UDP Port !udpPORT!"
echo Proposed Rule: !udpRULE_NAME!
netsh advfirewall firewall show rule name=!udpRULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo Rule !udpRULE_NAME! already exists. Skipping.
) else (
    echo Rule !udpRULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!udpRULE_NAME! dir=in action=allow protocol=UDP localport=!udpPORT!
    netsh advfirewall firewall add rule name=!udpRULE_NAME! dir=out action=allow protocol=UDP localport=!udpPORT!
)


REM PING Ports:
set RULE_NAME="ICMP Allow incoming V4 echo request"
netsh advfirewall firewall show rule name=!RULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo Rule !RULE_NAME! already exists. Skipping.
) else (
    echo Rule !RULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!RULE_NAME! protocol=icmpv4:8,any dir=in action=allow
)

set RULE_NAME="ICMP Allow incoming V6 echo request"
netsh advfirewall firewall show rule name=!RULE_NAME! >nul
if not ERRORLEVEL 1 (
    echo Rule !RULE_NAME! already exists. Skipping.
) else (
    echo Rule !RULE_NAME! does not exist. Creating...
    netsh advfirewall firewall add rule name=!RULE_NAME! protocol=icmpv6:8,any dir=in action=allow
)



REM REM Windows Remote Management Ports:
REM set PORT=5985
REM set RULE_NAME="Windows Remote Management (HTTP-In)"
REM netsh advfirewall firewall show rule name=!RULE_NAME! >nul
REM if not ERRORLEVEL 1 (
REM     echo Rule !RULE_NAME! already exists. Skipping.
REM ) else (
REM     echo Rule !RULE_NAME! does not exist. Creating...
REM     netsh advfirewall firewall add rule name=!RULE_NAME! dir=in action=allow protocol=TCP localport=!PORT!
REM     netsh advfirewall firewall add rule name=!RULE_NAME! dir=out action=allow protocol=TCP localport=!PORT!
REM )

REM set PORT=5985
REM set RULE_NAME="Windows Remote Management - Compatibility Mode (HTTP-In)"
REM netsh advfirewall firewall show rule name=!RULE_NAME! >nul
REM if not ERRORLEVEL 1 (
REM     echo Rule !RULE_NAME! already exists. Skipping.
REM ) else (
REM     echo Rule !RULE_NAME! does not exist. Creating...
REM     netsh advfirewall firewall add rule name=!RULE_NAME! dir=in action=allow protocol=TCP localport=!PORT!
REM     netsh advfirewall firewall add rule name=!RULE_NAME! dir=out action=allow protocol=TCP localport=!PORT!
REM )




echo "done."