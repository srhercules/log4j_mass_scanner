# Log4j Vulnerabilities Mass Scanner
Multithreading mass scanner for Log4j vulnerabilities in all Active Directory domain hosts.

Details:
- Get enabled servers list from Active Directory.
- Multithreading scan all doamain hosts for Log4j vulnerabilities, using Qualys Scanner https://github.com/Qualys/log4jscanwin
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
- Connectivity whit ports 135 and 445 to all domain hosts.
- Mail server with open relay to send mail.

# Usage:
- Direct download: https://github.com/srhercules/log4j_mass_scanner/raw/main/LOG4J.zip
- Unzip LOG4J.ZIP to C:\LOG4J\.
- Edit C:\LOG4J\LOG4J.PS1 and change #E-MAIL variables: $FROM, $TO, $SUBJECT, $SMTP_SERVER, $SMTP_PORT.
- Execute C:\LOG4J\LOG4J.PS1.
- Dont use PsExec when running, the scanner will monitor psexec process to finish data collect.

# Tips:
- Servers list will saved on C:\LOG4J\COMPUTERS\SERVERS.CSV.
- Data logs will be pupulated on C:\LOG4J\LOGS\ and moved to (FAIL VULNERABLE NOT_VULNERABLE).
- Results with Chart, CSV and Log Detail will be saved on C:\LOG4J\RESULTS.
- You can monitor threads running opening new window of Powershell and run (tasklist | findstr /i psexec).
