CREATE PROCEDURE [dbo].[GET_Leg]  -- [GET_Leg] 10, 1
/*
Scheduler Screen
*/
@LegTypeKey		INT=0,
@OrderTypeKey	INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT C.LegKey,A.Instruction AS WorkFlow ,C.[Action],C.[Description], A.LegTypeKey
	FROM [LegType] A 
		  INNER JOIN [Leg] C		ON C.LegtypeKey=A.LegtypeKey
		  INNER JOIN ordertype X	ON X.OrderTypeKey=A.OrderTypeKey
		  INNER JOIN [Status] S		ON S.StatusKey=A.StatusKey
		WHERE S.StatusName='Active' AND A.LegtypeKey= @LegTypeKey AND X.OrderTypeKey= @OrderTypeKey
	ORDER BY A.LegTypeKey
END
