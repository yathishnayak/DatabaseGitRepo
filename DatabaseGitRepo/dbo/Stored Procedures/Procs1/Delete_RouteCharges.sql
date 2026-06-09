
CREATE PROCEDURE [dbo].[Delete_RouteCharges]
(
	@RouteKey		INT=0,
	@OutPut			BIT=0 OUTPUT
)
AS

BEGIN
	BEGIN TRY
		SELECt OE.ItemKey  INTO #TempItenKeys FROM OrderExpense OE
		INNER JOIN Item I WITH (NOLOCK) ON I.ItemKey = OE.Itemkey
		WHERE ItemTypeKey=4 AND RouteKey=@RouteKey
		DELETE FROM OrderExpense WHERE RouteKey=@RouteKey AND Itemkey IN (SELECT ItemKey FROM #TempItenKeys)
		SET @OutPut=1
	END TRY
	BEGIN CATCH
		SET @OutPut=0
	END CATCH
END
