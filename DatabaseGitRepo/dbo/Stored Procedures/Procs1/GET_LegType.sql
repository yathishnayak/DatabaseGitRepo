CREATE PROCEDURE [dbo].[GET_LegType]
/*
Scheduler Screen
*/
@OrderTypeKey INT=1
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT DISTINCT A.LegTypeKey,LegTypeID,A.Instruction AS WorkFlow,C.[Action],X.OrderType AS OrderType
	FROM [LegType] A 
		  INNER JOIN [Leg] C		ON C.LegtypeKey=A.LegtypeKey
		  INNER JOIN ordertype X	ON X.OrderTypeKey=A.OrderTypeKey
		  INNER JOIN [Status] S		ON S.StatusKey=A.StatusKey
		WHERE S.StatusName='Active' AND A.OrderTypeKey= @OrderTypeKey
	ORDER BY A.LegTypeKey
END
