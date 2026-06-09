CREATE PROCEDURE [dbo].[Update_RouteDriverKey]
/*
RoutsDL
*/
@OrderKey		INT,
@OrderDetailKey INT,
@DriverKey		INT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	UPDATE dbo.Routes 
	SET DriverKey =@DriverKey  
	WHERE OrderKey = @OrderKey AND OrderDetailKey = @OrderDetailKey
END
