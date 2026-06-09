

/*
DECLARE @Res NVARCHAR(MAX)
EXEC TMS_Integration_VerificationReport_Delete  '','FANU3261658','','', @Res OUTPUT
SELECT @Res
*/

CREATE PROCEDURE [dbo].[TMS_Integration_VerificationReport_Delete]
(
		 @OrderNo			VARCHAR(20)	 = ''
		,@ContainerNo		VARCHAR(20)	 = ''
		,@ShipmentRefNo		VARCHAR(50)  = ''
		,@WorkOrderNo		VARCHAR(50) = ''
		,@Result			NVARCHAR(MAX)  OUTPUT
)
AS
CREATE TABLE #TmpOrderKey
(
	OrderKey INT 
)

DECLARE		@ORDERKEY	INT,
			@CustKey	int,
			@SiteId		varchar(20)

Select TOp 1 @OrderKey = OH.OrderKey	, @CustKey = CustKey
From OrderHeader OH
inner join ORderDetail OD on OH.OrderKey = OD.ORderKey
where (OrderNo =  @OrderNo  OR 
		case when OD.ContainerNo = '' then '--' else OD.ContainerNo end = @ContainerNo OR 
		case when OH.BrokerRefNo = '' then '--' else OH.BrokerRefNo end  = @ShipmentRefNo OR 
		case when BookingNo = '' then '--' else BookingNo end = @WorkOrderNo)
		ORDER BY OH.OrderKey  DESC

SEt @SiteID = case when @Custkey = 1966 then 'Flexport'
					   When @Custkey = 2867 then 'EDRAY'
					   When @Custkey = 3170 then 'DHL'
					   When @Custkey = 1652 then 'DHL'
					   When @Custkey = 3024 then 'DHL'
					   When @Custkey = 3165 then 'ACER'
					   When @Custkey = 1559 then 'ROBINSON'
					   When @Custkey = 1718 then 'ROBINSON'
					   When @CustKey = 2155 then 'KHNN'
					   else '' end

Print @OrderKey
Print @CustKey
print @SiteID

IF(ISNULL(@ShipmentRefNo,'')<>'')
BEGIN
	INSERT INTO #TmpOrderKey 
	SELECT OrderKey FROM ORderHeader  WHERE BrokerRefNo LIKE '%' + @ShipmentRefNo + '%'
END

if(Isnull(@WorkOrderNo,'') <> '')
BEGIN
	INSERT INTO #TmpOrderKey 
	SELECT OrderKey FROM ORderHeader  WHERE BookingNo LIKE '%' + @WorkOrderNo + '%'
END

CREATE TABLE #Integration
(
	SiteID			varchar(50),
	DataKey			int,
	TMS_ORderKey	int,
	ContainerNo		varchar(50),
	workOrderNumber	varchar(50),
	TMS_ORderDetailKey		int
)
if(@siteid = 'Flexport')
Begin
	insert into #Integration (SiteID, DataKey, TMS_ORderKey,  ContainerNo, workOrderNumber, TMS_ORderDetailKey)
	select @SiteID, FH.datakey, FH.TMS_OrderKey, FC.equipmentNumber, FH.workOrderNumber, FC.TMSOrderDetailKey
	from Integration_JCB.dbo.Flexpro_Header FH
	inner join Integration_JCB.dbo.Flexpro_ContainerList FC on FH.DataKey = FC.DataKey
	where @SiteID = 'Flexport'  and (
		 FH.TMS_OrderNo = @ORderno OR
		 FC.equipmentNumber = @ContainerNo OR
		 FH.shipmentReferenceNumber like '%' + case when @ShipmentRefNo = '' then '--' else  @ShipmentRefNo  end + '%'  
		OR FH.workOrderNumber = @WorkOrderNo )
End
SELECT * FROm #Integration
if(@siteid = 'Robinson')
Begin
	insert into #Integration (SiteID, DataKey, TMS_ORderKey,  ContainerNo, workOrderNumber, TMS_ORderDetailKey)
	select @SiteID, FH.datakey, FH.TMS_OrderKey, FC.equipmentNumber, FH.workOrderNumber, FC.TMSOrderDetailKey
	from Integration_JCB.dbo.Robinson_Header FH
	inner join Integration_JCB.dbo.Robinson_ContainerList FC on FH.DataKey = FC.DataKey
	where @SiteID = 'Robinson'  and (
		 FH.TMS_OrderNo = @ORderno OR
		 FC.equipmentNumber = @ContainerNo OR
		 FH.shipmentReferenceNumber like '%' + case when @ShipmentRefNo = '' then '--' else  @ShipmentRefNo  end + '%'  
		OR FH.workOrderNumber = @WorkOrderNo )
End

if(@siteid = 'DHL')
Begin
	insert into #Integration (SiteID, DataKey, TMS_ORderKey,  ContainerNo, workOrderNumber, TMS_ORderDetailKey)
	select @siteID, FH.datakey, FH.TMS_OrderKey, FC.equipmentNumber, FH.workOrderNumber, FC.TMSOrderDetailKey
	from Integration_JCB.dbo.DHL_Header FH
	inner join Integration_JCB.dbo.DHL_ContainerList FC on FH.DataKey = FC.DataKey
	where @SiteID = 'DHL' and (
		 FH.TMS_OrderNo = @ORderno OR
		 FC.equipmentNumber = @ContainerNo OR
		 FH.shipmentReferenceNumber like '%' + case when @ShipmentRefNo = '' then '--' else  @ShipmentRefNo  end + '%'  
		OR FH.workOrderNumber = @WorkOrderNo )
End

if(@siteid = 'EDRAY')
Begin
	insert into #Integration (SiteID, DataKey, TMS_ORderKey,  ContainerNo, workOrderNumber, TMS_ORderDetailKey)
	select @SiteID, FH.datakey, FH.TMS_OrderKey, FC.equipmentNumber, FH.workOrderNumber, FC.TMSOrderDetailKey
	from Integration_JCB.dbo.EDRAY_Header FH
	inner join Integration_JCB.dbo.EDRAY_ContainerList FC on FH.DataKey = FC.DataKey
	where @SiteID = 'EDRAY' and (
		 FH.TMS_OrderNo = @ORderno OR
		 FC.equipmentNumber = @ContainerNo OR
		 FH.shipmentReferenceNumber like '%' + case when @ShipmentRefNo = '' then '--' else  @ShipmentRefNo  end + '%'  
		OR FH.workOrderNumber = @WorkOrderNo )
End

if(@siteid = 'KHNN')
Begin
	insert into #Integration (SiteID, DataKey, TMS_ORderKey,  ContainerNo, workOrderNumber, TMS_ORderDetailKey)
	select @SiteID, FH.datakey, FH.TMS_OrderKey, FC.equipmentNumber, FH.workOrderNumber, TMSOrderDetailKey
	from Integration_JCB.dbo.KHNN_Header FH
	inner join Integration_JCB.dbo.KHNN_ContainerList FC on FH.DataKey = FC.DataKey
	where @SiteID = 'KHNN' and (
		 FH.TMS_OrderNo = @ORderno OR
		 FC.equipmentNumber = @ContainerNo OR
		 FH.shipmentReferenceNumber like '%' + case when @ShipmentRefNo = '' then '--' else  @ShipmentRefNo  end + '%'  
		OR FH.workOrderNumber = @WorkOrderNo )
End

if(@siteid = 'ACER')
Begin
	insert into #Integration (SiteID, DataKey, TMS_ORderKey,  ContainerNo, workOrderNumber, TMS_ORderDetailKey)
	select @SiteID, FH.datakey, FH.TMS_OrderKey, FC.equipmentNumber, FH.workOrderNumber, FC.TMSOrderDetailKey
	from Integration_JCB.dbo.ACER_Header FH
	inner join Integration_JCB.dbo.ACER_ContainerList FC on FH.DataKey = FC.DataKey
	where @SiteID = 'ACER'  and (
		 FH.TMS_OrderNo = @ORderno OR
		 FC.equipmentNumber = @ContainerNo OR
		 FH.shipmentReferenceNumber like '%' + case when @ShipmentRefNo = '' then '--' else  @ShipmentRefNo  end + '%'  
		OR FH.workOrderNumber = @WorkOrderNo )
End

--select '#Integration',* from #Integration

SELECT				OH.OrderKey , I.SiteID	, I.DataKey
INTO				#SelectedRecord
FROM				OrderHeader OH
INNER JOIN			OrderDetail OD ON OD.OrderKey = OH.OrderKey 
LEFT JOIN			TMS_Integration_Header TH ON OH.OrderKey = TH.TMS_OrderKey 
LEFT JOIN			TMS_Integration_Container TC ON TH.DataKey = TC.DataKey AND TH.SiteID = TC.SiteID 
					and OD.OrderDetailKey = TC.TMS_OrderDetailKey
LEft join			#Integration I on TH.DataKey = I.DataKey and TH.SiteID = I.SiteID and OD.OrderDetailKey = I.TMS_ORderDetailKey
WHERE				(ISNULL(@OrderNo,'') = ''  OR OH.OrderNo  = @OrderNo ) 
					AND (ISNULL(@WorkOrderNo,'') = ''  OR I.workOrderNumber = @WorkOrderNo )
					AND (ISNULL(@ContainerNo,'') = '' OR OD.ContainerNo = @ContainerNo OR   I.ContainerNo = @ContainerNo)
					AND (ISNULL(@ShipmentRefNo,'') = '' OR OH.OrderKey IN (SELECT OrderKey from #TmpOrderKey))

SELECT * FROM #SelectedRecord

if(isnull(@Orderkey,0) = 0 OR isnull(@SiteID,'') = '')
Begin
	Return '';
End

create table #990
(
	SiteID	varchar(50),
	DataKey		int,
	DocKey			int,
	DocControlNo	varchar(20),
	DocContent		nvarchar(max),
	DocCreated		DateTime,
	DocUploaded		DateTime
)

if(@Siteid = 'Flexport')
Begin
insert into #990 (SiteID, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
select @SiteID as Siteid, A.DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded 
	from Integration_JCB.dbo.Flexpro_990DocData A
	inner join #SelectedRecord I on a.DataKey = I.DataKey
	where SiteID = @SiteID
End
if(@Siteid = 'Robinson')
Begin
insert into #990 (SiteID, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
select @SiteID as Siteid, A.DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded 
	from Integration_JCB.dbo.Robinson_990DocData A
	inner join #SelectedRecord I on a.DataKey = I.DataKey
	where SiteID = @SiteID
End
if(@Siteid = 'DHL')
Begin
insert into #990 (SiteID, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
select @SiteID as Siteid, A.DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded 
	from Integration_JCB.dbo.DHL_990DocData A
	inner join #SelectedRecord I on a.DataKey = I.DataKey
	where SiteID = @SiteID
End

if(@Siteid = 'EDRAY')
Begin
	insert into #990 (SiteID, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
	select @SiteID as Siteid, A.DataKey, DocKey, Doc_Content, '', Doc_Date, Doc_Date
		from Integration_JCB.dbo.EDRAY_990Docs A
		inner join #SelectedRecord I on a.DataKey = I.DataKey
		where SiteID = @SiteID
End

if(@Siteid = 'KHNN')
Begin
	insert into #990 (SiteID, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
	select @SiteID as Siteid, A.DataKey, DocKey, '', --Doc_Content, 
		'', Doc_Date, Doc_Date
		from Integration_JCB.dbo.KHNN_990Docs A
		inner join #SelectedRecord I on a.DataKey = I.DataKey
		where SiteID = @SiteID
End

--Select '990', * from #990

create table #997
(
	SiteID			varchar(50),
	FileProcessKey	int,
	DataKey			int,
	DocKey			int,
	DocControlNo	varchar(20),
	DocContent		nvarchar(max),
	DocCreated		DateTime,
	DocUploaded		DateTime
)

if(@Siteid = 'Flexport')
Begin
	insert into #997 (SiteID,FileProcessKey, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'Flexport' as Siteid,FH.FileProcessKey, FH.DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded 
		from Integration_JCB.dbo.Flexpro_997DocData A
		inner join Integration_JCB.dbo.Flexpro_Header FH on A.FileProcessKey = FH.FileProcessKey
		inner join #SelectedRecord I on FH.DataKey = I.DataKey
		where SiteID = @SiteID
End
if(@Siteid = 'Robinson')
Begin
	insert into #997 (SiteID,FileProcessKey, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'Robinson' as Siteid,FH.FileProcessKey, FH.DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded 
		from Integration_JCB.dbo.Robinson_997DocData A
		inner join Integration_JCB.dbo.Robinson_Header FH on A.FileProcessKey = FH.FileProcessKey
		inner join #SelectedRecord I on FH.DataKey = I.DataKey
		where SiteID = @SiteID
End

if(@Siteid = 'DHL')
Begin
	insert into #997 (SiteID,FileProcessKey, DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'DHL' as Siteid, FH.FileProcessKey, FH.DataKey, DocKey, DocContent, DocControlNo, DocCreated, DocUploaded 
		from Integration_JCB.dbo.DHL_997DocData A
		inner join Integration_JCB.dbo.DHL_Header FH on A.FileProcessKey = FH.FileProcessKey
		inner join #SelectedRecord I on FH.DataKey = I.DataKey
		where SiteID = @SiteID
End

--Select '997', * from #997

create table #214
(
	SiteID			varchar(50),
	DataKey			int,
	DocKey			int,
	StopKey			int,
	StopType		varchar(20),
	ScheduleActual	char(1),
	DocControlNo	varchar(20),
	DocContent		nvarchar(max),
	DocCreated		DateTime,
	DocUploaded		DateTime
)

if(@Siteid = 'Flexport')
Begin
	insert into #214 (SiteID, DataKey, DocKey,StopKey,StopType, ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'Flexport' as Siteid, A.DataKey, DocKey,StopKey, A.StopType, A.ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded 
	from Integration_JCB.dbo.Flexpro_214DocData A
	inner join #SelectedRecord I on A.DataKey = I.DataKey
	where SiteID = @SiteID
End
if(@Siteid = 'Robinson')
Begin
	insert into #214 (SiteID, DataKey, DocKey,StopKey,StopType, ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'Robinson' as Siteid, A.DataKey, DocKey,StopKey, A.StopType, A.ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded 
	from Integration_JCB.dbo.Robinson_214DocData A
	inner join #SelectedRecord I on A.DataKey = I.DataKey
	where SiteID = @SiteID
End
if(@Siteid = 'DHL')
Begin
	insert into #214 (SiteID, DataKey, DocKey,StopKey,StopType, ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'DHL' as Siteid, A.DataKey, DocKey,StopKey, A.StopType, A.ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded 
	from Integration_JCB.dbo.DHL_214DocData A
	inner join #SelectedRecord I on A.DataKey = I.DataKey
	where SiteID = @SiteID
End

if(@Siteid = 'EDRAY')
Begin
	insert into #214 (SiteID, DataKey, DocKey,StopKey,StopType, ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'EDRAY' as Siteid, A.DataKey, DocKey, A.StopKey, '', A.ScheduledActual, a.Doc_Content, '', A.Doc_Date, A.Doc_Date
	from Integration_JCB.dbo.EDRAY_214Docs A
	inner join #SelectedRecord I on A.DataKey = I.DataKey
	where SiteID = @SiteID
End

if(@Siteid = 'KHNN')
Begin
	insert into #214 (SiteID, DataKey, DocKey,StopKey,StopType, ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'KHNN' as Siteid, A.DataKey, DocKey, A.StopKey, '', A.ScheduledActual, a.Doc_Content, '', A.Doc_Date, A.Doc_Date
	from Integration_JCB.dbo.EDRAY_214Docs A
	inner join #SelectedRecord I on A.DataKey = I.DataKey
	where SiteID = @SiteID
End

if(@Siteid = 'ACER')
Begin
	insert into #214 (SiteID, DataKey, DocKey,StopKey,StopType, ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded )
	select 'ACER' as Siteid, A.DataKey, DocKey,StopKey, A.StopType, A.ScheduleActual, DocContent, DocControlNo, DocCreated, DocUploaded 
	from Integration_JCB.dbo.ACER_214DocData A
	inner join #SelectedRecord I on A.DataKey = I.DataKey
	where SiteID = @SiteID
End

--Select '214', * from #214

SELECT				top 1 TH.SiteID, TH.DataKey,WorkOrdernumber,WorKOrderDate,TMS_OrderKey,DataType,TC.ContainerKey,ContainerNo,TMS_OrderDetailKey
INTO				#LINKTMP
FROM				TMS_Integration_Header TH
LEFT JOIN			TMS_Integration_Container TC ON TH.DataKey = TC.DataKey AND TH.SiteID = TC.SiteID 
WHERE				TH.TMS_OrderKey = @ORDERKEY and TH.SiteID = @SiteID 

--select * from #LINKTMP
create table #Header
(
	SiteID						varchar(20),
	DataKey						int,
	FileProcessKey				int,
	originatorCode				varchar(100), 
	receiverCode				varchar(100), 
	category					varchar(100),  
	workOrderNumber				varchar(100), 
	workOrderDate				varchar(100),  
	shipmentReferenceNumber		varchar(100),  
	billOfLadingNumber			varchar(100),  
	vessel						varchar(100),  
	shipper						varchar(100),  
	carrierCode					varchar(100), 
	Consignee					varchar(100)
)

if(@Siteid = 'Flexport')
Begin
	insert into #Header (SiteID,DataKey, FilePRocessKey, originatorCode, receiverCode, category, workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee)
	select @siteID, FH.DataKey, FilePRocessKey, originatorCode, receiverCode, category, FH.workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee
	from Integration_JCB.dbo.Flexpro_Header FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where @siteID = 'Flexport'
End
if(@Siteid = 'Robinson')
Begin
	insert into #Header (SiteID,DataKey, FilePRocessKey, originatorCode, receiverCode, category, workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee)
	select @siteID, FH.DataKey, FilePRocessKey, originatorCode, receiverCode, category, FH.workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee
	from Integration_JCB.dbo.Robinson_Header FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where @siteID = 'Robinson'
End
if(@Siteid = 'DHL')
Begin
	insert into #Header (SiteID,DataKey, FilePRocessKey, originatorCode, receiverCode, category, workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee)
	select @siteID, FH.DataKey, FilePRocessKey, originatorCode, receiverCode, category, FH.workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee
	from Integration_JCB.dbo.DHL_Header FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where @siteID = 'DHL'
End

if(@Siteid = 'ACER')
Begin
	insert into #Header (SiteID,DataKey, FilePRocessKey, originatorCode, receiverCode, category, workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee)
	select @siteID, FH.DataKey, FilePRocessKey, originatorCode, receiverCode, category, FH.workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, 	vessel, shipper, carrierCode, Consignee
	from Integration_JCB.dbo.ACER_Header FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where @siteID = 'ACER'
End

if(@Siteid = 'EDRAY')
Begin
	insert into #Header (SiteID,DataKey, FilePRocessKey, originatorCode, receiverCode, category, workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, vessel, shipper, carrierCode, Consignee)
	select @siteID, FH.DataKey, FilePRocessKey, originatorCode, receiverCode, category, FH.workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, vessel, shipper, carrierCode, Consignee
	from Integration_JCB.dbo.EDRAY_Header FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where @siteID = 'EDRAY'
End


if(@Siteid = 'KHNN')
Begin
	insert into #Header (SiteID,DataKey, FilePRocessKey, originatorCode, receiverCode, category, workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, vessel, shipper, carrierCode, Consignee)
	select @siteID, FH.DataKey, FilePRocessKey, originatorCode, receiverCode, category, FH.workOrderNumber, workOrderDate, 
		shipmentReferenceNumber, billOfLadingNumber, vessel, shipper, carrierCode, Consignee
	from Integration_JCB.dbo.KHNN_Header FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where @siteID = 'KHNN'
End
--Select * from #Header

Create Table #Container
(
	DataKey				int,
	ContainerKey		int,
	equipmentNumber		varchar	(50),
	equipmentTypeCode	varchar	(50),
	pieceCount			varchar	(20),
	grossWeight			varchar	(20),
	weightUOM			varchar	(20),
	volume				varchar	(20),
	volumeUOM			varchar (20),
	freightDescription	varchar (100),
	isHazmat			varchar (20),
	sealNumberList		varchar (200),
	TMS_ContainerSizeKey int,
	TMSOrderDetailKey	int,
	HazardInfo			varchar(200)
)

if(@Siteid = 'Flexport')
Begin
	insert into #Container (DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo)
	select FH.DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo
	from Integration_JCB.dbo.Flexpro_ContainerList FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where I.SiteId = 'Flexport'
End
if(@Siteid = 'Robinson')
Begin
	insert into #Container (DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo)
	select FH.DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo
	from Integration_JCB.dbo.Robinson_ContainerList FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where I.SiteId = 'Robinson'
End
if(@Siteid = 'DHL')
Begin
	insert into #Container (DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo)
	select FH.DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo
	from Integration_JCB.dbo.DHL_ContainerList FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where I.SiteId = 'DHL'
End

if(@Siteid = 'EDRAY')
Begin
	insert into #Container (DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo)
	select FH.DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo
	from Integration_JCB.dbo.EDRAY_ContainerList FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where I.SiteId = 'EDRAY'
End


if(@Siteid = 'KHNN')
Begin
	insert into #Container (DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo)
	select FH.DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, ''
	from Integration_JCB.dbo.KHNN_ContainerList FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where I.SiteId = 'KHNN'
End
if(@Siteid = 'ACER')
Begin
	insert into #Container (DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo)
	select FH.DataKey, ContainerKey, equipmentNumber, equipmentTypeCode, pieceCount, grossWeight, weightUOM, volume, volumeUOM, 
			freightDescription, isHazmat, sealNumberList, TMS_ContainerSizeKey, TMSOrderDetailKey, HazardInfo
	from Integration_JCB.dbo.ACER_ContainerList FH 
	inner join #SelectedRecord I on Fh.DataKey = I.DataKey
	where I.SiteId = 'ACER'
End

--Select * from #Container

create table #StopList
(
	SiteID				varchar(20),
	[StopKey]			[int] ,
	[ContainerKey]		[int] ,
	[stopType]			[varchar](50),
	[stopName]			[varchar](100) ,
	[stopNumber]		[varchar](10),
	[facilityCode]		[varchar](50),
	[stopReferenceNumber] [varchar](10),
	[address1]			[varchar](100),
	[Address2]			[varchar](100),
	[city]				[varchar](100),
	[state]				[varchar](20),
	[country]			[varchar](20),
	[postalCode]		[varchar](20),
	[ScheduledDateTime] [datetime] ,
	[IsScheduleSent]	[bit] ,
	[ActualDateTime]	[datetime] ,
	[IsActualSent]		[bit] ,
	[ScheduleSentDate]	[datetime] ,
	[ActualSentDate]	[datetime] ,
	[IsDocSent]			[bit] ,
	[DocSentDate]		[datetime] 
)

if(@Siteid = 'Flexport')
Begin
	insert into #StopList (SiteID, StopKey, ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate)
	select @SiteID, StopKey, FL.ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate
	from Integration_JCB.dbo.Flexpro_StopList FL 
	inner join integration_JCB.dbo.Flexpro_ContainerList CL on FL.ContainerKey = CL.ContainerKey
	inner join #SelectedRecord I on CL.DataKey = I.DataKey
	where I.SiteId = @SiteID
END
if(@Siteid = 'Robinson')
Begin
	insert into #StopList (SiteID, StopKey, ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate)
	select @SiteID, StopKey, FL.ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate
	from Integration_JCB.dbo.Robinson_StopList FL 
	inner join integration_JCB.dbo.Robinson_ContainerList CL on FL.ContainerKey = CL.ContainerKey
	inner join #SelectedRecord I on CL.DataKey = I.DataKey
	where I.SiteId = @SiteID
END
if(@Siteid = 'DHL')
Begin
	insert into #StopList ( SiteID,StopKey, ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate)
	select @SiteID,StopKey, FL.ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate
	from Integration_JCB.dbo.DHL_StopList FL 
	inner join integration_JCB.dbo.DHL_ContainerList CL on FL.ContainerKey = CL.ContainerKey
	inner join #SelectedRecord I on CL.DataKey = I.DataKey
	where I.SiteId = @SiteID
END

if(@Siteid = 'ACER')
Begin
	insert into #StopList (SiteID, StopKey, ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate)
	select @SiteID, StopKey, FL.ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, 0, null
	from Integration_JCB.dbo.ACER_StopList FL 
	inner join integration_JCB.dbo.ACER_ContainerList CL on FL.ContainerKey = CL.ContainerKey
	inner join #SelectedRecord I on CL.DataKey = I.DataKey
	where I.SiteId = @SiteID
END

if(@Siteid = 'EDRAY')
Begin
	insert into #StopList (SiteID, StopKey, ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate)
	select @SiteID, StopKey, FL.ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, '', city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, 0, null
	from Integration_JCB.dbo.EDRAY_StopList FL 
	inner join integration_JCB.dbo.EDRAY_ContainerList CL on FL.ContainerKey = CL.ContainerKey
	inner join #SelectedRecord I on CL.DataKey = I.DataKey
	where I.SiteId = @SiteID
END


if(@Siteid = 'KHNN')
Begin
	insert into #StopList (SiteID, StopKey, ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, Address2, city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate)
	select @SiteID, StopKey, FL.ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber, address1, '', city, 
		state, country, postalCode, ScheduledDateTime , IsScheduleSent, ActualDateTime, IsActualSent, ScheduleSentDate, 
		ActualSentDate, IsDocSent, DocSentDate
	from Integration_JCB.dbo.KHNN_StopList FL 
	inner join integration_JCB.dbo.KHNN_ContainerList CL on FL.ContainerKey = CL.ContainerKey
	inner join #SelectedRecord I on CL.DataKey = I.DataKey
	where I.SiteId = @SiteID
END
--select * from #StopList

SET @Result = (
SELECT		OH.OrderKey, OD.SealNo  , OH.OrderNo,OH.OrderDate,OH.BrokerRefNo, C.CustID,C.CustName,OH.CustKey, OD.ContainerNo
			, Props =	(SELECT	 * 
						FROM	vContainerType CT 
						WHERE	CT.OrderDetailKey = OD.OrderDetailKey  FOR JSON PATH )
			, Link =	(SELECT		*
									, Routes =	(SELECT	RT.RouteKey,L.LegID,L.FromLocation,L.ToLocation,
													RT.PickupDateFrom,RT.PickupDateTo,
														RT.DeliveryDateFrom,RT.DeliveryDateTo,
														RT.ActualArrival ,RT.ActualDeparture ,
														RT.IsDryRun,RT.IsEmpty
												FROM			Routes RT 
												INNER JOIN		Leg L ON RT.LegKey = L.LegKey 
												WHERE			RT.OrderDetailKey = OD.OrderDetailKey  FOR JSON PATH ),  
									Integration = (SELECT		*,
													Doc990 = (SELECT * FROM #990 F9 WHERE F9.DataKey = FH.DataKey  FOR JSON PATH) ,
													Doc997 = (SELECT * FROM #997 F7 WHERE F7.FileProcessKey = FH.FileProcessKey 
																FOR JSON PATH ),
													Container = (SELECT		* ,
																[StopList] =(SELECT			* ,
																			Doc214 =(SELECT	* 
																					FROM	#214 FD 
																					WHERE	FD.DataKey = FH.DataKey AND FD.StopKey = FS.StopKey 
																					FOR JSON PATH  )
																			FROM	#StopList FS 
																			WHERE	FS.ContainerKey = FC.ContainerKey FOR JSON PATH )
																FROM		#Container FC 
																WHERE		FC.DataKey = FH.DataKey  FOR JSON PATH)
						FROM			#Header FH  
						--WHERE			FH.DataKey = LN.DataKey AND LN.SiteID = @SiteID  
						FOR JSON PATH )
			FROM			#LINKTMP LN 
			WHERE			(OH.OrderKey = LN.TMS_OrderKey)					
			FOR JSON PATH)					
FROM		OrderHeader OH
INNER JOIN	OrderDetail OD ON OD.OrderKey = OH.OrderKey
INNER JOIN	Customer C ON OH.CustKey = C.CustKey
WHERE		Oh.OrderKey = @ORDERKEY
			FOR JSON PATH )