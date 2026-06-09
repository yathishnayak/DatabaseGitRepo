CREATE PROCEDURE [dbo].[Scheduler_InsertUpdateGnosisData]
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

	SELECT *
	INTO #tempgnosisdata
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey	INT				'$.OrderDetailKey',
			MBL				NVARCHAR(100)	'$.MBL',
			SSLKey			INT				'$.SSLKey',
			Vessel			NVARCHAR(100)	'$.Vessel',
			ETA				DATETIME		'$.ETA',
			LFD				DATETIME		'$.LFD',
			SizeTypeKey		INT				'$.SizeTypeKey',
			StatusKey		INT				'$.StatusKey',
			Available		INT				'$.Available',
			AvailableDate	DATETIME		'$.AvailableDate',
			Hold			INT				'$.Hold',
			HoldType		INT				'$.HoldType',
			HoldNote		NVARCHAR(500)	'$.HoldNote'
		)

	DECLARE @DataCount INT=0;
	SELECT @DataCount=COUNT(1) FROM Container_GnosisData WITH (NOLOCK) WHERE OrderDetailKey=(SELECT TOP 1 OrderDetailKey FROM #tempgnosisdata)
	IF(@DataCount=0)
	BEGIN
		INSERT INTO Container_GnosisData
				(OrderDetailKey, MBL , SSLKey, Vessel, ETA_ATA, LFD, Size_Type,	
				 ContainerStatus, Available, Hold, HoldType, HoldNote, AvailableDate)
		SELECT   OrderDetailKey, MBL , SSLKey, Vessel, ETA, LFD, SizeTypeKey,	
				 StatusKey, Available, Hold, HoldType, HoldNote, AvailableDate
				FROM #tempgnosisdata
	END
	ELSE
	BEGIN
		UPDATE CGD 
		SET MBLChangedByUser=CASE WHEN ISNULL(TGD.MBL,'')<>ISNULL(CGD.MBL,'') THEN 1 ELSE CGD.MBLChangedByUser END,
			SSLChangedByUser=CASE WHEN ISNULL(TGD.SSLKey,'')<>ISNULL(CGD.SSLKey,'') THEN 1 ELSE CGD.SSLChangedByUser END,
			VesselChangedByUser=CASE WHEN ISNULL(TGD.Vessel,'')<>ISNULL(CGD.Vessel,'') THEN 1 ELSE CGD.VesselChangedByUser END,
			ETA_ATAChangedByUser=CASE WHEN ISNULL(TGD.ETA,'')<>ISNULL(CGD.ETA_ATA,'') THEN 1 ELSE CGD.ETA_ATAChangedByUser END,
			LFDChangedByUser=CASE WHEN ISNULL(TGD.LFD,'')<>ISNULL(CGD.LFD,'') THEN 1 ELSE CGD.LFDChangedByUser END,
			Size_TypeChangedByUser=CASE WHEN ISNULL(TGD.SizeTypeKey,'')<>ISNULL(CGD.Size_Type,'') THEN 1 ELSE CGD.Size_TypeChangedByUser END,
			ContainerStatusChangedByUser=CASE WHEN ISNULL(TGD.StatusKey,'')<>ISNULL(CGD.ContainerStatus,'') THEN 1 ELSE CGD.ContainerStatusChangedByUser END,
			AvailableChangedByUser=CASE WHEN ISNULL(TGD.Available,'')<>ISNULL(CGD.Available,'') THEN 1 ELSE CGD.AvailableChangedByUser END,
			HoldChangedByUser=CASE WHEN ISNULL(TGD.Hold,'')<>ISNULL(CGD.Hold,'') THEN 1 ELSE CGD.HoldChangedByUser END,
			HoldTypeChangedByUser=CASE WHEN ISNULL(TGD.HoldType,'')<>ISNULL(CGD.HoldType,'') THEN 1 ELSE CGD.HoldTypeChangedByUser END,
			AvailableDateChangedByUser=CASE WHEN ISNULL(TGD.AvailableDate,'')<>ISNULL(CGD.AvailableDate,'') THEN 1 ELSE CGD.AvailableDateChangedByUser END,

			MBL=CASE WHEN ISNULL(TGD.MBL,'')<>ISNULL(CGD.MBL,'') THEN TGD.MBL ELSE CGD.MBL END,
			SSLKey=CASE WHEN ISNULL(TGD.SSLKey,'')<>ISNULL(CGD.SSLKey,'') THEN TGD.SSLKey ELSE CGD.SSLKey END,
			Vessel=CASE WHEN ISNULL(TGD.Vessel,'')<>ISNULL(CGD.Vessel,'') THEN TGD.Vessel ELSE CGD.Vessel END,
			ETA_ATA=CASE WHEN ISNULL(TGD.ETA,'')<>ISNULL(CGD.ETA_ATA,'') THEN TGD.ETA ELSE CGD.ETA_ATA END,
			LFD=CASE WHEN ISNULL(TGD.LFD,'')<>ISNULL(CGD.LFD,'') THEN TGD.LFD ELSE CGD.LFD END,
			Size_Type=CASE WHEN ISNULL(TGD.SizeTypeKey,'')<>ISNULL(CGD.Size_Type,'') THEN TGD.SizeTypeKey ELSE CGD.Size_Type END,
			ContainerStatus=CASE WHEN ISNULL(TGD.StatusKey,'')<>ISNULL(CGD.ContainerStatus,'') THEN TGD.StatusKey ELSE CGD.ContainerStatus END,
			Available=CASE WHEN ISNULL(TGD.Available,'')<>ISNULL(CGD.Available,'') THEN TGD.Available ELSE CGD.Available END,
			Hold=CASE WHEN ISNULL(TGD.Hold,'')<>ISNULL(CGD.Hold,'') THEN TGD.Hold ELSE CGD.Hold END,
			HoldType=CASE WHEN ISNULL(TGD.HoldType,'')<>ISNULL(CGD.HoldType,'') THEN TGD.HoldType ELSE CGD.HoldType END,
			HoldNote=CASE WHEN ISNULL(TGD.HoldNote,'')<>ISNULL(CGD.HoldNote,'') THEN TGD.HoldNote ELSE CGD.HoldNote END,
			AvailableDate=CASE WHEN ISNULL(TGD.AvailableDate,'')<>ISNULL(CGD.AvailableDate,'') THEN TGD.AvailableDate ELSE CGD.AvailableDate END
		FROM Container_GnosisData CGD
		INNER JOIN #tempgnosisdata TGD ON (CGD.OrderDetailKey=TGD.OrderDetailKey)
	END
	DROP TABLE #tempgnosisdata
END
