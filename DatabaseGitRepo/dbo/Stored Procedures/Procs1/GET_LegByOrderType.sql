CREATE PROCEDURE [dbo].[GET_LegByOrderType]  -- [GET_LegByOrderType]  2
/*
Dispatch /Scheduler Screen
*/
@OrderTypeKey	INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT MIN(C.LegKey) as LegKey,C.LegID AS [Description], MIN(A.LegTypeKey) AS LegTypeKey
	FROM [LegType] A 
		  INNER JOIN [Leg] C		ON C.LegtypeKey=A.LegtypeKey
		  INNER JOIN ordertype X	ON X.OrderTypeKey=A.OrderTypeKey
		  INNER JOIN [Status] S		ON S.StatusKey=A.StatusKey
		WHERE S.StatusName='Active' AND X.OrderTypeKey= @OrderTypeKey
	GROUP BY C.LegID
	ORDER BY C.LegID;
END
