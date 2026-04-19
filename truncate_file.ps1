$lines = Get-Content 'c:\projects\abaimind\lib\pages\auth\register_page.dart'
($lines | Select-Object -First 254) | Set-Content 'c:\projects\abaimind\lib\pages\auth\register_page.dart' -Encoding UTF8
