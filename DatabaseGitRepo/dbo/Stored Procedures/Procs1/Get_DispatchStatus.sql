CREATE PROCEDURE [dbo].[Get_DispatchStatus]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT [Status] AS StatusKey, [Description] AS StatusName
	FROM dbo.RouteStatus

	--SELECT [Status] AS StatusKey, [Description] AS StatusName
	--FROM dbo.OrderDetailStatus WHERE StatusType='Dispatch'
	
END
