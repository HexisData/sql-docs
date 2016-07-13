# sql-docs
HTML generator for SQL Server user-defined functions

Produces an HTML document with information on SQL Server function. Built using YAML headers combined with metadata from INFORMATION_SCHEMA.ROUTINES

Based on Phil Factor's https://www.simple-talk.com/sql/t-sql-programming/documenting-your-sql-server-database/

# Files 
- **documementationTemplate.html**. Contains an HTML template, with {{tokens}} that get be replaced by the powershell script
- **generate.ps1**. Set the parameters inside this file to conect to the right SQL Server instance. Run to generate HTML file. 
 
# Screenshot
![screenshot](https://raw.githubusercontent.com/HotQuant/sql-docs/master/screenshot.png)
