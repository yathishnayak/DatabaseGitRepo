

CREATE PROCEDURE [dbo].[Gnosis_Export_InsertUpdate_BookingSCACPatch]
(
	-- @JsonData		NVARCHAR(MAX) = '[{"BookingNo":"NAM6721182","ScacCode":"COSU","SteamShipLinekey":2},{"BookingNo":"DALA44729600","ScacCode":"HDMU","SteamShipLinekey":9},{"BookingNo":"RICEX8667800","ScacCode":"ONEY","SteamShipLinekey":15}]'
	@RequestSent		NVARCHAR(MAX) = '[{"BookingNo":"241228369","ScacCode":"MAEU","SteamShipLinekey":12},{"BookingNo":"241609606","ScacCode":"MAEU","SteamShipLinekey":12},{"BookingNo":"241610223","ScacCode":"MAEU","SteamShipLinekey":12}]',
	@ResponseRcvd		NVARCHAR(MAX) = '[{"BookingNo":"241228369","ScacCode":"MAEU","SteamShipLinekey":12,"detail":"No tracking request found","message":null},{"BookingNo":"241609606","ScacCode":"MAEU","SteamShipLinekey":12,"detail":"No tracking request found","message":null},{"BookingNo":"241610223","ScacCode":"MAEU","SteamShipLinekey":12,"detail":"No tracking request found","message":null}]'
)


AS

BEGIN
	
	DECLARE @ExportBookingKey INT = 0

	INSERT INTO		Gnosis_Export_BookingRequestResponse
					(RequestSent,ResponseRcvd,CreatedDate)
	SELECT			@RequestSent,@ResponseRcvd,GETDATE()

	SET @ExportBookingKey = @@IDENTITY

	
	CREATE TABLE #TrackingData
	(
		SlNo				INT,
		BookingNo			VARCHAR(50),
		ScacCode			VARCHAR(20),
		SteamShipLinekey	INT,
		Detail				VARCHAR(1000),
		Msg					VARCHAR(1000)
	)


	INSERT INTO		#TrackingData
					(SlNo,BookingNo,ScacCode,SteamShipLinekey,Detail,Msg)
	SELECT			ROW_NUMBER() OVER (ORDER BY BookingNo), BookingNo,ScacCode,SteamShipLinekey,Detail,Msg
					FROM OPENJSON	(@ResponseRcvd,'$')
									WITH (
										BookingNo				VARCHAR(50)		'$.BookingNo' ,
										ScacCode				VARCHAR(20)		'$.ScacCode' ,
										SteamShipLinekey		INT				'$.SteamShipLinekey' ,
										Detail					VARCHAR(1000)	'$.detail' ,
										Msg						VARCHAR(1000)	'$.message'
										)
	
	SELECT * FROM #TrackingData
	
	INSERT INTO		Gnosis_Export_BookingSCACPatch
					(ExportBookingKey,BookingNo,SCACCode,SteamShipLinekey, IsUpdated,Response,CreatedDate,UpdatedDate)
	SELECT			@ExportBookingKey,TD.BookingNo,TD.ScacCode,TD.SteamShipLinekey,1,ISNULL(msg,detail), GETDATE(),GETDATE()
	FROM			#TrackingData TD
	LEFT OUTER JOIN	Gnosis_Export_BookingSCACPatch BS  WITH (NOLOCK) ON TD.BookingNo = BS.BookingNo AND TD.SteamShipLinekey = BS.SteamShipLinekey
	WHERE			BS.BookingNo IS NULL


END
