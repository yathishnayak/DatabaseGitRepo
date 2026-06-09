
CREATE PROCEDURE [dbo].[Gnosis_Export_GetBookingNoForTrackingBooking]

AS

BEGIN
	SELECT			A.Booking_number,A.Booking_uuid, A.Carrier_scac
	FROM			Gnosis_Export_TrackingRequestBooking A  WITH (NOLOCK)
	LEFT JOIN		Gnosis_Export_TrackingRequestBookingStatus B  WITH (NOLOCK) On A.Booking_uuid = B.uuid
	WHERE			B.uuid IS NULL
	FOR JSON PATH
END
