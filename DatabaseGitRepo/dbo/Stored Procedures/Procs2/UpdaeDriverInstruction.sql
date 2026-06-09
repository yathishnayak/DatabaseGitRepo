CREATE PROCEDURE [dbo].[UpdaeDriverInstruction]
(
	@OrderDetailKey	INT,
	@RouteKey		INT=0,
	@DriverNotes	VARCHAR(500)
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	--UPDATE dbo.OrderDetail
	--SET DriverNotes = @DriverNotes
	--WHERE OrderDetailKey=@OrderDetailKey

	UPDATE dbo.Routes
	SET DriverInstructions = @DriverNotes
	WHERE RouteKey=@RouteKey
END
