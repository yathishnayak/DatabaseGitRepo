
CREATE PROCEDURE [dbo].[Update_OrderExpense]
@ItemKey		VARCHAR(100),
@RouteKey		INT,
@UserKey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	DECLARE @OrderDetailKey	int

	Select @OrderDetailKey = OrderDetailKey
	from Routes WITH (NOLOCK) 
	where RouteKey = @RouteKey

	IF ISNULL(@ItemKey,0)=0
	BEGIN
		DELETE FROM dbo.OrderExpense WHERE RouteKey= @RouteKey;
		SET @OutPut=1;
		RETURN
	END;

	IF ( SELECT COUNT(1) FROM dbo.OrderExpense WHERE RouteKey= @RouteKey )>0
	BEGIN
		DELETE FROM dbo.OrderExpense WHERE RouteKey= @RouteKey;
	END;

	CREATE Table #Item
	(
		ItemKey INT
	);

	INSERT INTO #Item (ItemKey)
	SELECT [Value] FROM Fn_SplitParam (@ItemKey);

	INSERT INTO [dbo].[OrderExpense]([Itemkey],[RouteKey],[UnitCost],Qty,NewUnitCost,[CreateDate],[CreateUserKey], OrderDetailKey)
	SELECT	I.ItemKey,@RouteKey,ISNULL(IT.UnitCost,0) AS UnitCost,1,NULL AS NewUnitCost,
			GETDATE() AS CreateDate,@UserKey , @OrderDetailKey
	FROM #Item I 
		INNER JOIN dbo.Item IT ON I.Itemkey=IT.ItemKey;

	UPDATE E 
		SET E.Qty= CONVERT(NUMERIC(18, 2), (DATEDIFF(MINUTE,E.DateFrom,E.DateTo)) / 60 + ((DATEDIFF(MINUTE,E.DateFrom,E.DateTo)) % 60) / 100.0),
			OrderDetailKey = @OrderDetailKey
		FROM dbo.OrderExpense E 
				INNER JOIN dbo.Item I ON I.ItemKey=E.Itemkey
				INNER JOIN dbo.ItemPriceBasis P ON P.PriceBasisKey=I.PriceBasisKey
		WHERE P.PriceBasisID='Hourly' AND E.RouteKey=@RouteKey and DATEDIFF(HOUR,E.DateFrom,E.DateTo) < 1000

	SET @OutPut=1;
	
END
