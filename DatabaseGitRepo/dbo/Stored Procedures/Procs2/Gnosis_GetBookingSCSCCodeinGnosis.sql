





CREATE PROCEDURE [dbo].[Gnosis_GetBookingSCSCCodeinGnosis]


AS

BEGIN
	SELECT		DISTINCT OH.BookingNo,SteamShipLinekey, SSL.ScacCode
	FROM		OrderHeader OH  WITH (NOLOCK)
	INNER JOIN	OrderDetail OD  WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
	LEFT JOIN	SteamShipLine SSL  WITH (NOLOCK) ON OH.SteamShipLinekey = SSL.LineKey
	LEFT JOIN	Gnosis_BookingSCACPatch BS  WITH (NOLOCK) ON OH.BookingNo = BS.BookingNo AND SSL.ScacCode = BS.SCACCode
	WHERE		OH.OrderTypeKey = 2 AND ISNULL(SteamShipLinekey,'') <> '' AND ISNULL(SSL.ScacCode,'') <> '' AND ISNULL(OH.BookingNo,'') <> ''
				AND BS.BookingNo IS NULL AND ISNULL(IsUpdated,0) = 0 -- AND OD.Status NOT IN (10,13,12,14,15) 
	END

