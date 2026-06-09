





CREATE VIEW [dbo].[Gnosis_Export_VBookingSCACPatch] -- SELECT * FROM Gnosis_Export_VBookingSCACPatch
AS 

SELECT			*
FROM			(SELECT			ROW_NUMBER() OVER (PARTITION BY BookingNo,SCACCode ORDER BY CreatedDate DESC ) SL, *
				FROM			Gnosis_Export_BookingSCACPatch A  WITH (NOLOCK) ) A
WHERE			SL = 1
