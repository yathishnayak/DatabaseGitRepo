CREATE PROCEDURE [dbo].[Get_ItemRate] -- [Get_ItemRate]
@ItemKey INT=1
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	   	
	--DECLARE @DriverPayItemKey INT
	--DECLARE @DriverPayItemDesc VARCHAR(255)
	--DECLARE @DriverPayAmt DECIMAL(18,2)
	DECLARE @ItemType VARCHAR(20)

	SET @ItemType= ( SELECT H.ItemType FROM dbo.Item A INNER JOIN ItemType H ON H.ItemTypeKey=A.ItemTypeKey WHERE ItemKey=@ItemKey)

	
	--SET @DriverPayItemKey= ( SELECT ItemKey FROM dbo.Item WHERE ItemID='DRIVER PAY' )
	--SET @DriverPayItemDesc= ( SELECT Description FROM dbo.Item WHERE ItemID='DRIVER PAY' )

	--SET @DriverPayAmt=( SELECT ISNULL(UnitCost,0) FROM dbo.Item WHERE itemkey= @DriverPayItemKey)

	IF @ItemType = 'Expense'
	BEGIN
		--************************Driver Location Rate*****************************
		SELECT DriverKey,ItemKey,CityKey,MAX(DriverRateKey) AS DriverRateKey INTO #DriverItemRate4
		FROM DriverLocationItem 
		WHERE  EffectiveDate<= CAST(GETDATE() AS DATE) AND Itemkey=@ItemKey	AND DriverKey IS NOT NULL
		GROUP BY DriverKey,ItemKey,CityKey
		--*****************Location Rate - *********************************
		SELECT DriverKey,ItemKey,CityKey,MAX(DriverRateKey) AS DriverRateKey INTO #DriverItemRate5
		FROM DriverLocationItem 
		WHERE  EffectiveDate<= CAST(GETDATE() AS DATE) AND Driverkey IS NULL 
			AND Itemkey=@ItemKey AND DriverKey IS NULL AND ItemKey=@ItemKey
		GROUP BY DriverKey,ItemKey,CityKey
		--**************************************************************************
		SELECT DISTINCT I.ItemKey,I.[Description] AS ItemDescription,CD.CityKey AS CityKey1,CD.DriverKey AS CDKey,
				DR.UnitCost AS LocationRate1,CD1.CityKey AS CityKey2,DR1.UnitCost AS LocationRate2,I.UnitCost AS ItemMasterRate	,
				@ItemType AS ItemType
		FROM dbo.Item	I
			INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey=I.ItemTypeKey	OR IT.ItemTypeKey = 5					
			LEFT JOIN ( 
						SELECT CityKey,DriverKey,DriverRateKey ,ItemKey
						FROM #DriverItemRate4 						
						) CD ON CD.Itemkey=I.ItemKey
			LEFT JOIN DriverLocationItem DR  ON DR.DriverRateKey=CD.DriverRateKey
			LEFT JOIN ( SELECT CityKey,DriverRateKey ,ItemKey
						FROM #DriverItemRate5 							
						) CD1 ON CD1.ItemKey=I.ItemKey
			LEFT JOIN DriverLocationItem DR1  ON DR1.DriverRateKey=CD1.DriverRateKey			
		WHERE I.ItemKey=@ItemKey-- AND I.ItemID NOT IN ('DRIVER PAY')
	END
	IF @ItemType= 'Service'
	BEGIN
		--************************Customer Location Rate**************************
		SELECT CityKey,Itemkey ,CustomerKey,MAX(BaseRateKey) AS BaseRateKey INTO #CustItemRate1
		FROM CustomerItemRate 
		WHERE  EffectiveDate<= CAST(GETDATE() AS DATE) AND CustomerKey IS NOT NULL AND ItemKey=@ItemKey
		GROUP BY CityKey,Itemkey,CustomerKey
		--*****************Location Rate - Service********************************
		SELECT CityKey,Itemkey ,MAX(BaseRateKey) AS BaseRateKey INTO #CustItemRate2
		FROM CustomerItemRate 
		WHERE  EffectiveDate<= CAST(GETDATE() AS DATE) AND CustomerKey IS NULL AND ItemKey=@ItemKey
		GROUP BY CityKey,Itemkey,CustomerKey

		SELECT DISTINCT I.ItemKey,I.[Description] AS ItemDescription,CD.CityKey AS CityKey1,CD.CustomerKey AS CDKey,
				CR.UnitPrice AS LocationRate1,CR1.CityKey AS CityKey2,CR1.UnitPrice AS LocationRate2,I.UnitCost AS ItemMasterRate,
				@ItemType AS ItemType
		FROM dbo.Item	I
			INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey=I.ItemTypeKey 	OR IT.ItemTypeKey = 5				
			LEFT JOIN ( 
						SELECT CityKey,CustomerKey,BaseRateKey ,ItemKey
						FROM #CustItemRate1  
						) CD ON CD.Itemkey=I.ItemKey
			LEFT JOIN CustomerItemRate CR  ON CR.BaseRateKey=CD.BaseRateKey
			LEFT JOIN ( SELECT CityKey,BaseRateKey ,ItemKey
						FROM #CustItemRate2 							
						) CD1 ON CD1.ItemKey=I.ItemKey
			LEFT JOIN CustomerItemRate CR1  ON CR1.BaseRateKey=CD1.BaseRateKey			
		WHERE I.ItemKey=@ItemKey-- AND I.ItemID NOT IN ('DRIVER PAY')
	END
	--****************************************************************
	
END
