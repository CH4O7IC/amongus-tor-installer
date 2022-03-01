# Dieser Installer führt durch die Installation von der Other Roles-Modifikation für Among Us
# Dazu werden zu Beginn Systemvariablen auf höchster Ebene (Windows) hinzugefügt,
# weshalb für diesen Schritt eine Admin-Shell geöffnet wird.

# Nach dieser Einrichtung wird die Admin-Shell geschlossen und der Installer muss 
# neu gestartet werden, um die eigentliche Installation zu starten.

# Es ist möglich das Mod-Archiv über den Installer herunterladen zu lassen oder dies zuvor selbst zu tun.
# Der Installer wird den Nutzer durch diese Schritte führen.

# Nach der Installation werden temporäre Dateien, wie das zip-Archiv wieder entfernt, da sie nicht weiter benötigt werden.

# Es wird bei Bedarft auch eine Verknüpfung auf dem Desktop abgelegt.

# Nach der vollständigen Installation wird die modifizierte Among Us-Version gestartet.


# -----------------------------------------------------------------------------------------------------------------------------
# ------ Anfang Einrichtung Systemvariablen --------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------


# Function for adding Systempath-Variables

function Add-PathVar {
    param (
        $varName
    )

    $descVar = 'null'
    if ($varName -eq 'AmongUsDownloads') {
        $descVar = 'Ich benötige den Pfad zu einem Ordner, wo die heruntergeladene zip-Datei temporär gespeichert werden kann.
        '
    }
    if ($varName -eq 'SteamCommon') {
        $descVar = 'Ich benötige den vollständigen Pfad zu Deinem common-Steamordner (endet mit "\Steam\steamapps\common").
        '
    }

    if ([System.Environment]::GetEnvironmentVariable($varName, "Machine") -eq $null) {
        Write-Output $descVar
        $steamCommonPath = Read-Host -Prompt 'Bitte gib diesen Pfad nun *korrekt!* ein'
        [Environment]::SetEnvironmentVariable($varName, $steamCommonPath, "Machine")
        Write-Output '
        '
    }
    while (-NOT (Test-Path ([System.Environment]::GetEnvironmentVariable($varName, "Machine")))) {
        Write-Output 'Irgendetwas stimmt mit dem angegebenen Pfad nicht...
        '
        $steamCommonPath = Read-Host -Prompt 'Bitte gib den Pfad erneut ein und überprüfe ihn bitte gründlich auf Typos'
        [Environment]::SetEnvironmentVariable($varName, $steamCommonPath, "Machine") 
        Write-Output '
        '
    }
}




# Systemvariablen für einen Downloads-Ordner und zu dem Steam-Common-Ordner sind notwendig, damit nicht bei jeder neuen Installation die PATHS abgefragt werden müssen.

# Existieren besagte Variablen noch nicht, so wird einer Admin-Shell geöffnet, wo die Einrichtung stattfinden kann. (Systemvariablen können nicht über eine normale Shell erstellt werden)

# Existieren besagte Variablen bereits, wird dieser Schritt übersprungen

if (([System.Environment]::GetEnvironmentVariable('SteamCommon', "Machine") -eq $null) -or ([System.Environment]::GetEnvironmentVariable('AmongUsDownloads', "Machine") -eq $null)) {


    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        # Relaunch as an elevated process:
        Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
        exit     
    }
    Write-Output 'Hallo!

Ich bin der AmongUsModInstaller. Ich helfe Dir beim Installieren von Among Us Mods.

Da ich ein paar Änderungen an deinen Systemvariablen vornehmen muss, habe ich eine Adminshell geöffnet.

************************************************
INFO: Ich bin eigentlich auf die Steamversion von Among Us zugeschnitten.
Vielleicht klappt das Setup auch mit ähnlichen Pfaden für andere Plattformen...
Dies wurde allerdings nicht getestet.
************************************************ 
'

$agreementQuest = Read-Host 'Sollte Dir das nicht gefallen, antworte jetzt bitte mit "NO", um das Setup abzubrechen. 
Habe ich deine Zustimmung, kannst du irgendetwas eingeben oder auch einfach Enter drücken'
    if ($agreementQuest -eq 'NO') {
        Write-Output '
Das ist schade...
Ich wünsch Dir was!'
        Start-Sleep -s 7
        break
    }
    Write-Output '


'

    
    # Setup für zukünftige Sitzungen und Vermeidung der Notwendigkeit Änderungen am Sourcecode vorzunehmen
    # Hinzufügen von SteamCommon bzw. AmongUsDownloads zum PATH, sollte dies nicht bereits existent sein

    if ([System.Environment]::GetEnvironmentVariable('SteamCommon', "Machine") -eq $null) {
        Add-PathVar -varName 'SteamCommon'
    }
    if ([System.Environment]::GetEnvironmentVariable('AmongUsDownloads', "Machine") -eq $null) {
        Add-PathVar -varName 'AmongUsDownloads'
    }

    Write-Output 'Toll! Alle Systemvariablen wurden gesetzt. Bitte starte den Installer gleich wieder neu, damit wir fortfahren können.'
    Start-Sleep -s 10

    break

    # Der Installer wird nun beendet und muss neu gestartet werden, um die eigentliche Installation durchzuführen
}



# -----------------------------------------------------------------------------------------------------------------------------
# ------ Ende Einrichtung Systemvariablen --------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------
# ------ Anfang Installation ---------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------



# Abfragen der erstellten Systemvariablen

$steamPath = [System.Environment]::GetEnvironmentVariable("SteamCommon", "Machine") 
$downloadPath = [System.Environment]::GetEnvironmentVariable("AmongUsDownloads", "Machine")

Write-Output '
Hello again!
Dann wollen wir mal mit der eigentlichen Installation beginnen!
'

# Für die Installation reicht die Eingabe der Other Roles-Version nach GitHub-Nummerierung (bspw. 3.1.2 oder 2.0.1)

$version = Read-Host 'Bitte verrate mir, welche Version der (OtherRoles) Mod du installieren möchtest (z.B. "3.1.2")'

# Die Version wird auch benötigt, wenn das zip-Archiv heruntergeladen wurde, da die Ordnernamen je nach Version einen angepassten Namen erhalten

Write-Output '
Nun möchte ich etwas wissen: Hast du das zip-Archiv,welches die enthält Mods bereits heruntergeladen?'
$webCheck = Read-Host -Prompt '
Sollte dies der Fall sein, antworte bitte mit "YES". Sonst kannst du einfach "Enter" drücken'

# Wenn das Archiv heruntergeladen wurde, heißt es im default-case "TheOtherRoles.zip"
# Wurde dieses umbenannt, so ist der Nutzer aufgefordert dies anzugeben.

if ($webCheck -eq 'YES') {
    Write-Output '
Du hast also das zip-Archiv bereits heruntergeladen.
Dann gehe ich davon aus, dass das Archiv "TheOtherRoles.zip" heißt.'
    $zipFile = 'TheOtherRoles.zip'

    $zipQuest = Read-Host '
Sollte dies nicht der Fall sein, verrate mir bitte, wie die Datei heißt (inklusive .zip-Endung). 
Sonst drücke bitte einfach "Enter"'
    if (-NOT ($zipQuest -eq '')) {
        $zipFile = $zipQuest
    }
    
    $zipPath = "$downloadPath\$zipFile"
}
if (-NOT ($webCheck -eq 'YES')) {
    Write-Output '
Du hast das Archiv also noch nicht heruntergeladen.
Dann werde ich das für dich übernehmen.
    '

    $zipFile = 'TheOtherRoles.zip'

    $webSource = 'https://github.com/Eisbison/TheOtherRoles/releases/download/v'+$version+'/TheOtherRoles.zip'
    
    $zipPath = "$downloadPath\$zipFile"
    Write-Output '>>>>>> Cleaning zip-Files
        '

    if (Test-Path -Path $zipPath) {
        Remove-Item $zipPath
    }
    Write-Output '<<<<<< DONE cleaning zip-Files
    
>>>>>> Downloading
    '
    $check = $true
    do {
        try {
#            Invoke-WebRequest -Uri $webSource -OutFile $zipPath
            Invoke-WebRequest -Uri $webSource -OutFile $zipPath
            $check = $true
        } catch {
            $check = $false
            Write-Output 'Ich kann die angegebene Version nicht finden / herunterladen.
            Bitte überprüfe ob
            ' + $webSource + '
            der richtige Link zur Datei ist.
            '
            $webSource = Read-Host 'Wenn ja dann versuche füge ihn bitte nochmal ein oder korrigiere den Link bitte!'
            Write-Output '
            '
        }
    } while (-NOT $check)
    Write-Output '<<<<<< DONE downloading
    '
}

$versionUnder = $version -replace '\.', '_'

# Name für kopierten Ordner
Write-Output 'Damit Du Among Us auch weiterhin ohne Mods spielen kannst, werde ich eine Kopie des Among Us Ordners anfertigen.
Hier wird dann auch das zip-Archiv entpackt.
Du findest den Ordner unter dem Namen TheOtherRoles_<version> in deinem steamapps/common-Ordner.
'

$newFolder = 'TheOtherRoles_'+$versionUnder

Write-Output '>>>>>> Cleaning AU Mod installations from simmilar named versions
'
if (Test-Path $steamPath\$newFolder) {
    Remove-Item -LiteralPath $steamPath\$newFolder -Force -Recurse
}
Write-Output '<<<<<< DONE cleaning
'

Write-Output '>>>>>> Copying from plain AU directory
'

Copy-Item -Path $steamPath\'Among Us' -Destination $steamPath\$newFolder -Recurse

Write-Output '<<<<<< DONE copying
'

# Entpacken der zip-Archivs in den kopierten Among Us Ordner
if (-NOT (Test-Path $zipPath)) {
    Write-Output 'Überprüfe bitte, ob sich die zip-Datei wirklich im bei den Variablen angegebenen Download-Ordner befindet.'
    break
}

Write-Output '>>>>>> Unzipping zip-File to copied directory
'
Expand-Archive -LiteralPath $zipPath -DestinationPath $steamPath\$newFolder
Write-Output '<<<<<< DONE unzipping

>>>>>> Cleaning zip-Files
'

# Entfernen des Archivs, um Fehler bei gleicher Benennung mehrerer Dateien zu vermeiden
Remove-Item $zipPath
Write-Output '<<<<<< DONE cleaning
'

# Hinzufügen einer Verknüpfung auf den Desktop
$shctQuest = Read-Host -Prompt 'Möchtest Du eine Verknüpfung erstellt bekommen?
Wenn ja, dann drücke einfach Enter, wenn nicht, dann Antworte bitte mit "NO"'
if (-NOT ($shctQuest -eq 'NO')) {
    Write-Output '
>>>>>> Creating Shortcut
        '
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\$newFolder.lnk")
    $Shortcut.TargetPath = "$steamPath\$newFolder\Among Us.exe"
    $Shortcut.Save()
    Write-Output '<<<<<< DONE creating Shortcut'
}




# Starten der gemoddeten Among Us Version
& $steamPath\$newFolder\'Among Us.exe'

Write-Output '
*************************************************************************************
Das Setup ist abgeschlossen und das Spiel wird gestartet.
Wenn Du Dich für eine Verknüpfung entschieden hast, findest du sie auf Deinem Desktop.

Viel Spaß!
*************************************************************************************'
    
# -----------------------------------------------------------------------------------------------------------------------------
# ------ Ende Installation ---------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------

# SIG # Begin signature block
# MIIFjQYJKoZIhvcNAQcCoIIFfjCCBXoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOtnXABCCvocSSfQkTTDua7B7
# hsSgggMnMIIDIzCCAgugAwIBAgIQd4BtLBKl0KpJS6Xdw0fJ2zANBgkqhkiG9w0B
# AQsFADAbMRkwFwYDVQQDDBBDSDRPN0lDIChHaXRodWIpMB4XDTIxMDQxNTE4MDg1
# MloXDTIyMDQxNTE4Mjg1MlowGzEZMBcGA1UEAwwQQ0g0TzdJQyAoR2l0aHViKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKUEOHYGjaHnSXhYdtf1SpGB
# cnQE/brOjxkwjv32mDndOrR9BhLt6uTa0vooSzNO69XpaulVrVAKPcj2Vhzd2nvp
# UUZLTuXNPumvCPVwSLFVgYL5gtw2XdG55RplM3ijmhj30SZjMJqfz1fTNit8xgqq
# Jxfh6uyfNScVueS2FheFX+1hc5heQ1KT8hrPCki9QSS8Q4D2QIkGaHCqJIifkr6Y
# gYdKr1Hrp31uCgq40nitK8y4eGKjFQ3bt5t5b+fV8M8tHbzxHm4JG+Ref4hiYeXz
# 62dRv7qeKiQjk+LNxpuWQyfgNNBgLuOnN8mzrAJdiflKdf1fsPgl6OF/s5oUwkkC
# AwEAAaNjMGEwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsG
# A1UdEQQUMBKCEENINE83SUMgKEdpdGh1YikwHQYDVR0OBBYEFGD1CMEE9Rugl1J1
# +BUltsINt5C0MA0GCSqGSIb3DQEBCwUAA4IBAQCRraVjTipAUCruQW/+zzL6a/ch
# D32QZS3wwGHcFbcUj9KoUho55ZbJ/ovUh4e3jtpthZPu0ngGdpFWiTetUkQ+3X4W
# 7+/sZkY6OM7ZQzgtBKtF2MQA+2NWAFbZb9mwphFBp5vpjufrgO05Gx0hYyYd8ISu
# RWj4j7fI5rmROGZTI3E9XmYAkIIaTj/EfCJECHsW2lc2kKrxOZwhn3oWXzezil3o
# ueqfi8woetLKKyTnCboVEg2CLZogJVND8XTPRD12Vrdj4ImaRgN/iO16nQwJo/rq
# vwC4Klr1yoceGHcyw8MWVd7N35fYEmAKP//qvtX76z+h3/CYiyPrviHwe7LvMYIB
# 0DCCAcwCAQEwLzAbMRkwFwYDVQQDDBBDSDRPN0lDIChHaXRodWIpAhB3gG0sEqXQ
# qklLpd3DR8nbMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAA
# MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR2sjM/ItqVCi68+rorC/Gb/cek2zAN
# BgkqhkiG9w0BAQEFAASCAQB0atvZQffSn6W/vwzL8fyQJEYNUUBY3Ll43aV9p4MM
# +FSwJKgmiJqTi2zSqlAFUj0Iv8oJKhWG0FV3aBboXEC7vlSKS2cD3bPpKAVaHqHV
# sCwC4NXDAhWuP2K4BcH2WnwzakpUnaIB1p4ftlbw9fQ9HyravdfkbLkJftMPh5l0
# IN3UuT73HBC6l/d4V7ihTmjO76Jb7Ruuv60ls3NtDAnMkPsKNb/qdp4AEFdAlFZR
# ZStDv6/TiP9NMqF2dpOf9hcpfKuxP7bzJGu2DCRZZ+1VUKPZg7OIYLv69sEsGeUj
# 2HBrU6hHpdkhiK160eW1hwsVHxGp43/Sw0meZVPvkKGR
# SIG # End signature block
