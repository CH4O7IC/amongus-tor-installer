# Source:
# https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3

Write-Host ''
Write-Host '>>> Trying to locate your Steam-common folder
'
$pathList = (Get-ChildItem -Path C:\ -Filter "common" -Recurse -Directory -ErrorAction SilentlyContinue).Fullname
$steamPath = ($pathList -match "steamapps\\common")[0]
Write-Host 'Please confirm that this is your Steam-common folder:

-> ' $steamPath
Write-Host ''
Write-Host If this is the wrong folder please enter the full correct path below!

$valid = $true
do {
    Write-Host ''
    $customPath = Read-Host "Path (Enter to skip)"
    if (-not($customPath -eq '')) {
        $valid = $false
        if ((Test-Path $customPath\'Among Us')) {
            $steamPath = $customPath
            break
        }
        Write-Host $customPath
        Write-Host This path is not valid. Please try again
    }
} while (-not $valid)



$dirOld = "TheOtherRoles-vx.x.x"
Write-Host ">>> Cleaning previous Other Roles instances
"
if (Test-Path $steamPath\$dirOld) {
   Remove-Item -LiteralPath $steamPath\$dirOld -Force -Recurse
}
Write-Host "<<< DONE cleaning
"


Write-Host ">>> Copying Among Us installation
"
Copy-Item -Path $steamPath\'Among Us' -Destination $steamPath\$dirOld -Recurse
Write-Host "<<< DONE copying"


$repo = "Eisbison/TheOtherRoles"
$file = "TheOtherRoles.zip"
$releases = "https://api.github.com/repos/$repo/releases"
Write-Host '>>> Determining latest release'
$tag = (curl.exe -s $releases | ConvertFrom-Json)[0].tag_name
Write-Host ''
$latestTag = $tag
Write-Host 'Latest version found is ' $tag '. If you want another version please enter it below.'
Write-Host ''
$customTag = Read-Host "Version (Enter to skip)"
if (-not($customTag -eq '')) {
    if ($customTag -match 'v') {
        $tag = $customTag
    } else {
        $tag = 'v' + $customTag
    }
}



$downloaded = $false
do {
    $download = "https://github.com/$repo/releases/download/$tag/$file"
    $name = $file.Split(".")[0]
    $zip = "$name-$tag.zip"
    $dir = "$name-$tag"

    Rename-Item $steamPath\$dirOld $steamPath\$dir

    $dirOld = $dir

    Write-Host '>>> Dowloading version ' $tag ' from repository ' $repo
    Write-Host ''
    curl.exe -s -LO $download
    Write-Host "<<< DONE downloading
    "
    try {
        Write-Host '>>> Trying to unzip
        '
        Expand-Archive -Path .\$file -DestinationPath $steamPath\$dir
        $downloaded = $true
        Write-Host "DONE unzipping
        "
    } catch {
        $downloaded = $false
        Write-Host '<<< Unzipping failed!'
        Write-Host '----- Falling back to latest release -----'
        Write-Host ''
        Remove-Item -Path .\$file -Force
        $tag = $latestTag
    }
} while (-NOT $downloaded)


Write-Host ">>> Cleaning up zip files
"
Remove-Item -Path .\$file -Force
Remove-Item -LiteralPath $steamPath\'TheOtherRoles-vx.x.x' -Force -Recurse
Write-Host "<<< DONE cleaning
"
& $steamPath\$dir\'Among Us.exe'


Write-Host Do you want a desktop shortcut for your modded version?
$shct = Read-Host Hit enter for a shortcut, NO for none

if (-NOT ($shct -match 'NO')) {
    Write-Host ''
    Write-Host ">>> Creating shortcut
    "
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\$dir.lnk")
    $Shortcut.TargetPath = "$steamPath\$dir\Among Us.exe"
    $Shortcut.Save()
    Write-Host '<<< DONE creating Shortcut'
}



Write-Output '
*************************************************************************************
The setup is complete!
If you chose for a shortcut you will find it on your desktop.

Have fun!
*************************************************************************************
'
    
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
