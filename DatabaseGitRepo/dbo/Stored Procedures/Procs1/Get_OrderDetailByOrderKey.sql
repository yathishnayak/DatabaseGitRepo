CREATE PROCEDURE [dbo].[Get_OrderDetailByOrderKey] -- Get_OrderDetailByOrderKey 36674
/*
Order Screen > Ordr Level Detail
*/
@OrderKey  INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		OD.OrderDetailKey,
		OD.OrderKey,
		OD.ContainerID,
		OD.ContainerNo,
		CS.ContainerSizeKey AS ContainerSize,
		OD.Chassis,
		OD.SealNo,
		OD.[Weight],
		ISNULL(OD.[WeightUnit],0) AS WeightUnit,
		CASE OD.[WeightUnit] 
        WHEN 1 THEN 'LB' 
        WHEN 2 THEN 'KG'       
        ELSE '' 
		END WeightUnitDesc, 
		OD.ApptDateFrom,
		OD.ApptDateTo,
		OD.PickupDate,
		OD.PickupTime,
		OD.DropOffDate,
		OD.DropOffTime,
		OD.ActualPickupTime,
		OD.ActualDropOffTime,
		OD.ActualPickupDate,
		OD.ActualDropOffDate,
		OD.[Status],
		OD.StatusDate,
		HR.Description AS HoldReason,
		OD.HoldDate,
		OCT.Comment  AS OrderComment,
		OS.Description AS OrderStatus,
		CS.Description AS ContainerizeDesc,
		HR.Description AS HoldReasonDescr ,
		OD.VesselETA as VesselETA
		, isnull(isStreetTurn,0) as isStreetTurn
		, isnull(U1.UserName,'') AS StreetTurnSetUser
		, ISNULL(StreetTurnSetDate,CONVERT(DATE,'2000-01-01')) AS StreetTurnSetDate
	FROM
		dbo.OrderDetail OD 
		 --Left join vOrderContainerTypes	OCT	  on OD.OrderDetailKey = OCT.OrderDetailKey
		 LEft join [vContainerTypeByOrderKey] OCT on OD.OrderDetailKey = OCT.OrderDetailKey
		 --LEFT JOIN dbo.OrderDetailComments OC ON OC.orderdetailkey = OD.orderdetailkey
		 --LEFT JOIN dbo.Comment C			  ON c.CommentKey = OC.CommentKey
		 LEFT JOIN dbo.OrderStatus OS		  ON OS.[Status]= OD.[status]
		 LEFT JOIN dbo.ContainerSize CS		  ON CS.ContainerSizeKey = OD.ContainerSizeKey
		 LEFT JOIN dbo.Holdreason HR		  ON hr.HoldReasonKey = OD.HoldReasonKey
		 LEFT JOIN DBO.[User] U1				  ON OD.StreetTurnSetUser = U1.UserKey
	WHERE OrderKey = @OrderKey;
END
