CREATE PROCEDURE [dbo].[Delete_ItemsForAccounting]
@OrderDetailKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DELETE FROM dbo.ItemsForAccounting where OrderDetailKey= @OrderDetailKey
END
