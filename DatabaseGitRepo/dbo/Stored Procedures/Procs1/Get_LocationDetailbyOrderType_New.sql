/*
declare @UserKey INT = 486, @JSONString NVARCHAR(MAX), @JSONOutput NVARCHAR(MAX), @Status BIT = 0, @Reason VARCHAR(1000) = ''
set @JSONString = '{"OrderTypeKey": 0,"LoationType": "Pickup","CustKey": 3165}'
exec [Get_LocationDetailbyOrderType_New] @UserKey, @JSONString, @JSONOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
SELECT @Status, @Reason, @JSONOutput 

*/
CREATE PRocEDURE [dbo].[Get_LocationDetailbyOrderType_New] 
(
	@UserKey      INT,
	@JSONString   NVARCHAR(MAX),
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @OrderTypeKey	INT= 1, @LoationType	VARCHAR(20) ='Delivery', @CustKey	INT=16

	SELECT @OrderTypeKey = OrderTypeKey, @LoationType = LoationType,@CustKey = CustKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
		OrderTypeKey  INT         '$.OrderTypeKey',
		LoationType	  VARCHAR(20) '$.LoationType',
		CustKey	      INT         '$.CustKey' 
	)
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
		PHone		VARCHAR(50),
		Email		VARCHAR(100),
		Email2		VARCHAR(100),
		Phone2		VARCHAR(50),
		Fax			VARCHAR(50)
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
			  ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			  ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.ShippingPortTerminals ST WITH (NOLOCK)
			INNER JOIN ShippingPort SP	WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
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
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
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
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.Customer C				WITH (NOLOCK)
			INNER JOIN dbo.CustomerAddress CA	WITH (NOLOCK) ON CA.CustKey=C.CustKey
			INNER JOIN [Address] Z		WITH (NOLOCK) ON Z.AddrKey=CA.AddrKey
			INNER JOIN [Status] S		WITH (NOLOCK) ON S.Statuskey=C.StatusKey 
			Left join [PaymentTerms] PT WITH (NOLOCK) ON C.PaymentTermsKey = PT.PaymentTermsKey
		WHERE S.StatusName='Active'	AND C.CustKey = @CustKey
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
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.ShippingPortTerminals ST	WITH (NOLOCK)
			INNER JOIN ShippingPort SP		WITH (NOLOCK) ON SP.ShippingPortKey=ST.PortKey
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
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
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
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
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
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax 
		FROM [Yard] Y 
			INNER JOIN [Address] Z ON Z.AddrKey=Y.AddrKey
	END

	IF @OrderTypeKey=4 AND( @LoationType='Pickup' OR @LoationType='Return' )
	BEGIN
		INSERT INTO #Temp
		SELECT	
			 Z.AddrName AS [Name],			
			 ISNULL(z.AddrKey,0) AS AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.Yard C				WITH (NOLOCK)
			INNER JOIN [Address] Z		WITH (NOLOCK) ON Z.AddrKey=C.AddrKey
		WHERE C.IsActive = 1
	END
	IF @OrderTypeKey=4 AND @LoationType='Delivery' 
	BEGIN
		INSERT INTO #Temp
		SELECT
			 ST.TerminaID AS [Name],				
			 ISNULL(z.AddrKey,0) as AddrKey,
			 ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1
			 ,ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			 ISNULL(Z.ZipCode,'') AS ZipCode
			 ,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			 ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.ShippingPortTerminals ST	WITH (NOLOCK)
			INNER JOIN ShippingPort SP		WITH (NOLOCK) ON SP.ShippingPortKey=ST.PortKey
			INNER JOIN [Address] Z			WITH (NOLOCK) ON Z.AddrKey=ST.AddrKey
			INNER JOIN [Status] S			WITH (NOLOCK) ON S.Statuskey=ST.StatusKey 			
		WHERE S.StatusName='Active'
	END
	IF @OrderTypeKey=0 --AND @LoationType='Pickup' 
	BEGIN
		INSERT INTO #Temp
		SELECT	
			 Z.AddrName AS [Name],			
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
		WHERE S.StatusName='Active'	AND C.CustKey = @CustKey
		UNION ALL
		SELECT	
			  ST.TerminaID AS [Name],		  
			  ISNULL(z.AddrKey,0) AS AddrKey,
			  ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1,
			  ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City ,ISNULL(Z.State,'') AS [State],
			  ISNULL(Z.ZipCode,'') AS ZipCode,
			  ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
			  ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax			
		FROM dbo.ShippingPortTerminals ST WITH (NOLOCK)
			INNER JOIN ShippingPort SP	WITH (NOLOCK)ON SP.ShippingPortKey=ST.PortKey
			INNER JOIN [Address] Z		WITH (NOLOCK)ON Z.AddrKey=ST.AddrKey
			INNER JOIN [Status] S		WITH (NOLOCK)ON S.Statuskey=ST.StatusKey 			
		WHERE S.StatusName='Active' AND Z.AddrKey IN (SELECT OD.SourceAddrKey FROM OrderDetail OD
		INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey 
		WHERE CustKey=@CustKey AND OH.Status NOT IN(5,6,7,8,9))
	END

	set @JSONOutput = (SELECT * FROM #Temp Order By [Name] FOR JSON PATH)
	set @Status = 1
	set @Reason = 'Success'
	SELECT @JSONOutput
	DROP TABLE #Temp
END
