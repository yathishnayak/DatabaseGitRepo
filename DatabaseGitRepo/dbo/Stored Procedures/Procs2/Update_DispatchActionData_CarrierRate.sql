
CREATE procedure [dbo].[Update_DispatchActionData_CarrierRate] -- Update_DispatchActionData_CarrierRate 368014,100
(  

	--@OrderDetailKey int = 103912,
	@RouteKey int ,
	@CarrierRate decimal 
)
AS
BEGIN
	update [routes] 
	set CarrierRate = @CarrierRate
	where  RouteKey = @RouteKey
--	where OrderDetailKey = @OrderDetailKey and RouteKey = @RouteKey


END 
