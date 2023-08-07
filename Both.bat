cd /d %~dp0
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Mosaic\runForAllOrders.ps1'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Crayola\runForAllOrders.ps1'"
