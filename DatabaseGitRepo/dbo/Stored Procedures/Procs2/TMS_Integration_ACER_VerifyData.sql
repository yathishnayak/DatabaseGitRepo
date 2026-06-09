CREATE proc TMS_Integration_ACER_VerifyData
as
Begin
	select distinct OH.ORderKey, IH.InvoiceKey
	into #TempAcerInvoice
	from  OrderHeader OH 
	inner join OrderDetail OD on OH.OrderKey = OD.OrderKey
	inner join Invoicedetail ID on OD.OrderDetailKey = ID.OrderDetailKey
	inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
	where OH.CustKey = 3165 and IH.StatusKey >= 2 

	insert into TMS_Integration_Header(SiteID, DataKey, WorkOrdernumber, WorKOrderDate, TMS_OrderKey, DataType)
	select 'ACER', AH.DataKey,OH.OrderNo,OH.OrderDate, A.OrderKey,'Update1'
	from #TempAcerInvoice A
	inner join OrderHeader OH on A.OrderKey = OH.orderkey 
	left join Integration_JCB.dbo.ACER_Header AH on OH.OrderKey = AH.TMS_OrderKey
	Left join TMS_Integration_Header TH on A.OrderKey = TH.TMS_OrderKey
	where TH.TMS_OrderKey is null

	insert into TMS_Integration_Container (SiteID, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey )
	select TH.SiteID, TH.DataKey, AC.ContainerKey, OD.ContainerNo, OD.OrderDetailKey
	from #TempAcerInvoice A
	inner join TMS_Integration_Header TH on A.OrderKey = TH.TMS_OrderKey
	inner join OrderDetail OD on TH.TMS_OrderKey = OD.OrderKey
	left join TMS_Integration_Container TC on OD.OrderDetailKey = TC.TMS_OrderDetailKey
	left join Integration_JCB.dbo.ACER_ContainerList AC on TH.DataKey = AC.DataKey and OD.ContainerNo = AC.equipmentNumber
	where TC.ContainerKey is null

	insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
	select distinct TH.Siteid, TH.DataKey, Tc.ContainerKey, SL.StopKey, Rt.RouteKey, Rt.LegKey
	from #TempAcerInvoice A
	inner join TMS_Integration_Header TH on A.OrderKey = TH.TMS_OrderKey
	inner join OrderDetail OD on TH.TMS_OrderKey = OD.OrderKey
	Inner join TMS_Integration_Container TC on OD.OrderDetailKey = TC.TMS_OrderDetailKey
	inner join Routes RT on OD.OrderDetailKey = Rt.OrderDetailKey and isnull(IsDryRun,0) = 0
	LEft join TMS_Integration_Routes TR on RT.RouteKey = Tr.TMS_RouteKey and Tr.DataKey = Th.DataKey
	left join Integration_JCB.dbo.ACER_StopList SL on TC.ContainerKey = SL.ContainerKey and SL.TMS_RouteKey = RT.RouteKey
	where TR.datakey is null and SL.StopKey is not null

	Drop table #TempAcerInvoice
END




