#Check device modelnumber. This will be used to check the device modelnumber against the XML File.
$GetModelBIOS = Get-CimInstance -ClassName Win32_ComputerSystem | ForEach-Object { $_.model }

<#
Define XML Location. The best is not to mess with this. create te drivers.xml in the folder where your psscript is stored.

$XMLFile = Set XML Location
$XMLConfig = Read XML Content
#>
$XMLFile = "$PSScriptRoot\drivers.xml"
$XMLConfig = [system.xml.xmldocument](Get-Content $XMLFile)

#Define where to download the drivers.zip file
$DownloadFile = "C:\Temp\drivers.zip"

<#
$GetURL = Read XML File and extract the URL where to download the drivers.
$GetHashXML = Read XML File and extract the Hash file that is stored in the XML. This must match the Hash from the downloaded file.
$MatchModel = Read XML File and extract the model.
#>
$GetURL = $XMLConfig.drivers.driverlist | Where {$_.model -eq "$GetModelBios"} | ForEach-Object { $_.driverurl }
$GetHashXML = $XMLConfig.drivers.driverlist | Where {$_.model -eq "$GetModelBios"} | ForEach-Object { $_.hash }
$MatchModel = $XMLConfig.drivers.driverlist | Where {$_.model -eq "$GetModelBios"} | ForEach-Object { $_.driverpath }

# Check driverpath.
$DriverPath = Test-Path -Path "C:\Temp\drivers.zip"

if ($GetURL) {

write-host "Drivers gevonden voor $GetModelBios`:" -ForegroundColor White -BackgroundColor Darkgreen

write-host "Drivers worden gedownload van de gekozen repository via: $GetURL`:" -ForegroundColor White -BackgroundColor Yellow
Invoke-WebRequest -URI $GetURL -OutFile $DownloadFile

Write-Output "Hash van XML (verwachte Hash): $GetHashXML"
write-output "Hash van gedownload bestand: $GetFileHash"


if ($GetHashXML -eq (Get-FileHash -Path $DownloadFile | Select-Object -ExpandProperty Hash -first 1)) {
    write-host "Hash komt overeen met XML. Het bestand is veilig!" -ForegroundColor White -BackgroundColor Green
}

else {
    write-host "Hash komt NIET overeen met XML. Bestand zal worden verwijderd! Raadpleeg de drivers.xml" -ForegroundColor White -BackgroundColor Red
    Remove-Item -Path $DownloadFile
}

# get-ChildItem $matchmodel | % { $_.FullName }

# Get-ChildItem "$matchmodel" -Recurse -Filter "*.inf" | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }
}
else { 
write-host "Geen drivers gevonden voor $GetModelBios. Gelieve de drivers.xml raadplegen." -ForegroundColor White -BackgroundColor Red
Exit
}