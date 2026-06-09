/*

DECLARE 
	@UserKey	INT = 486, 
	@JSONString NVARCHAR(MAX), 
	@JSONOutput NVARCHAR(MAX), 
	@Status		BIT = 0, 
	@Reason		VARCHAR(1000) = '',
	@IsDebug	bit = 1
	SET @JSONString = '{"OrderDetailKey":1,"LocationType":"From","LegKey":2}'
EXEC [Location_GetByLeg] @UserKey, @JSONString, @JSONOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @ISDebug
SELECT @Status, @Reason, @JSONOutput 

*/
CREATE PROCEDURE [dbo].[Location_GetByLeg]
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
	DECLARE @OrderDetailKey	INT, @LegKey	Int , @CustomerKey	INT, @MarketKey INT,
		@Location	varchar(50), @LocationType varchar(10)

	SELECT @OrderDetailKey = OrderDetailKey, @LegKey = LegKey,
		@LocationType = LocationType
	FROM OPENJSON(@JSONString,'$')
    WITH (
		OrderDetailKey  INT         '$.OrderDetailKey',
		LegKey			int			'$.LegKey',
		LocationType	varchar(10) '$.LocationType'
	)

	select @CustomerKey = Custkey 
	from orderdetail OD WITH (NOLOCK)
	inner join ORderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	where OrderDetailKey = @OrderDetailKey

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
	if(@LocationType = 'From')
	Begin
		Select @Location = fromlocation from Leg WITH (NOLOCK) where LegKey = @Legkey
	End
	if(@LocationType = 'To')
	Begin
		Select @Location = ToLocation from Leg WITH (NOLOCK) where LegKey = @Legkey
	End

	if(@IsDebug = 1)
	Begin
		SELECT @OrderDetailKey as orderDetailKey, @LegKey as LegKey,
			@CustomerKey as CustomerKey, @LocationType as LocationType,
			@Location as Location
	End

	select * into #Port from #Temp 
	select * into #Customer from #Temp
	Select * into #Yard from #Temp 

	if(@Location = 'Port')
	Begin
		INSERT INTO #Temp
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
		WHERE  ISNULL(ST.IsActive,0) = 1 and ISNULL(ST.IsDeleted,0) = 0
		ORDER BY [Name]
	End

	if(@Location in ('Customer','Consignee','Shipper'))
	Begin

		INSERT INTO #Temp
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
		WHERE S.StatusName='Active'	AND C.CustKey = @CustomerKey 
		ORDER BY [Name]
	End

	if(@Location in ('Yard','Warehouse','Depot','Scale'))
	Begin
		INSERT INTO #Temp
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
		WHERE C.IsActive = 1
		ORDER BY [Name]
	End
	
		
	if(@IsDebug = 1)
	Begin
		SELECT '#temp' as Head, * from #temp
	End	

	set @JSONOutput = (SELECT * FROM #Temp  FOR JSON PATH)
	set @Status = 1
	set @Reason = 'Success'
	SELECT @JSONOutput
	DROP TABLE #Temp
END