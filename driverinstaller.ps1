#Download latest XML Repo from Github
Invoke-WebRequest -URI https://raw.githubusercontent.com/dannyplace/powershelldriverrepo/main/drivers.xml -OutFile $PSScriptRoot\drivers.xml
write-host "Downloading newest driverrepo" -ForegroundColor White -BackgroundColor Yellow

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

write-host "Drivers found for model: $GetModelBios" -ForegroundColor White -BackgroundColor Darkgreen

write-host "Drivers being downloaded from: $GetURL`:" -ForegroundColor White -BackgroundColor Yellow
Invoke-WebRequest -URI $GetURL -OutFile $DownloadFile

if ($GetHashXML -eq (Get-FileHash -Path $DownloadFile | Select-Object -ExpandProperty Hash -first 1 -OutVariable GetFileHash)) {
    write-host "Hash matches with XML. The file should be secure!" -ForegroundColor White -BackgroundColor Green

    Expand-Archive -Path $DownloadFile

    Get-ChildItem $matchmodel | ForEach-Object { $_.FullName }

    Get-ChildItem "$matchmodel" -Recurse -Filter "*.inf" | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }

}

else {
    write-host "Hash does NOT matche with the XML. File will be deleted! Refer to drivers.xml or Github." -ForegroundColor White -BackgroundColor Red
    Remove-Item -Path $DownloadFile
}
}
else { 
write-host "No drivers found for $GetModelBios. Please refer to drivers.xml." -ForegroundColor White -BackgroundColor Red
Exit
}
write-Output "Driver package Hash: $GetFileHash"
Write-Output "XML Hash (verwachte Hash): $GetHashXML"