

CREATE Proc TMS_Integration_Flexport_UpdateMissingRoute -- TMS_Integration_Flexport_UpdateMissingRoute 12286
(
	@DataKey		int = 0
)
as
Begin
	set nocount on
	set fmtonly off 

	declare @cnt int = 1
	select @cnt =count(1) from TMS_Integration_Routes
	where SiteID = 'Flexport' and DataKey = @DataKey

	if(isnull(@cnt,0) = 1)
	Begin
		print 'Inserting .... '
		Begin Try
		insert into TMS_Integration_Routes(SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey)
		select distinct SD.siteid, SD.TKT_DataKey, TKT_ContainerKey, SL.StopKey, SL.TMS_RouteKey, SL.TMS_LegKey
		from TKT_RouteData RD WITH (NOLOCK) 
		inner join TKT_SyncData SD  WITH (NOLOCK) on SD.TMS_OrderDetailKey = RD.OrderDetailKey
		inner join Integration_JCB.dbo.Flexpro_StopList SL  WITH (NOLOCK) on SL.ContainerKey = SD.TKT_ContainerKey and RD.StopType <> SL.stopNumber
		LEft join TMS_integration_routes TR  WITH (NOLOCK) on SD.TKT_DataKey = TR.DataKey and SD.SiteID = TR.SiteID and TR.TMS_RouteKey = RD.RouteKey
		where  SD.SiteID = 'Flexport' and SD.TKT_DataKey = @datakey
		End Try
		Begin Catch
			print ERROR_MESSAGE()
			print 'Error in Insert'
		End Catch
	End
		
End
