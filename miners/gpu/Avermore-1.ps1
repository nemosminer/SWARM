##Miner Path Information
if($amd.avermore.path1){$Path = "$($amd.avermore.path1)"}
else{$Path = "None"}
if($amd.avermore.uri){$Uri = "$($amd.avermore.uri)"}
else{$Uri = "None"}
if($amd.avermore.minername){$MinerName = "$($amd.avermore.minername)"}
else{$MinerName = "None"}
if($Platform -eq "linux"){$Build = "Tar"}
elseif($Platform -eq "windows"){$Build = "Zip"}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$ConfigType = "AMD1"

##Parse -GPUDevices
if($AMDDevices1 -ne ''){$Devices = $AMDDevices1}

##Get Configuration File
$GetConfig = "$dir\config\miners\avermore.json"
try{$Config = Get-Content $GetConfig | ConvertFrom-Json}
catch{Write-Warning "Warning: No config found at $GetConfig"}

##Export would be /path/to/[SWARMVERSION]/build/export##
$ExportDir = Join-Path $dir "build\export"

##Prestart actions before miner launch
$Prestart = @()
$PreStart += "export LD_LIBRARY_PATH=$ExportDir"
$Config.$ConfigType.prestart | foreach {$Prestart += "$($_)"}

if($CoinAlgo -eq $null)
{
  $Config.$ConfigType.commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  $MinerAlgo = $_
  $AlgoPools | Where Symbol -eq $MinerAlgo | foreach {
  if($Algorithm -eq "$($_.Algorithm)")
  {
    if($Config.$ConfigType.difficulty.$($_.Algorithm)){$Diff=",d=$($Config.$ConfigType.difficulty.$($_.Algorithm))"}
    [PSCustomObject]@{
    Delay = $Config.$ConfigType.delay
    Symbol = "$($_.Algorithm)"
    MinerName = $MinerName
    Prestart = $PreStart
    Type = $ConfigType
    Path = $Path
    Devices = $Devices
    DeviceCall = "sgminer-gm"
    Arguments = "--gpu-platform $AMDPlatform --api-listen --api-port 4028 -k $($Config.$ConfigType.naming.$($_.Algorithm)) -o stratum+tcp://$($_.Host):$($_.Port) -u $($_.User1) -p $($_.Pass1)$($Diff) -T $($Config.$ConfigType.commands.$($_.Algorithm))"
    HashRates = [PSCustomObject]@{$($_.Algorithm) = $($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)}
    Quote = if($($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)){$($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)*($_.Price)}else{0}
    PowerX = [PSCustomObject]@{$($_.Algorithm) = if($Watts.$($_.Algorithm)."$($ConfigType)_Watts"){$Watts.$($_.Algorithm)."$($ConfigType)_Watts"}elseif($Watts.default."$($ConfigType)_Watts"){$Watts.default."$($ConfigType)_Watts"}else{0}}
    ocdpm = if($Config.$ConfigType.oc.$($_.Algorithm).dpm){$Config.$ConfigType.oc.$($_.Algorithm).dpm}else{$OC."default_$($ConfigType)".dpm}
    ocv = if($Config.$ConfigType.oc.$($_.Algorithm).v){$Config.$ConfigType.oc.$($_.Algorithm).v}else{$OC."default_$($ConfigType)".v}
    occore = if($Config.$ConfigType.oc.$($_.Algorithm).core){$Config.$ConfigType.oc.$($_.Algorithm).core}else{$OC."default_$($ConfigType)".core}
    ocmem = if($Config.$ConfigType.oc.$($_.Algorithm).mem){$Config.$ConfigType.oc.$($_.Algorithm).mem}else{$OC."default_$($ConfigType)".memory}
    ocmdpm = if($Config.$ConfigType.oc.$($_.Algorithm).mdpm){$Config.$ConfigType.oc.$($_.Algorithm).mdpm}else{$OC."default_$($ConfigType)".mdpm}
    ocfans = if($Config.$ConfigType.oc.$($_.Algorithm).fans){$Config.$ConfigType.oc.$($_.Algorithm).fans}else{$OC."default_$($ConfigType)".fans}
    MinerPool = "$($_.Name)"
    FullName = "$($_.Mining)"
    Port = 4028
    API = "sgminer-gm"
    URI = $Uri
    BUILD = $Build
    Algo = "$($_.Algorithm)"
     }
    }
   }
  }
 }
