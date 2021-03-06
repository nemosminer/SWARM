
$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName

 $starpool_Request = [PSCustomObject]@{} 
 
  if($Poolname -eq $Name)
   {
 try {
     $starpool_Request = Invoke-RestMethod "https://www.starpool.biz/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "SWARM contacted ($Name) for a failed API check. " 
     return 
 }
 
 if (($starpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "SWARM contacted ($Name) but ($Name) Pool API had issues. " 
     return 
 } 
  
$starpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name |  Where-Object {$Naming.$($starpool_Request.$_.name)} | ForEach-Object {

    $starpool_Algorithm = Get-Algorithm $starpool_Request.$_.name
    $starpool_Host = "$_.starpool.biz"
    $starpool_Port = $starpool_Request.$_.port
    $Divisor = (1000000*$starpool_Request.$_.mbtc_mh_factor)

    if($Algorithm -eq $starpool_Algorithm)
     {
        if($Stat_Algo -ne "Day"){$Stat = Set-Stat -Name "$($Name)_$($starpool_Algorithm)_profit" -Value ([Double]$starpool_Request.$_.estimate_current/$Divisor*(1-($starpool_Request.$_.fees/100)))}
        else{$Stat = Set-Stat -Name "$($Name)_$($starpool_Algorithm)_profit" -Value ([Double]$starpool_Request.$_.estimate_last24h/$Divisor *(1-($starpool_Request.$_.fees/100)))}
   

       if($Wallet)
	   {
        If($AltWallet1 -ne ''){if($AltPassword1 -eq "DASH" -or $AltPassword1 -eq "LTC" -or $AltPassword1 -eq "CANN" -or $AltPassword1 -eq "DGB"){$SWallet1 = $AltWallet1}}
        else{$Swallet1 = $Wallet1}
        If($AltWallet2 -ne ''){if($AltPassword2 -eq "DASH" -or $AltPassword2 -eq "LTC" -or $AltPassword2 -eq "CANN" -or $AltPassword2 -eq "DGB"){$SWallet2 = $AltWallet2}}
        else{$Swallet2 = $Wallet2}
        If($AltWallet3 -ne ''){if($AltPassword3 -eq "DASH" -or $AltPassword3 -eq "LTC" -or $AltPassword3 -eq "CANN" -or $AltPassword3 -eq "DGB"){$SWallet2 = $AltWallet3}}
        else{$Swallet3 = $Wallet3}
        If($AltPassword1 -ne ''){if($AltPassword1 -eq "DASH" -or $AltPassword1 -eq "LTC" -or $AltPassword1 -eq "CANN" -or $AltPassword1 -eq "DGB"){$SPass1 = $AltPassword1}}
        else{$Spass1 = $Passwordcurrency1}
        If($AltPassword2 -ne ''){if($AltPassword2 -eq "DASH" -or $AltPassword2 -eq "LTC" -or $AltPassword2 -eq "CANN" -or $AltPassword2 -eq "DGB"){$SPass2 = $AltPassword2}}
        else{$Spass2 = $Passwordcurrency2}
        If($AltPassword3 -ne ''){if($AltPassword3 -eq "DASH" -or $AltPassword3 -eq "LTC" -or $AltPassword3 -eq "CANN" -or $AltPassword3 -eq "DGB"){$SPass3 = $AltPassword3}}
        else{$Spass3 = $Passwordcurrency3}    
        [PSCustomObject]@{
            Coin = "No"
            Symbol = $starpool_Algorithm
            Mining = $starpool_Algorithm
            Algorithm = $starpool_Algorithm
            Price = if($Stat_Algo -eq "Day"){$Stat.Live}else{$Stat.$Stat_Algo}
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $starpool_Host
            Port = $starpool_Port
            User1 = $SWallet1
	        User2 = $SWallet2
            User3 = $SWallet3
            CPUser = $SWallet1
            CPUPass = "c=$SPass1,ID=$Rigname1"
            Pass1 = "c=$SPass1,ID=$Rigname1"
            Pass2 = "c=$SPass2,ID=$Rigname2"
	        Pass3 = "c=$SPass3,ID=$Rigname3"
            Location = $Location
            SSL = $false
          }
        }
     }
    }
   }