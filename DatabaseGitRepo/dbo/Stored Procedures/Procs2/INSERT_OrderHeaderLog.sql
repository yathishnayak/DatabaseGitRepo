


CREATE PROCEDURE [dbo].[INSERT_OrderHeaderLog]
(
	@Type	varchar(10) = 'Update'
)
AS
BEGIN	
	DECLARE @User		VARCHAR(50)
	SET @User=( SELECT SYSTEM_USER )	
--***************Insert Only******************	
	if(@Type = 'Update' OR @Type = 'Insert')
	Begin
		INSERT INTO [JCB_Logs].dbo.[ORderHeader_Log]
		(OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey, DestinationAddrKey, ReturnAddrKey, 
		SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, PortoForiginKey, CarrierKey, 
		VesselName, BillOfLading, BookingNo, IsHazardous, IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, 
		Ach_Enabled, Ach_Amount, CreateUserKey, LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, ConsigneeAddrKey, CompanyKey,
		CsrKey, CommentKey, ETADate, BaseRateAmount, SalesPersonKey, ReleaseNo, IntegrationWONo,CSRManagerKey, OrderSource, 
		MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive, ConsigneeKey, 
		ActionDate, ActionType, ActionUserKey, ActionMode)
		SELECT  	
			OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey, DestinationAddrKey, ReturnAddrKey, 
			SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, PortoForiginKey, CarrierKey, 
			VesselName, BillOfLading, BookingNo, IsHazardous, IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, 
			Ach_Enabled, Ach_Amount, CreateUserKey, LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, ConsigneeAddrKey, CompanyKey,
			CsrKey, CommentKey, ETADate, BaseRateAmount, SalesPersonKey, ReleaseNo, IntegrationWONo,CSRManagerKey, OrderSource, 
			MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive, ConsigneeKey, 
			GETDATE(),'INSERT',isnull(LastUpdateUserKey, CreateUserKey), @Type
		FROM #inserted 
	END

			
	if(@Type = 'Update' OR @Type = 'Delete')
	Begin
		Declare @DeleteUserKey	int = 0
		if(@Type='Delete')
		Begin
			select @DeleteUserKey = OH.LastUpdateUserKey
			from #Deleted D
			inner join Orderheader_Deleted OH WITH(NOLOCK) on D.orderKey = OH.OrderKey
		End

		INSERT INTO [JCB_Logs].dbo.[ORderHeader_Log]
		(OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey, DestinationAddrKey, ReturnAddrKey, 
		SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, PortoForiginKey, CarrierKey, 
		VesselName, BillOfLading, BookingNo, IsHazardous, IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, 
		Ach_Enabled, Ach_Amount, CreateUserKey, LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, ConsigneeAddrKey, CompanyKey,
		CsrKey, CommentKey, ETADate, BaseRateAmount, SalesPersonKey, ReleaseNo, IntegrationWONo,CSRManagerKey, OrderSource, 
		MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive, ConsigneeKey, 
		ActionDate, ActionType, ActionUserKey, ActionMode)
		SELECT  	
				OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey, DestinationAddrKey, ReturnAddrKey, 
				SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, PortoForiginKey, CarrierKey, 
				VesselName, BillOfLading, BookingNo, IsHazardous, IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, 
				Ach_Enabled, Ach_Amount, CreateUserKey, LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, ConsigneeAddrKey, CompanyKey,
				CsrKey, CommentKey, ETADate, BaseRateAmount, SalesPersonKey, ReleaseNo, IntegrationWONo,CSRManagerKey, OrderSource, 
				MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive, ConsigneeKey, 
				GETDATE(),'DELETE', Case when @Type = 'Delete' then @DeleteUserKey else  isnull(LastUpdateUserKey, CreateUserKey) end, @Type
		FROM #deleted 
	END
END

