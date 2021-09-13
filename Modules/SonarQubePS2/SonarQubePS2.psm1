$script:serverConfig = ("{0}/SonarQube/server_config" -f [Environment]::GetFolderPath('ApplicationData'))
if (-not (Test-Path $script:serverConfig)) {
  $null = New-Item -Path $script:serverConfig -ItemType File -Force
}
$script:SonarQubeServerUrl = [Uri](Get-Content $script:serverConfig)

class Authentication {
  [PSCredential]$Credential
  [bool]$Token

  Authentication([PSCredential]$Credential, [bool]$Token) {
    $this.Credential = $Credential
    $this.Token = $Token
  }

  [hashtable]GetAuthorizationHeader() {
    $username = $this.Credential.UserName
    $password = $this.Credential.GetNetworkCredential().Password

    $encodedString = $null
    if ($this.Token) {
      $encodedString = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($password):"))
    }
    else {
      $encodedString = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($username):$($password)")) 
    }
    
    $Header = @{
      Authorization = "Basic $encodedString"
    }
    
    return $Header  
  }
}

function Set-SonarQubeConfigServer {
  [CmdletBinding()]
  [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
  param(
    [Parameter( Mandatory )]
    [ValidateNotNullOrEmpty()]
    [Alias('Uri')]
    [Uri]
    $Server
  )

  begin {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
  }

  process {
    $script:SonarQubeServerUrl = $Server

    Set-Content -Value $Server -Path "$script:serverConfig"
  }

  end {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
  }
}

function Get-SonarQubeConfigServer {
  [CmdletBinding()]
  [OutputType([System.String])]
  param()

  begin {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
  }

  process {
    Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    $Result = ($script:SonarQubeServerUrl -replace "\/$", "")

    return $Result
  }

  end {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
  }
}

function New-SonarQubeSession {
  [CmdletBinding()]
  [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
  param(
    [Parameter(Mandatory = $True)]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential,
    [switch]
    $Token
  )

  begin {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
  }

  process {
    Write-Debug "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
    Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking SonarQubeMethod with `$parameter"
    
    if ($MyInvocation.MyCommand.Module.PrivateData) {
      Write-Debug "[$($MyInvocation.MyCommand.Name)] Adding session result to existing module PrivateData"
      $MyInvocation.MyCommand.Module.PrivateData.Session = [Authentication]::New($Credential, $Token)
    }
    else {
      Write-Debug "[$($MyInvocation.MyCommand.Name)] Creating module PrivateData"
      $MyInvocation.MyCommand.Module.PrivateData = @{
        'Session' = [Authentication]::New($Credential, $Token)
      }
    }
  }

  end {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
  }
}

function New-SonarQubeProject {
  <#
    .SYNOPSIS
        Creates a new project in SonarQube
    .DESCRIPTION
      This function creates a new issue in SonarQube.
    
      Creating an project requires a lot of data, and the exact data may be different from one instance of SonarQube to the next.

    .PARAMETER Name
      Name of the project. If name is longer than 500, it is abbreviated.

    .PARAMETER ProjectKey
      Key of the project

    .PARAMETER Visibility
      Whether the created project should be visible to everyone, or only specific user/groups.
      If no visibility is specified, the default project visibility will be used.

    .PARAMETER Credential
      Credentials to use to connect to SonarQube. If token is specified, this password will use as token.

    .PARAMETER Token
      Define that the password should used as an token

    .EXAMPLE
        Set-SonarQubeConfigServer -Server 'https://localhost:9000/'
        New-SonarQubeSession -Token 'XXXXXXX'
        New-SonarQubeProject -Name "[NameOfProject]" -ProjectKey "[KeyOfProject]"
    #>
  [CmdletBinding()]
  param(
    [ValidatePattern('(?:^.{1,500}$)')]
    [string]
    $Name,
    [ValidatePattern('(?:^[a-z0-9_\-\.\:]+$)')]
    [string]
    $ProjectKey,
    [ValidateSet('private', 'public')]
    [string]
    $Visibility,
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential,
    [switch]
    $Token
  )
    
  begin {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

    $server = Get-SonarQubeConfigServer -ErrorAction Stop

    $ResourceUri = "$server/api/projects/create"
  }
    
  process {
     
    $Body = @{
      project = $ProjectKey
      name    = $Name
    }

    $Header = $null

    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Credential')) {
      $Header = [Authentication]::New($Credential, $Token).GetAuthorizationHeader()
    }
    else {
      $Header = $MyInvocation.MyCommand.Module.PrivateData.Session.GetAuthorizationHeader()
    }
    
    $Result = Invoke-RestMethod -Method 'Post' -Uri $ResourceUri -Body $Body -Headers $Header

    return $Result.project
  }
    
  end {
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
  }
}
