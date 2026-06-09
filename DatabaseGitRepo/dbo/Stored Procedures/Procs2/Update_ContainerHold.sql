CREATE PROCEDURE [dbo].[Update_ContainerHold]
/*
Container Screen - Update as Hold
*/
@OrderKey INT,
@Output   BIT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	UPDATE OrderHeader
	SET [Status]=8
	WHERE OrderKey=@OrderKey

	SET @Output=1
END
