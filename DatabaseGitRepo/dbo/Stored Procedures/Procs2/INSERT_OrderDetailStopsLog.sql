


CREATE PROCEDURE [dbo].[INSERT_OrderDetailStopsLog]
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
		INSERT INTO [Table_Log].dbo.[OrderDetailStops_Log]
					 ([OrderDetailStopKey],[OrderDetailKey],[OrderStopKey],[StopTypeKey],[StopName],[StopNameSetUserKey],[StopNameSetDateTime],[StopAddrKey],
                     [StopNumber],[LocationType],[SchedulePickupDate],[SchedulePickupUserKey],[SchedulePickupSetDateTime],[SchedulePickupDateTo],[SchedulePickupToUserKey],
					 [SchedulePickupToSetDateTime],[ActualPickupDate],[ActualPickupUserKey],[ActualPickupSetDateTime],[ScheduleDeliveryDate],[ScheduleDeliveryUserKey],
					 [ScheduleDeliverySetDateTime],[ScheduleDeliveryDateTo],[ScheduleDeliveryToUserKey],[ScheduleDeliveryToSetDateTime],[ActualDeliveryDate],
					 [ActualDeliveryUserKey],[ActualDeliverySetDateTime],[ToRouteKey],[FromRouteKey],[StatusKey],[CreateDate],[CreateUserKey],[UpdateDate],
					 [UpdateUserKey],[IsDryRunPort],[DryRunPortSetDateTime],[DryRunPortSetUserKey],[IsDryRunCustomer],[DryRunCustomerSetDateTime],
					 [DryRunCustomerSetUserKey],[RefNo],[IsTMFChecked],[IsCTFChecked],[TMFCheckUserKey],[CTFCheckUserKey],[TMFCheckDate],[CTFCheckDate],
					 [ReasonCode],[DropOrLive],[DropOrLiveSetUserKey],[DropOrLiveSetDatetime],[ExceptionReasonCode],[ExceptionRCSetUserKey],[ExceptionRCSetDateTime],
					 [IsDeleted],[DeleteUserKey],[DeleteDate],[IsBobTail],[BobtailSetDateTime],[BobtailSetUserKey],[IsEmpty],[EmptySetDateTime],[EmptySetUserKey],
					 [IsStreetTurn],[StreetSturnSetDateTime],[StreetSturnSetUserKey],[IsChassisSplit],[ChassisSplitSetDateTime],[ChassisSplitSetUserKey],[Is247Pickup],
					 [Is247PickupMarkedby],[Is247PickupMarkedDate],[Is247Delivery],[Is247DeliveryMarkedBy],[Is247DeliveryMarkedDate],[StopIndex],[Action],
      				 [ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [OrderDetailStopKey],[OrderDetailKey],[OrderStopKey],[StopTypeKey],[StopName],[StopNameSetUserKey],[StopNameSetDateTime],[StopAddrKey],
                     [StopNumber],[LocationType],[SchedulePickupDate],[SchedulePickupUserKey],[SchedulePickupSetDateTime],[SchedulePickupDateTo],[SchedulePickupToUserKey],
					 [SchedulePickupToSetDateTime],[ActualPickupDate],[ActualPickupUserKey],[ActualPickupSetDateTime],[ScheduleDeliveryDate],[ScheduleDeliveryUserKey],
					 [ScheduleDeliverySetDateTime],[ScheduleDeliveryDateTo],[ScheduleDeliveryToUserKey],[ScheduleDeliveryToSetDateTime],[ActualDeliveryDate],
					 [ActualDeliveryUserKey],[ActualDeliverySetDateTime],[ToRouteKey],[FromRouteKey],[StatusKey],[CreateDate],[CreateUserKey],[UpdateDate],
					 [UpdateUserKey],[IsDryRunPort],[DryRunPortSetDateTime],[DryRunPortSetUserKey],[IsDryRunCustomer],[DryRunCustomerSetDateTime],
					 [DryRunCustomerSetUserKey],[RefNo],[IsTMFChecked],[IsCTFChecked],[TMFCheckUserKey],[CTFCheckUserKey],[TMFCheckDate],[CTFCheckDate],
					 [ReasonCode],[DropOrLive],[DropOrLiveSetUserKey],[DropOrLiveSetDatetime],[ExceptionReasonCode],[ExceptionRCSetUserKey],[ExceptionRCSetDateTime],
					 [IsDeleted],[DeleteUserKey],[DeleteDate],[IsBobTail],[BobtailSetDateTime],[BobtailSetUserKey],[IsEmpty],[EmptySetDateTime],[EmptySetUserKey],
					 [IsStreetTurn],[StreetSturnSetDateTime],[StreetSturnSetUserKey],[IsChassisSplit],[ChassisSplitSetDateTime],[ChassisSplitSetUserKey],[Is247Pickup],
					 [Is247PickupMarkedby],[Is247PickupMarkedDate],[Is247Delivery],[Is247DeliveryMarkedBy],[Is247DeliveryMarkedDate],[StopIndex],'INSERT',
					 GETDATE(),isnull(UpdateUserKey, CreateUserKey), @Type
		FROM #inserted 
	END

			
	if(@Type = 'Update' OR @Type = 'Delete')
	Begin
		Declare @DeleteUserKey	int = 0
		if(@Type='Delete')
		Begin
			select @DeleteUserKey = OD.UpdateUserKey
			from #Deleted D
			inner join OrderDetailStops_Deleted OD on D.OrderDetailStopKey = OD.OrderDetailStopKey
		End

		INSERT INTO [Table_Logs].dbo.[OrderDetailStops_Log]
					([OrderDetailStopKey],[OrderDetailKey],[OrderStopKey],[StopTypeKey],[StopName],[StopNameSetUserKey],[StopNameSetDateTime],[StopAddrKey],
                     [StopNumber],[LocationType],[SchedulePickupDate],[SchedulePickupUserKey],[SchedulePickupSetDateTime],[SchedulePickupDateTo],[SchedulePickupToUserKey],
					 [SchedulePickupToSetDateTime],[ActualPickupDate],[ActualPickupUserKey],[ActualPickupSetDateTime],[ScheduleDeliveryDate],[ScheduleDeliveryUserKey],
					 [ScheduleDeliverySetDateTime],[ScheduleDeliveryDateTo],[ScheduleDeliveryToUserKey],[ScheduleDeliveryToSetDateTime],[ActualDeliveryDate],
					 [ActualDeliveryUserKey],[ActualDeliverySetDateTime],[ToRouteKey],[FromRouteKey],[StatusKey],[CreateDate],[CreateUserKey],[UpdateDate],
					 [UpdateUserKey],[IsDryRunPort],[DryRunPortSetDateTime],[DryRunPortSetUserKey],[IsDryRunCustomer],[DryRunCustomerSetDateTime],
					 [DryRunCustomerSetUserKey],[RefNo],[IsTMFChecked],[IsCTFChecked],[TMFCheckUserKey],[CTFCheckUserKey],[TMFCheckDate],[CTFCheckDate],
					 [ReasonCode],[DropOrLive],[DropOrLiveSetUserKey],[DropOrLiveSetDatetime],[ExceptionReasonCode],[ExceptionRCSetUserKey],[ExceptionRCSetDateTime],
					 [IsDeleted],[DeleteUserKey],[DeleteDate],[IsBobTail],[BobtailSetDateTime],[BobtailSetUserKey],[IsEmpty],[EmptySetDateTime],[EmptySetUserKey],
					 [IsStreetTurn],[StreetSturnSetDateTime],[StreetSturnSetUserKey],[IsChassisSplit],[ChassisSplitSetDateTime],[ChassisSplitSetUserKey],[Is247Pickup],
					 [Is247PickupMarkedby],[Is247PickupMarkedDate],[Is247Delivery],[Is247DeliveryMarkedBy],[Is247DeliveryMarkedDate],[StopIndex],[Action],
      				 [ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [OrderDetailStopKey],[OrderDetailKey],[OrderStopKey],[StopTypeKey],[StopName],[StopNameSetUserKey],[StopNameSetDateTime],[StopAddrKey],
                     [StopNumber],[LocationType],[SchedulePickupDate],[SchedulePickupUserKey],[SchedulePickupSetDateTime],[SchedulePickupDateTo],[SchedulePickupToUserKey],
					 [SchedulePickupToSetDateTime],[ActualPickupDate],[ActualPickupUserKey],[ActualPickupSetDateTime],[ScheduleDeliveryDate],[ScheduleDeliveryUserKey],
					 [ScheduleDeliverySetDateTime],[ScheduleDeliveryDateTo],[ScheduleDeliveryToUserKey],[ScheduleDeliveryToSetDateTime],[ActualDeliveryDate],
					 [ActualDeliveryUserKey],[ActualDeliverySetDateTime],[ToRouteKey],[FromRouteKey],[StatusKey],[CreateDate],[CreateUserKey],[UpdateDate],
					 [UpdateUserKey],[IsDryRunPort],[DryRunPortSetDateTime],[DryRunPortSetUserKey],[IsDryRunCustomer],[DryRunCustomerSetDateTime],
					 [DryRunCustomerSetUserKey],[RefNo],[IsTMFChecked],[IsCTFChecked],[TMFCheckUserKey],[CTFCheckUserKey],[TMFCheckDate],[CTFCheckDate],
					 [ReasonCode],[DropOrLive],[DropOrLiveSetUserKey],[DropOrLiveSetDatetime],[ExceptionReasonCode],[ExceptionRCSetUserKey],[ExceptionRCSetDateTime],
					 [IsDeleted],[DeleteUserKey],[DeleteDate],[IsBobTail],[BobtailSetDateTime],[BobtailSetUserKey],[IsEmpty],[EmptySetDateTime],[EmptySetUserKey],
					 [IsStreetTurn],[StreetSturnSetDateTime],[StreetSturnSetUserKey],[IsChassisSplit],[ChassisSplitSetDateTime],[ChassisSplitSetUserKey],[Is247Pickup],
					 [Is247PickupMarkedby],[Is247PickupMarkedDate],[Is247Delivery],[Is247DeliveryMarkedBy],[Is247DeliveryMarkedDate],[StopIndex],'DELETE',
					 GETDATE(), Case when @Type = 'Delete' then @DeleteUserKey else  isnull(UpdateUserKey, CreateUserKey) end, @Type
		FROM #deleted 
	END
END

