CREATE PROCEDURE [dbo].[GET_OrderType]
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT OrderTypeKey,OrderType 
	FROM OrderType A INNER JOIN [Status] S ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active'
END
