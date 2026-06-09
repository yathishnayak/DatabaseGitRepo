
CREATE PROCEDURE [dbo].[TMS_Integrations_GetLocationByLegKey] -- [TMS_Integrations_GetLocationByLegKey] 'From', 180, 28
@LoationType	VARCHAR(20) ='PICKUP',
@CustKey		INT = 16 ,
@LegKey			SMALLINT= 13
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @Location VARCHAR(30);	
	IF @LoationType='PICKUP'
	BEGIN
		SET @Location= ( SELECT FromLocation FROM dbo.leg WHERE LegKey= @LegKey)
	END

	--select @Location

	IF @LoationType='DELIVERY'
	BEGIN
		SET @Location= ( SELECT ToLocation FROM dbo.leg WHERE LegKey= @LegKey)
	END

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
		Type		varchar(50)
	);
	--****************************Import***********************************
		IF  @Location = 'Customer'  OR @Location = 'Consignee'
		BEGIN
			INSERT INTO #Temp
			SELECT	
				 Z.AddrName AS [Name],			
				 ISNULL(z.AddrKey,0) AS AddrKey,
				 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
				 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
				 ISNULL(Z.ZipCode,'') AS ZipCode
				 ,ISNULL(Z.Country,'')AS Country
				 , 'Customer' as Type
			FROM dbo.Customer C						WITH (NOLOCK)
				INNER JOIN dbo.CustomerAddress CA	WITH (NOLOCK) ON CA.CustKey=C.CustKey
				INNER JOIN [Address] Z				WITH (NOLOCK) ON Z.AddrKey=CA.AddrKey
				INNER JOIN [Status] S				WITH (NOLOCK) ON S.Statuskey=C.StatusKey 	
			WHERE S.StatusName='Active'	AND C.CustKey = @CustKey
		END;
		IF @Location='Port' OR @Location='Shipper' 
		BEGIN
			INSERT INTO #Temp
			SELECT	
				  ST.TerminaID AS [Name],		  
				  ISNULL(z.AddrKey,0) AS AddrKey,
				  ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1,
				  ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
				  ISNULL(Z.ZipCode,'') AS ZipCode,
				  ISNULL(Z.Country,'')AS Country	
				  , 'PORT' as Type
			FROM dbo.ShippingPortTerminals ST WITH (NOLOCK)
				INNER JOIN ShippingPort SP	WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
				INNER JOIN [Address] Z		WITH (NOLOCK)ON Z.AddrKey=ST.AddrKey
				INNER JOIN [Status] S		WITH (NOLOCK)ON S.Statuskey=ST.StatusKey 			
			WHERE S.StatusName='Active'	
		END
		IF @Location='Yard' OR @Location = 'Depot' OR @Location ='Warehouse'
		BEGIN
			INSERT INTO #Temp
			SELECT  Z.AddrName AS [Name],		
				 ISNULL(z.AddrKey,0) AS AddrKey,
				 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
				 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
				 ISNULL(Z.ZipCode,'') AS ZipCode
				 ,ISNULL(Z.Country,'')AS Country
				 , 'Yard' as Type
			FROM [Yard] Y 
				INNER JOIN [Address] Z ON Z.AddrKey=Y.AddrKey
		END
		IF @Location='All'
		BEGIN
			INSERT INTO #Temp
			SELECT
				 ST.TerminaID AS [Name],				
				 ISNULL(z.AddrKey,0) as AddrKey,
				 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
				 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
				 ISNULL(Z.ZipCode,'') AS ZipCode
				 ,ISNULL(Z.Country,'')AS Country	
				 , 'PORT' as Type
			FROM dbo.ShippingPortTerminals ST	WITH (NOLOCK)
				INNER JOIN ShippingPort SP		WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
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
				 ,ISNULL(Z.Country,'')AS Country	
				 , 'Customer' as Type
			FROM dbo.Customer C				WITH (NOLOCK)
				INNER JOIN dbo.CustomerAddress CA	WITH (NOLOCK) ON CA.CustKey=C.CustKey
				INNER JOIN [Address] Z		WITH (NOLOCK) ON Z.AddrKey=CA.AddrKey
				INNER JOIN [Status] S		WITH (NOLOCK) ON S.Statuskey=C.StatusKey 
				Left join [PaymentTerms] PT WITH (NOLOCK) ON C.PaymentTermsKey = PT.PaymentTermsKey
			WHERE S.StatusName='Active' AND C.CustKey = @CustKey
			UNION ALL
			SELECT  Z.AddrName AS [Name],		
				 ISNULL(z.AddrKey,0) AS AddrKey,
				 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
				 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
				 ISNULL(Z.ZipCode,'') AS ZipCode
				 ,ISNULL(Z.Country,'')AS Country
				 , 'YARD' as Type
			FROM [Yard] Y 
				INNER JOIN [Address] Z ON Z.AddrKey=Y.AddrKey
		END

	SELECT * FROM #Temp
	order by Type, Name
	for JSON PATH
	DROP TABLE #Temp;
END
