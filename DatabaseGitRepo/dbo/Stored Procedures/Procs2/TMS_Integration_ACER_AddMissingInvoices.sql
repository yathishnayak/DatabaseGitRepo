CREATE Proc [dbo].[TMS_Integration_ACER_AddMissingInvoices]
as
Begin
	insert into TMS_Integration_Header
	select 'ACER' SiteID, AH.DataKey, AH.WorkOrdernumber, AH.WorKOrderDate, AH.TMS_OrderKey, 'DIRECT' DataType
	from Integration_JCB.dbo.ACER_Header AH
	left join TMS_Integration_Header TH on AH.DataKey = TH.DataKey AND TH.SiteID = 'ACER'
	where TH.DataKey is null 

	insert into TMS_Integration_Container
	select 'ACER' SiteID, AC.DataKey, AC.ContainerKey, AC.equipmentNumber, AC.TMSOrderDetailKey
	from Integration_JCB.dbo.ACER_Header AH
	inner join Integration_JCB.dbo.ACER_ContainerList AC on AH.DataKey = Ac.DataKey
	inner join TMS_Integration_Header TH on AH.DataKey = TH.DataKey AND TH.SiteID = 'ACER'
	LEft join TMS_Integration_Container TC on TH.DataKey = Tc.DataKey AND TC.SiteID = 'ACER'
	where tc.DataKey is null
End

