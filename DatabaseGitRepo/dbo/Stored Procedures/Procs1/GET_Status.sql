CREATE PROCEDURE [dbo].[GET_Status]  --- [GET_Status]'Container'
@Screen VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	IF @Screen='Order'
	BEGIN
		SELECT [Status] AS StatusKey,[Description] AS StatusName
		FROM dbo.OrderStatus
		WHERE IsActive=1		
		RETURN
	END

	IF @Screen='Container'
	BEGIN
		SELECT [Status] AS StatusKey,[Description] AS StatusName
		FROM dbo.OrderDetailStatus
		WHERE IsActive=1 AND StatusType IS NULL		
		RETURN
	END

	SELECT [Status] AS StatusKey,[Description] AS StatusName
	FROM dbo.OrderDetailStatus WHERE StatusType= @Screen

END
