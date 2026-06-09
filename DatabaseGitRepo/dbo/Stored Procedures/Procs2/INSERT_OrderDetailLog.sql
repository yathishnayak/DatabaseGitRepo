
CREATE PROCEDURE [dbo].[INSERT_OrderDetailLog]
AS
BEGIN
	DECLARE @User		VARCHAR(50)
	SET @User=( SELECT SYSTEM_USER )	
	
	INSERT INTO [dbo].[OrderDetail_Log]
				(
					[OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey]
					,[Chassis],[SealNo],[Weight],[ApptDateFrom],[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay]
					,[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime],[PickupDate],[DropOffDate],[CutOffDate]
					,[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
					,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey]
					,[SourceAddrKey],[DestinationAddrKey],[CreateDate],[LastUpdateDate],[LegTypeKey],[ActionType],[ActionUser]
				)
	SELECT   [OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey],[Chassis],[SealNo],[Weight],[ApptDateFrom]
			,[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay],[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime]
			,[PickupDate],[DropOffDate],[CutOffDate],[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
			,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey],[SourceAddrKey],[DestinationAddrKey]
			,[CreateDate],[LastUpdateDate],[LegTypeKey] ,'INSERT', isnull(UpdateUserKey, CreateUserKey)
	FROM #INSERTED 

	INSERT INTO [dbo].[OrderDetail_Log]
				(
					[OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey]
					,[Chassis],[SealNo],[Weight],[ApptDateFrom],[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay]
					,[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime],[PickupDate],[DropOffDate],[CutOffDate]
					,[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
					,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey]
					,[SourceAddrKey],[DestinationAddrKey],[CreateDate],[LastUpdateDate],[LegTypeKey],[ActionType],[ActionUser]
				)
	SELECT   [OrderDetailKey],[OrderKey],[ContainerNo],[ConfirmationNo],[ContainerSizeKey],[Chassis],[SealNo],[Weight],[ApptDateFrom]
			,[ApptDateTo],[Status],[StatusDate],[HoldReasonKey],[LastFreeDay],[HoldDate],[ReturnDate],[ReturnTime],[PickupTime],[DropOffTime]
			,[PickupDate],[DropOffDate],[CutOffDate],[RouteKey],[ActualPickupTime],[ActualDropOffTime],[ActualPickupDate],[ActualDropOffDate],[ContainerID]
			,[IsHazardus],[IsOverWeight],[IsTriaxle],[NeedtobeScaled],[CommentKey],[CreateUserKey],[UpdateUserKey],[SourceAddrKey],[DestinationAddrKey]
			,[CreateDate],[LastUpdateDate],[LegTypeKey] ,'DELETE', isnull(UpdateUserKey, CreateUserKey)
	FROM #DELETED 
END
