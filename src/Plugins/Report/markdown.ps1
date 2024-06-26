. (Join-Path $PSScriptRoot 'markdown_funcs.ps1')

$Github_UserRepo = $Params.Github_UserRepo
$UserMessage     = $Params.UserMessage
$NoAppVeyor      = $Params.NoAppVeyor
$IconSize        = if ($Params.IconSize) { $Params.IconSize } else { 32 }
$NoIcons         = $Params.NoIcons
$Title           = if ($Params.Title) { $Params.Title } else {  'Update-AUPackages' }

# Optional Parameters for non github.com source code repositories
# If PackageSourceRoot is specified, links will be drived from it instead of $Github_UserRepo
$PackageSourceRootUrl = if ($Params.PackageSourceRootUrl) { $Params.PackageSourceRootUrl } elseif ($Params.Github_UserRepo) { "https://github.com/$Github_UserRepo" } else { 'https://github.com/majkinetor/au-packages-template' }
$PackageSourceBranch = if ($Params.PackageSourceBranch) { $Params.PackageSourceBranch } else { 'master' }

#=======================================================================================

$now             = $Info.startTime.ToUniversalTime().ToString('yyyy-MM-dd HH:mm')
$au_version      = Get-Module Chocolatey-AU -ListAvailable | ForEach-Object Version | Select-Object -First 1 | ForEach-Object { "$_" }
$package_no      = $Info.result.all.Length

$update_all_url  = "$PackageSourceRootUrl/blob/$PackageSourceBranch/update_all.ps1"

$icon_ok = 'https://cdn.jsdelivr.net/gh/majkinetor/au@master/AU/Plugins/Report/r_ok.png'
$icon_er = 'https://cdn.jsdelivr.net/gh/majkinetor/au@master/AU/Plugins/Report/r_er.png'

"# $Title"

#=== Header ===============================
if (!$NoAppVeyor -and $Github_UserRepo) { "[![](https://ci.appveyor.com/api/projects/status/github/${Github_UserRepo}?svg=true)](https://ci.appveyor.com/project/$Github_UserRepo/build/$Env:APPVEYOR_BUILD_NUMBER)" }

@"
[![$package_no](https://img.shields.io/badge/AU%20packages-$($package_no)-red.svg)](#ok)
[![$au_version](https://img.shields.io/badge/AU-$($au_version)-blue.svg)](https://www.powershellgallery.com/packages/AU)
[![](http://transparent-favicon.info/favicon.ico)](#)[![](http://transparent-favicon.info/favicon.ico)](#)
**UTC**: $now [![](http://transparent-favicon.info/favicon.ico)](#) [$Github_UserRepo]($PackageSourceRootUrl)

_This file is automatically generated by the [update_all.ps1]($update_all_url) script using the [Chocolatey-AU module](https://github.com/chocolatey-community/chocolatey-au)._
"@

"`n$UserMessage`n"

#=== Body ===============================

$errors_word = if ($Info.error_count.total -eq 1) {'error'} else {'errors' }
if ($Info.error_count.total) {
    "<img src='$icon_er' width='24'> **LAST RUN HAD $($Info.error_count.total) [$($errors_word.ToUpper())](#errors) !!!**" }
else {
    "<img src='$icon_ok' width='24'> **Last run was OK**"
}

""
md_fix_newline $Info.stats

$columns = 'Icon', 'Name', 'Updated', 'Pushed', 'RemoteVersion', 'NuspecVersion'
if ($NoIcons) { $columns = $columns[1.10] }
if ($Info.pushed) {
    md_title Pushed
    md_table $Info.result.pushed -Columns $columns
}

if ($Info.error_count.total) {
    md_title Errors
    md_table $Info.result.errors -Columns ($columns + 'Error' | Where-Object { ('Updated', 'Pushed') -notcontains $_ } )
    $Info.result.errors | ForEach-Object {
        md_title $_.Name -Level 3
        md_code "$($_.Error)"
    }
}

if ($Info.result.ignored) {
    md_title Ignored
    md_table $Info.result.ignored -Columns 'Icon', 'Name', 'NuspecVersion', 'IgnoreMessage'
}

if ($Info.result.ok) {
    md_title OK
    md_table $Info.result.ok -Columns $columns
    $Info.result.ok | ForEach-Object {
        md_title $_.Name -Level 3
        md_code $_.Result
    }
}
