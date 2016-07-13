if OBJECT_ID('dbo.fnIsPositive') IS NOT NULL DROP FUNCTION dbo.fnIsPositive
GO

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
CREATE FUNCTION dbo.fnIsPositive(@num int, @num2 int)
RETURNS BIT
AS BEGIN
  RETURN CASE 
    WHEN @num > 0 AND @num2 > 0 THEN 1
    ELSE 0
  END
END

