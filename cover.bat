@echo off

rem Install OpenCover and ReportGenerator, and save the path to their executables.
echo Installing packages
nuget install -Verbosity quiet -OutputDirectory packages -Version 4.6.519 OpenCover
if %errorlevel% neq 0 exit /b %errorlevel%
nuget install -Verbosity quiet -OutputDirectory packages -Version 3.1.2 ReportGenerator
if %errorlevel% neq 0 exit /b %errorlevel%

echo Building Release with symbols
dotnet build -c Release /p:DebugType=Full
if %errorlevel% neq 0 exit /b %errorlevel%

if exist coverage\OpenCover.xml del /q coverage\OpenCover.xml
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist coverage mkdir coverage
if %errorlevel% neq 0 exit /b %errorlevel%

echo Running OpenCover
"packages\OpenCover.4.6.519\tools\OpenCover.Console.exe" -target:"dotnet.exe" -targetargs:"test Quill.Delta.Test\Quill.Delta.Test.csproj --configuration Release --no-build" -filter:"+[*]* -[*.Test*]* -[nunit*]*" -excludebyattribute:"System.CodeDom.Compiler.GeneratedCodeAttribute" -skipautoprops -oldStyle -mergeoutput -register:user -output:"coverage\OpenCover.xml"
if %errorlevel% neq 0 exit /b %errorlevel%

echo Running ReportGenerator
"packages\ReportGenerator.3.1.2\tools\ReportGenerator.exe" "-reports:coverage\OpenCover.xml" "-targetdir:coverage"
if %errorlevel% neq 0 exit /b %errorlevel%
