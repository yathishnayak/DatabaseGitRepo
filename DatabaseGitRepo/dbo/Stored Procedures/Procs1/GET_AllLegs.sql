CREATE PROCEDURE [dbo].[GET_AllLegs] 
/*
Scheduler Screen/Dispatch Screen
*/
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT MIN(C.LegKey) AS LegKey ,C.LegID AS [Description]
	FROM [LegType] A 
		  INNER JOIN [Leg] C		ON C.LegtypeKey=A.LegtypeKey
		  INNER JOIN ordertype X	ON X.OrderTypeKey=A.OrderTypeKey
		  INNER JOIN [Status] S		ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active'
	GROUP BY C.LegID	
END
