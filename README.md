# [SonarQubePS](https://www.sonarqube.org/)

SonarQubePS2 is a Windows PowerShell module to interact with SonarSource via a REST API, while maintaining a consistent PowerShell look and feel.

## Instructions

### Installation

Install SonarQubePS2 from the [PowerShell Gallery][1] `Install-Module` requires PowerShellGet (included in PS v7)

```powershell
# One time only install:
Install-Module SonarQubePS2 -Scope CurrentUser

# Check for updates occasionally:
Update-Module SonarQubePS2
```

### Usage

```powershell
# To use each session:
Import-Module SonarQubePS2
Set-SonarQubeConfigServer 'https://YourCloud.SonarQube.local'
New-SonarQubeSession -Credential $cred
```

You can find the full documentation on our in the console.

```powershell
# Review the help at any time!
Get-Help about_SonarQubePS
Get-Command -Module SonarQubePS
Get-Help Get-SonarQubeIssue -Full # or any other command
```

### Contribute

Want to contribute to SonarSourcePS? Great!
We appreciate [everyone](https://SonarSourceps.org/#people) who invests their time to make our modules the best they can be.

Check out our guidelines on [Contributing] to our modules and documentation.

## Testing

Run new SonarQube container for testing

```bash
docker run --rm -it -p 9000:9000 sonarqube
```

SonarQube should be up and running at http://localhost:9000. Use the following default credentials to login into the SonarQube

```
username: admin
password: admin
```

## Disclaimer

Hopefully this is obvious, but:

> This is an open source project (under the [MIT license]), and all contributors are volunteers. All commands are executed at your own risk. Please have good backups before you start, because you can delete a lot of stuff if you're not careful.


## See Also:

+ https://docs.sonarqube.org/latest/extend/web-api/
+ https://next.sonarqube.com/sonarqube/web_api/api/projects
+ https://github.com/DanielBock73/SonarQubePS2

[1]: https://www.powershellgallery.com/packages/SonarQubePS2