


-- Gnosis_GetBookingSCSCCodeinGnosis_Delete

CREATE PROCEDURE [dbo].[Gnosis_Export_GetBookingSCSCCodeinGnosis] 
AS

BEGIN

	CREATE TABLE [dbo].[#TempData](
			[BookingNo]			[varchar](50) NULL,
			[SteamShipLinekey]	[int] NULL,
			[ScacCode]			[varchar](30) NULL
	) ON [PRIMARY]

	--IF(@@SERVERNAME = 'JCTDEV')
	--	BEGIN	
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'NAM6721182', 2, N'COSU')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'DALA44729600', 9, N'HDMU')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'RICEX8667800', 15, N'ONEY')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'241609606  ', 12, N'MAEU')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'YCH24122154', 15, N'ONEY')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'RICEZ5397700', 15, N'ONEY')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'RICEZ6229900', 15, N'ONEY')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'241610223', 12, N'MAEU')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'61290152', 8, N'HLCU')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'RICEAB452300', 15, N'ONEY')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'DALA32094500', 9, N'HDMU')
	--		INSERT [dbo].[#TempData] ([BookingNo], [SteamShipLinekey], [ScacCode]) VALUES (N'RICEAS071800', 15, N'ONEY')
	--	END
	

	INSERT INTO		[#TempData]
	SELECT			DISTINCT LTRIM(RTRIM(OH.BookingNo))BookingNo,OH.SteamShipLinekey, LTRIM(RTRIM(SSL.ScacCode))
	FROM			OrderHeader OH  WITH (NOLOCK)
	INNER JOIN		OrderDetail OD  WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
	LEFT JOIN		SteamShipLine SSL  WITH (NOLOCK) ON OH.SteamShipLinekey = SSL.LineKey
	LEFT JOIN		Gnosis_Export_BookingSCACPatch BS  WITH (NOLOCK) ON OH.BookingNo = BS.BookingNo AND OH.SteamShipLinekey = BS.SteamShipLinekey
	WHERE			OH.OrderTypeKey = 2 AND ISNULL(OH.SteamShipLinekey,0) > 0 AND ISNULL(OH.BookingNo,'') <> '' AND LTRIM(RTRIM(SSL.ScacCode)) <> ''
					AND BS.BookingNo IS NULL AND ISNULL(IsUpdated,0) = 0 AND OD.Status NOT IN (10,13,12,14,15) 
					--  AND OH.BookingNo  IN ('241610223')
					

	SELECT   * FROM #TempData
	FOR JSON PATH
	DROP TABLE #TempData

	
	-- SELECT			'' BookingNo,0 SteamShipLinekey,'' ScacCode FOR JSON PATH



END

