/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"CustKey":1046, "CityKey":11187, "DateTime" : "2023-07-23"}'
	EXEC [GET_CustomerLocationItemList_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[GET_CustomerLocationItemList_V2]-- GET_CustomerLocationItemList 1046,11187,'2023-07-23'
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END
		
	DECLARE 
		@CustomerKey	INT = 15,
		@CityKey		INT = 10198,
		@EffectiveDate	DATE = '06/25/2021'

	SELECT 
		@CustomerKey   = CustomerKey,
		@CityKey	   = CityKey,
		@EffectiveDate = EffectiveDate
	FROM OPENJSON(@JSONString)
	WITH(
		CustomerKey		INT		'$.CustKey',
		CityKey			INT		'$.CityKey',
		EffectiveDate   DATE	'$.DateTime'
		)

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

	SET @BrokerKey= ( SELECT DISTINCT ClientOrBrokerKey	FROM dbo.CustomerItemRate WITH (NOLOCK) 
						WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )
	SET @IsClient= ( SELECT DISTINCT IsClient FROM dbo.CustomerItemRate WITH (NOLOCK) 
						WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )
	SET @IsBroker= ( SELECT DISTINCT IsBroker FROM dbo.CustomerItemRate WITH (NOLOCK) 
					    WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )
	SET @EmailContact = ( SELECT DISTINCT EmailContact  FROM dbo.CustomerItemRate WITH (NOLOCK) 
							WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )

	INSERT INTO #Items ( BaseRateKey,Itemkey,CityKey,CustomerKey ,UnitPrice,EffectiveDate )
	SELECT BaseRateKey,A.Itemkey,A.CityKey,A.CustomerKey as CustKey,UnitPrice,A.EffectiveDate 
	FROM dbo.CustomerItemRate A WITH (NOLOCK)
	INNER JOIN dbo.Item I WITH (NOLOCK)		ON I.ItemKey=A.Itemkey
	INNER JOIN dbo.ItemType T WITH (NOLOCK)	ON I.ItemTypeKey=T.ItemTypeKey
	INNER JOIN dbo.[Status] S WITH (NOLOCK)	ON S.StatusKey=I.StatusKey
	INNER JOIN (SELECT Customerkey,citykey, itemkey,MAX(effectivedate) effectivedate,max(LastUpdateDate) AS LastUpdateddate from CustomerItemRate WITH (NOLOCK) 
	Group by Customerkey,citykey, itemkey) InCI ON InCI.CustomerKey=A.CustomerKey AND A.CityKey=InCI.CityKey AND A.Itemkey=InCI.ItemKey AND A.EffectiveDate=InCI.effectivedate AND A.LastUpdateDate=InCI.LastUpdateddate
	WHERE (A.CustomerKey=@CustomerKey OR @CustomerKey IS NULL) AND A.CityKey=@CityKey AND S.StatusName='Active' AND A.EffectiveDate=@EffectiveDate
	AND T.ItemType in ( @ItemType,'Expense + Service')

	SELECT @CustomerKey as CustKey, @CityKey as CityKey, @EffectiveDate as EffectiveDate,
		0 as BaseRateKey,ItemKey,ItemID,A.[Description],ItemType ,A.UnitCost AS Rate,@BrokerKey AS BrokerKey,@IsClient AS IsClient,@IsBroker AS IsBroker,@EmailContact AS EmailContact
	FROM dbo.Item A WITH (NOLOCK) 
		INNER JOIN dbo.ItemType T WITH (NOLOCK)	ON A.ItemTypeKey=T.ItemTypeKey
		INNER JOIN dbo.Status S	 WITH (NOLOCK)	ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND ItemKey NOT IN (SELECT Itemkey FROM #Items)	AND T.ItemType in ( @ItemType, 'Expense + Service')
	UNION ALL
	SELECT ISNULL(A.CustomerKey,0) AS CustKey, A.CityKey, A.EffectiveDate,
		BaseRateKey,A.Itemkey ,I.itemID,I.[Description],ItemType ,UnitPrice,NULL AS BrokerKey,0 AS IsClient,0 AS IsBroker,NULL AS EmailContact
	FROM #Items A
		INNER JOIN dbo.Item I WITH (NOLOCK)		ON I.itemkey=A.itemkey
		INNER JOIN dbo.ItemType T WITH (NOLOCK)	ON T.ItemTypeKey=I.ItemTypeKey
	ORDER BY  ItemType , ItemID
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
	   
END