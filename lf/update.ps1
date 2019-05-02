import-module au

$releases = 'https://github.com/gokcehan/lf/releases'

function global:au_SearchReplace {
   @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*packageName\s*=\s*)('.*')"  = "`$1'$($Latest.PackageName)'"
        }

        "$($Latest.PackageName).nuspec" = @{
            "(\<releaseNotes\>).*?(\</releaseNotes\>)" = "`${1}$($Latest.ReleaseNotes)`$2"
        }

        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x32:).*"            = "`${1} $($Latest.URL32)"
          "(?i)(\s+x64:).*"            = "`${1} $($Latest.URL64)"
          "(?i)(checksum32:).*"        = "`${1} $($Latest.Checksum32)"
          "(?i)(checksum64:).*"        = "`${1} $($Latest.Checksum64)"
          "(?i)(Get-RemoteChecksum).*" = "`${1} $($Latest.URL64)"
        }
    }
}

function global:au_BeforeUpdate { Get-RemoteFiles -Purge }

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

    $re    = 'windows-.*\.zip$'
    $url   = $download_page.links | ? href -match $re | select -First 2 -expand href | % { 'https://github.com' + $_ }

    $version  = $url -split '/' | select -Last 1 -Skip 1

    @{
        Version      = "0.$($version -split 'r' | select -Skip 1)"
        URL32        = $url -notmatch 'amd64' | select -First 1
        URL64        = $url -match    'amd64' | select -First 1
        ReleaseNotes = "https://github.com/gokcehan/lf/releases/tag/${version}"
    }
}

update -ChecksumFor none
