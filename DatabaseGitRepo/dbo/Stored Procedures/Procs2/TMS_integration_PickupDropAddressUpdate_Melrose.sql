

CREATE	PROCEDURE	[dbo].[TMS_integration_PickupDropAddressUpdate_Melrose] -- TMS_integration_PickupDropAddressUpdate_Melrose '[{"Datakey":353}]'
(
	@Json NVARCHAR(MAX)
)

AS


DECLARE @Debug INT = 0

SELECT			Datakey
INTO			#DATATemp
FROM OPENJSON	(@Json,'$')
				WITH (
					Datakey				VARCHAR(50)		'$.Datakey' 
				)

-- SELECT * FROM #DATATemp

SELECT		ROW_NUMBER() OVER (ORDER BY DataKey,ContainerKey,StopKey)Sl,*
INTO		#TMPData
FROM		(SELECT		H.Datakey Datakey, CL.ContainerKey ContainerKey, CL.equipmentNumber AS ContainerNo, SL.Stopkey Stopkey, stopType, stopName,address1,Address2,city,state,country,postalCode, TMS_CustKey , TMS_MarketLocationKey			
			FROM		Integration_JCB.dbo.Melrose_Header H WITH (NOLOCK)
			INNER JOIN	#DATATemp DT ON H.DataKey = DT.DataKey
			INNER JOIN	Integration_JCB.dbo.Melrose_ContainerList CL WITH (NOLOCK) On H.DataKey = Cl.DataKey 
			INNER JOIN	Integration_JCB.dbo.Melrose_StopList SL WITH (NOLOCK) On Cl.ContainerKey = Sl.ContainerKey
			-- GROUP BY	H.Datakey,stopType, stopName,address1,Address2,city,state,country,postalCode, TMS_CustKey , TMS_MarketLocationKey	
			) A	

-- SELECT * FROM #TMPData

DECLARE		@LocationName	VARCHAR(100),
			@Addr1			VARCHAR(100),
			@Addr2			VARCHAR(100),
			@City			VARCHAR(100),
			@State			VARCHAR(100),
			@Country		VARCHAR(100),
			@Postal			VARCHAR(100),
			@CustKey		INT,
			@StopName		VARCHAR(100),
			@MarketLocationKey INT,
			@PortKey		INT,
			@TerminalKey	INT,
			@ContainerNo	VARCHAR(50)
IF(@Debug = 1)
	BEGIN
		SELECT * FROM #TMPData
	END
DECLARE		@i INT = 1, @n INT = (SELECT COUNT(*) FROM #TMPData), @CNT INT = 0, @CityKey INT = 0, @Addrkey INT = 0, @DataKey INT = 0, @StopType VARCHAR(20) = '', @CustomerAddress INT = 0
IF(@Debug = 1)
	BEGIN
		SELECT @n
	END
WHILE (@i <= @n)
	BEGIN
		SET @Addrkey = 0
		SELECT		@LocationName = stopName ,@Addr1 = address1,@Addr2 = Address2,@City = city,@State = state, @Country = country,@Postal = postalCode 
					,@DataKey = Datakey, @StopType = StopType, @CustKey = TMS_CustKey, @StopName = stopName, @MarketLocationKey = TMS_MarketLocationKey, @ContainerNo = ContainerNo
		FROM		#TMPData
		WHERE		Sl = @i


		-- SET @LocationName = 'New Location Name Test ' + CAST(@i  AS VARCHAR)


		-- SELECT		@LocationName ,@Addr1 ,@Addr2 ,@City ,@State , @Country ,@Postal,@DataKey , @StopType 

		SELECT		@Addrkey = AddrKey
		FROM		Address 
		WHERE		ISNULL(AddrName,'') = ISNULL(@LocationName,'') AND ISNULL(Address1,'') = ISNULL(@Addr1,'') AND ISNULL(Address2,'') = ISNULL(@Addr2,'') 
					AND ISNULL(City,'') = ISNULL(@City,'') AND ISNULL(Country,'') = ISNULL(@Country,'') AND ISNULL(ZipCode,'') = ISNULL(@Postal,'') 
		-- SELECT 'add',@Addrkey
	
		IF(ISNULL(@Addrkey,0) = 0)
			BEGIN
					-- SELECT * FROm LocationData 
					SET @CityKey = 0

					SELECt		@CityKey = CityKey
					FROM		LocationData
					WHERE		Country = @Country AND State = @State AND City = @City AND ZipCode = @Postal 

					IF(ISNULL(@CityKey,0) = 0)
						BEGIN
							-- SELECT  @Country,@State,@City,@Postal,1,GETDATE(),1,0,NULL
							INSERT INTO LocationData
										(Country,State,City,ZipCode,StatusKey,CreateDate,IsActive,IsDelete,PriceGroupingKey)
							SELECT		@Country,@State,@City,@Postal,1,GETDATE(),1,0,NULL
							SET			@CityKey = @@IDENTITY
						END
					
					IF(ISNULL(@LocationName,'') <> '')
						BEGIN
							INSERT INTO Address 
										(AddrName,Address1,Address2,City,State,ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
							SELECT		@LocationName,@Addr1,@Addr2,@City,@State,@Postal,@Country,NULL,NULL,NULL,NULL,NULL,NULL, @CityKey
						END

					SET			@Addrkey = @@IDENTITY
			END

		IF(@StopType = 'Ship From')
			BEGIN
				IF(@Debug = 1)
					BEGIN
						SELECT 'Ship From'
					END

				IF(@i = (SELECT MIN(Sl) FROM #TMPData WHERE StopType = 'Ship From' AND Datakey = @DataKey))
					BEGIN
						-- SELECT MIN(Sl) FROM #TMPData WHERE StopType = 'Ship From' AND Datakey = @DataKey
						UPDATE		OH
						SET			SourceAddrKey = CASE WHEN ISNULL(SourceAddrKey,0) = 0 THEN @Addrkey ELSE SourceAddrKey END
						FROM		TMS_Integration_Header H
						INNER JOIN	#DATATemp DT ON H.DataKey = DT.DataKey
						INNER JOIN	OrderHeader OH ON H.TMS_OrderKey = OH.OrderKey 
						WHERE		H.DataKey = @DataKey AND SiteID = 'Melrose'  

						UPDATE		H
						SET			TMS_SourceAddrKey = @Addrkey
						FROM		Integration_JCB.dbo.Melrose_Header H
						WHERE		DataKey = @DataKey 

					END

				
					BEGIN
						UPDATE		OH
						SET			SourceAddrKey = CASE WHEN ISNULL(SourceAddrKey,0) = 0 THEN @Addrkey ELSE SourceAddrKey END
						--SELECT		@i AS SL, SourceAddrKey,CASE WHEN ISNULL(SourceAddrKey,0) = 0 THEN @Addrkey ELSE SourceAddrKey END
						FROM		TMS_Integration_Header H
						INNER JOIN	#DATATemp DT ON H.DataKey = DT.DataKey
						INNER JOIN	OrderDetail OH ON H.TMS_OrderKey = OH.OrderKey 
						WHERE		H.DataKey = @DataKey AND H.SiteID = 'Melrose'  AND ContainerNo = @ContainerNo  


						UPDATE		SL
						SET			TMS_SourceAddrKey = CASE WHEN ISNULL(TMS_SourceAddrKey,0) = 0 THEN @Addrkey ELSE TMS_SourceAddrKey END
						--SELECT		@i AS SL, SourceAddrKey,CASE WHEN ISNULL(SourceAddrKey,0) = 0 THEN @Addrkey ELSE SourceAddrKey END
						FROM		Integration_JCB.dbo.Melrose_ContainerList H
						INNER JOIN	Integration_JCB.dbo.Melrose_StopList SL ON H.ContainerKey = SL.ContainerKey
						INNER JOIN	#DATATemp DT ON H.DataKey = DT.DataKey
						WHERE		H.DataKey = @DataKey 
					END

				--SELECt			@CustomerAddress = COUNT(*)
				--FROM			CustomerAddress 
				--WHERE			CustKey = @CustKey AND AddrKey = @Addrkey AND AddrType = 'Pickup'

				--IF(@CustomerAddress = 0)
				--	BEGIN
				--		INSERT INTO CustomerAddress (CustKey,AddrKey,AddrType)
				--		SELECT @CustKey,@Addrkey,'Pickup'
				--	END

				SET @PortKey = (SELECT TOP 1 ShippingPortKey  FROM ShippingPort  WHERE ShippingPortID = @Stopname) 
				SET @PortKey = ISNULL(@PortKey,0)

				IF(@PortKey = 0)
					BEGIN
						IF(ISNULL(@Stopname,'') <> '')
							BEGIN
								INSERT INTO ShippingPort
											(ShippingPortID,AddrKey,StatusKey,CompanyKey,MarketLocationKey,IsActive,IsDeleted,CreateDate,CreateUserKey,Updatedate,UpdateUserKey)
								SELECT		@Stopname, @Addrkey,1,1,@MarketLocationKey,1,0,GETDATE(),NULL,GETDATE(),NULL
							END
						SET			@PortKey = @@IDENTITY
					END


				SET @TerminalKey = (SELECT TOP 1 TerminalKey FROM ShippingPortTerminals  WHERE TerminaID  = @Stopname) 
				SET @TerminalKey = ISNULL(@TerminalKey,0)

				IF(@TerminalKey = 0)
					BEGIN
						IF(ISNULL(@Stopname,'') <> '')
							BEGIN
								INSERT INTO ShippingPortTerminals
											(TerminaID,PortKey,AddrKey,StatusKey,IsActive,IsDeleted,CreateDate,CreateUserKey,UpdateDate,UpdateUserKey,PriceGroupingKey)
								SELECT		@Stopname, @PortKey,@Addrkey,1,1,0,GETDATE(),NULL,GETDATE(),NULL,NULL
							END
						SET			@TerminalKey = @@IDENTITY
					END

			END
		ELSE IF (@StopType = 'Ship To')
			BEGIN
				IF(@Debug = 1)
					BEGIN
						SELECT 'Ship To'
					END

				IF(@i = (SELECT MIN(Sl) FROM #TMPData WHERE StopType = 'Ship To' AND Datakey = @DataKey))
					BEGIN
						-- SELECT MIN(Sl) FROM #TMPData WHERE StopType = 'Ship To' AND Datakey = @DataKey
						UPDATE		OH
						SET			DestinationAddrKey = CASE WHEN ISNULL(DestinationAddrKey,0) = 0 THEN @Addrkey ELSE DestinationAddrKey END
						FROM		TMS_Integration_Header H
						INNER JOIN	#DATATemp DT ON H.DataKey = DT.DataKey
						INNER JOIN	OrderHeader OH ON H.TMS_OrderKey = OH.OrderKey 
						WHERE		H.DataKey = @DataKey AND SiteID = 'Melrose'

						UPDATE		H
						SET			TMS_DestinationAddrKey = @Addrkey
						FROM		Integration_JCB.dbo.Melrose_Header H
						WHERE		DataKey = @DataKey 

					END

				UPDATE		OH
				SET			DestinationAddrKey = CASE WHEN ISNULL(DestinationAddrKey,0) = 0 THEN @Addrkey ELSE DestinationAddrKey END
				--SELECT		@i AS SL, SourceAddrKey,CASE WHEN ISNULL(SourceAddrKey,0) = 0 THEN @Addrkey ELSE SourceAddrKey END
				FROM		TMS_Integration_Header H
				INNER JOIN	#DATATemp DT ON H.DataKey = DT.DataKey
				INNER JOIN	OrderDetail OH ON H.TMS_OrderKey = OH.OrderKey 
				WHERE		H.DataKey = @DataKey AND SiteID = 'Melrose' AND ContainerNo = @ContainerNo

				UPDATE		SL
				SET			TMS_DestinationAddrKey= CASE WHEN ISNULL(TMS_DestinationAddrKey,0) = 0 THEN @Addrkey ELSE TMS_DestinationAddrKey END
				--SELECT		@i AS SL, SourceAddrKey,CASE WHEN ISNULL(SourceAddrKey,0) = 0 THEN @Addrkey ELSE SourceAddrKey END
				FROM		Integration_JCB.dbo.Melrose_ContainerList H
				INNER JOIN	Integration_JCB.dbo.Melrose_StopList SL ON H.ContainerKey = SL.ContainerKey
				INNER JOIN	#DATATemp DT ON H.DataKey = DT.DataKey
				WHERE		H.DataKey = @DataKey 

				SELECt			@CustomerAddress = COUNT(*)
				FROM			CustomerAddress 
				WHERE			CustKey = @CustKey AND AddrKey = @Addrkey AND AddrType = 'Delivery'

				DECLARE @ISCustKeyExists INT = (SELECT COUNT(*) FROM Customer WHERE Custkey = @custkey)

				IF(@CustomerAddress = 0 AND ISNULL(@CustKey,0) > 0 AND ISNULL(@Addrkey,0) > 0 AND @ISCustKeyExists > 0)
					BEGIN
						INSERT INTO CustomerAddress (CustKey,AddrKey,AddrType)
						SELECT @CustKey,@Addrkey,'Delivery'
					END

			END

		SET @i = @i + 1
	
	END
