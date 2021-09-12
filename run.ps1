Import-Module -Name $PSScriptRoot/src/SonarQubePS2.psm1 -Force

# $VerbosePreference = "Continue"
# $DebugPreference = "Continue"

# Set-SonarQubeConfigServer -Server 'http://localhost:9000/'

# New-SonarQubeSession -Token '8295f5d9279a4bf85f91d581fdb9926239e6f732'
if ($Cred -eq $null) {
  $Cred = (Get-Credential -UserName 'admin')
}
New-SonarQubeSession -Credential $Cred

New-SonarQubeProject -Name "Test $([Guid]::NewGuid())" -ProjectKey "5.5.5:Projekt_$([Guid]::NewGuid() -replace "-", '')"

