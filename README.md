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
