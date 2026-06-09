CREATE PROCEDURE [dbo].[Get_ExpenseItem] -- [Get_ExpenseItem]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	   	
	DECLARE @DriverPayItemKey INT
	DECLARE @DriverPayItemDesc VARCHAR(255)
	DECLARE @DriverPayAmt DECIMAL(18,2)

	SET @DriverPayItemKey= ( SELECT ItemKey FROM dbo.Item WHERE ItemID='DRIVER PAY' )
	SET @DriverPayItemDesc= ( SELECT Description FROM dbo.Item WHERE ItemID='DRIVER PAY' )

	SET @DriverPayAmt=( SELECT ISNULL(UnitCost,0) FROM dbo.Item WHERE itemkey= @DriverPayItemKey)

	CREATE TABLE #OrderDetail
	(
		OrderDetailKey INT
	);	

	INSERT INTO #OrderDetail ( OrderDetailKey )
	SELECT DISTINCT OrderDetailKey 
	FROM #OrderDetailWrk

	CREATE TABLE #TempData
	(
		RouteKey INT
	);
	
	SELECT RouteKey  INTO #Route 
	FROM dbo.Routes 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #OrderDetailWrk )
	
	--*************Delete Incomplete Routes*****************
	DELETE FROM #Route
	WHERE RouteKey IN 
	(
		SELECT A.RouteKey
		FROM dbo.Routes A 
			INNER JOIN dbo.#Route RT ON RT.RouteKey=A.RouteKey
			INNER JOIN dbo.RouteStatus RTS ON RTS.[Status]=A.[Status]
		WHERE RTS.[Description]<>'Leg Completed'
	)
	--*******************************************************
	SELECT DISTINCT OH.CustKey INTO #Customer
	FROM dbo.Routes A 
		INNER JOIN #Route R ON R.RouteKey=A.RouteKey
		INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=A.OrderKey

	SELECT DISTINCT A.DriverKey INTO #Driver1
	FROM dbo.Routes A 
		INNER JOIN #Route R ON R.RouteKey=A.RouteKey

	--SELECT CityKey,Itemkey ,CustomerKey,MAX(BaseRateKey) AS BaseRateKey INTO #CustItemRate
	--FROM CustomerItemRate 
	--WHERE EffectiveDate<= CAST(GETDATE() AS DATE) AND CustomerKey IN 
	--	(
	--		SELECT CustKey FROM #Customer
	--	)
	--GROUP BY CityKey,Itemkey,CustomerKey

	--*********************Customer Wise Location Rate****************************
	SELECT CityKey,Itemkey ,CustomerKey,MAX(BaseRateKey) AS BaseRateKey INTO #CustItemRate
	FROM CustomerItemRate 
	WHERE  EffectiveDate<= CAST(GETDATE() AS DATE) AND CustomerKey IN 
		(
			SELECT DISTINCT CustKey FROM #Customer
		)
	GROUP BY CityKey,Itemkey,CustomerKey
	--*****************Driver Wise Location Rate - Expense************************
	SELECT DriverKey,ItemKey,CityKey,UnitCost,MAX(DriverRateKey) AS DriverRateKey INTO #DriverItemRate
	FROM DriverLocationItem 
	WHERE  EffectiveDate<= CAST(GETDATE() AS DATE) AND Driverkey IN 
	(
		SELECT DISTINCT Driverkey FROM #Driver1
	)
	GROUP BY DriverKey,ItemKey,CityKey,UnitCost
	--*****************Location Rate - Expense**********************************
	SELECT DriverKey,ItemKey,CityKey,UnitCost,MAX(DriverRateKey) AS DriverRateKey INTO #DriverItemRate1
	FROM DriverLocationItem 
	WHERE  EffectiveDate<= CAST(GETDATE() AS DATE) AND Driverkey IS NULL 	
	GROUP BY DriverKey,ItemKey,CityKey,UnitCost

	--SELECT
	--		ISNULL(CB.UnitPrice,C.Amount) AS DrvrPayAmt,
	--		A.RouteKey INTO  #DriverPay
	--FROM dbo.Routes A 
	--	INNER JOIN #Route R ON R.RouteKey=A.RouteKey
	--	INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=A.OrderKey
	--	INNER JOIN dbo.[Address] D ON D.AddrKey=A.DestinationAddrKey
	--	LEFT JOIN dbo.DriverPayByCity C ON C.CityKey=D.CityKey
	--	LEFT JOIN LocationData L ON L.CityKey=D.CityKey --L.City=D.City AND L.ZipCode=D.ZipCode
	--	LEFT JOIN ( SELECT CityKey,CustomerKey,BaseRateKey 
	--				FROM #CustItemRate 
	--				WHERE Itemkey=@DriverPayItemKey
	--			  ) CR ON CR.CityKey=L.CityKey AND OH.CustKey=CR.CustomerKey
	--	LEFT JOIN CustomerItemRate CB ON CB.BaseRateKey = CR.BaseRateKey

	SELECT
			COALESCE(DR.UnitCost,DR1.UnitCost,CB.UnitPrice,ISNULL(@DriverPayAmt,0)) AS DrvrPayAmt,
			A.RouteKey INTO  #DriverPay
	FROM dbo.Routes A 
		INNER JOIN #Route R ON R.RouteKey=A.RouteKey
		INNER JOIN dbo.OrderHeader OH ON OH.OrderKey=A.OrderKey
		INNER JOIN dbo.[Address] D ON D.AddrKey=A.DestinationAddrKey		
		LEFT JOIN ( SELECT CityKey,DriverKey,DriverRateKey 
					FROM #DriverItemRate 
					WHERE Itemkey=@DriverPayItemKey
				  ) CD ON CD.CityKey=D.CityKey AND CD.Driverkey=A.DriverKey
		LEFT JOIN DriverLocationItem DR  ON DR.DriverRateKey=CD.DriverRateKey
		LEFT JOIN ( SELECT CityKey,DriverKey,DriverRateKey 
					FROM #DriverItemRate1 
					WHERE Itemkey=@DriverPayItemKey
				  ) CD1 ON CD1.CityKey=D.CityKey
		LEFT JOIN DriverLocationItem DR1  ON DR1.DriverRateKey=CD1.DriverRateKey		
		LEFT JOIN ( SELECT CityKey,CustomerKey,BaseRateKey 
					FROM #CustItemRate 
					WHERE Itemkey=@DriverPayItemKey
				  ) CR ON CR.CityKey=D.CityKey AND OH.CustKey=CR.CustomerKey
		LEFT JOIN CustomerItemRate CB ON CB.BaseRateKey = CR.BaseRateKey
	--******************************************************	
		--SELECT DISTINCT I.ItemKey,I.[Description] AS ItemDescription,
		--	ISNULL(CB.UnitPrice,I.UnitCost) AS UnitCost,
		--	A.Qty,	
		--	NULL AS [ExtCost],
		--	RT.RouteKey,GETDATE() AS CreateDate ,A.OrderExpenseKey, RT.OrderDetailKey,OD.ContainerNo INTO #ExpenseItem
		--FROM OrderExpense A 
		--	INNER JOIN dbo.Item		I  ON I.ItemKey=A.Itemkey
		--	INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey=I.ItemTypeKey
		--	INNER JOIN dbo.[Routes] RT ON RT.RouteKey=A.RouteKey
		--	INNER JOIN OrderDetail OD  ON OD.OrderDetailKey=RT.OrderDetailKey
		--	INNER JOIN #Route R		   ON R.RouteKey=RT.RouteKey
		--	INNER JOIN dbo.[Address] D ON D.AddrKey=RT.DestinationAddrKey				
		--	LEFT JOIN ( 
		--				SELECT CityKey, CustomerKey, BaseRateKey, Itemkey
		--				FROM #CustItemRate 
		--				WHERE Itemkey<>@DriverPayItemKey 
		--				) CR ON CR.CityKey=d.CityKey AND CR.Itemkey=A.Itemkey
		--	LEFT JOIN CustomerItemRate CB ON CB.BaseRateKey = CR.BaseRateKey			
		--WHERE IT.ItemType='Expense' AND I.ItemID NOT IN ('DRIVER PAY')
		
		SELECT DISTINCT I.ItemKey,I.[Description] AS ItemDescription,
			--A.UnitCost,
			--CASE WHEN ISNULL(CR.UnitPrice,0)>0 THEN ISNULL(CR.UnitPrice,0) ELSE ISNULL(C.Amount,0) END AS UnitCost,
			COALESCE(DR.UnitCost,DR1.UnitCost,CB.UnitPrice,I.UnitCost) AS UnitCost,
			--CASE WHEN A.Qty>= [From] and A.Qty<= [To] THEN IB.UnitCost ELSE -1 END AS UnitCost,
			A.Qty,
			--CASE WHEN IB.Itemkey IS NULL THEN A.Qty ELSE 1 END AS QTY,
				--(A.UnitCost*CASE WHEN A.Qty=0 THEN 1 WHEN A.Qty IS NULL THEN 1 ELSE Qty END ),
				NULL AS [ExtCost],
				RT.RouteKey,GETDATE() AS CreateDate ,A.OrderExpenseKey,RT.OrderDetailKey,OD.ContainerNo INTO #ExpenseItem
			FROM OrderExpense A 
				INNER JOIN dbo.Item		I  ON I.ItemKey=A.Itemkey
				INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey=I.ItemTypeKey
				INNER JOIN dbo.[Routes] RT ON RT.RouteKey=A.RouteKey
				INNER JOIN OrderDetail OD  ON OD.OrderDetailKey=RT.OrderDetailKey
				INNER JOIN  dbo.OrderHeader OH	ON OH.OrderKey=RT.OrderKey
				INNER JOIN #Route R		   ON R.RouteKey=RT.RouteKey
				INNER JOIN dbo.[Address] D ON D.AddrKey=RT.DestinationAddrKey				
				LEFT JOIN ( SELECT CityKey,DriverKey,DriverRateKey 
							FROM #DriverItemRate 
							WHERE Itemkey<>@DriverPayItemKey
				  ) CD ON CD.CityKey=D.CityKey AND CD.Driverkey=RT.DriverKey
				LEFT JOIN DriverLocationItem DR  ON DR.DriverRateKey=CD.DriverRateKey
				LEFT JOIN ( SELECT CityKey,DriverKey,DriverRateKey 
							FROM #DriverItemRate1 
							WHERE Itemkey<>@DriverPayItemKey
						  ) CD1 ON CD1.CityKey=D.CityKey
				LEFT JOIN DriverLocationItem DR1  ON DR1.DriverRateKey=CD1.DriverRateKey		
				LEFT JOIN ( SELECT CityKey,CustomerKey,BaseRateKey 
							FROM #CustItemRate 
							WHERE Itemkey<>@DriverPayItemKey
						  ) CR ON CR.CityKey=D.CityKey AND OH.CustKey=CR.CustomerKey
				LEFT JOIN CustomerItemRate CB ON CB.BaseRateKey = CR.BaseRateKey
			WHERE IT.ItemType in ('Expense','Expense + Service') AND I.ItemID NOT IN ('DRIVER PAY')
		
		--  Driver Pay
		SELECT  @DriverPayItemKey AS ItemKey,@DriverPayItemDesc AS ItemDescription,
				    D.DrvrPayAmt AS UnitCost,1 AS Qty,RT.OrderDetailKey,OD.ContainerNo
		FROM dbo.Routes RT 
				INNER JOIN #Route R			ON R.RouteKey=RT.RouteKey
				INNER JOIN OrderDetail OD	ON OD.OrderDetailKey=RT.OrderDetailKey
				LEFT JOIN #DriverPay D		ON D.RouteKey=RT.RouteKey 		
		UNION ALL		
		SELECT ItemKey,ItemDescription,UnitCost,Qty,OrderDetailKey,ContainerNo
		FROM #ExpenseItem
END
