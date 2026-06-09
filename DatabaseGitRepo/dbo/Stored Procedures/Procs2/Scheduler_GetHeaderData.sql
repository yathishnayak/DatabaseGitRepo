/*
	DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='{"OrderDetailKey":175659}',@Status BIT=0,@IsDebug		BIT = 0, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
	Exec Scheduler_GetHeaderData @UserKey,@JSONString, @IsDebug,@Status OUTPUT,@Reason OUTPUT
	Select @JsonOutput, @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Scheduler_GetHeaderData]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	
	DECLARE @JsonOutput NVARCHAR(MAX), @GnosisCount INT=0, @BondedCount INT=0
	
	
	DECLARE @OrderDetailKey INT =	0
	SELECT @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderDetailKey			INT			'$.OrderDetailKey'
		)

	DECLARE @OrderKey INT =  (SELECT TOP 1 OrderKey FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey = @OrderDetailKey )

	IF(ISNULL(@OrderKey,0) > 0)
		BEGIN
			EXEC Insert_OrderDetailStops_ByOrderKey @OrderKey
		END

	CREATE TABLE #tmp(JsonOutput NVARCHAR(MAX))
	INSERT INTO #tmp
	Exec OrderDetail_GetStopList @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, 0
	select @JsonOutput=JsonOutput FROM #Tmp

	--SELECT @GnosisCount= COUNT(1) FROM Gnosis_Integration_Container_Final  WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
	SELECT @GnosisCount= COUNT(1) FROM Container_GnosisData WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey  
	SELECT @BondedCount= COUNT(1) FROM ContainerTypesLink WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey  AND ContainerTypeKey=16

	SELECT ISNULL(OD.OrderTypeKey,OH.OrderTypeKey) OrderTypeKey,
		   --ISNULL(OD.PriorityKey,2) PriorityKey,
		   CASE WHEN ISNULL(OD.PriorityKey,2) IN (1,2,3,4) THEN null ELSE OD.PriorityKey END PriorityKey,
		   ISNULL(Od.BookingNo,'')BookingNo,
		   ISNULL(CustRefNo,brokerrefno)CustRefNo,ISNULL(TMFCheckOff,0)TMFCheckOff,ISNULL(CTFCheckOff,0)CTFCheckOff,
		   ISNULL(OD.BillOfLadding,OH.BillOfLading) AS MBL,
		   ISNULL(SizeCheckOff,0)SizeCheckOff,IsTMFJCTPaid,IsTMFCustomerPaid,IsCTFJCTPaid,IsCTFCustomerPaid,
		   --MBL,LFD,SSLKey,Size_Type,Hold,Vessel,VesselETA,ContainerStatusKey,Available,HoldType,HoldNote,
	       CASE WHEN @GnosisCount>0 THEN CAST(1 AS BIT)  ELSE CAST(0 AS BIT) END  IsGnosisTracking,
	       ISNULL(OD.CSRKey,OH.CSRKey) CSRKey,JCTPaidDemurrage,ISNULL(OD.LinkedContainerNo,'') LinkedContainerNo,
		   ISNULL(OD.MarkedNoEmptyAvailable,0) AS NoEmptyMarked,DropOrLive,
		   IsContainerLinked=CASE WHEN ISNULL(OD.LinkedContainerNo,'')='' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
	       GnosisData=JSON_QUERY((
						   SELECT MBL,CAST(LFD AS datetime) LFD,ISNULL(SSLKey,OHI.SteamShipLinekey) SSLKey, 
						   ISNULL(CGD.Size_Type,ODI.ContainerSizeKey) AS SizeTypeKey,Hold,Vessel,
						   CAST(ETA_ATA AS DATETIME) AS ETA,ContainerStatus AS StatusKey,
						   CASE WHEN Available=0 THEN CAST(0 AS INT) ELSE CAST(1 AS INT) END Available,
						   HoldType,HoldNote,AvailableDate, ETA_ATAChangedByUser,ContainerStatusChangedByUser,
						   ISNULL(MBLChangedByUser,0) MBLChangedByUser,LFDChangedByUser,SSLChangedByUser,
						   Size_TypeChangedByUser,HoldChangedByUser,VesselChangedByUser,
						   AvailableChangedByUser,HoldTypeChangedByUser,AvailableDateChangedByUser
						   FROM OrderDetail ODI WITH (NOLOCK)
						   LEFT JOIN Container_GnosisData CGD WITH (NOLOCK) ON ODI.OrderDetailKey=CGD.OrderDetailKey
						   INNER JOIN OrderHeader OHI WITH (NOLOCK) ON OHI.OrderKey=ODI.OrderKey
						   Where ODI.OrderDetailKey=@OrderDetailKey 
						   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)),
		 StopDetails=JSON_QUERY(@JsonOutput),
		 ISNULL(OD.SenderInfo,OH.SenderInfo) AS SenderInfo,
		 ISNULL(OD.Consignee,OH.Consignee) AS Consignee,
		 ISNULL(OD.ConsigneeKey,OH.ConsigneeKey) AS ConsigneeKey,
		 ISNULL (PTTChecked,0) PTTChecked, 
   IsbondedExist = CASE WHEN @BondedCount >0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM OrderDetail OD  WITH (NOLOCK)
	INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
	--LEFT JOIN Container_GnosisData CGD WITH (NOLOCK) ON CGD.OrderDetailKey=OD.OrderDetailKey
	WHERE OD.OrderDetailKey=@OrderDetailKey
	FOR JSON PATH, Without_Array_Wrapper;
	SET @Status=1;
	SET @Reason='Success';
	DROP TABLE #Tmp
END
