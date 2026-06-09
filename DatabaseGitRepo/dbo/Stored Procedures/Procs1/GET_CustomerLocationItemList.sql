CREATE PROCEDURE [dbo].[GET_CustomerLocationItemList]-- GET_CustomerLocationItemList 1046,11187,'2023-07-23'
@CustomerKey	INT = 15,
@CityKey		INT = 10198,
@EffectiveDate	DATE = '06/25/2021'
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @BrokerKey		INT= NULL
	DECLARE @IsClient		BIT= 0
	DECLARE @IsBroker		BIT= 0
	DECLARE @EmailContact	VARCHAR(100)=NULL
	DECLARE @ItemType		VARCHAR(20)

	IF ISNULL(@CityKey,0) = 0
	BEGIN		
		RETURN ;
	END

	SET @Customerkey= CASE WHEN @Customerkey=0 THEN NULL ELSE @Customerkey END

	IF ISNULL(@CustomerKey,0)=0
	BEGIN
		SET @ItemType='Expense'
	END
	ELSE
	BEGIN
		SET @ItemType='Service'
	END

	CREATE TABLE #Items
	(
		BaseRateKey INT,
		Itemkey INT,
		CityKey INT,
		CustomerKey INT ,
		UnitPrice DECIMAL(18,2),
		EffectiveDate  DATE
	)

	SET @BrokerKey= ( SELECT DISTINCT ClientOrBrokerKey	FROM dbo.CustomerItemRate 
						WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )
	SET @IsClient= ( SELECT DISTINCT IsClient FROM dbo.CustomerItemRate 
						WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )
	SET @IsBroker= ( SELECT DISTINCT IsBroker FROM dbo.CustomerItemRate 
					    WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )
	SET @EmailContact = ( SELECT DISTINCT EmailContact  FROM dbo.CustomerItemRate 
							WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )

	INSERT INTO #Items ( BaseRateKey,Itemkey,CityKey,CustomerKey ,UnitPrice,EffectiveDate )
	SELECT BaseRateKey,A.Itemkey,A.CityKey,A.CustomerKey ,UnitPrice,A.EffectiveDate 
	FROM dbo.CustomerItemRate A
	INNER JOIN dbo.Item I		ON I.ItemKey=A.Itemkey
	INNER JOIN dbo.ItemType T	ON I.ItemTypeKey=T.ItemTypeKey
	INNER JOIN dbo.[Status] S	ON S.StatusKey=I.StatusKey
	INNER JOIN (SELECT Customerkey,citykey, itemkey,MAX(effectivedate) effectivedate,max(LastUpdateDate) AS LastUpdateddate from CustomerItemRate 
	Group by Customerkey,citykey, itemkey) InCI ON InCI.CustomerKey=A.CustomerKey AND A.CityKey=InCI.CityKey AND A.Itemkey=InCI.ItemKey AND A.EffectiveDate=InCI.effectivedate AND A.LastUpdateDate=InCI.LastUpdateddate
	WHERE (A.CustomerKey=@CustomerKey OR @CustomerKey IS NULL) AND A.CityKey=@CityKey AND S.StatusName='Active' AND A.EffectiveDate=@EffectiveDate
	AND T.ItemType in ( @ItemType,'Expense + Service')

	SELECT @CustomerKey as CustomerKey, @CityKey as CityKey, @EffectiveDate as EffectiveDate,
		0 as BaseRateKey,ItemKey,ItemID,A.[Description],ItemType ,A.UnitCost AS Rate,@BrokerKey AS BrokerKey,@IsClient AS IsClient,@IsBroker AS IsBroker,@EmailContact AS EmailContact
	FROM dbo.Item A 
		INNER JOIN dbo.ItemType T	ON A.ItemTypeKey=T.ItemTypeKey
		INNER JOIN dbo.Status S		ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND ItemKey NOT IN (SELECT Itemkey FROM #Items)	AND T.ItemType in ( @ItemType, 'Expense + Service')
	UNION ALL
	SELECT ISNULL(A.CustomerKey,0) AS CustomerKey, A.CityKey, A.EffectiveDate,
		BaseRateKey,A.Itemkey ,I.itemID,I.[Description],ItemType ,UnitPrice,NULL AS BrokerKey,0 AS IsClient,0 AS IsBroker,NULL AS EmailContact
	FROM #Items A
		INNER JOIN dbo.Item I		ON I.itemkey=A.itemkey
		INNER JOIN dbo.ItemType T	ON T.ItemTypeKey=I.ItemTypeKey
	ORDER BY  ItemType , ItemID
	   
END
