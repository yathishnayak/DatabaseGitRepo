/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_DelayedContainerLegCount_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DelayedContainerLegCount_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT Count(1) As DelayedContainerLegCount FROM (
	SELECT C.CustName,OH.OrderNo,A.OrderKey,A.OrderDetailKey ,A.RouteKey,L.LegID,
		Sour.AddrName AS FromLocation,Dst.AddrName AS ToLocation,A.IsEmpty, A.PickupDateFrom,
		A.PickupDateTo,A.DeliveryDateFrom,A.DeliveryDateTo
	FROM dbo.Routes A 
		INNER JOIN dbo.OrderHeader OH	ON OH.OrderKey=A.OrderKey
		INNER JOIN dbo.Customer C		ON C.CustKey=OH.CustKey
		INNER JOIN dbo.Leg L			ON L.LegKey=A.LegKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=A.[Status]
		LEFT JOIN  dbo.[Address] Sour	ON Sour.AddrKey=A.SourceAddrKey
		LEFT JOIN  dbo.[Address] Dst	ON Dst.AddrKey=A.DestinationAddrKey
	WHERE  
	(( ISNULL(A.PickupDateTo, A.PickupDateFrom)<GETDATE() AND A.ActualDeparture IS NULL )
	OR( ISNULL(A.DeliveryDateTo,A.DeliveryDateFrom)<GETDATE() AND A.ActualArrival IS NULL ))
	) A
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status = 1
	SET @Reason = 'Success'
END