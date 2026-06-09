CREATE PROCEDURE [dbo].[Get_OrderCarrierDetailByOrderKey]
/*
dbo.fn_getorderdatabykey, dbo.fn_getorderdatabyorderkey, dbo.fn_getorderdatabyorderkey
*/
@OrderKey  INT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	 SELECT DISTINCT
		 oh.OrderKey,
		 oh.OrderNo,
		 oh.OrderDate, oh.CustKey, oh.BillToAddrKey,oh.SourceAddrKey, oh.DestinationAddrKey , 
		 oh.ReturnAddrKey, oh.SourceKey, oh.OrderTypeKey, oh.[Status], oh.StatusDate, HR.[Description] AS HoldReason, oh.HoldDate,
		 oh.BrokerKey, oh.BrokerRefNo, oh.PortoForiginKey, oh.CarrierKey, oh.VesselName,
		 oh.BillOfLading, oh.BookingNo,
		 oh.IsHazardous, oh.PriorityKey, 
		 oh.CreateDate,oh.CreateUserKey, oh.PortofDestinationKey, 
		 cr.CarrierID 
	 FROM  dbo.OrderHeader oh
		LEFT JOIN dbo.Carrier cr    ON cr.CarrierKey = oh.CarrierKey
		LEFT JOIN Dbo.Holdreason HR ON HR.HoldReasonKey=OH.HoldReasonKey
	 WHERE  oh.OrderKey = @OrderKey;
END
