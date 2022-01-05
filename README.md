# Automated Log4j Vulnerabilities Mass Scanner
## Scan thousands hosts in your Active Directory domain in minutes/hours. Scanner main features include multithreading and a detailed report that display, for instance, how many vulnerabilties were found in each host, files paths with vulnerabilities, charts, top vulnerable hosts, summary and mail report.
### Supported CVE(s): CVE-2021-4104, CVE-2021-44228, CVE-2021-44832, CVE-2021-45046, CVE-2021-45105

# Features:
- Get enabled servers list from Active Directory.
- Multithreading scan over PsExec on all domain hosts for Log4j vulnerabilities, using Qualys Scanner https://github.com/Qualys/log4jscanwin
- Memory overload protection, pause execution when exceed 80% memory used.
- Generate CSV results.
- Generate charts.
- Generate logs details.
- Send e-mail report.

Created by: Hércules Gustavo Gusmao

Creation date: 03/01/2022

Version: 1.0

# Requirements
- Query AD computers privileges (Get-ADComputer).
- Administrator privileges on all domain hosts.
- Connectivity with ports 135 and 445 to all domain hosts.
- PsExec execution privileges.
- Mail server with open relay to send mail.

# Usage:
- Direct download: https://github.com/srhercules/log4j_mass_scanner/raw/main/LOG4J.zip
- Unzip LOG4J.ZIP to C:\LOG4J\.
- Edit C:\LOG4J\LOG4J.PS1 and change #E-MAIL variables: $FROM, $TO, $SUBJECT, $SMTP_SERVER and $SMTP_PORT.
- Execute C:\LOG4J\LOG4J.PS1.
- Don't use PsExec while running the scanner, since it monitors PsExec process's to finish data collection.

# Tips:
- Servers list will be saved on C:\LOG4J\COMPUTERS\SERVERS.CSV.
- Detailed logs will be pupulated on C:\LOG4J\LOGS\ and moved to (FAIL, VULNERABLE or NOT_VULNERABLE).
- Results with Chart, CSV and Log Detail will be saved on C:\LOG4J\RESULTS.
- You can monitor scanner execution by running "tasklist | findstr /i psexec" on a new PowerShell window..Scan is concluded if no process is listed.

# Coming soon:
- Include fail reason.
- Processor usage overload protection.
- Chart embedded on report.

# Images:
## - Console output
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Console_Output.png)
## Mail report with details
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Mail_Report.png)
## CSV parsed to Excel.
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Csv_Parsed.PNG)
## Log details
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Log_Detail.png)
## Charts
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Chart_Status.png)
![alt text](https://github.com/srhercules/log4j_mass_scanner/blob/main/IMAGES/Chart_Log4j.png)
