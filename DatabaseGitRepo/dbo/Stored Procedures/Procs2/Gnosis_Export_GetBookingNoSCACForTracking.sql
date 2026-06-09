
-- DROP PROCEDURE Gnosis_Export_GetBookingSCACPatch

-- SELECT GETDATE()
CREATE PROCEDURE [dbo].[Gnosis_Export_GetBookingNoSCACForTracking]
(
	@FromDate	DATETIME = '2024-07-01 00:00:00.000'
)
AS
SELECT			SL,BookingNo,SCACCode,SteamShipLinekey
FROM			Gnosis_Export_VBookingSCACPatch A  WITH (NOLOCK)
LEFT JOIN		Gnosis_Export_TrackingRequestBooking B  WITH (NOLOCK) ON A.BookingNo = B.Booking_number
WHERE			A.CreatedDate > @FromDate AND Response <> 'No tracking request found' AND B.Booking_number IS NULL
FOR JSON PATH
