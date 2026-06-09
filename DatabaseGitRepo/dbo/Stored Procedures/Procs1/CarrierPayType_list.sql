create proc CarrierPayType_list
as 
begin
	set nocount on
	set fmtonly off
	select PayTypeKey, PayTypeName from Carrier_PayTypes
	where isActive = 1
end
