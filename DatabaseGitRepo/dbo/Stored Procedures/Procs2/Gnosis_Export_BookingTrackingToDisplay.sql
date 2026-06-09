/*
DECLARE @Userkey INT = 1144, @JsonString NVARCHAR(MAX) = '', @Status BIT , @Reason VARCHAR(1000)
EXEC Gnosis_Export_BookingTrackingToDisplay @Userkey, @JsonString, @Status OUTPUT, @Reason OUTPUT  
SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Gnosis_Export_BookingTrackingToDisplay]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)

AS

CREATE TABLE #TMPData
(
	 OrderNo					VARCHAR(50)
	,CustName					VARCHAR(200)
	,BookingNo					VARCHAR(50)
	,ScacCode					VARCHAR(50)
	,BookingTrackingStatus		VARCHAR(50)
	,TrackingDate				DATETIME
	,Remarks					VARCHAR(1000)
)

INSERT INTO	#TMPData
SELECT		OrderNo, CustName, BookingNo,ScacCode, BookingTrackingStatus,  TrackingDate, Remarks
FROM		(SELECT			OH.OrderNo, CustName, OD.BookingNo,SSL.ScacCode, '' BookingTrackingStatus, '' AS TrackingDate
							, CASE WHEN ISNULL(SSL.ScacCode,'') = '' THEN 'SCAC Code is Blank' ELSE '' END 
							+ CASE WHEN ISNULL(OD.BookingNo,'') = '' THEN ';Booking No is Blank' ELSE '' END					
							AS  Remarks
			FROM			OrderHeader OH  WITH (NOLOCK)
			INNER JOIN		OrderDetail OD  WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
			LEFT JOIN		SteamShipLine SSL  WITH (NOLOCK) ON OH.SteamShipLinekey = SSL.LineKey
			LEFT JOIN		Customer C  WITH (NOLOCK) ON OH.CustKey = C.CustKey
			WHERE			OH.OrderTypeKey = 2 AND OD.Status NOT IN (10,13,12,14,15) )A


UPDATE		#TMPData
SET			BookingTrackingStatus = 'Request Not Sent', TrackingDate = NULL
WHERE		ISNULL(Remarks,'') <> ''

-- SELECT * FROM #TMPData WHERE ISNULL(Remarks,'') = ''

UPDATE		TD
SET			Remarks = BC.Response 
			+ CASE WHEN ISNULL(TR.Returnmessage,'') = '' THEN '' ELSE ' / ' + ISNULL(TR.Returnmessage,'') END
			+ CASE WHEN ISNULL(tracking_status,'') = '' THEN '' ELSE ' / ' + ISNULL(tracking_status,'') END
			,TrackingDate = ISNULL(TR.CreatedDate, BC.CreatedDate)
			,BookingTrackingStatus = ISNULL(TRS.tracking_status, 'Failure')
FROM		#TMPData TD 
LEFT JOIN	Gnosis_Export_BookingSCACPatch BC  WITH (NOLOCK) ON TD.BookingNo = BC.BookingNo AND TD.ScacCode = BC.SCACCode
LEFT JOIN	Gnosis_Export_TrackingRequestBooking TR  WITH (NOLOCK) ON BC.BookingNo = TR.Booking_number AND TR.Carrier_scac = BC.SCACCode
LEFT JOIN	Gnosis_Export_TrackingRequestBookingStatus TRS  WITH (NOLOCK) ON TR.Booking_number = TRS.booking_number AND TR.Booking_uuid = TRS.uuid
WHERE		ISNULL(tracking_status,'') <> 'Successful' AND ISNULL(Remarks,'') = ''

SET @Status=1
SET @Reason='Success'

SELECT * FROM #TMPData
WHERE Remarks <> ''
for json path

DROP TABLE #TMPData