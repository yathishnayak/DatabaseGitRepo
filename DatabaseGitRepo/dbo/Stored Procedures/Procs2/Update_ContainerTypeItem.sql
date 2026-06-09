
CREATE PROCEDURE [dbo].[Update_ContainerTypeItem]
@OrderDetailKey INT=265,
@ContType		VARCHAR(500)='',
@CreateUserKey  INT=1
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	IF( SELECT COUNT(1) FROM dbo.Invoicedetail WHERE OrderDetailKey=@OrderDetailKey)>0
	BEGIN
		RETURN
	END;	
	--INSERT INTO Test23
	--select @OrderDetailKey,@ContType
	--*************************************************
	DECLARE @_ItemKey   INT
	DECLARE @_CityKey   INT
	DECLARE @_CustKey   INT
	DECLARE @_DriverKey INT

	DECLARE @_ItemKey1	INT
	DECLARE @_Qty		DECIMAL(18,2)
	DECLARE @_UnitCost	DECIMAL(18,2)
	DECLARE @_DateFROM	DATETIME
	DECLARE @_DateTo	DATETIME
	DECLARE @TopRow		INT
	DECLARE @RowData VARCHAR(500)

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
		ItemType		VARCHAR(50)
	)


	CREATE TABLE #ItemRate
	(
	ItemKey INT,
	Rate DECIMAL(18,2),
	ItemType VARCHAR(50)
	)

	CREATE Table #Item2
	(
		ID INT Identity(1,1),
		String VARCHAR(500)
	);

	CREATE Table #ItemData
	(
		Itemkey		INT,
		Qty			DECIMAL(18,2),
		Rate		DECIMAL(18,2),
		DateFrom	DATETIME,
		DateTo		DATETIME
	);

	CREATE Table #ItemData2
	(
		ID INT Identity(1,1),
		String VARCHAR(500)
	);

	--****************************************************

	DECLARE @RouteKey INT;
	DECLARE @New_CommentKey INT

	CREATE TABLE #ExtContType
	(
		OrderDetailKey	INT,
		CommentKey		INT,
		ContType		VARCHAR(50),
		ContainerNo		VARCHAR(20),
		ShortCmnt		VARCHAR(20)		
	)

	CREATE TABLE #NewContType1
	(
		OrderDetailKey	INT,
		CommentKey		INT,
		ContType		VARCHAR(50),
		ContainerNo		VARCHAR(20),
		ShortCmnt		VARCHAR(20)		
	)

	CREATE TABLE #OrderRoute
	(
		RouteKey INT,
		Exclude  BIT
	)	
	--***************Exisitng Cont Type and Item handling***************
	INSERT INTO #OrderRoute (RouteKey,Exclude)
	SELECT RouteKey,A.IsRateVerified
	FROM dbo.routes A 		
	WHERE OrderDetailKey=@OrderDetailKey	

	INSERT INTO #OrderRoute (RouteKey,Exclude)
	SELECT distinct  A.RouteKey,1
	FROM dbo.VoucherDetail A 
	inner join dbo.Routes R on (A.RouteKey = R.RouteKey)
	where  OrderDetailKey=@OrderDetailKey
	--WHERE RouteKey IN ( SELECT RouteKey FROM dbo.Routes WHERE OrderDetailKey=@OrderDetailKey );	

	INSERT INTO #ExtContType (OrderDetailKey,CommentKey,ContType,ContainerNo,ShortCmnt)
	EXECUTE Get_ContainerTypeForContainer @OrderDetailKey, ''

	UPDATE #ExtContType
	SET ContType =LTRIM(RTRIM(ContType));	

	SELECT A.*,I.ItemKey INTO #ExtContTypeItem 
	FROM #ExtContType A 
		JOIN dbo.ContainerTypes I ON I.TypeID=A.ContType;

		--insert into Test123
		--select * from #ExtContTypeItem

	--**************Delete Existing Comments and insert new one if exitst***************
	DELETE	FROM OrderDetailComments 
	WHERE CommentKey IN ( SELECT CommentKey FROM #ExtContType )

	DELETE FROM dbo.Comment WHERE CommentKey IN ( SELECT CommentKey FROM #ExtContType )

	--exec [Container_TypeInsert] @OrderdetailKey, 0
	

	IF ISNULL(@ContType,'')<>''
	BEGIN	
		INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
		VALUES (@ContType, GETDATE(),@CreateUserKey);	

		SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) 

		INSERT INTO dbo.OrderDetailComments(OrderDetailKey,CommentKey)
		VALUES (@OrderDetailKey, @New_CommentKey)

		exec [Container_TypeInsert] @OrderdetailKey, @New_CommentKey
	END
	--*******************New ContType***************************************************
		
	INSERT INTO #NewContType1 (OrderDetailKey,CommentKey,ContType,ContainerNo,ShortCmnt)
	EXECUTE Get_ContainerTypeForContainer @OrderDetailKey, ''

	--INSERT INTO #NewContType (OrderDetailKey,CommentKey,ContType,ContainerNo,ShortCmnt)
	--SELECT @OrderDetailKey,0,[value] ,'',''
	--FROM STRING_SPLIT( @ContType,',') 

	--SELECT * FROM #NewContType

	--select * from #NewContType

	UPDATE #NewContType1
	SET ContType =LTRIM(RTRIM(ContType));			

	SELECT A.*,I.ItemKey INTO #NewContTypeItem 
	FROM #NewContType1 A 
	JOIN dbo.ContainerTypes I ON I.TypeID=A.ContType;

	DELETE FROM #NewContTypeItem WHERE ItemKey IS NULL

	--insert into Test1234
	--select * from #NewContType

	SELECT A.Itemkey INTO #ItemtoInsert
	FROM #NewContTypeItem A 
		LEFT JOIN  #ExtContTypeItem B ON A.ItemKey=B.ItemKey
	WHERE B.ItemKey IS NULL

	SELECT B.Itemkey INTO #ItemtoDelete
	FROM  #ExtContTypeItem B 
		LEFT JOIN  #NewContTypeItem A ON A.ItemKey=B.ItemKey
	WHERE A.ItemKey IS NULL
	--********************Insert/Delete into Order Expense***********************
	SELECT DISTINCT RouteKey INTO #RouteItem 
	FROM #OrderRoute
	WHERE Exclude=0

	DELETE FROM dbo.OrderExpense 
	WHERE RouteKey IN ( SELECT DISTINCT RouteKey FROM #OrderRoute WHERE Exclude=0 ) 
		AND Itemkey IN  ( SELECT Itemkey FROM #ItemtoDelete )

	--EXEC Auto_ChargeContainerProps @OrderDetailKey,0

	--WHILE ( SELECT COUNT(1) FROM #RouteItem )>0
	--BEGIN
	----**********************************************		
	--	SET @RouteKey= ( SELECT TOP 1 RouteKey FROM #RouteItem ORDER BY RouteKey)
		
	--	SET @_CityKey  =0
	--	SET @_CustKey  =0
	--	SET @_DriverKey=0
	

	--	SET @_CityKey= (	
	--					SELECT TOP 1 D.CityKey 
	--					FROM dbo.Routes RT INNER JOIN [Address] D ON D.AddrKey=RT.DestinationAddrKey 
	--					WHERE RT.RouteKey=@RouteKey 
	--			   )
	--	SET @_CustKey=(	
	--				SELECT H.CustKey 
	--				FROM dbo.Routes RT 
	--					INNER JOIN dbo.OrderHeader H ON H.OrderKey=RT.OrderKey 
	--				WHERE RT.RouteKey=@RouteKey  
	--			  )

	--	SET @_DriverKey= (  
	--					SELECT DriverKey 
	--					FROM dbo.Routes 
	--					WHERE RouteKey=@RouteKey 
	--				 )
	--	IF OBJECT_ID(N'tempdb..#ItemRateCal2') IS NOT NULL 
	--	BEGIN
	--		DROP TABLE #ItemRateCal2
	--	END
		
	--	TRUNCATE TABLE  #ItemRateCal	

	--	SELECT DISTINCT ItemKey INTO #ItemRateCal2 FROM #ItemtoInsert

	--	WHILE ( SELECT COUNT(1) FROM #ItemRateCal2)>0
	--	BEGIN
	--		SET @_ItemKey= ( SELECT TOP 1 ItemKey FROM #ItemRateCal2)

	--		INSERT INTO #ItemRateCal (	ItemKey,ItemDesc,CityKey1,CDKey,LocationRate1,CityKey2,
	--									LocationRate2,ItemMasterRate,ItemType
	--									)
	--		EXECUTE dbo.Get_ItemRate @_ItemKey

	--		DELETE FROM #ItemRateCal2 WHERE ItemKey= @_ItemKey
	--	END
	--		--select * from #ItemRateCal 
	--	--***************Get Expense Items********************
	--	IF ISNULL(@_DriverKey,0) = 0 AND ISNULL(@_CityKey,0) = 0
	--	BEGIN		
	--			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
	--			SELECT DISTINCT ItemKey,ItemMasterRate ,'Expense' AS ItemType
	--			FROM #ItemRateCal 
	--			WHERE ItemType='Expense'		
	--	END

	--	IF ISNULL(@_CityKey,0) <> 0
	--	BEGIN		
	--			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
	--			SELECT DISTINCT ItemKey,LocationRate2 ,'Expense' AS ItemType
	--			FROM #ItemRateCal 
	--			WHERE ItemType='Expense' AND CityKey2 = @_CityKey			
	--	END
	--	--**************Get Service Items****************************
	--	IF ISNULL(@_CustKey,0) = 0 AND ISNULL(@_CityKey,0) = 0
	--	BEGIN		
	--			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
	--			SELECT DISTINCT ItemKey,ItemMasterRate ,'Service' AS ItemType
	--			FROM #ItemRateCal 
	--			WHERE ItemType='Service'		
	--	END

	--	IF ISNULL(@_CustKey,0) = 0 AND ISNULL(@_CityKey,0) <> 0
	--	BEGIN		
	--			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
	--			SELECT DISTINCT ItemKey,LocationRate2 ,'Service' AS ItemType
	--			FROM #ItemRateCal 
	--			WHERE ItemType='Service' AND CityKey2 = @_CityKey			
	--	END

	--	IF ISNULL(@_CustKey,0) <> 0 AND ISNULL(@_CityKey,0) <> 0
	--	BEGIN			
	--			INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
	--			SELECT DISTINCT ItemKey,LocationRate1 ,'Service' AS ItemType
	--			FROM #ItemRateCal 
	--			WHERE ItemType='Service' AND CityKey1 = @_CityKey AND CDKey=@_CustKey			
	--	END

	--	IF OBJECT_ID(N'tempdb..#FinalRate') IS NOT NULL 
	--	BEGIN
	--		DROP TABLE #FinalRate
	--	END

	--	SELECT A.Itemkey,ISNULL(I.Rate,A.ItemMasterRate) AS Rate,ISNULL(I.ItemType ,A.ItemType) AS ItemType INTO #FinalRate
	--	FROM ( SELECT DISTINCT ItemKey,ItemMasterRate,ItemType FROM #ItemRateCal ) A  
	--		LEFT JOIN #ItemRate I ON I.ItemKey=A.itemkey
			
	--		--select * from #ItemtoInsert
	--		--select * from #ItemtoDelete
	----******************************************************************
	----******************************************************************
	--	INSERT INTO [dbo].[OrderExpense]([Itemkey],[RouteKey],[UnitCost],Qty,NewUnitCost,[CreateDate],[CreateUserKey],DateFrom,DateTo)
	--	SELECT	I.ItemKey,@RouteKey,ISNULL(IT.Rate,0) AS UnitCost,1,NULL AS NewUnitCost,
	--		GETDATE() AS CreateDate,@CreateUserKey ,NULL,NULL
	--	FROM #ItemtoInsert I 
	--	INNER JOIN dbo.#FinalRate IT ON I.Itemkey=IT.ItemKey
				
	--	DELETE FROM #RouteItem WHERE RouteKey=@RouteKey
		
	--END 
END
