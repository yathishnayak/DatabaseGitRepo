

CREATE PROCEDURE [dbo].[Gnosis_Export_GetBookingNoForTrackingBookingStatus]

AS

BEGIN
	SELECT			A.Booking_number,A.uuid AS Booking_uuid
	FROM			Gnosis_Export_TrackingRequestBookingStatus A  WITH (NOLOCK)
	LEFT JOIN		Gnosis_Export_BookingDetails B  WITH (NOLOCK) On A.uuid = B.uuid
	WHERE			tracking_status = 'Successful' AND  B.uuid IS NULL
	FOR JSON PATH
END
