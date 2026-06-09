CREATE PROCEDURE [dbo].[GET_Priority]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT PriorityKey,[Description],ColorCode 
	FROM dbo.[Priority] A 
		INNER JOIN dbo.[Status] S ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND IsWarehouse = 0;
END
