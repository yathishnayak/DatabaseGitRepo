/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"OrderKey":184214}',
	@Status BIT=0,@IsDebug		BIT = 1,
	@Reason VARCHAR(100)=''
EXec [Container_EditList] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PRocedure [dbo].[Container_EditList] 
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	--INSERT INTO SqlExecutionTimeLog
	--(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	--VALUes (@UserKey,'Container_EditList','Procedure Entered','',GETDATE())

	Declare
		@OrderKey		int	= 0

	Select @OrderKey = OrderKey
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		OrderKey			INT				'$.OrderKey'
	)

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
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
	/*
	SELECT 
        
    FROM dbo.OrderHeader OH   with ( NOLOCK) 			
        LEFT JOIN dbo.Customer CUS	 with ( NOLOCK)		ON CUS.CustKey = OH.CustKey      
        LEFT JOIN dbo.[Broker] BR	 with ( NOLOCK)		ON OH.BrokerKey = BR.BrokerKey
        LEFT JOIN dbo.OrderType OT	 with ( NOLOCK)		ON OH.OrderTypeKey = OT.OrderTypeKey   

		LEFT JOIN [Address] SR	 with ( NOLOCK)			ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] DT	 with ( NOLOCK)			ON	DT.AddrKey=OH.DestinationAddrKey
		LEFT JOIN [Address] CA	 with ( NOLOCK)			ON CUS.AddrKey = CA.AddrKey
		LEFT JOIN [Address] RT	 with ( NOLOCK)			ON OH.ReturnAddrKey = RT.AddrKey
		LEFT JOIN [Address] BA	 with ( NOLOCK)			ON BR.AddrKey = BA.AddrKey
		LEFT JOIN [User] U	 with ( NOLOCK)				ON OH.CreateUserKey = U.UserKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
	*/
	
	SELECT 
		'ContainerNo'	= OD.ContainerNo	,
		'OrderTypeName'		= ISNULL(OT.OrderType	,'N/A')	,
		'OrderTypeKey'	= OD.OrderTypeKey   ,
		'BookingNo'		= OD.BookingNo,--ISNULL(OD.BookingNo	,'N/A')	,
		'Ref'			= OD.CustRefNo,--ISNULL(OD.CustRefNo	,'N/A')	,	
		'Ship_From'		=ISNULL( ODS_Fr.StopName,'N/A')	,
		'Ship_To'		= ISNULL(ODS_To.StopName,'N/A')	,
		'DropOrLive'	= ISNULL(OD.DropOrLive,'N/A')		,
		'Return_To'		= ISNULL(ODS_Re.StopName,'N/A')	,
		'StopOffA'		= ISNULL(ODS_StpA.StopName,'N/A')	,
		'StopOffB'		= ISNULL(ODS_StpB.StopName,'N/A')	,
		'Size'			= ISNULL(CSz.[Description],'N/A')	,
		'SealNo'			= ISNULL(OD.SealNo		,'N/A')	,
		'Weight'		= OD.[Weight]	,
		'WeightUnitDesc'			= CASE 
			WHEN OD.WeightUnit = 1 THEN 'LB'
			WHEN OD.WeightUnit = 2 THEN 'KG'
			ELSE ''
		END,		
		'Priority'		= ISNULL(P.[Description],'N/A')	,
		'PriorityKey'	= OD.PriorityKey   ,
		--'Properties'	= CT.TypeID		   ,
		STUFF((
            SELECT ',' + CT.ShortCode
            FROM ContainerTypesLink	CTL		WITH (NOLOCK)	
						LEFT JOIN ContainerTypes CT		WITH (NOLOCK)	ON CTL.ContainerTypeKey = CT.ContainerTypeKey
						WHERE OD.OrderDetailKey = CTL.OrderDetailKey
            FOR XML PATH('')
            ), 1, 1, '') AS Properties,
		--'Properties'=(SELECT CT.TypeID 
		--				FROM ContainerTypesLink	CTL		WITH (NOLOCK)	
		--				LEFT JOIN ContainerTypes CT		WITH (NOLOCK)	ON CTL.ContainerTypeKey = CT.ContainerTypeKey
		--				WHERE OD.OrderDetailKey = CTL.OrderDetailKey)
		'SizeKey'			= CSz.ContainerSizeKey	,
		'OrderDetailKey'= OD.OrderDetailKey,
		'ODStopKeySF' = ODS_Fr.OrderDetailStopKey,
		'ODStopKeyST' = ODS_To.OrderDetailStopKey,
		'ODStopKeyRT' = ODS_Re.OrderDetailStopKey,
		'ODStopKeySTA' = ODS_StpA.OrderDetailStopKey,
		'ODStopKeySTB' = ODS_StpB.OrderDetailStopKey,

		'StopAddrKeySF' = ODS_Fr.StopAddrKey,
		'StopAddrKeyST' = ODS_To.StopAddrKey,
		'StopAddrKeyRT' = ODS_Re.StopAddrKey,
		'StopAddrKeySTA' = ODS_StpA.StopAddrKey,
		'StopAddrKeySTB' = ODS_StpB.StopAddrKey,

		'LocTypeSF'		= ODS_Fr.LocationType,
		'LocTypeST'		= ODS_To.LocationType,
		'LocTypeRT'		= ODS_Re.LocationType,
		'LocTypeSTA'	= ODS_StpA.LocationType,
		'LocTypeSTB'	= ODS_StpB.LocationType,

		'StatusKey' = OD.[Status],
		'CsrKey'    = CR.CsrKey,
		'CsrName'   = ISNULL(CR.CsrName,'N/A'),
		OD.WeightUnit
	FROM OrderDetail OD WITH (NOLOCK)
		INNER JOIN OrderHeader			OH			WITH (NOLOCK)	ON OD.OrderKey = OH.OrderKey
		INNER JOIN OrderType			OT			WITH (NOLOCK)	ON ISNULL(OD.OrderTypeKey,OH.OrderTypeKey) = OT.OrderTypeKey
		LEFT JOIN [Priority]			P			WITH (NOLOCK)	ON ISNULL(OD.PriorityKey,OH.PriorityKey) = P.PriorityKey
--		LEFT JOIN OrderDetailStops		ODS			WITH (NOLOCK)	ON OD.OrderDetailKey = ODS.OrderDetailKey
		--LEFT JOIN OrderDetailStops		ODS_Fr		WITH (NOLOCK)	ON OD.ShipFromStopKey = ODS_Fr.OrderDetailStopKey
		--LEFT JOIN OrderDetailStops		ODS_To		WITH (NOLOCK)	ON OD.ShipToStopKey = ODS_To.OrderDetailStopKey
		--LEFT JOIN OrderDetailStops		ODS_Re		WITH (NOLOCK)	ON OD.ReturnToStopKey = ODS_Re.OrderDetailStopKey
		LEFT JOIN OrderDetailStops		ODS_Fr		WITH (NOLOCK)	ON OD.OrderDetailKey = ODS_Fr.OrderDetailKey AND ODS_Fr.StopTypeKey = 1 
																	AND ISNULL(ODS_Fr.IsDryRunCustomer,0) = 0 
																	AND ISNULL(ODS_Fr.IsDryRunPort,0) = 0
		LEFT JOIN OrderDetailStops		ODS_To		WITH (NOLOCK)	ON OD.OrderDetailKey = ODS_To.OrderDetailKey AND ODS_To.StopTypeKey = 3 
																	AND ISNULL(ODS_To.IsDryRunCustomer,0) = 0 
																	AND ISNULL(ODS_To.IsDryRunPort,0) = 0
		LEFT JOIN OrderDetailStops		ODS_Re		WITH (NOLOCK)	ON OD.OrderDetailKey = ODS_Re.OrderDetailKey AND ODS_Re.StopTypeKey = 5
																	AND ISNULL(ODS_Re.IsDryRunCustomer,0) = 0 
																	AND ISNULL(ODS_Re.IsDryRunPort,0) = 0
		--LEFT JOIN OrderDetailStops		ODS_StpA	WITH (NOLOCK)	ON OD.StopOffA_StopKey = ODS_StpA.OrderDetailStopKey
		--LEFT JOIN OrderDetailStops		ODS_StpB	WITH (NOLOCK)	ON OD.StopOffB_StopKey = ODS_StpB.OrderDetailStopKey
		OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODS WITH (NOLOCK)
						WHERE ODS.OrderDetailKey = OD.OrderDetailKey
						  AND ODS.StopTypeKey = 2
						  AND ISNULL(ODS.IsDryRunCustomer, 0) = 0
						  AND ISNULL(ODS.IsDryRunPort, 0) = 0
						ORDER BY ODS.StopNumber ASC
						) ODS_StpA --ON OD.OrderDetailKey = ODS_StpA.OrderDetailKey

		OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODS WITH (NOLOCK)
						WHERE ODS.OrderDetailKey = OD.OrderDetailKey
						  AND ODS.StopTypeKey = 4
						  AND ISNULL(ODS.IsDryRunCustomer, 0) = 0
						  AND ISNULL(ODS.IsDryRunPort, 0) = 0
						ORDER BY ODS.StopNumber ASC
						) ODS_StpB --ON OD.OrderDetailKey = ODS_StpA.OrderDetailKey
		LEFT JOIN ContainerSize			CSz			WITH (NOLOCK)	ON OD.ContainerSizeKey = CSz.ContainerSizeKey
		LEFT JOIN CSR                   CR          WITH (NOLOCK)   ON OD.CSRKey  = CR.CsrKey    
		--LEFT JOIN ContainerTypesLink	CTL			WITH (NOLOCK)	ON OD.OrderDetailKey = CTL.OrderDetailKey
		--LEFT JOIN ContainerTypes		CT			WITH (NOLOCK)	ON CTL.ContainerTypeKey = CT.ContainerTypeKey

	WHERE OH.OrderKey = @orderKey and OD.Status<>15
   FOR JSON PATH, INCLUDE_NULL_VALUES


	--INSERT INTO SqlExecutionTimeLog
	--(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	--VALUes (@UserKey,'Container_EditList','Procedure Execution end','',GETDATE())

	SET @Status = 1
	SET @Reason = 'Success'
	SET ARITHABORT OFF;

	
END
 