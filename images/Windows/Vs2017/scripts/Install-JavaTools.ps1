choco install jdk8 -y
choco install jdk9 -y
choco install ant -y
choco install maven -y

Import-Module -Name ImageHelpers -Force

$currentPath = Get-MachinePath

$pathSegments = $currentPath.Split(';')
$newPathSegments = @()

foreach ($pathSegment in $pathSegments)
{
    if($pathSegment -notlike '*java*')
    {
        $newPathSegments += $pathSegment
    }
}

$javaInstalls = Get-ChildItem -Path 'C:\Program Files\Java' -Filter 'jdk*8*' | Sort-Object -Property Name -Descending | Select-Object -First 1
$latestJava8Install = $javaInstalls.FullName;

$newPath = [string]::Join(';', $newPathSegments)
$newPath = $latestJava8Install + '\bin;' + $newPath

$env:Path = Set-MachinePath -NewPath $newPath

setx JAVA_HOME $latestJava8Install /M
$env:JAVA_HOME = $latestJava8Install

#Move maven variables to Machine
$userSid = (Get-WmiObject win32_useraccount -Filter "name = '$env:USERNAME' AND domain = '$env:USERDOMAIN'").SID
$userEnvironmentKey = 'Registry::HKEY_USERS\' + $userSid + '\Environment'

$m2 = (Get-ItemProperty -Path $userEnvironmentKey -Name M2).M2
$m2_home = (Get-ItemProperty -Path $userEnvironmentKey -Name M2_HOME).M2_HOME
$maven_opts = (Get-ItemProperty -Path $userEnvironmentKey -Name MAVEN_OPTS).MAVEN_OPTS

$m2_repo = 'C:\ProgramData\m2'
New-Item -Path $m2_repo -ItemType Directory -Force

setx M2 $m2 /M
setx M2_HOME $m2_home /M
setx M2_REPO $m2_repo /M
setx MAVEN_OPTS $maven_opts /M

Write-Host "Java $(java -version) on path"
Write-Host "Maven $(mvn -version) on path"
Write-Host "Ant $(ant -version) on path"
exit 0