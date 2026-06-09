
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"ContainerNo":"MSDU5636783"}'
SET	@IsDebug  = 1

EXEC [Admin_CompareMilestones] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/


CREATE PRocEDURE [dbo].[Admin_CompareMilestones] -- Admin_CompareMilestones 'NYKU355701'
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	@Result1		VARCHAR(1000)	= ''	OUTPUT,
	@Result2		VARCHAR(1000)	= ''	OUTPUT,
	@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@IsDebug		BIT				= 0
)
AS

BEGIN
	
	DECLARE @ContainerNo VARCHAR(20) = ''

	SELECT	@ContainerNo = ContainerNo
	FROM	OPENJSON(@JSONString, '$')
			WITH (
					ContainerNo			VARCHAR(20)	 '$.ContainerNo'
				)


	DECLARE @JsonResult NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#TMPRoutes') IS NOT NULL
	BEGIN
		DROP TABLE #TMPRoutes;
	END

	IF OBJECT_ID('tempdb..#TMPOrderdetail') IS NOT NULL
	BEGIN
		DROP TABLE #TMPOrderdetail;
	END


	CREATE TABLE #ContainerData
	(	
		ClientName		VARCHAR(50),
		TMS_OrderKey	INT,
		DataKey			INT,
		ContainerKey	INT,
		ContainerNo		VARCHAR(50),

		CreateDate		DATETIME
	)

	INSERT INTO #ContainerData
	SELECT		'DHL',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, H.CreateDate
	FROM		Integration_JCB.dbo.DHL_Header  H
	INNER JOIN	Integration_JCB.dbo.DHL_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

	INSERT INTO #ContainerData
	SELECT		'Flexport',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, H.CreateDate
	FROM		Integration_JCB.dbo.Flexpro_Header  H
	INNER JOIN	Integration_JCB.dbo.Flexpro_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

	INSERT INTO #ContainerData
	SELECT		'Melrose',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, H.CreateDate
	FROM		Integration_JCB.dbo.Melrose_Header  H
	INNER JOIN	Integration_JCB.dbo.Melrose_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

	INSERT INTO #ContainerData
	SELECT		'Robinson',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, H.CreateDate
	FROM		Integration_JCB.dbo.Robinson_Header  H
	INNER JOIN	Integration_JCB.dbo.Robinson_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

	INSERT INTO #ContainerData
	SELECT		'CNB',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, H.CreateDate
	FROM		Integration_JCB.dbo.CNB_Header  H
	INNER JOIN	Integration_JCB.dbo.CNB_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

	INSERT INTO #ContainerData
	SELECT		'KHNN',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, NULL AS CreateDate
	FROM		Integration_JCB.dbo.KHNN_Header  H
	INNER JOIN	Integration_JCB.dbo.KHNN_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

	INSERT INTO #ContainerData
	SELECT		'ACER',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, H.CreateDate
	FROM		Integration_JCB.dbo.ACER_Header  H
	INNER JOIN	Integration_JCB.dbo.ACER_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

	INSERT INTO #ContainerData
	SELECT		'CENTURY',TMS_OrderKey,H.DataKey,Cl.ContainerKey,CL.equipmentNumber, H.CreateDate
	FROM		Integration_JCB.dbo.CENTURY_Header  H
	INNER JOIN	Integration_JCB.dbo.CENTURY_ContainerList CL ON H.DataKey = CL.DataKey
	WHERE		CL.equipmentNumber = @ContainerNo AND ISNULL(TMS_OrderKey,'') <> ''

 

	CREATE TABLE #StopData
	(	
		DataKey				INT,
		StopKey				INT,
		ScheduledDateTime	DATETIME,
		ActualDateTime		DATETIME,
		stopNumber			INT,
		IsScheduleSent		BIT,
		ScheduleSentDate	DATETIME,
		IsActualSent		BIT,
		ActualSentDate		DATETIME,
		facilityCode		VARCHAR(20)
	)

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.DHL_StopList SL 
	INNER JOIN	Integration_JCB.dbo.DHL_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.Flexpro_StopList SL 
	INNER JOIN	Integration_JCB.dbo.Flexpro_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.Melrose_StopList SL 
	INNER JOIN	Integration_JCB.dbo.Melrose_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.Robinson_StopList SL 
	INNER JOIN	Integration_JCB.dbo.Robinson_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.CNB_StopList SL 
	INNER JOIN	Integration_JCB.dbo.CNB_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.KHNN_StopList SL 
	INNER JOIN	Integration_JCB.dbo.KHNN_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.ACER_StopList SL 
	INNER JOIN	Integration_JCB.dbo.ACER_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber

	INSERT INTO #StopData
	SELECT		Cl.DataKey,StopKey,ScheduledDateTime,ActualDateTime,SL.stopNumber, IsScheduleSent,ScheduleSentDate, IsActualSent, ActualSentDate 
				,facilityCode
	FROM		Integration_JCB.dbo.CENTURY_StopList SL 
	INNER JOIN	Integration_JCB.dbo.CENTURY_ContainerList CL ON SL.ContainerKey = CL.ContainerKey
	WHERE		CL.equipmentNumber = @ContainerNo 
	ORDER BY	stopNumber


	SELECT		RT.Routekey, L.LegID, RT.OrderKey, RT.LegNo, RT.OrderDetailKey
				,isnull(Isnull(RT.PickupDateTo,RT.PickupDateFrom), RT.ActualDeparture)ScheduledDeparture
				,isnull(isnull(RT.DeliveryDateTo, Rt.DeliveryDateFrom),RT.ActualArrival)ScheduledArrival
				, ISNULL(ActualDeparture,'')ActualDeparture,ISNULL(ActualArrival,'')ActualArrival
	INTO		#TMPRoutes
	FROm		Routes RT WITH (NOLOCK)
	INNER JOIN	Leg L WITH (NOLOCK) On RT.LegKey = L.LegKey

	--SELECT * FROM #StopData
	--SELECT * FROM #ContainerData

	SELECT		OrderDetailKey, OD.OrderKey, OD.BillOfLadding, OD.OrderTypeKey, ContainerNo 
	INTO		#TMPOrderdetail
	FROM		OrderDetail OD WITH (NOLOCK)
	WHERE		ContainerNo = @ContainerNo

	IF(@IsDebug = 1)
		BEGIN
			SELECT * FROM #TMPOrderdetail
			SELECT * FROM #ContainerData
		END

	SET @JsonResult =   (
                            SELECT		
                                ClientName,
                                CL.DataKey,
                                OD.OrderKey,
                                OrderDetailKey,
                                OD.ContainerNo,
                                ContainerKey, 
                                ISNULL(OD.BillOfLadding, OH.BillOfLading) AS MBLNo,
                                OT.OrderType,
								C.CustName  AS CustomerName,
								OrderNo AS OrderNo,
								OrderSource AS OrderSource,
								CL.CreateDate,
								OH.CustKey,
                                StopDetails = (
                                    SELECT		
                                        StopKey,
                                        ScheduledDateTime,
                                        ActualDateTime,
                                        SL.stopNumber,
                                        IsScheduleSent,
                                        ScheduleSentDate,
                                        IsActualSent,
                                        ActualSentDate,
                                        facilityCode
                                    FROM		
                                        #StopData SL  
                                        INNER JOIN	#ContainerData CD 
                                            ON SL.DataKey = CD.DataKey
                                    WHERE		
                                        CL.DataKey = CD.DataKey
                                    ORDER BY	
                                        stopNumber 
                                    FOR JSON PATH
                                ),
                                ROuteDetails = (
                                    SELECT		
                                        * 
                                    FROM 
                                        #TMPRoutes RT
                                    WHERE		
                                        RT.OrderDetailKey = ISNULL(OD.OrderDetailKey,0)
                                    Order By	
                                        LegNo
                                    FOR JSON PATH
                                )
                            FROM		
                                #TMPOrderdetail OD 
                                LEFT JOIN	#ContainerData CL  ON OD.OrderKey = ISNULL(TMS_OrderKey,0)
                                LEFT JOIN	OrderHeader OH WITH (NOLOCK)    ON OH.OrderKey = OD.OrderKey 
                                LEFT JOIN   OrderType OT WITH (NOLOCK)      ON OT.OrderTypeKey = ISNULL(OD.OrderTypeKey,OH.OrderTypeKey)
								LEFT JOIN	Customer C WITH (NOLOCK)   ON OH.CustKey = C.CustKey
                            -- WHERE ISNULL(TMS_OrderKey,0) <> 0
                            FOR JSON PATH, INCLUDE_NULL_VALUES
                        )

	SELECT @JsonResult AS JsonResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'

	DROP TABLE	#TMPRoutes
	DROP TABLE	#TMPOrderdetail
	DROP TABLE	#ContainerData

END
