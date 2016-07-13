# sql-docs
HTML generator for SQL Server user-defined functions

Based on Phil Factor's https://www.simple-talk.com/sql/t-sql-programming/documenting-your-sql-server-database/

## How it works
Put a header on your function using very simple YAML syntax.

**sql-docs** produces an HTML document with information gleaned YAML headers combined with metadata from INFORMATION_SCHEMA.ROUTINES

Open generate.ps1 and set the variables `$ServerName` and `$Database` to point to your instance, then run generate.ps1

```yaml
/**
summary:
  fnIsPositive returns true if both parameters are positive,
  and returns false otherwise
parameters:
  - name : num
    type: int
    description: any integer, positive or negative
    ifNull: fnIsPositive will return false, because NULL is not a positive number
  - name: num2
    type: int
    description: asdfsadf
    ifNull: nothing
author: rod3095
examples:
  - SELECT ajr.fnIsPositive(3)
  - SELECT ajr.fnIsPositive(-17)
  - SELECT ajr.fnIsPositive(NULL)
returns: 1 if @num is positive, 0 otherwise
**/
```

## Files 
- **documementationTemplate.html**. Contains an HTML template, with {{tokens}} that get be replaced by the powershell script
- **generate.ps1**. Set the parameters inside this file to conect to the right SQL Server instance. Run to generate HTML file. 
 
## Screenshot
Here is what the generated HTML looks like when run on a database with a single function (using the demo function [dbo.IsPositive](https://raw.githubusercontent.com/HotQuant/sql-docs/master/FunctionForDemoPurposes_fnIsPositive.sql))

![screenshot](https://raw.githubusercontent.com/HotQuant/sql-docs/master/screenshot.png)
