CREATE PROCEDURE [dbo].[Get_ItemDetailbyCategory] -- [Get_ItemDetailbyCategory] 0, 442941
@Legkey			INT=0,
@Routekey		INT=384,
@ShowOnlyMapped	BIT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @ItemCategoryFrom VARCHAR(50)
	DECLARE @ItemCategoryTo VARCHAR(50)

	DECLARE @_ItemKey   INT
	DECLARE @_CityKey   INT
	DECLARE @_CustKey   INT
	DECLARE @_DriverKey INT

	SET @_CityKey= (	
						SELECT D.CityKey 
						FROM dbo.Routes RT INNER JOIN [Address] D ON D.AddrKey=RT.DestinationAddrKey 
						WHERE RT.RouteKey=@RouteKey 
				   )
	SET @_CustKey=(	
					SELECT H.CustKey 
					FROM dbo.Routes RT 
						INNER JOIN dbo.OrderHeader H ON H.OrderKey=RT.OrderKey 
					WHERE RT.RouteKey=@RouteKey  
				  )

	SET @_DriverKey= (  
						SELECT DriverKey 
						FROM dbo.Routes 
						WHERE RouteKey=@RouteKey 
					 )

	--select @_CityKey,@_CustKey,@_DriverKey

	CREATE TABLE #ItemRateCal
	(
		ItemKey			INT,
		ItemDesc		VARCHAR(200),
		CityKey1		INT,
		CDKey			INT,
		LocationRate1	DECIMAL(18,2),
		CityKey2		INT,
		LocationRate2	DECIMAL(18,2),
		ItemMasterRate	DECIMAL(18,2),
		ItemType		VARCHAR(50),
		InvoiceItemDesc	varchar(100)
	)

	SET @Routekey= ISNULL(@Routekey,0)
	
	IF(@Routekey<> 0 and @Legkey = 0)
	BEGIN
		SELECT @Legkey = LegKey FROM dbo.Routes WHERE RouteKey = @Routekey
	END

	SELECT Itemkey,NewUnitCost AS Unitcost INTO #RouteItemRate 
	FROM dbo.OrderExpense 
	WHERE RouteKey=@Routekey

	SET @ItemCategoryFrom= (
						SELECT FromLocation 
						FROM Leg 
						WHERE LegKey=@Legkey
						)

	SET @ItemCategoryTo= (
						SELECT ToLocation 
						FROM Leg 
						WHERE LegKey=@Legkey
						)

		CREATE TABLE #ExtItems
		(
			RouteKey		INT,
			LegKey			SMALLINT,
			ItemKey			INT,
			ItemTypeKey		INT,
			ItemID			VARCHAR(30),
			CategoryName	VARCHAR(50),
			FromLocation	VARCHAR(50),
			ToLocation		VARCHAR(50),
			ItemDescription VARCHAR(255),
			UnitCost		DECIMAL(18,5),
			Qty				DECIMAL(18,5),
			ItemType		VARCHAR(50),
			PriceBasisDescription VARCHAR(50),
			PriceBasisKey	SMALLINT,
			DateFrom		DATETIME,
			DateTo			DATETIME,
			InvoiceItemDesc	varchar(100)
		)

		CREATE Table #Item
		(
			ItemKey INT,
			Qty DECIMAL(10,5)
		);

		CREATE TABLE #ItemRate
		(
		ItemKey INT,
		Rate DECIMAL(18,5),
		ItemType VARCHAR(50)
		);

		IF @Routekey>0
		BEGIN
			INSERT INTO #ExtItems (RouteKey,LegKey,ItemKey,ItemTypeKey,ItemID,CategoryName,FromLocation,ToLocation,
								   ItemDescription,UnitCost,Qty,ItemType,PriceBasisDescription,PriceBasisKey,DateFrom,DateTo, InvoiceItemDesc)
			SELECT A.RouteKey,A.LegKey,I.ItemKey,IT.ItemTypeKey,isnull(I.ItemID,I.InvoiceItemDesc),IC.[Name] AS CategoryName,
				L.FromLocation ,L.ToLocation,
				isnull(I.Description,I.InvoiceItemDesc) AS ItemDescription,I.UnitCost ,O.Qty, 
				IT.Description AS ItemType,IPB.Description AS 'PriceBasisDescription',
				IPB.PriceBasisKey,O.DateFrom,O.DateTo, I.InvoiceItemDesc
			FROM dbo.Routes A 
				INNER JOIN dbo.OrderExpense O	ON O.RouteKey=A.RouteKey
				INNER JOIN dbo.item I			ON I.ItemKey=O.Itemkey
				INNER JOIN dbo.[Status] ST		ON ST.StatusKey = I.StatusKey
				INNER JOIN dbo.ItemType IT		ON I.ItemTypeKey = IT.ItemTypeKey
				INNER JOIN [dbo].[ItemPriceBasis] IPB	ON IPB.PriceBasisKey = I.PriceBasisKey
				INNER JOIN itemcategory IC		ON IC.CategoryKey=I.CategoryKey
				LEFT JOIN leg L					ON L.LegKey=A.LegKey
			WHERE A.RouteKey=@Routekey
		END

	--*******************All generalItems************************************************	
	DECLARE @GenItems1 TABLE
		(
		RouteKey INT,
		LegKey INT,
		ItemKey INT,
		ItemTypeKey INT,
		ItemID VARCHAR(300),
		CategoryName VARCHAR(300),
		FromLocation VARCHAR(300),
		ToLocation	VARCHAR(300),
		ItemDescription	VARCHAR(300),
		UnitCost		DECIMAL(18,2),
		Qty				INT,
		ItemType		VARCHAR(300),
		PriceBasisDescription	VARCHAR(300),
		PriceBasisKey		SMALLINT,
		InvoiceItemDesc		VARCHAR(300)
		);

	IF(@ShowOnlyMapped=0)
	BEGIN
		INSERT INTO @GenItems1
		SELECT 0 AS RouteKey, 0 AS LegKey,I.ItemKey,IT.ItemTypeKey,ISNULL(I.ItemID,I.InvoiceItemDesc),IC.[Name] AS CategoryName,IC.[Name] AS FromLocation,
			IC.[Name] AS ToLocation,	ISNULL(I.Description,I.InvoiceItemDesc) AS ItemDescription,I.UnitCost , 0 AS Qty,
			IT.Description AS ItemType,IPB.Description AS 'PriceBasisDescription',
			IPB.PriceBasisKey , I.InvoiceItemDesc
			
	FROM dbo.item I
		INNER JOIN dbo.ItemType IT				ON I.ItemTypeKey = IT.ItemTypeKey
		INNER JOIN dbo.[Status] ST				ON ST.StatusKey = I.StatusKey
		INNER JOIN [dbo].[ItemPriceBasis] IPB	ON IPB.PriceBasisKey = I.PriceBasisKey 
		INNER JOIN ItemCategory IC				ON IC.CategoryKey=I.CategoryKey
		LEFT JOIN #ExtItems E					ON E.ItemKey=I.ItemKey
		WHERE IC.[Name]='General' AND ST.StatusName='Active' AND E.ItemKey IS NULL
	END
	ELSE
	BEGIN
		INSERT INTO @GenItems1
		SELECT 0 AS RouteKey, 0 AS LegKey,I.ItemKey,IT.ItemTypeKey,ISNULL(I.ItemID,I.InvoiceItemDesc),IC.[Name] AS CategoryName,IC.[Name] AS FromLocation,
			IC.[Name] AS ToLocation,	ISNULL(I.Description,I.InvoiceItemDesc)  AS ItemDescription,I.UnitCost , 0 AS Qty,
			IT.Description AS ItemType,IPB.Description AS 'PriceBasisDescription',
			IPB.PriceBasisKey , I.InvoiceItemDesc
			
	FROM dbo.item I
		INNER JOIN dbo.ItemType IT				ON I.ItemTypeKey = IT.ItemTypeKey
		INNER JOIN dbo.[Status] ST				ON ST.StatusKey = I.StatusKey
		INNER JOIN [dbo].[ItemPriceBasis] IPB	ON IPB.PriceBasisKey = I.PriceBasisKey 
		INNER JOIN ItemCategory IC				ON IC.CategoryKey=I.CategoryKey
		LEFT JOIN #ExtItems E					ON E.ItemKey=I.ItemKey
		WHERE IC.[Name]='General' AND ST.StatusName='Active' AND E.ItemKey IS NULL AND I.ItemTypeMappingKey IS NOT NULL
	END

	SELECT * INTO #GenItems
	FROM @GenItems1
	

	--*************************************************************************************

	SELECT RouteKey,LegKey,ItemKey,ItemTypeKey,ItemID,CategoryName,FromLocation,ToLocation,ItemDescription,UnitCost, Qty,
		ItemType,PriceBasisDescription,PriceBasisKey,DateFrom,DateTo , InvoiceItemDesc
		INTO #ItemList
	FROM #ExtItems
	UNION ALL
	SELECT RouteKey,LegKey,ItemKey,ItemTypeKey,ItemID,CategoryName,FromLocation,ToLocation,ItemDescription,UnitCost,0 AS Qty,
		ItemType,PriceBasisDescription,PriceBasisKey,NULL AS DateFrom,NULL AS DateTo, InvoiceItemDesc
	FROM #GenItems 
	UNION ALL
	SELECT 0 AS RouteKey, 0 AS LegKey,I.ItemKey,IT.ItemTypeKey,
		ISNULL(I.ItemID,I.InvoiceItemDesc),IC.[Name] AS CategoryName,IC.[Name] AS FromLocation,'' AS ToLocation,
			ISNULL(I.Description,I.InvoiceItemDesc)  AS ItemDescription,I.UnitCost ,  0 AS Qty,
			IT.Description AS ItemType,IPB.Description AS 'PriceBasisDescription',
			IPB.PriceBasisKey,NULL AS DateFrom,NULL AS DateTo, I.InvoiceItemDesc
	FROM dbo.item I
		INNER JOIN dbo.ItemType IT				ON I.ItemTypeKey = IT.ItemTypeKey
		INNER JOIN dbo.[Status] ST				ON ST.StatusKey = I.StatusKey
		INNER JOIN [dbo].[ItemPriceBasis] IPB	ON IPB.PriceBasisKey = I.PriceBasisKey 
		INNER JOIN ItemCategory IC				ON IC.CategoryKey=I.CategoryKey
		LEFT JOIN #ExtItems E					ON E.ItemKey=I.ItemKey
	WHERE IC.[Name]=@ItemCategoryFrom AND ST.StatusName='Active'AND E.ItemKey IS NULL
	UNION ALL
	SELECT 0 AS RouteKey, 0 AS LegKey,I.ItemKey,IT.ItemTypeKey,
			ISNULL(I.ItemID,I.InvoiceItemDesc),IC.[Name] AS CategoryName,'' AS FromLocation,IC.[Name] AS ToLocation,
			ISNULL(I.Description,I.InvoiceItemDesc) AS ItemDescription,I.UnitCost , 0 AS Qty, 
			IT.Description AS ItemType,IPB.Description AS 'PriceBasisDescription',
			IPB.PriceBasisKey,NULL AS DateFrom,NULL AS DateTo, I.InvoiceItemDesc
	FROM dbo.item I
		INNER JOIN dbo.ItemType IT				ON I.ItemTypeKey = IT.ItemTypeKey
		INNER JOIN dbo.[Status] ST				ON ST.StatusKey = I.StatusKey
		INNER JOIN [dbo].[ItemPriceBasis] IPB	ON IPB.PriceBasisKey = I.PriceBasisKey 
		INNER JOIN ItemCategory IC				ON IC.CategoryKey=I.CategoryKey
		LEFT JOIN #ExtItems E					ON E.ItemKey=I.ItemKey
	WHERE IC.[Name]=@ItemCategoryTo AND ST.StatusName='Active'AND E.ItemKey IS NULL
	ORDER BY CategoryName,FromLocation,RouteKey

	
	if((select count(1) from OrderDetailComments ODC
		inner join Comment C on ODC.CommentKey = C.CommentKey
		inner join Routes R on ODC.OrderDetailKey = R.orderdetailkey
	where C.Description like '%Transload%' and R.RouteKey = @Routekey)>0)
	Begin
		Insert INTO #ItemList
		SELECT 0 AS RouteKey, 0 AS LegKey,I.ItemKey,IT.ItemTypeKey,
				ISNULL(I.ItemID,I.InvoiceItemDesc),IC.[Name] AS CategoryName,'' AS FromLocation,IC.[Name] AS ToLocation,
				ISNULL(I.Description,I.InvoiceItemDesc) AS ItemDescription,I.UnitCost , 0 AS Qty, 
				IT.Description AS ItemType,IPB.Description AS 'PriceBasisDescription',
				IPB.PriceBasisKey,NULL AS DateFrom,NULL AS DateTo, I.InvoiceItemDesc
		FROM dbo.item I
			INNER JOIN dbo.ItemType IT				ON I.ItemTypeKey = IT.ItemTypeKey
			INNER JOIN dbo.[Status] ST				ON ST.StatusKey = I.StatusKey
			INNER JOIN [dbo].[ItemPriceBasis] IPB	ON IPB.PriceBasisKey = I.PriceBasisKey 
			INNER JOIN ItemCategory IC				ON IC.CategoryKey=I.CategoryKey
			LEFT JOIN #ExtItems E					ON E.ItemKey=I.ItemKey
		WHERE IC.[Name]='Warehouse' AND ST.StatusName='Active'AND E.ItemKey IS NULL
		ORDER BY CategoryName,FromLocation,RouteKey
	End

	SELECT DISTINCT ItemKey INTO #ItemRateCal2 FROM #ItemList WHERE ISNULL(RouteKey,0)=0

	WHILE ( SELECT COUNT(1) FROM #ItemRateCal2)>0
	BEGIN
		SET @_ItemKey= ( SELECT TOP 1 ItemKey FROM #ItemRateCal2)

		INSERT INTO #ItemRateCal (	ItemKey,ItemDesc,CityKey1,CDKey,LocationRate1,CityKey2,
									LocationRate2,ItemMasterRate,ItemType
								 )
		EXECUTE dbo.Get_ItemRate @_ItemKey

		DELETE FROM #ItemRateCal2 WHERE ItemKey= @_ItemKey
	END

	--***************Get Expense Items********************
	IF ISNULL(@_DriverKey,0) = 0 AND ISNULL(@_CityKey,0) = 0
	BEGIN		
			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
			SELECT DISTINCT ItemKey,ItemMasterRate ,'Expense' AS ItemType
			FROM #ItemRateCal 
			WHERE ItemType='Expense'		
	END

	IF  ISNULL(@_CityKey,0) <> 0
	BEGIN		
			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
			SELECT DISTINCT ItemKey,LocationRate2 ,'Expense' AS ItemType
			FROM #ItemRateCal 
			WHERE ItemType='Expense' AND CityKey2 = @_CityKey			
	END

	--IF ISNULL(@_DriverKey,0) <> 0 AND ISNULL(@_CityKey,0) <> 0
	--BEGIN		
	--		INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
	--		SELECT DISTINCT ItemKey,LocationRate1 ,'Expense' AS ItemType
	--		FROM #ItemRateCal 
	--		WHERE ItemType='Expense' AND CityKey2 = @_CityKey --AND CDKey=@_DriverKey			
	--END
	--**************Get Service Items****************************
	IF ISNULL(@_CustKey,0) = 0 AND ISNULL(@_CityKey,0) = 0
	BEGIN		
			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
			SELECT DISTINCT ItemKey,ItemMasterRate ,'Service' AS ItemType
			FROM #ItemRateCal 
			WHERE ItemType='Service'		
	END

	IF ISNULL(@_CustKey,0) = 0 AND ISNULL(@_CityKey,0) <> 0
	BEGIN		
			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
			SELECT DISTINCT ItemKey,LocationRate2 ,'Service' AS ItemType
			FROM #ItemRateCal 
			WHERE ItemType='Service' AND CityKey2 = @_CityKey			
	END

	IF ISNULL(@_CustKey,0) <> 0 AND ISNULL(@_CityKey,0) <> 0
	BEGIN			
			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
			SELECT DISTINCT ItemKey,LocationRate2 ,'Service' AS ItemType
			FROM #ItemRateCal 
			WHERE ItemType='Service' AND CityKey1 = @_CityKey AND CDKey=@_CustKey			
	END
	
	--********************************************************************
	SELECT A.Itemkey,ISNULL(I.Rate,A.ItemMasterRate) AS Rate,ISNULL(I.ItemType ,A.ItemType) AS ItemType INTO #FinalRate
	FROM ( SELECT DISTINCT ItemKey,ItemMasterRate,ItemType FROM #ItemRateCal ) A  
	LEFT JOIN #ItemRate I ON I.ItemKey=A.itemkey
	
	SELECT RouteKey,LegKey,A.ItemKey,ItemTypeKey,ItemID,CategoryName,FromLocation,ToLocation,ItemDescription,
		COALESCE(H.Unitcost,Rate,isnull(A.UnitCost,0)) AS UnitCost, isnull(Qty,0) as Qty,
		A.ItemType,PriceBasisDescription,PriceBasisKey,DateFrom,DateTo, InvoiceItemDesc
	FROM #ItemList A 
	LEFT JOIN #FinalRate G ON G.ItemKey=A.ItemKey
	LEFT JOIN #RouteItemRate H ON H.Itemkey=A.ItemKey

END
