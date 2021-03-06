##Miner Path Information
if($nvidia.ewbf.path2){$Path = "$($nvidia.ewbf.path2)"}
else{$Path = "None"}
if($nvidia.ewbf.uri){$Uri = "$($nvidia.ewbf.uri)"}
else{$Uri = "None"}
if($nvidia.ewbf.minername){$MinerName = "$($nvidia.ewbf.minername)"}
else{$MinerName = "None"}
if($Platform -eq "linux"){$Build = "Tar"}
elseif($Platform -eq "windows"){$Build = "Zip"}

$ConfigType = "NVIDIA2"

##Parse -GPUDevices
if($NVIDIADevices2 -ne ''){$GPUDevices2 = $NVIDIADevices2}
if($GPUDevices2 -ne '')
 {
  $GPUEDevices2 = $GPUDevices2 -replace ',',' '
  $Devices = $GPUEDevices2
 }

##Get Configuration File
$GetConfig = "$dir\config\miners\ewbf.json"
try{$Config = Get-Content $GetConfig | ConvertFrom-Json}
catch{Write-Warning "Warning: No config found at $GetConfig"}

##Export would be /path/to/[SWARMVERSION]/build/export##
$ExportDir = Join-Path $dir "build\export"

##Prestart actions before miner launch
$Prestart = @()
$PreStart += "export LD_LIBRARY_PATH=$ExportDir"
$Config.$ConfigType.prestart | foreach {$Prestart += "$($_)"}

##Build Miner Settings
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
      DeviceCall = "ewbf"
      Arguments = "--api 0.0.0.0:42001 --server $($_.Host) --port $($_.Port) --user $($_.User2) --pass $($AlgoPools.$_.Pass2)$($Diff) $($Config.$ConfigType.commands.$($_.Algorithm))"
      HashRates = [PSCustomObject]@{$($_.Algorithm) = $($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)}
      Quote = if($($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)){$($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)*($_.Price)}else{0}
      PowerX = [PSCustomObject]@{$($_.Algorithm) = if($Watts.$($_.Algorithm)."$($ConfigType)_Watts"){$Watts.$($_.Algorithm)."$($ConfigType)_Watts"}elseif($Watts.default."$($ConfigType)_Watts"){$Watts.default."$($ConfigType)_Watts"}else{0}}
      ocpower = if($Config.$ConfigType.oc.$($_.Algorithm).power){$Config.$ConfigType.oc.$($_.Algorithm).power}else{$OC."default_$($ConfigType)".Power}
      occore = if($Config.$ConfigType.oc.$($_.Algorithm).core){$Config.$ConfigType.oc.$($_.Algorithm).core}else{$OC."default_$($ConfigType)".core}
      ocmem = if($Config.$ConfigType.oc.$($_.Algorithm).memory){$Config.$ConfigType.oc.$($_.Algorithm).memory}else{$OC."default_$($ConfigType)".memory}
      MinerPool = "$($_.Name)"
      FullName = "$($_.Mining)"
      API = "EWBF"
      Port = 42001
      URI = $Uri
      BUILD = $Build
      Algo = "$($_.Algorithm)"
       }
     }
   }
 }
}