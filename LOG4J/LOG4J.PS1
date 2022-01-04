<#
Log4j Mass Scanner

Description: Multithreading mass scan for Log4j in all domain hosts.

Details:
- Get enabled servers list from Active Directory.
- Multithreading scan all doamain hosts for Log4j vulnerabilities, using Qualys Scanner https://github.com/Qualys/log4jscanwin
- Generete CSV results.
- Generete charts.
- Generete logs details.
- Send e-mail report.

Created by: Hércules Gustavo Gusmao
Creation date: 03/01/2022
Version: 1.0
#>

#VARIABLES
#E-MAIL
$FROM="Log4j Scanner log4j.scanner@yourdomain.com"
$TO="destination@yourdomain.com"
$SUBJECT="Log4j Scanner Report"
$SMTP_SERVER="10.0.0.111"
$SMTP_PORT="25"

$REPORT="C:\LOG4J\RESULTS\REPORT.HTML"


#COUNTERS
$START=get-date -format g
$TOTAL=0
$SUCCESS=0
$FAIL=0	
$VULN=0
$NOT_VULN=0


#FUNCTION_CUT
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


#HOME
del -Recurse -Force C:\LOG4J\COMPUTERS -ErrorAction:SilentlyContinue| out-null
del -Recurse -Force C:\LOG4J\LOGS -ErrorAction:SilentlyContinue| out-null
del -Recurse -Force C:\LOG4J\RESULTS  -ErrorAction:SilentlyContinue| out-null
invoke-expression "taskkill -f -im psexec.exe" 2>&1| out-null

mkdir C:\LOG4J\COMPUTERS -ErrorAction:SilentlyContinue| out-null
mkdir C:\LOG4J\LOGS\FAIL -ErrorAction:SilentlyContinue| out-null
mkdir C:\LOG4J\LOGS\VULNERABLE -ErrorAction:SilentlyContinue| out-null
mkdir C:\LOG4J\LOGS\NOT_VULNERABLE  -ErrorAction:SilentlyContinue| out-null
mkdir C:\LOG4J\RESULTS  -ErrorAction:SilentlyContinue| out-null
c:
cd \LOG4J
cls
echo ""
type C:\LOG4J\AUXI\BANNER.TXT
echo "" 
echo "Started: $START"
echo "" 
echo "- Domain: $ENV:USERDNSDOMAIN"
echo "- Running Account: $ENV:USERNAME"
echo "- Log4j Scanner Server: $ENV:COMPUTERNAME"
echo "" 


#GET_COMP
echo "Getting enabled computers on AD..."
Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true"' -Property * | Select-Object Name,OperatingSystem,ipv4Address,Created,CanonicalName | Sort-Object -Property CanonicalName | ConvertTo-Csv -NoTypeInformation | % { $_ -replace '"', ""} | findstr /v "OperatingSystem #TYPE" | out-file C:\LOG4J\COMPUTERS\SERVERS.CSV
echo ""


#TOTAL_SRV
$COUNT = Get-Content -Path C:\LOG4J\COMPUTERS\SERVERS.CSV
$TOTAL = $COUNT.count
Write-Host "- Total Servers: $TOTAL" -ForegroundColor yellow -BackgroundColor black
echo ""


#COLLECT
echo "Running Log4j Scanner on domain hosts..."
echo ""

$HST = Get-Content -Path C:\LOG4J\COMPUTERS\SERVERS.CSV|cut -f 0 -d ","
ForEach ($HST in $HST) {
	$MEM = gwmi -Class win32_operatingsystem |
	Select-Object @{n='MemoryUsage';e ={
	$n = ($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)/$_.TotalVisibleMemorySize * 100
	[math]::Round($n)
	} }|findstr /v "MemoryUsage -----------"
	$MEMUSED = [int]::Parse($MEM)

	if ($MEMUSED -lt 82) {
		start-process powershell -argument "C:\LOG4J\AUXI\LOG4J_MASS.PS1 $HST" -NoNewWindow
	}
	else {
		echo "WARNING: memory usage exceeds 80% - Dont worry, execution paused."
		echo "Memory usage: $MEMUSED %"
		echo "Waiting free memory to restart..."
		Start-Sleep 300
		start-process powershell -argument "C:\LOG4J\AUXI\LOG4J_MASS.PS1 $HST" -NoNewWindow
	}
}


#PSEXEC_MONITOR
do {
	Start-Sleep 20
	Get-Process|findstr /i psexec|Out-Null
	} while ($LASTEXITCODE -eq 0)


#STATUS
$COUNT = dir C:\LOG4J\LOGS\VULNERABLE
$VULN = $COUNT.count

$COUNT = dir C:\LOG4J\LOGS\NOT_VULNERABLE
$NOT_VULN = $COUNT.count

$COUNT = dir C:\LOG4J\LOGS\FAIL
$FAIL = $COUNT.count

$SUCCESS=$VULN+$NOT_VULN

echo "Scan Status"
echo "============"
echo "" 
Write-Host "- Scan Failed: $FAIL" -ForegroundColor red -BackgroundColor black
Write-Host "- Scan Success: $SUCCESS" -ForegroundColor blue -BackgroundColor black
echo "" 

echo "Log4j Status"
echo "============"
echo ""
Write-Host "- Vulnerable: $VULN" -ForegroundColor red -BackgroundColor black
Write-Host "- Not Vulnerable: $NOT_VULN" -ForegroundColor blue -BackgroundColor black
echo ""

echo "Results"
echo "======="
echo ""


#CSV_GENERATOR
echo "- Genereting CSV results..."

Write-Output "Status,Vulnerabilities,Name,OperatingSystem,ipv4Address,Created,CanonicalName" > C:\LOG4J\RESULTS\LOG4J_STATUS.CSV

$HST = dir -name C:\LOG4J\LOGS\VULNERABLE| % {$_.replace(".txt","")}
ForEach ($HST in $HST) {
	$LINE = Get-Content -Path C:\LOG4J\COMPUTERS\SERVERS.CSV | findstr /R "$HST,"
	$VLN = Get-Content -Path C:\LOG4J\LOGS\VULNERABLE\$HST.txt | findstr Vulnerabilities|cut -f 3
	Write-Output "VULNERABLE,$VLN,$LINE" >> C:\LOG4J\RESULTS\LOG4J_STATUS.CSV
}

$HST = dir -name C:\LOG4J\LOGS\NOT_VULNERABLE| % {$_.replace(".txt","")}
ForEach ($HST in $HST) {
	$LINE = Get-Content -Path C:\LOG4J\COMPUTERS\SERVERS.CSV | findstr /R "$HST,"
	Write-Output "NOT_VULNERABLE,0,$LINE" >> C:\LOG4J\RESULTS\LOG4J_STATUS.CSV
}

$HST = dir -name C:\LOG4J\LOGS\FAIL| % {$_.replace(".txt","")}
ForEach ($HST in $HST) {
	$LINE = Get-Content -Path C:\LOG4J\COMPUTERS\SERVERS.CSV | findstr /R "$HST,"
	#$ERROR = Get-Content -Path C:\LOG4J\LOGS\FAIL\$HST.txt|findstr ErroID|cut -f 4|cut -f 0 -d ","
	Write-Output "FAIL,N/A,$LINE" >> C:\LOG4J\RESULTS\LOG4J_STATUS.CSV
}


#GETTOP10
$csv = Import-Csv -Header "Status", "Vulnerabilities", "Name" -delimiter ',' C:\LOG4J\RESULTS\LOG4J_STATUS.CSV
$csv | Sort-Object -Descending @{e={$_.Vulnerabilities -as [int]}}|findstr VULNERABLE | Select -First 10 | % {$_.replace("VULNERABLE     ","")}| % {$_.replace("             "," - ")} > C:\LOG4J\TOP_VULN.TXT


#CHART
echo "- Genereting Charts..."
type C:\LOG4J\AUXI\CHART_FUNCTION.PS1 > C:\LOG4J\AUXI\CHART_GENERATOR.PS1

echo `@`' >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "Name, amount" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "NOT_VULNERABLE, $NOT_VULN" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "VULNERABLE, $VULN" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "`'`@ | ConvertFrom-Csv | select Name, amount | Out-PieChart -PieChartTitle `"LOG4J STATUS`" -saveImage 'C:\LOG4J\RESULTS\LOG4J_STATUS.PNG'" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "" >>  C:\LOG4J\AUXI\CHART_GENERATOR.PS1

echo `@`' >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "Name, amount" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "SCAN_SUCCESS, $SUCCESS" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "SCAN_FAIL, $FAIL" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "`'`@ | ConvertFrom-Csv | select Name, amount | Out-PieChart -PieChartTitle `"SCAN STATUS`" -saveImage 'C:\LOG4J\RESULTS\SCAN_STATUS.PNG'" >> C:\LOG4J\AUXI\CHART_GENERATOR.PS1
echo "" >>  C:\LOG4J\AUXI\CHART_GENERATOR.PS1

powershell.exe -ExecutionPolicy Bypass -File "C:\LOG4J\AUXI\CHART_GENERATOR.PS1"
del -Recurse -Force C:\LOG4J\AUXI\CHART_GENERATOR.PS1

$FINISH=get-date -format g

#REPORT
$HTML=@"
<html>
<p style="font-family:verdana">
<h1>LOG4J SCANNER</h1>
<h4>Started: $START</h4>
<h4>Finished: $FINISH</h4>
<h4>Domain: $ENV:USERDNSDOMAIN</h4>
<h4>Running Account: $ENV:USERNAME</h4>
<h4>Log4j Scanner Server: $ENV:COMPUTERNAME</h4>
<hr>

<h3><u><b>Active Directory Data</u></b></h3>
<ul>
<li>Total Servers: <b>$TOTAL</b></li>
</ul>
<hr>

<h3><b><u>Scan Status</u></b></h3>
<ul>
<li>Scan Fail: <font color=red><b>$FAIL</b></font></li>
<li>Scan Success: <font color=blue><b>$SUCCESS</b></font></li>
</ul>
<hr>

<h3><b><u>Log4j Status</u></b></h3>
<ul>
<li>Vulnerable: <font color=red><b>$VULN</b></font></li>
<li>Not vulnerable: <font color=blue><b>$NOT_VULN</b></font></li>
</ul>
<hr>

<h3><u><b>Top 10 vulnerables</u></b></h3>
<ul>
"@
echo $HTML > $REPORT
$TOP = Get-Content -Path C:\LOG4J\TOP_VULN.TXT
ForEach ($TOP in $TOP) {Write-Output "<li>$TOP</li>" >> $REPORT}
echo "</ul>" >> $REPORT
echo "<hr>" >> $REPORT
echo "</body>" >> $REPORT
echo "</html>" >> $REPORT


#ZIP_LOGS
echo "- Compressing Logs..."
Compress-Archive C:\LOG4J\LOGS\VULNERABLE C:\LOG4J\RESULTS\LOG4J_DETAILS.ZIP -Update| out-null
$RESUTS_DATE=Get-Date -Format yyyy-MM-dd-T-HH-mm
Compress-Archive C:\LOG4J\RESULTS C:\LOG4J\RESULTS_$RESUTS_DATE.ZIP -Update| out-null

#SEND_MAIL
echo "- Sending e-mail..."
$ATTACH=(get-childitem "C:\LOG4J\RESULTS\").fullname
Send-MailMessage -From $FROM -To $TO -Subject $SUBJECT -Attachments $ATTACH -BodyAsHtml -Body (Get-Content -path $REPORT -Raw) -SmtpServer $SMTP_SERVER -Port $SMTP_PORT
echo ""


#SHOWTOP10
echo "Top 10 vulnerables"
echo "=================="
echo "" 
type C:\LOG4J\TOP_VULN.TXT 
echo ""
del -Recurse -Force C:\LOG4J\TOP_VULN.TXT 


#FINISH
echo "Finished: $FINISH"
echo ""
start "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$REPORT"
pause
exit