/*
declare @UserKey INT = 486, @JSONString NVARCHAR(MAX), @JSONOutput NVARCHAR(MAX), @Status BIT = 0, @Reason VARCHAR(1000) = '',@IsDebug bit = 1
set @JSONString = '{"OrderTypeKey":1,"LocationType":"RT","CustomerKey":2996,"MarketKey":2}'
exec [Location_GetByOrderType] @UserKey, @JSONString, @JSONOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @ISDebug
SELECT @Status, @Reason, @JSONOutput 

*/
CREATE PRocEDURE [dbo].[Location_GetByOrderType]
(
	@UserKey      INT,
	@JSONString   NVARCHAR(MAX),
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT,
	@IsDebug		bit = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	-- Pickup = SF , Delivery = ST , Return = RT
	DECLARE @OrderTypeKey	INT, @LocationType	VARCHAR(20) , @CustomerKey	INT, @MarketKey INT

	SELECT @OrderTypeKey = OrderTypeKey, @LocationType = LocationType,@CustomerKey = CustomerKey,@MarketKey = MarketKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
		OrderTypeKey  INT         '$.OrderTypeKey',
		LocationType  VARCHAR(20) '$.LocationType',
		CustomerKey	  INT         '$.CustomerKey',
		MarketKey    INT         '$.MarketKey'
	)
	CREATE TABLE #Temp 
	(
		AddrType	varchar(10),
		[Name]		VARCHAR(100),
		AddrKey		INT,
		AddrName	VARCHAR(100),
		Address1	VARCHAR(100),
		Address2	VARCHAR(100), 
		City		VARCHAR(100),
		[State]		VARCHAR(100),
		ZipCode		VARCHAR(10),
		Country		VARCHAR(50),
		PHone		VARCHAR(50),
		Email		VARCHAR(100),
		Email2		VARCHAR(100),
		Phone2		VARCHAR(50),
		Fax			VARCHAR(50)
	)
	if(@IsDebug = 1)
	Begin
		SELECT @OrderTypeKey as OrderTypeKey, @LocationType as LocationType,@CustomerKey as CustomerKey,@MarketKey as MarketKey
	End

	select * into #Port from #Temp 
	select * into #Customer from #Temp
	Select * into #Yard from #Temp 

	
		INSERT INTO #Port
		SELECT	'Port' as AddrType,
				ltrim(rtrim(ST.TerminaID)) AS [Name],		  
				ISNULL(z.AddrKey,0) AS AddrKey,
				ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1,
				ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
				ISNULL(Z.ZipCode,'') AS ZipCode,
				ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
				ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.ShippingPortTerminals ST WITH (NOLOCK)
			--INNER JOIN ShippingPort SP	WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
			INNER JOIN [Address] Z		WITH (NOLOCK)ON Z.AddrKey=ST.AddrKey
			INNER JOIN [Status] S		WITH (NOLOCK)ON S.Statuskey=ST.StatusKey 			
		WHERE --S.StatusName='Active'	AND 
			  (ST.MarketLocationKey = @MarketKey OR 0=@MarketKey) and ISNULL(ST.IsActive,0) = 1 and ISNULL(ST.IsDeleted,0) = 0
		ORDER BY [Name]

		INSERT INTO #Port
		SELECT	'Port' as AddrType,
				ltrim(rtrim(ST.TerminaID)) AS [Name],		  
				ISNULL(z.AddrKey,0) AS AddrKey,
				ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1,
				ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
				ISNULL(Z.ZipCode,'') AS ZipCode,
				ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
				ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.ShippingPortTerminals ST WITH (NOLOCK)
			--INNER JOIN ShippingPort SP	WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
			INNER JOIN [Address] Z		WITH (NOLOCK)ON Z.AddrKey=ST.AddrKey
			INNER JOIN [Status] S		WITH (NOLOCK)ON S.Statuskey=ST.StatusKey 			
		WHERE --S.StatusName='Active'	AND 
			  (ST.MarketLocationKey=-1) and ISNULL(ST.IsActive,0) = 1 and ISNULL(ST.IsDeleted,0) = 0
		ORDER BY [Name]
	

		INSERT INTO #Customer
		SELECT	
			'Customer' as AddrType,
			 ltrim(rtrim(Z.AddrName)) AS [Name],			
			 ISNULL(z.AddrKey,0) AS AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.Customer C						WITH (NOLOCK)
			INNER JOIN dbo.CustomerAddress CA	WITH (NOLOCK) ON CA.CustKey=C.CustKey
			INNER JOIN [Address] Z				WITH (NOLOCK) ON Z.AddrKey=CA.AddrKey
			INNER JOIN [Status] S				WITH (NOLOCK) ON S.Statuskey=C.StatusKey 	
		WHERE S.StatusName='Active'	AND C.CustKey = @CustomerKey --And  C.MarketLocationKey = @MarketKey
		ORDER BY [Name]

		INSERT INTO #Yard
		SELECT	
			 'Yard' as AddrType,
			 ltrim(rtrim(Z.AddrName)) AS [Name],			
			 ISNULL(z.AddrKey,0) AS AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.Yard C				WITH (NOLOCK)
			INNER JOIN [Address] Z		WITH (NOLOCK) ON Z.AddrKey=C.AddrKey
		WHERE C.IsActive = 1 AND (C.MarketLocationKey = @MarketKey OR 0=@MarketKey)
		ORDER BY [Name]

	if(@IsDebug = 1)
	Begin
		Select '##Port', * from #Port
		Select '##Customer', * from #Customer
		Select '##Yard', * from #Yard
	End
	--****************************Import***********************************
	if (@OrderTypeKey = 1)
	Begin
		IF( @LocationType='SF')
		BEGIN
			insert  into #Temp
			Select * from #Port 
			union all 
			Select * from #Yard 
			Order By [Name]
		END
		IF( @LocationType = 'RT')
		BEGIN
			insert  into #Temp
			Select * from #Port order by [Name]
		END
		IF (@LocationType='ST')
		BEGIN
			insert  into #Temp
			SElect * from #Customer 
			union all 
			Select * from #Yard 
		END
		IF (@LocationType='AF' OR @LocationType = 'AT')
		BEGIN
			insert  into #Temp
			SElect * from #Yard
			union All 
			SElect * from #Port
			union all 
			Select * from #Customer 
		END
	END
	--******************************Export********************************
	IF @OrderTypeKey=2 
	Begin
		IF ( @LocationType='SF' )
		BEGIN
			insert  into #Temp
			SElect * from #Port
			union all
			Select * from #Yard  
			union all
			SElect * from #Customer 			
		END
		IF ( @LocationType='RT' )
		BEGIN
			insert  into #Temp
			SElect * from #Port
			--union all
			--Select * from #Yard  
		END
		IF (@LocationType='ST' )
		BEGIN
			insert  into #Temp
			SElect * from #Customer 
			union all 
			Select * from #Yard 
			union all
			SElect * from #Port
		END
		IF (@LocationType='AF' OR @LocationType = 'AT')
		BEGIN
			insert  into #Temp
			SElect * from #Yard
			union All 
			SElect * from #Port
			union all 
			Select * from #Customer 
		END
	END
	--******************************DOOR TO DOOR ********************************
	IF @OrderTypeKey=3
	BEGIN
		IF (@LocationType='SF' OR @LocationType='RT' OR @LocationType='AF' OR @LocationType = 'AT' OR @LocationType='ST')
		BEGIN
			insert  into #Temp
			SElect * from #Customer
			union All 
			SElect * from #Port
			union all 
			Select * from #Yard 
		END
	END
	--******************************EMPTY********************************
	IF @OrderTypeKey=4 
	Begin
		IF(  @LocationType='AF' OR @LocationType = 'AT')
		BEGIN
			insert  into #Temp
			SElect * from #Customer
			union All 
			Select * from #Yard 
		END
		IF( @LocationType='SF')
		BEGIN
			insert  into #Temp
			SElect * from #Customer
			union All 
			Select * from #Yard 
			union All 
			SElect * from #Port
		END
		IF( @LocationType='ST')
		BEGIN
			insert  into #Temp
			SElect * from #Customer
			union All 
			Select * from #Yard 
			union All 
			SElect * from #Port
		END
		IF( @LocationType='RT' )
		BEGIN
			insert  into #Temp
			SElect * from #Port
		END
	END

	--******************************ANY********************************
	IF @OrderTypeKey=0 
	BEGIN
		insert  into #Temp
		SElect * from #Customer
		union All 
		SElect * from #Port
		union all 
		Select * from #Yard 
	END

	if(@IsDebug = 1)
	Begin
		SElect @OrderTypeKey as OrderTypeKey, * from #temp
	End	

	drop table #Customer
	drop table #Port
	drop table #Yard

	set @JSONOutput = (SELECT * FROM #Temp  FOR JSON PATH)
	set @Status = 1
	set @Reason = 'Success'
	SELECT @JSONOutput
	DROP TABLE #Temp
END
