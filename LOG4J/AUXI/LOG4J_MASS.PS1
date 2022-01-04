$HSTR=$args[0]
$VULNS=0
invoke-expression "C:\LOG4J\AUXI\PsExec.exe -accepteula -nobanner \\$HSTR -s -c C:\LOG4J\AUXI\Log4jScanner.exe /scan > C:\LOG4J\LOGS\$HSTR.txt" 2>&1
(Get-Content "C:\LOG4J\LOGS\$HSTR.txt") -replace "`0", "" | findstr /i "Qualys CVE-2021 Vulnerabilities Summary: Date: Duration: Scanned:"| set-content -encoding ASCII C:\LOG4J\LOGS\$HSTR.txt

type C:\LOG4J\LOGS\$HSTR.txt | findstr Vulnerabilities | Out-Null
if ($LASTEXITCODE -eq 1) {
	move C:\LOG4J\LOGS\$HSTR.txt C:\LOG4J\LOGS\FAIL\$HSTR.txt
	exit
}

function cut {
  param(
    [Parameter(ValueFromPipeline=$True)] [string]$inputobject,
    [string]$delimiter='\s+',
    [string[]]$field
  )

  process {
    if ($field -eq $null) { $inputobject -split $delimiter } else {
      ($inputobject -split $delimiter)[$field] }
  }
}

$VLN = Get-Content -Path C:\LOG4J\LOGS\$HSTR.txt | findstr Vulnerabilities|cut -f 3
if ($VLN -eq 0) {
    move C:\LOG4J\LOGS\$HSTR.txt C:\LOG4J\LOGS\NOT_VULNERABLE\$HSTR.txt
}
else {
    move C:\LOG4J\LOGS\$HSTR.txt C:\LOG4J\LOGS\VULNERABLE\$HSTR.txt
}