
CREATE proc [dbo].[TMS_Integration_VerifyWorkOrderNo] -- TMS_Integration_VerifyWorkOrderNo 'S00138706',630
(
	@WorkOrderNumber	varchar(100) = '',
	@CustKey			int = 0,
	@IsExists			bit = 0 output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	set @IsExists = 0

	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1)
	FROM OrderHeader OH with (nolock)
	WHERE CustKey = @CustKey and
			BookingNo = @WorkOrderNumber

	if(@CNT > 0)
	begin
		SET @IsExists = 1
		SELECT  OH.OrderKey, OH.CustKey, OH.BrokerKey, OH.CarrierKey, OH.SourceAddrKey, OH.DestinationAddrKey,
		ContainerDataList = (Select OrderDetailKey, OD.ContainerSizeKey,
				LegList = (select RouteKey, RT.LegKey, SourceAddrKey, DestinationAddrKey,
							L.LegID, L.FromLocation, L.ToLocation, Pt.PickUpType,
							SA.AddrName S_AddrName, SA.Address1 S_Address1, SA.Address2 S_Address2, 
								SA.City S_City, SA.State S_State, SA.Country S_Country, SA.ZipCode S_ZipCode,
							DA.AddrName D_AddrName, DA.Address1 D_Address1, DA.Address2 D_Address2, 
								DA.City D_City, DA.State D_State, DA.Country D_Country, DA.ZipCode D_ZipCode
							from Routes RT with (nolock) 
							LEft join Leg L with (nolock) on RT.LegKey = L.LegKey
							Left join Address SA with (nolock) on RT.SourceAddrKey = SA.AddrKey
							Left join Address DA with (nolock) on RT.DestinationAddrKey = DA.AddrKey
							Left join PickUpType PT with (nolock) on L.PickupTypeKey = PT.PickupTypeKey
							where OD.OrderDetailKey = RT.OrderDetailKey
							For JSON Path
				), OD.ContainerNo, CS.Description as ContainerSize
			from OrderDetail OD with (nolock) 
			LEft join ContainerSize CS with (nolock) on OD.ContainerSizeKey = CS.ContainerSizeKey
			where OD.OrderKey = OH.OrderKey
			For JSON Path
		), B.BrokerID, B.BrokerName,
			C.CarrierID, C.CarrierName,
			CU.CustID, CU.CustName, CU.IsFactored, CU.CreditCheck, CU.CreditLimit,
			SA.AddrName S_AddrName, SA.Address1 S_Address1, SA.Address2 S_Address2, 
				SA.City S_City, SA.State S_State, SA.Country S_Country, SA.ZipCode S_ZipCode,
			DA.AddrName D_AddrName, DA.Address1 D_Address1, DA.Address2 D_Address2, 
			DA.City D_City, DA.State D_State, DA.Country D_Country, DA.ZipCode D_ZipCode
		FROM OrderHeader OH with (nolock)
		left join Broker B with (nolock) on OH.BrokerKey = B.BrokerKey
		Left join Carrier C with (nolock) on OH.CarrierKey = C.CarrierKey
		LEft join Customer CU with (nolock) on OH.CustKey = CU.CustKey
		Left join Address SA with (nolock) on OH.SourceAddrKey = SA.AddrKey
		Left join Address DA with (nolock) on OH.DestinationAddrKey = DA.AddrKey
		WHERE OH.CustKey = @CustKey and
			BookingNo = @WorkOrderNumber
		For JSON Path, without_array_wrapper
	end
	else
	Begin
		select 0 OrderKey,0 CustKey, 0 BrokerKey, 0 CarrierKey, 0 SourceAddrKey, 0 DestinationAddrKey,
			ContainerData = (Select 0 OrderDetailKey, 0 ContainerSizeKey,
				LegList = (select 0 RouteKey, 0 LegKey, 0 SourceAddrKey, 0 DestinationAddrKey
							For JSON Path
				) For JSON Path
			)
		For JSON Path, without_array_wrapper
	end
END
