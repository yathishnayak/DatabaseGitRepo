/**
DECLARE @OutPut BIT
exec [Insert_ApprovedOrderExpense] '80, 93, 97, 249',212215,512,0,@OutPut OUTPUT 
SELECT @OutPut
**/

CREATE PROCEDURE [dbo].[Insert_ApprovedOrderExpense]  -- DECLARE @OutPut BIT, exec [Insert_ApprovedOrderExpense] '93, 97, 249',212215,512,0,@OutPut OUTPUT SELECT @OutPut
/*
Scheduler Screen
*/
@ItemKey			VARCHAR(5000), -- Comma Separated ItemKey,Qty,Rate,DateFrom and DateTo
@RouteKey			INT,
@CreateUserKey		INT,
@IsVerified			BIT=0,
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON ;
	SET FMTONLY OFF;

	SET @IsVerified= ISNULL(@IsVerified,0)

	--DECLARE @output bit

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
	DECLARE @OrderDetailKey	int

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
	SELECT @OrderDetailKey = OrderDetailKey
	From Routes RT WITH (NOLOCK)
	Where RT.routekey = @RouteKey

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
		ItemType		VARCHAR(50)
	)


	CREATE TABLE #ItemRate
	(
	ItemKey INT,
	Rate DECIMAL(18,2),
	ItemType VARCHAR(50)
	)

	SET @OutPut=0;

	--IF ISNULL(@ItemKey,'0')='0'
	--BEGIN
	--	DELETE FROM dbo.OrderExpense WHERE RouteKey= @RouteKey;
	--	SET @OutPut=1;
	--	RETURN
	--END;

	
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


	INSERT INTO #Item2 (String)
	select [Value] FROM Fn_SplitParam (@ItemKey)

	--select * from #Item2

	WHILE (SELECT count(1) FROM #Item2)>0
	BEGIN
	    SET @TopRow= 0
		SET @RowData=''
		SET @_ItemKey1= NULL
		SET @_Qty= NULL
		SET @_DateFROM= NULL
		SET @_DateTO=   NULL
		SET @_UnitCost= NULL

		TRUNCATE TABLE #ItemData2

		SET @TopRow= ( SELECT TOP 1 ID FROM #Item2  ORDER BY ID )

		SET @RowData= (SELECT String FROM #Item2 WHERE ID=@TopRow)	

		INSERT INTO #ItemData2 (String)
		SELECT [Value] FROM STRING_SPLIT(@RowData,'|')


		SET @_ItemKey1=  ( SELECT CAST(String AS INT) FROM #ItemData2 WHERE ID=1)
		SET @_Qty=       ( SELECT CAST(String AS DECIMAL(18,2)) FROM #ItemData2 WHERE ID=2 )
		SET @_UnitCost=  ( SELECT CAST(String AS DECIMAL(18,2)) FROM #ItemData2 WHERE ID=3)
		SET @_DateFROM=  ( SELECT CAST(String AS DATETIME) FROM #ItemData2 WHERE ID=4 )
		SET @_DateTo=    ( SELECT CAST(String AS DATETIME) FROM #ItemData2 WHERE ID=5 )

		--if(@_DateFROM > @_DateTo)
		Begin
			INSERT INTO #ItemData (Itemkey, Qty,Rate, DateFrom,DateTo) 
			SELECT @_ItemKey1,@_Qty,@_UnitCost,@_DateFROM,@_DateTo
		end

		DELETE FROM #Item2 WHERE ID= @TopRow
	END   
		--UPDATE #ItemData
		--SET DateFrom= CASE	WHEN DateFrom='01-01-0001 00:00:00' THEN NULL 
		--					WHEN DateFrom='1900-01-01 00:00:00.000' THEN NULL ELSE DateFrom END,-- 1900-01-01 00:00:00.000
		--	DateTo= CASE WHEN DateTo='01-01-0001 00:00:00' THEN NULL 
		--				 WHEN DateTo='1900-01-01 00:00:00.000' THEN NULL ELSE DateTo END

			--select * from #ItemData

			--return
	
		SELECT DISTINCT ItemKey INTO #ItemRateCal2 FROM #ItemData

		WHILE ( SELECT COUNT(1) FROM #ItemRateCal2)>0
		BEGIN
			SET @_ItemKey= ( SELECT TOP 1 ItemKey FROM #ItemRateCal2)

			INSERT INTO #ItemRateCal (	ItemKey,ItemDesc,CityKey1,CDKey,LocationRate1,CityKey2,
										LocationRate2,ItemMasterRate,ItemType
									 )
			EXECUTE dbo.Get_ItemRate @_ItemKey

			DELETE FROM #ItemRateCal2 WHERE ItemKey= @_ItemKey
		END
			--select * from #ItemRateCal 
		--***************Get Expense Items********************
		IF ISNULL(@_DriverKey,0) = 0 AND ISNULL(@_CityKey,0) = 0
		BEGIN		
				INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
				SELECT DISTINCT ItemKey,ItemMasterRate ,'Expense' AS ItemType
				FROM #ItemRateCal 
				WHERE ItemType in('Expense','Expense + Service')		
		END

		IF ISNULL(@_CityKey,0) <> 0
		BEGIN		
				INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
				SELECT DISTINCT ItemKey,LocationRate2 ,'Expense' AS ItemType
				FROM #ItemRateCal 
				WHERE ItemType in('Expense','Expense + Service') AND CityKey2 = @_CityKey			
		END
		--**************Get Service Items****************************
		IF ISNULL(@_CustKey,0) = 0 AND ISNULL(@_CityKey,0) = 0
		BEGIN		
				INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
				SELECT DISTINCT ItemKey,ItemMasterRate ,'Service' AS ItemType
				FROM #ItemRateCal 
				WHERE ItemType in('Service','Expense + Service')	
		END

		IF ISNULL(@_CustKey,0) = 0 AND ISNULL(@_CityKey,0) <> 0
		BEGIN		
				INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
				SELECT DISTINCT ItemKey,LocationRate2 ,'Service' AS ItemType
				FROM #ItemRateCal 
				WHERE ItemType in('Service','Expense + Service') AND CityKey2 = @_CityKey			
		END

		IF ISNULL(@_CustKey,0) <> 0 AND ISNULL(@_CityKey,0) <> 0
		BEGIN			
				INSERT INTO #ItemRate ( ItemKey,Rate,ItemType)
				SELECT DISTINCT ItemKey,LocationRate1 ,'Service' AS ItemType
				FROM #ItemRateCal 
				WHERE ItemType in('Service','Expense + Service') AND CityKey1 = @_CityKey AND CDKey=@_CustKey			
		END

		--SELECT * FROM #ItemRate

		SELECT A.Itemkey,ISNULL(I.Rate,A.ItemMasterRate) AS Rate,ISNULL(I.ItemType ,A.ItemType) AS ItemType INTO #FinalRate
		FROM ( SELECT DISTINCT ItemKey,ItemMasterRate,ItemType FROM #ItemRateCal ) A  
			LEFT JOIN #ItemRate I ON I.ItemKey=A.itemkey
		--***********************************************************
		BEGIN TRANSACTION
		BEGIN TRY
			--IF ( SELECT COUNT(1) FROM dbo.OrderExpense WHERE RouteKey= @RouteKey )>0
			--BEGIN
			--	DELETE FROM dbo.OrderExpense WHERE RouteKey= @RouteKey
			--END

			IF @IsVerified =1
			BEGIN
				INSERT INTO [dbo].[OrderExpense]([Itemkey],[RouteKey],[UnitCost],NewUnitCost,Qty,[CreateDate],
					[CreateUserKey],DateFrom,DateTo, OrderDetailKey)
				SELECT distinct	I.ItemKey,@RouteKey, ISNULL(I.Rate,0) AS UnitCost, ISNULL(I.Rate,0) AS NewUnitCost,
				ISNULL(I.Qty,0) Qty, GETDATE() AS CreateDate,@CreateUserKey ,I.DateFrom,I.DateTo, @OrderDetailKey
				FROM #ItemData I 
					INNER JOIN dbo.Item IT ON I.Itemkey=IT.ItemKey			
			END
			ELSE
			BEGIN	

				SELECT * INTO #ItemFinalData FROM #ItemData
				WHERE ItemKey NOT IN(SELECT ItemKey FROM [OrderExpense] where RouteKey=@RouteKey)

				INSERT INTO [dbo].[OrderExpense]([Itemkey],[RouteKey],[UnitCost],Qty,NewUnitCost,[CreateDate],[CreateUserKey],DateFrom,DateTo)
				SELECT distinct	I.ItemKey,@RouteKey,ISNULL(FR.Rate,0) AS UnitCost,I.Qty AS Qty,NULL AS NewUnitCost,
						GETDATE() AS CreateDate,@CreateUserKey ,I.DateFrom,I.DateTo
				FROM #ItemFinalData I 
					INNER JOIN dbo.Item IT ON I.Itemkey=IT.ItemKey
					INNER JOIN #FinalRate FR ON I.ItemKey=FR.ItemKey			
			END	
			
			UPDATE E 
			SET E.Qty= CONVERT(NUMERIC(18, 2), (DATEDIFF(MINUTE,E.DateFrom,E.DateTo)) / 60 + ((DATEDIFF(MINUTE,E.DateFrom,E.DateTo)) % 60) / 100.0),
				OrderDetailKey = @OrderDetailKey
			FROM dbo.OrderExpense E 
					INNER JOIN dbo.Item I ON I.ItemKey=E.Itemkey
					INNER JOIN dbo.ItemPriceBasis P ON P.PriceBasisKey=I.PriceBasisKey
			WHERE P.PriceBasisID='Hourly' AND E.RouteKey=@RouteKey and DATEDIFF(HOUR,E.DateFrom,E.DateTo) < 1000

			UPDATE dbo.[Routes] 
			SET IsChargesApproved= 0, 
			ChargesApprovedDate = null,
			ChargesApprovedBy= null
			WHERE RouteKey = @Routekey;

		COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
		--SELECT ERROR_MESSAGE()
			ROLLBACK TRANSACTION			
			SET @OutPut=0
		END CATCH

	SET @OutPut=1;
END
