
CREATE PROCEDURE [dbo].[TMS_Integration_LocationDetailbyOrderType] -- [TMS_Integration_LocationDetailbyOrderType] 1, 'Pickup', 1966
@OrderTypeKey	smallint=1,
@LoationType	VARCHAR(20) ='Delivery',
@CustKey		INT=16
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	CREATE TABLE #Temp 
	(
		[Name]		VARCHAR(100),
		AddrKey		INT,
		AddrName	VARCHAR(100),
		Address1	VARCHAR(100),
		Address2	VARCHAR(100), 
		City		VARCHAR(100),
		[State]		VARCHAR(100),
		ZipCode		VARCHAR(10),
		Country		VARCHAR(50),
		Type		varchar(20)
	)
	--****************************Import***********************************
	IF @OrderTypeKey=1 AND( @LoationType='Pickup' OR @LoationType='Return' )
	BEGIN
		INSERT INTO #Temp
		SELECT	
			  ST.TerminaID AS [Name],		  
			  ISNULL(z.AddrKey,0) AS AddrKey,
			  ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1,
			  ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			  ISNULL(Z.ZipCode,'') AS ZipCode,
			  ISNULL(Z.Country,'')AS Country,
			  'PORT' as Type
		FROM dbo.ShippingPortTerminals ST WITH (NOLOCK)
			--INNER JOIN ShippingPort SP	WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
			INNER JOIN [Address] Z		WITH (NOLOCK)ON Z.AddrKey=ST.AddrKey
			INNER JOIN [Status] S		WITH (NOLOCK)ON S.Statuskey=ST.StatusKey 			
		WHERE S.StatusName='Active'		
	END
	IF @OrderTypeKey=1 AND @LoationType='Delivery' 
	BEGIN
		INSERT INTO #Temp
		SELECT	
			 Z.AddrName AS [Name],			
			 ISNULL(z.AddrKey,0) AS AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country,
			 'CUSTOMER' as Type
		FROM dbo.Customer C						WITH (NOLOCK)
			INNER JOIN dbo.CustomerAddress CA	WITH (NOLOCK) ON CA.CustKey=C.CustKey
			INNER JOIN [Address] Z				WITH (NOLOCK) ON Z.AddrKey=CA.AddrKey
			INNER JOIN [Status] S				WITH (NOLOCK) ON S.Statuskey=C.StatusKey 	
		WHERE S.StatusName='Active'	AND C.CustKey = @CustKey
	END
	--******************************Export********************************
	IF @OrderTypeKey=2 AND( @LoationType='Pickup' OR @LoationType='Return' )
	BEGIN
		INSERT INTO #Temp
		SELECT	
			 Z.AddrName AS [Name],			
			 ISNULL(z.AddrKey,0) AS AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country	,
			 'CUSTOMER' as Type
		FROM dbo.Customer C				WITH (NOLOCK)
			INNER JOIN dbo.CustomerAddress CA	WITH (NOLOCK) ON CA.CustKey=C.CustKey
			INNER JOIN [Address] Z		WITH (NOLOCK) ON Z.AddrKey=CA.AddrKey
			INNER JOIN [Status] S		WITH (NOLOCK) ON S.Statuskey=C.StatusKey 
			Left join [PaymentTerms] PT WITH (NOLOCK) ON C.PaymentTermsKey = PT.PaymentTermsKey
		WHERE  C.CustKey = @CustKey		
	END
	IF @OrderTypeKey=2 AND @LoationType='Delivery' 
	BEGIN
		INSERT INTO #Temp
		SELECT
			 ST.TerminaID AS [Name],				
			 ISNULL(z.AddrKey,0) as AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country	,
			 'PORT' as Type
		FROM dbo.ShippingPortTerminals ST	WITH (NOLOCK)
			--INNER JOIN ShippingPort SP		WITH (NOLOCK) ON SP.ShippingPortKey=ST.PortKey
			INNER JOIN [Address] Z			WITH (NOLOCK) ON Z.AddrKey=ST.AddrKey
			INNER JOIN [Status] S			WITH (NOLOCK) ON S.Statuskey=ST.StatusKey 			
		WHERE S.StatusName='Active'	
	END
	IF @OrderTypeKey=3
	BEGIN
		INSERT INTO #Temp
		SELECT
			 ST.TerminaID AS [Name],				
			 ISNULL(z.AddrKey,0) as AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country		,
			 'PORT' as Type
		FROM dbo.ShippingPortTerminals ST	WITH (NOLOCK)
			--INNER JOIN ShippingPort SP		WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
			INNER JOIN [Address] Z			WITH (NOLOCK)ON Z.AddrKey=ST.AddrKey
			INNER JOIN [Status] S			WITH (NOLOCK)ON S.Statuskey=ST.StatusKey 			
		WHERE S.StatusName='Active'	
		UNION ALL
		SELECT	
			 Z.AddrName AS [Name],		
			 ISNULL(z.AddrKey,0) AS AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country,
			 'CUSTOMEr' as Type
		FROM dbo.Customer C				WITH (NOLOCK)
			INNER JOIN dbo.CustomerAddress CA	WITH (NOLOCK) ON CA.CustKey=C.CustKey
			INNER JOIN [Address] Z		WITH (NOLOCK) ON Z.AddrKey=CA.AddrKey
			INNER JOIN [Status] S		WITH (NOLOCK) ON S.Statuskey=C.StatusKey 
			Left join [PaymentTerms] PT WITH (NOLOCK) ON C.PaymentTermsKey = PT.PaymentTermsKey
		WHERE  C.CustKey = @CustKey
		UNION ALL
		SELECT  Z.AddrName AS [Name],		
			 ISNULL(z.AddrKey,0) AS AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country,
			 'YARD' as Type
		FROM [Yard] Y 
			INNER JOIN [Address] Z ON Z.AddrKey=Y.AddrKey
	END

	SELECT * FROM #Temp
	--WHERE AddrName like '%3000%'
	order by Type, Name
	For JSON PATH
	DROP TABLE #Temp
END
