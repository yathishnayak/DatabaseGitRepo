CREATE PROCEDURE [dbo].[Get_PickUpDeliveryLocation]
@OrderDetailKey INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT ISNULL(Pick.City,'') AS PickUpLocation, ISNULL(Del.City,'') AS DeliveryLocation
	FROM dbo.OrderHeader OH 
		INNER JOIN dbo.OrderDetail OD	ON OD.OrderKey=OH.OrderKey
		LEFT JOIN dbo.[Address]	Pick	ON Pick.AddrKey=OH.SourceAddrKey
		LEFT JOIN dbo.[Address] Del		ON Del.AddrKey=OH.DestinationAddrKey
	WHERE OD.OrderDetailKey= @OrderDetailKey	
END
