CREATE PROCEDURE [dbo].[InsertUpdate_ShippingPortTerminal]
/*

DECLARE @TerminalAddress nvarchar(max) = '{"Address":[{"AddrKey":0,"AddrName":"abc35971234","Address1":"chicago1234","Address2":"chicago","City":"Holtsville","State":"NY","ZipCode":"00501","Country":"USA","Website":"http://localhost:4200/address","Phone":"+1(843)412-4374","Email":"unknown@trikaiser.com","Fax":null,"Phone2":"12345678920","Email2":"unknown@trikaiser.com","CityKey":31984,"Longitude":0,"Latitude":0,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0,"RecTimeStamp":null,"CreateUserName":null,"UpdateUserName":null}]}'

DECLARE @Status BIT = 0, @Reason VARCHAR(100) = ''

EXEC InsertUpdate_ShippingPortTerminal 0,'',1,1, @TerminalAddress,1,28, @Status OUTPUT, @Reason OUTPUT

SELECT @Status, @Reason
*/
(
	@TerminalKey			INT,
	@TerminaID				VARCHAR(50),
	@PortKey				SMALLINT,
	@StatusKey				INT,
	@TerminalAddress		NVARCHAR(MAX) = '',
	@IsActive				BIT,
	@UserKey				INT,
	@Status					BIT=1 OUTPUT,
	@Reason					VARCHAR(100) OUTPUT
)
AS

BEGIN

	SET @IsActive=CASE WHEN @StatusKey=1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
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

	BEGIN TRANSACTION
	BEGIN TRY
		

			INSERT INTO			#Address_temp
								(AddrKey,AddrName,Address1,Address2,City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
			SELECT				*
			FROM				OPENJSON (@TerminalAddress,'$.Address')
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
			
			SELECT			@AddrKey = AddrKey from #Address_temp
		
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




		IF (@TerminalKey=0)
			BEGIN
				INSERT INTO			ShippingPortTerminals 
									(TerminaID,PortKey,AddrKey,StatusKey,IsActive,IsDeleted,CreateDate,CreateUserKey,Updatedate,UpdateUserKey)
				SELECT				@TerminaID,NULL,@AddrKey,@StatusKey,@IsActive,0,GETDATE(),@UserKey,GETDATE(),@UserKey

				SET					@TerminalKey = SCOPE_IDENTITY()
				SET					@Status = 1
				SET					@Reason = 'Record Created Successfully'

			END
		ELSE
			BEGIN
				UPDATE				ShippingPortTerminals
				SET					TerminaID=@TerminaID,
									PortKey = NULL,--IF(@PortKey,0),
									AddrKey=@AddrKey,
									StatusKey=@StatusKey,
									IsActive = @IsActive ,
									Updatedate = GETDATE(),
									UpdateUserKey = @UserKey 
				WHERE				TerminalKey=@TerminalKey

				SET					@Status = 1
				SET					@Reason = 'Record Updated Successfully'

			END

		

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		SET			@Status = 0
		SET			@Reason = 'Record Failed to Update'

		PRINT		@@error
		PRINT		Error_Message()
		PRINT		'Rollback'

		ROLLBACK TRANSACTION
	END CATCH
END
