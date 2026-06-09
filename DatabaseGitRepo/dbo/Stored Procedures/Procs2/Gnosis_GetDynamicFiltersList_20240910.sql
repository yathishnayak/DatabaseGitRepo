CREATE PROCEDURE [dbo].[Gnosis_GetDynamicFiltersList_20240910]   
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)	
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	Declare @IsDebug	bit = 0

	Declare
		@CustKeys				varchar(max),
		@CSRKeys				varchar(max),
		@CSMKeys				varchar(max),
		@ContainerStatusKeys	varchar(max),	
		@HoldStatus				varchar(20)	,
		@HoldTypes				varchar(50)	,
		@TerminalNames			varchar(max),
		@TerminalCodes			varchar(max),
		@VesselIMOs				varchar(max),
		@SalesPersonKeys		varchar(max),
		@PickupAvailable		varchar(5),			
		@PickUpFrom				datetime  ,
        @PickUpTo				datetime ,
		@DischargeYN			varchar(2),
		@IsCTF				bit		,
		@IsTMF				bit		,
		@IsLine				bit		,
		@IsOther			bit		,	
		@IsCustoms			bit		,
		@MarketKeys			VARCHAR(MAX)

	Select  @CustKeys = isnull(CustKeys,''),
		@CSRKeys = isnull(CSRKeys,''),  @ContainerStatusKeys = isnull(ContainerStatusKeys,''),
		@HoldStatus = isnull(HoldStatus,''), @TerminalNames = isnull(TerminalNames,''),
		@TerminalCodes = isnull(TerminalCodes,''), @HoldTypes = isnull(HoldTypes,''),
		@PickupAvailable = isnull(PickupAvailable,''), @VesselIMOs = isnull(VesselIMOs,''),
		@CSMKeys = isnull(CSMKeys,''), @SalesPersonKeys = isnull(SalesPersonKeys,''),
		@PickUpFrom =isnull(PickUpFrom ,''), @PickUpTo = isnull(PickUpTo ,''), @MarketKeys=ISNULL(MarketKeys,'')
	from OpenJSON(@JsonString, '$')
	WITH (
		CSRKeys				varchar(max)	'$.CSRKeys',
		ContainerStatusKeys	varchar(max)	'$.ContainerStatusKeys',
		HoldStatus			varchar(max)	'$.HoldStatus',
		HoldTypes			varchar(50)		'$.HoldTypes',
		TerminalNames		varchar(max)	'$.TerminalNames',
		TerminalCodes		varchar(max)	'$.TerminalCodes',
		VesselIMOs		    varchar(max)    '$.VesselIMOs',
		PickupAvailable		varchar(5)		'$.PickupAvailable',
		CustKeys			varchar(max)	'$.CustKeys',
		CSMKeys				varchar(max)	'$.CSMKeys',
		SalesPersonKeys		varchar(max)	'$.SalesPersonKeys',
		PickUpFrom          datetime        '$.PickUpFrom', 
		PickUpTo            datetime        '$.PickUpTo' ,
		MarketKeys          varchar(max)    '$.MarketKeys',
		DischargeYN			varchar(2)		'$.DischargeYN'
	)

	SET @IsCTF = CASE WHEN @HoldTypes LIKE '%CTF%' THEN 1 ELSE 0 END 
	SET @IsTMF = CASE WHEN @HoldTypes LIKE '%TMF%' THEN 1 ELSE 0 END 
	SET @IsLine = CASE WHEN @HoldTypes LIKE '%LINE%' THEN 1 ELSE 0 END  
	SET	@IsOther = CASE WHEN @HoldTypes LIKE '%OTHER%' THEN 1 ELSE 0 END 
	SET @IsCustoms = CASE WHEN @HoldTypes LIKE '%CUSTOMS%' THEN 1 ELSE 0 END 
	
	CREATE TABLE #CustKeys
	(
		CustKey		int,
		CustName	varchar(200)
	)
	IF(LEN(ISNULL(@CustKeys,'')) > 0)
	BEGIN
		insert into #CustKeys(CustName)
		select value from dbo.Fn_SplitParamCol(@CustKeys)

		Update CK set CustName =C.CustName
		from Customer C WITH (NOLOCK) 
		Inner join #CustKeys CK On C.CustKey = CK.CustKey
	END

	CREATE TABLE #CSRKeys
	(
		CSRKey		int,
		CSRName		varchar(100)
	)
	IF(LEN(ISNULL(@CSRKeys,'')) > 0)
	BEGIN
		insert into #CSRKeys(CSRName)
		select value from dbo.Fn_SplitParamCol(@CSRKeys)
	END

	CREATE TABLE #CSMKeys
	(
		CSMKey		int,
		CSMName		varchar(100)
	)
	IF(LEN(ISNULL(@CSMKeys,'')) > 0)
	BEGIN
		insert into #CSMKeys(CSMName)
		select value from dbo.Fn_SplitParamCol(@CSMKeys)

		update C SET CSMKey = R.CsrKey
		from #CSMKeys C
		inner join CSR R on C.CSMName = R.CsrName 
	END

	CREATE TABLE #SalesPersonKeys
	(
		SalesPersonKey		int
	)
	IF(LEN(ISNULL(@SalesPersonKeys,'')) > 0)
	BEGIN
		insert into #SalesPersonKeys(SalesPersonKey)
		select value from dbo.Fn_SplitParamCol(@SalesPersonKeys)
	END

	CREATE TABLE #ContainerStatusKeys
	(
		ContainerStatusKey		varchar(50)
	)
	IF(LEN(ISNULL(@ContainerStatusKeys,'')) > 0)
	BEGIN
		insert into #ContainerStatusKeys(ContainerStatusKey)
		select value from dbo.Fn_SplitParamCol(@ContainerStatusKeys)
	END

	CREATE TABLE #MarketKeys
	(
		MarketKey		varchar(50)
	)
	IF(LEN(ISNULL(@MarketKeys,'')) > 0)
	BEGIN
		insert into #MarketKeys(MarketKey)
		select value from dbo.Fn_SplitParamCol(@MarketKeys)
	END

	CREATE TABLE #TerminalNames
	(
		TerminalName		varchar(100)
	)
	IF(LEN(ISNULL(@TerminalNames,'')) > 0)
	BEGIN
		insert into #TerminalNames(TerminalName)
		select value from dbo.Fn_SplitParamCol(@TerminalNames)
	END

	CREATE TABLE #TerminalCodes
	(
		TerminalCode		varchar(100)
	)
	IF(LEN(ISNULL(@TerminalCodes,'')) > 0)
	BEGIN
		insert into #TerminalCodes(TerminalCode)
		select value from dbo.Fn_SplitParamCol(@TerminalCodes)
	END

	CREATE TABLE #VesselIMOs
	(
		VesselIMO		varchar(100)
	)
	IF(LEN(ISNULL(@VesselIMOs,'')) > 0)
	BEGIN
		insert into #VesselIMOs(VesselIMO)
		select value from dbo.Fn_SplitParamCol(@VesselIMOs)
	END

	

	if(@IsDebug = 1)
	Begin
		SElect
		@CustKeys  as  CustKeys, @HoldTypes as HoldTypes,
		@CSRKeys  as  CSRKey,  @ContainerStatusKeys  as  ContainerStatusKey,
		@HoldStatus  as  HoldStatus, @TerminalNames  as  TerminalNames, @TerminalCodes  as  TerminalCodes,
		@PickupAvailable  as  PickupAvailable,
		@CSMKeys  as  CSMKeys, @SalesPersonKeys  as  SalesPersonKeys,@VesselIMOs as VesselIMOs, @PickUpFrom as PickUpFrom,@PickUpTo as PickUpTo,
		@IsCTF  as  IsCTF, @IsTMF  as  IsTMF, @IsLine  as  IsLine, @IsOther  as  IsOther, @IsCustoms  as  IsCustoms

		select * from #CustKeys
		select * from #CSRKeys
		select * from #CSMKeys
		select * from #SalesPersonKeys
		select * from #ContainerStatusKeys
		select * from #TerminalNames
		select * from #TerminalCodes
		select * from #VesselIMOs
		Select * from #MarketKeys
	End

	SELECT UUID,  
	  [Delivery Location City] as DelLocCity, 
		[Order CSR] as OrderCSR, [Delivery Location State] as DelLocState, 
		[Broker Ref No] as BrokerRefNo, [Customer],[Delivery Location Name] as DelLocName
	Into #CustData
	FROM  
	(
	  SELECT a.UUID, Field_name, Field_value
	  FROM GNosis_Integration_ContainerCustomer_FINAL A
	  inner join Gnosis_Integration_Container_Final B on a.UUID = b.UUID
	) AS SourceTable  
	PIVOT  
	(  
	  max(Field_Value)
	  FOR Field_name IN ([Delivery Location City], 
		[Order CSR], [Delivery Location State], [Broker Ref No], [Customer],[Delivery Location Name])  
	) AS PivotTable;

	Select distinct Final_dest_city , 
		MarketLocation = case when Final_dest_city in ('Chicago, US','Harvey, US','Joliet, US','Elwood, US')
		Then 'Chicago' 
		when isnull(Final_dest_city,'') = '' then '' 
		else 'Long Beach' end
	into #MktLocation
	from Gnosis_Integration_Container_FINAL

		SElect distinct  CD.Container_type as ContainerSize,
			cd.ContainerStatus
			,isnull(C.OrderCSR, CR.CsrName) CSRName
			, CM.CsrName as  CSMName
			, isnull(C.Customer,CU.CustName) as Customer
			, CD.Available_for_pickup as PickupAvailable,
			Cd.Pod_terminal_name as TerminalName,
			CD.Pod_terminal_firms_code as TerminalCode,
			CD.Final_dest_city as FinalDestCity,
			H.CTF, H.Customs, H.Line, H.Other, H.TMF,
			HoldStatus = Case when CTF = 'true' OR TMF = 'true' OR Line = 'true' OR Other = 'true' OR Customs = 'true' then 1
			else 0 end,
			OH.SalesPersonKey,
			OH.MarketLocationKey,
			case when isnull(Discharged_dt,'') = '' then 'N' else 'Y' end as DischargeYN
		INTO #TempData
		FROM			Gnosis_Integration_Container_Final CD  WITH (NOLOCK) --ON CDJ.RecordKey = CD.RecordKey
		LEFT JOIN		GNosis_Integration_MBL_FINAL MB  WITH (NOLOCK) ON CD.uuid = MB.uuid
		LEFT JOIN		Gnosis_Integration_Holds_Final H  WITH (NOLOCK) ON CD.UUID = H.UUID
		LEFT JOIN		OrderDetail OD WITH (NOLOCK) ON CD.Container_number = OD.ContainerNo
		LEFT JOIN		ORDERHEADER OH WITH (NOLOCK) ON OD.ORDERKEY = OH.OrderKey
		LEFT JOIN		#CustData C on CD.uuid = C.uuid
		--LEFT JOIN		vGnosis_Container_Status CS on CD.DataKey = CS.DataKey
		Left join		CSR CM on ltrim(rtrim(C.OrderCSR)) = ltrim(rtrim(CM.CsrName))
		LEFT JOIN		CSR CR WITH (NOLOCK)  on OH.CsrKey = CR.CsrKey
		LEFT JOIN		CUSTOMER CU WITH (NOLOCK)  on OH.CustKey = CU.CustKey
		LEFT JOIN		#MktLocation ML On CD.Final_dest_city = ML.Final_dest_city
		where 
			CD.ContainerStatus not in ('Out for Delivery','Empty Returned', 'Loaded on Vessel','Ready to Load', 'At Origin') and
			(IsNULL(@ContainerStatusKeys ,'') = '' OR ContainerStatus in (Select ContainerStatusKey from #ContainerStatusKeys)) AND
			--(ISNULL(@CSRKeys,'') = '' OR C.OrderCSR in (select CSRName from #CSRKeys)) AND
			(ISNULL(@CSRKeys,'') = '' OR REPLACE(REPLACE(LTRIM(RTRIM(isnull(C.OrderCSR, CM.CsrName))),CHAR(10),''),CHAR(9),'') in (select REPLACE(REPLACE(LTRIM(RTRIM(CSRName)),CHAR(10),''),CHAR(9),'') from #CSRKeys)) AND
			(ISNULL(@CSMKeys,'') = '' OR OH.CSRManagerKey in (select CSMKey from #CSMKeys)) AND
			(ISNULL(@CustKeys,'') = '' OR C.Customer in (select CustName from #CustKeys)) AND
			(ISNULL(@SalesPersonKeys,'') = '' OR OH.SalesPersonKey in (select SalesPersonKey from #SalesPersonKeys)) AND
			(ISNULL(@PickupAvailable,'') = '' OR Case when Cd.Available_for_pickup = 'true' then 'Yes' else 'No' end =@PickupAvailable) AND
			(ISNULL(@HoldStatus,'') = '' OR 
				( @HoldStatus = case when CTF='true' OR TMF='true' OR Line='true' OR Other='true' OR Customs='true' then 'YES'
				else 'NO' end)) AND
			----CTF=@IsCTF OR TMF=@IsTMF OR Line=@IsLine OR Other=@IsOther OR Customs=@IsCustoms) AND
			(ISNULL(@PickUpFrom,'') = '' OR Pickup_appointment_dt >=@PickUpFrom) AND
			(ISNULL(@PickUpTo,'') = '' OR Pickup_appointment_dt <=@PickUpTo) AND
			(ISNULL(@DischargeYN,'') = '' OR (case when isnull(Discharged_dt,'') = '' then 'N' else 'Y' end) = @DischargeYN) AND
			(ISNULL(@TerminalNames,'') = '' OR Pod_terminal_name in (select TerminalName from #TerminalNames)) AND
			(ISNULL(@MarketKeys,'') = '' OR ML.MarketLocation in (Select MarketKey from #MarketKeys) ) 

	select 
		ContainerStatus = (
			select distinct ContainerStatus
		from #TempData
		where ContainerStatus <> ''
		Order by ContainerStatus
		FOR JSON PATH
		),
		CSRList = (
			select distinct CSRName
			from #TempData CC
			WHERE isnull(CSRName,'') <> ''
			Order by CSRName
			FOR JSON PATH
		),
		CSMList = (
			select distinct CSMName
			from #TempData CC
			WHERE isnull(CSMName,'') <> ''
			Order by CSMName
			FOR JSON PATH
		),
		CustomerList = (
			select distinct Customer, C.CustKey
			from #TempData CC
			LEft join Customer C on CC.Customer = C.CustName
			WHERE isnull(Customer,'') <> ''
			Order by Customer
			FOR JSON PATH
		),
		TerminalNameList = (
			select distinct TerminalName
			from #TempData CC
			WHERE isnull(TerminalName,'') <> ''
			Order by TerminalName
			FOR JSON PATH
		),
		SalesPersonList = (
			select distinct CC.SalesPersonKey, SalesPersonName
			from #TempData CC
			Inner join SalesPerson SP on CC.SalesPersonKey = SP.SalesPersonKey
			Order by SalesPersonName
			FOR JSON PATH
		),
		PickupAvailable = (
			select distinct CC.PickupAvailable
			from #TempData CC
			WHERE isnull(PickupAvailable,'') <> ''
			FOR JSON PATH
		),
		HoldStatus = (
			select distinct case when HoldStatus = 1 then 'Yes' else 'NO' END as HoldStatus from (
			select distinct CC.HoldStatus
			from #TempData CC
			) A
			FOR JSON PATH
		),
		HoldType = ( --case when @HoldStatus = '' then (
		SELECT distinct  HoldType FROM(
			SELECT 'CTF' AS HoldType
			UNION ALL
			SELECT 'TMF'
			UNION ALL
			SELECT 'CUSTOMS' 
			UNION ALL
			SELECT 'LINE'
			UNION ALL
			SELECT  'OTHERS'
			)A where HoldType <> ''
			FOR JSON PATH
		--)
		--when @HoldStatus = 'YES' then (
		--SELECT distinct  HoldType FROM(
		--	SELECT case when @IsCTF = 1 then 'CTF' else '' end AS HoldType
		--	UNION ALL
		--	SELECT case when @IsTMF = 1 then 'TMF' else '' end 
		--	UNION ALL
		--	SELECT case when @IsCustoms = 1 then 'CUSTOMS' else '' end
		--	UNION ALL
		--	SELECT case when @IsLine = 1 then 'LINE' else '' end
		--	UNION ALL
		--	SELECT case when @IsOther = 1 then 'OTHERS' else '' end
		--	)A where HoldType <> ''
		--	FOR JSON PATH
		--) else (select 'ALL' as HoldType) end
		),
		MarketLocation = (
			select distinct  MarketLocation
			from #TempData CC
			Inner join #MktLocation ML on CC.FinalDestCity = ML.Final_dest_city
			FOR JSON PATH
		),
		DischargeYN = (select distinct  DischargeYN
			from #TempData CC
			FOR JSON PATH
			)
	For JSON PATH
	
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
	drop table #ContainerStatusKeys
	drop table #CSMKeys 
	drop table #CSRKeys
	drop table #CustData
	drop table #CustKeys
	drop table #SalesPersonKeys
	drop table #TerminalCodes
	drop table #TerminalNames
	drop table #VesselIMOs
	drop table #TempData
	drop table #MarketKeys
	drop table #MktLocation
END