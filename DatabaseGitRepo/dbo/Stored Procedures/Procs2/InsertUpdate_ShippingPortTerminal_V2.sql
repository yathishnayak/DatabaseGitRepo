/*
	DECLARE @UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='{"CompanyKey":1,"Address":{"Address1":"2401 5th Ave.","Zip":"35020","City":"Bessemer","State":"AL","Country":"USA","AddrName":"CSX - Bessemer (CAICTF)"},"AddrKey":0,"TerminaID":"CSX - Bessemer (CAICTF)","StatusKey":"1","MarketLocationKey":"24","PriceGroupingKey":"9"}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
	exec InsertUpdate_ShippingPortTerminal_V2 @UserKey,@JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
	select @Status,@Reason
*/

/*
DECLARE  @UserKey INT = 953,
    @JsonString VARCHAR(MAX) = '{"CompanyKey":1,  "PortKey":1,"Address":{"Address1":"2401 5th Ave.", "Zip":"35020","City":"Bessemer","State":"AL","Country":"USA","AddrName":"CSX - Bessemer (CAICTF)"},"AddrKey":0, "TerminaID":"Test Terminal 3", "StatusKey":1, "MarketLocationKey":3, "PriceGroupingKey":9}',
    @IsDebug BIT = 1,
    @Status BIT = 0,
    @Reason NVARCHAR(1000) = '' 

EXEC InsertUpdate_ShippingPortTerminal_V2  @UserKey, @JsonString,@IsDebug, @Status OUTPUT,@Reason OUTPUT;

SELECT @Status, @Reason;

*/

CREATE PROCEDURE [dbo].[InsertUpdate_ShippingPortTerminal_V2]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	
	DECLARE 
	@TerminalKey			INT,
	@TerminaID				VARCHAR(50),
	@PortKey				SMALLINT,
	@StatusKey				INT,
	@TerminalAddress		NVARCHAR(MAX) = '',
	@IsActive				BIT,
	@PriceGroupingKey		INT,
	@MarketLocationKey		INT
	
	SELECT @TerminalKey = TerminalKey,@TerminaID=TerminaID,@PortKey=PortKey,@StatusKey=StatusKey,
		   @TerminalAddress=TerminalAddress,@IsActive=IsActive,@PriceGroupingKey=PriceGroupingKey,@MarketLocationKey=MarketLocationKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			TerminalKey			INT				'$.TerminalKey',
			TerminaID			VARCHAR(50)		'$.TerminaID',
			PortKey				SMALLINT		'$.PortKey',
			StatusKey			INT				'$.StatusKey',
			TerminalAddress		NVARCHAR(MAX)	'$.Address' AS JSON,
			IsActive			BIT				'$.IsActive',
			PriceGroupingKey	INT				'$.PriceGroupingKey',
			MarketLocationKey	INT				'$.MarketLocationKey'
		)

	DECLARE		@AddrKey  INT = 0
	
	CREATE TABLE #Address_temp
		  (
				AddrKey		INT,
				AddrName    NVARCHAR(510),
				Address1    NVARCHAR(510),
				Address2    NVARCHAR(510),
				City		NVARCHAR(510),
				State		NVARCHAR(510),
				ZipCode     NVARCHAR(100),
				Country     CHAR(3),
				Website		NVARCHAR(510),
				Phone		NVARCHAR(100),
				Email		NVARCHAR(510),
				Fax			NVARCHAR(100),
				Phone2		NVARCHAR(100),
				Email2		NVARCHAR(100),
				CityKey	    INT
		  ) 

	SET @IsActive=CASE WHEN @StatusKey=1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END

			-- Duplicate check
			IF EXISTS (
				SELECT 1 
				FROM ShippingPortTerminals WITH (NOLOCK)
				WHERE TerminaID = @TerminaID
				  AND ISNULL(IsDeleted,0) = 0
				  AND TerminalKey <> ISNULL(@TerminalKey,0)
			)
			BEGIN
				SET @Status = 0;
				SET @Reason = 'Terminal Id already exists';
				RETURN;
			END


	BEGIN TRANSACTION
	BEGIN TRY
		
			INSERT INTO			#Address_temp
								(AddrKey,AddrName,Address1,Address2,City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
			SELECT				*
			FROM				OPENJSON (@TerminalAddress,'$')
			WITH
			(
				AddrKey		int					'$.AddrKey',
				AddrName    NVARCHAR(510)		'$.AddrName',
				Address1    NVARCHAR(510)		'$.Address1',	
				Address2    NVARCHAR(510)		'$.Address2',		
				City		NVARCHAR(510)		'$.City',
				State		NVARCHAR(510)		'$.State',
				ZipCode     NVARCHAR(100)		'$.Zip',
				Country     CHAR(3)				'$.Country',
				Website		NVARCHAR(510)		'$.Website',
				Phone		NVARCHAR(100)		'$.Phone',
				Email		NVARCHAR(510)		'$.Email',
				Fax			NVARCHAR(100)		'$.Fax',
				Phone2		NVARCHAR(100)		'$.Phone2',
				Email2		NVARCHAR(100)		'$.Email2',
				CityKey		INT					'$.CityKey'
			);

			SELECT	@AddrKey = AddrKey from #Address_temp
		
			IF (isnull(@AddrKey,0) = 0)
				BEGIN
					INSERT INTO ADDRESS	
								(AddrName,Address1,Address2,City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
					SELECT		AddrName,Address1,Address2,City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey
					FROM		#Address_temp

					SET			@AddrKey = SCOPE_IDENTITY()

					UPDATE		#Address_temp 
					SET			AddrKey = @AddrKey
				END
			ELSE
				BEGIN
					UPDATE		ADDRESS	
					SET			AddrName =   b.AddrName,Address1 = b.Address1,Address2 = b.Address2,City = b.city,[State] = b.[State] ,ZipCode = b.ZipCode,Country = b.Country ,Website =   b.Website,Phone =	b.Phone,Email =	b.Email,
								Fax	=b.Fax,Phone2 =b.Phone2,Email2 =b.Email2,CityKey =b.CityKey
					FROM		[Address] A 
					INNER JOIN	#Address_temp B ON A.AddrKey = B.AddrKey
				END


		SET @TerminalKey=CASE WHEN @TerminalKey IS NULL THEN 0 ELSE @TerminalKey END

		IF (@TerminalKey=0)
			BEGIN
				INSERT INTO			ShippingPortTerminals 
									(TerminaID,PortKey,AddrKey,StatusKey,IsActive,IsDeleted,CreateDate,CreateUserKey,Updatedate,UpdateUserKey,
									 MarketLocationKey,PriceGroupingKey)
				SELECT				@TerminaID,NULLIF(@PortKey,0),@AddrKey,@StatusKey,@IsActive,0,GETDATE(),@UserKey,GETDATE(),@UserKey,
									@MarketLocationKey,@PriceGroupingKey

				SET					@TerminalKey = SCOPE_IDENTITY()
				SET					@Status = 1
				SET					@Reason = 'Terminal Created Successfully'

			END
		ELSE
			BEGIN
				UPDATE				ShippingPortTerminals
				SET					TerminaID=@TerminaID,
									PortKey = NULLIF(@PortKey,0),
									AddrKey=@AddrKey,
									StatusKey=@StatusKey,
									IsActive = @IsActive ,
									Updatedate = GETDATE(),
									UpdateUserKey = @UserKey,
									MarketLocationKey=@MarketLocationKey,
									PriceGroupingKey=@PriceGroupingKey
				WHERE				TerminalKey=@TerminalKey

				SET					@Status = 1
				SET					@Reason = 'Terminal Updated Successfully'

			END
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		SET			@Status = 0
		--SET			@Reason ='Failed to update the record'
		SET			@Reason = Error_Message()

		PRINT		@@error
		PRINT		Error_Message()
		PRINT		'Rollback'

		ROLLBACK TRANSACTION
	END CATCH
END