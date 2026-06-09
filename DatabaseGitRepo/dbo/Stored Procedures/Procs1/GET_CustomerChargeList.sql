CREATE Procedure [dbo].[GET_CustomerChargeList] -- [GET_CustomerChargeList] 210,0,'Service'
(
	@OrderDetailKey		int = 180,
	@CustomerKey		INT = 1135,
	@ItemType			varchar(50) = 'Service'
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@CustomerKey,0) = 0
	BEGIN		
		SELECT @CustomerKey= OH.CustKey 
		FROM OrderDetail OD 
		INNER JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey WHERE OrderDetailKey=@OrderDetailKey
	END

	IF ISNULL(@OrderDetailKey,0) = 0
	BEGIN		
		SELECT 0 AS RouteKey, 0 AS CustomerKey, 0 AS CityKey, GETDATE() as EffectiveDate,
			0 AS BaseRateKey,0 AS ItemKey,convert(varchar(50),'') AS ItemID,convert(varchar(100),'') [Description],
			convert(varchar(50),'') ItemType , convert(decimal(18,5),0) AS Rate
		RETURN ;
	END

	CREATE TABLE #Items
	(
		RouteKey	int,
		BaseRateKey INT,
		Itemkey INT,
		CityKey INT,
		CustomerKey INT ,
		UnitPrice DECIMAL(18,2),
		EffectiveDate  DATE
	)

	
	SELECT ISNULL(RouteKey,0) AS RouteKey, isnull(CityKey,1) AS CityKey, CONVERT(Datetime, getdate()) as LastEffectiveDate 
	INTO #Routes
	FROM Routes RT
	LEFT JOIN Address A ON RT.DestinationAddrKey = A.AddrKey
	WHERE OrderDetailKey = @OrderDetailKey --and Status = 5


	UPDATE A SET LastEffectiveDate = B.EffectiveDate 
	FROM #Routes A
	LEFT JOIN (
		SELECT CIR.CityKey, MAX(EffectiveDate) AS EffectiveDate
		FROM CustomerItemRate CIR 
		INNER JOIN #Routes R ON CIR.CityKey = R.CityKey
		WHERE CustomerKey = @CustomerKey 
		GROUP BY CIR.CityKey
	) B ON 1=1

	--select * from #Routes
	INSERT INTO #Items (RouteKey, BaseRateKey,Itemkey,CityKey,CustomerKey ,UnitPrice,EffectiveDate )
	SELECT RT.RouteKey, BaseRateKey,A.Itemkey,rt.CityKey,CustomerKey ,UnitPrice,EffectiveDate 
	FROM dbo.CustomerItemRate A
	INNER JOIN dbo.Item I		ON I.ItemKey=A.Itemkey
	INNER JOIN dbo.ItemType T	ON I.ItemTypeKey=T.ItemTypeKey
	INNER JOIN dbo.[Status] S	ON S.StatusKey=I.StatusKey
	INNER JOIN #Routes RT ON A.CityKey = A.CityKey AND A.EffectiveDate = RT.LastEffectiveDate
	WHERE  S.StatusName='Active' AND T.ItemType in ( @ItemType,'Expense + Service')

	SELECT * FROM (
		SELECT ISNULL(rt.RouteKey,0) AS RouteKey, @CustomerKey AS CustomerKey, RT.CityKey AS CityKey, GETDATE() AS EffectiveDate,
			0 AS BaseRateKey,ItemKey,ItemID,A.[Description],ItemType ,A.UnitCost AS Rate
		FROM dbo.Item A 
			INNER JOIN dbo.ItemType T	ON A.ItemTypeKey=T.ItemTypeKey
			INNER JOIN dbo.Status S		ON S.StatusKey=A.StatusKey
			LEFT join #Routes RT ON 1=1 
		WHERE S.StatusName='Active' AND ItemKey NOT IN (SELECT Itemkey FROM #Items)	AND T.ItemType in ( @ItemType,'Expense + Service')
		UNION ALL
		SELECT RT.RouteKey, ISNULL(A.CustomerKey,0) AS CustomerKey, A.CityKey, A.EffectiveDate,
			BaseRateKey,A.Itemkey ,I.itemID,I.[Description],ItemType ,UnitPrice
		FROM #Items A
			INNER JOIN dbo.Item I		ON I.itemkey=A.itemkey
			INNER JOIN dbo.ItemType T	ON T.ItemTypeKey=I.ItemTypeKey
			LEFT JOIN #Routes RT ON 1=1 AND RT.LastEffectiveDate IS NULL
	) a
	ORDER BY RouteKey, CustomerKey, CityKey,  ItemType , ItemID
	   
END
