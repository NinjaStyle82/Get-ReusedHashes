function Get-ReusedHashes {
    <#
    .SYNOPSIS
        Get reused hashes from an NTDS dump.
    .DESCRIPTION
        Get reused hashes from an NTDS dump. Optionally match against a list of DAs to get DAs matching in reused hash.
    .PARAMETER HashFileName
        Specifies the file name of the NTDS hash file.
    .PARAMETER DAsFileName
        Specifies the file name of the DAs list to match hashes against.
    .INPUTS
        None.
    .OUTPUTS
        System.String.
    .EXAMPLE
        C:\PS> Get-ReusedHashes -HashFileName ./hashes.ntds -DAsFileName ./dafile.txt -Top 10

        Count Name
        ----- ----
        22    283fe76bbbbbbbbbbbbbbbbbbbbbb4dd
        92    6557350e39bbbbbbbbbbbbbbbbbbb143
        111   8846f7eaeebbbbbbbbbbbbbbbbbbb86c
        142   e705b14ec26bbbbbbbbbbbbbbbbbbc55
        191   7038aaaaaaaaaee17ce5bbbbbbbbb537
        310   f27fbbbbbbbbbbbbbbbbbbbbbbbbbae3
        614   8cbbbbbbbbbbbbbbbbbbbbbbb1403a04
        952   31d6cfe0bbbbbbbbbbbbbbbbe0c089c0
        1217  64f12cddaa8bbbbbbbbbbbbbb73b949b
        1330  be7d803e4f7bbbbbbbbbbbbbb4c8b72c

        MatchedDAs
        ----------
        SolarWindsSVR
        SophosMGMT

    #>
    param (
        [parameter(Mandatory=$true,Position=0)]$HashFileName,
        $DAsFileName,
        [Int]$Top = 100
    )
    $HashFile = Get-Content $HashFileName

    $HashHT = @()
    $UsernameHT = @()
    foreach ($Hash in $HashFile){
        $Obj = @{
            Username = $Hash.Split(":")[0]
            LMHash   = $Hash.Split(":")[2]
            NTHash   = $Hash.Split(":")[3]
        }
        $HashHT += New-Object -TypeName PSObject -Property $Obj 
    }

    $Hashes = $HashHT | Group-Object -Property NTHash | Sort-Object Count | Select-Object -Last $Top
    if ($DAsFileName){
        $DAsFile = Get-Content $DAsFileName
        foreach ($Hash in $Hashes){
            foreach ($DA in $DAsFile){
                if ($Hash.Group.Username -match $DA){
                    $Obj = @{MatchedDAs = $DA}
                    $UsernameHT += New-Object -TypeName PSObject -Property $Obj
                }
            }
        }
    }

    $Hashes | Select-Object Count,Name | Out-String
    $UsernameHT | Out-String
}
