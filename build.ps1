dotnet-gitversion | ConvertFrom-Json | % { 
  echo "Set ModuleVersion to $($_.MajorMinorPatch)"
  Update-ModuleManifest -Path ./Modules/SonarQubePS2/SonarQubePS2.psd1 -ModuleVersion $_.MajorMinorPatch 
}
