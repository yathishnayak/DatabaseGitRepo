/*
	DECLARE 
		@UserKey	INT				= 29,
		@JSONString NVARCHAR(MAX)	= '',
		@Status 	BIT				= 0,
		@Reason		VARCHAR(1000)	= '' 
	
	EXEC Gnosis_Export_GetBookingDetails @UserKey, @JSONString, @Status output, @Reason output
	SELECT @Status, @Reason
*/

CREATE PROCEDURE	[dbo].[Gnosis_Export_GetBookingDetails] -- Gnosis_Export_GetBookingDetails 'GAOU6974889'
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF
	SET @Reason='Success'
	SET @Status=1
	SELECT			MBL,booking_number AS BookingNo, ISNULL(num_containers,0) AS ContainerCount,'' AS ConSize,'' AS ConType, por_cargo_cut_off_dt AS LFD , por_early_receive_dt AS EarlyReceive, first_vessel AS VesselName, first_voyage AS Voyage
					, vessel_etb_pol_dt AS VesselETB,vessel_etd_pol_dt AS VesselETD , pol_terminal_name AS  TerminalName, pol_terminal_firms_code AS TerminalCode, carrier_scac AS SCACCode
					,'' AS PortInGate, CSR.CsrName AS CSR, ML.MarketLocation AS Market, C.CustName AS Customer, AD.AddrName DeliveryLocation
	FROM			Gnosis_Export_BookingDetails_Final BD  WITH (NOLOCK)
	LEFT JOIN		(SELECT		*
					FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY BookingNo  ORDER BY OrderKey DESC) Sl, BookingNo , BillOfLading MBL, CsrKey, MarketLocationKey, CustKey
											,DestinationAddrKey
								FROM		OrderHeader OH  WITH (NOLOCK)
								WHERE		ISNULL(BookingNo,'') <> '' AND OH.OrderTypeKey = 2) A
					WHERE		Sl = 1) OH ON BD.booking_number = OH.BookingNo
	LEFT JOIN		CSR CSR  WITH (NOLOCK) ON ISNULL(OH.CsrKey,'') = ISNULL(CSR.CsrKey,'')
	LEFT JOIN		MarketLocation ML  WITH (NOLOCK) ON ISNULL(OH.MarketLocationKey,'') = ISNULL(ML.MarketLocationKey,'')
	LEFT JOIN		Customer C  WITH (NOLOCK) ON ISNULL(OH.CustKey,'') = ISNULL(C.CustKey,'')
	LEFT JOIN		Address AD  WITH (NOLOCK) ON ISNULL(OH.DestinationAddrKey,'') = ISNULL(AD.AddrKey,'')
	FOR JSON PATH;


END