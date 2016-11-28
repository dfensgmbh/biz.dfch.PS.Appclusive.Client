# biz.dfch.PS.Appclusive.Client
[![License](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client/blob/master/LICENSE)
[![Version](https://img.shields.io/nuget/v/biz.dfch.PS.Appclusive.Client.svg)](https://www.nuget.org/packages/biz.dfch.PS.Appclusive.Client/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.0-blue.svg)](https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client)

PowerShell module for the Appclusive Framework and Middleware

Assembly: biz.dfch.PS.Appclusive.Client

d-fens GmbH, General-Guisan-Strasse 6, CH-6300 Zug, Switzerland


## Download

* Get it on [NuGet](https://www.nuget.org/packages/biz.dfch.PS.Appclusive.Client/)

* See [Releases](https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client/releases) and [Tags](https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client/tags) on [GitHub](https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client)

## Release

1. `Start New Release` in SourceTree
1. Adjust/Update `src/biz.dfch.PS.Appclusive.Client.nuspec`
  1. `<version>`
  2. `<release notes>`
  3. version of `biz.dfch.CS.Appclusive.Api` (See at the bottom of the nuspec file)
  3. version of `biz.dfch.CS.Appclusive.Public` (See at the bottom of the nuspec file)
1. Update version of `biz.dfch.CS.Appclusive.Api` in `packages.config`
1. Update `ModuleVersion` in `biz.dfch.PS.Appclusive.Client.psd1` 
1. Push changes to origin
1. `Finish Release` in SourceTree
1. The nuget package will then automatically be published by TeamCity

## Installation

1. Exeucte `nuget.exe install biz.dfch.PS.Appclusive.Client -Version 2.8.1`
2. Execute `.\Install.ps1` in downloaded package folder


## Description

PowerShell module for the Appclusive Framework and Middleware

[![TeamCity Logo](https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client/blob/develop/TeamCity.png)](https://www.jetbrains.com/teamcity/)

Released with TeamCity
