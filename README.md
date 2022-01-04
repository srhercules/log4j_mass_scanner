# Log4j Vulnerabilities Mass Scanner
## Automated scan thousands hosts in your Active Directory domain in minutes, for Log4j vulnerabilities with multithreading mass scanner and detailed report.
### Supported CVE(s): CVE-2021-4104, CVE-2021-44228, CVE-2021-44832, CVE-2021-45046, CVE-2021-45105

# Features:
- Get enabled servers list from Active Directory.
- Multithreading scan all domain hosts for Log4j vulnerabilities, using Qualys Scanner https://github.com/Qualys/log4jscanwin
- Memory overload protection, pause execution when exced 80% memory used.
- Generete CSV results.
- Generete charts.
- Generete logs details.
- Send e-mail report.

Created by: Hércules Gustavo Gusmao

Creation date: 03/01/2022

Version: 1.0

# Prerequirements
- Permission do read computers on AD (Get-ADComputer).
- Administrator privileges on all domain hosts.
- Connectivity with ports 135 and 445 to all domain hosts.
- PsExec execution requirements atended.
- Mail server with open relay to send mail.

# Usage:
- Direct download: https://github.com/srhercules/log4j_mass_scanner/raw/main/LOG4J.zip
- Unzip LOG4J.ZIP to C:\LOG4J\.
- Edit C:\LOG4J\LOG4J.PS1 and change #E-MAIL variables: $FROM, $TO, $SUBJECT, $SMTP_SERVER and $SMTP_PORT.
- Execute C:\LOG4J\LOG4J.PS1.
- Dont use PsExec when running, the scanner will monitor psexec process to finish data collect.

# Tips:
- Servers list will saved on C:\LOG4J\COMPUTERS\SERVERS.CSV.
- Detailed ogs will be pupulated on C:\LOG4J\LOGS\ and moved to (FAIL, VULNERABLE or NOT_VULNERABLE).
- Results with Chart, CSV and Log Detail will be saved on C:\LOG4J\RESULTS.
- You can monitor threads running, opening new window of Powershell or CMD and run "tasklist | findstr /i psexec", collector will finish when not found PsExec process.

# Comming soon:
- Include fail reason.
- Chart embebed to report.

# Images:
## - Console output
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Console_Output.png)
## Mail report with details
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Mail_Report.png)
## CSV parsed to Excel.
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Csv_Parsed.PNG)
## Log datails
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Log_Detail.png)
## Charts
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Chart_Status.png)
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Chart_Log4j.png)
