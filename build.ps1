dotnet-gitversion | ConvertFrom-Json | % { Update-ModuleManifest -Path ./Modules/SonarQubePS2/SonarQubePS2.psd1 -ModuleVersion $_.MajorMinorPatch }