

CREATE PROCEDURE [dbo].[MarketLocation_InsertUpdate] 

/*

DECLARE @CustomerData nvarchar(max) = '{"MarketLocation":"MarketLocation1234","IsActive":"false","Address":[{"AddrKey":3758,"AddrName":"abc35971234","Address1":"chicago1234","Address2":"chicago","City":"Holtsville","State":"NY","ZipCode":"00501","Country":"USA","Website":"http://localhost:4200/address","Phone":"+1(843)412-4374","Email":"unknown@trikaiser.com","Fax":null,"Phone2":"12345678920","Email2":"unknown@trikaiser.com","CityKey":31984,"Longitude":0,"Latitude":0,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0,"RecTimeStamp":null,"CreateUserName":null,"UpdateUserName":null}]}'
,@MarketLocationKey INT = 20, @UserKey  INT = 29, @Status BIT = 0, @Reason VARCHAR(100) = ''

EXEC MarketLocation_InsertUpdate @MarketLocationKey, @CustomerData, @UserKey, @Status OUTPUT, @Reason OUTPUT

SELECT @Status, @Reason
*/
(

		@MarketLocationKey		INT,
		@CustomerData			NVARCHAR(MAX) = '',
		@UserKey				INT,
		@Status					BIT=1 OUTPUT,
		@Reason					VARCHAR(100) OUTPUT
)

AS

BEGIN

	DECLARE		@AddrKey  INT = 0, @MarketLocation VARCHAR(100) = '', @IsActive BIT = ''

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

	CREATE TABLE #MarketLocation_temp
		  (
				MarketLocation		NVARCHAR(510),
				AddrKey				INT
		  ) 

	


	BEGIN TRANSACTION
		BEGIN TRY

			INSERT INTO			#Address_temp
								(AddrKey,AddrName,Address1,Address2,City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
			SELECT				*
			FROM				OPENJSON (@CustomerData,'$.Address')
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
					SET			AddrName =   b.AddrName,Address1 = b.Address1,City = b.city,[State] = b.[State] ,ZipCode = b.ZipCode,Country = b.Country ,								Website =   b.Website,								Phone =	b.Phone,								Email =	b.Email,
								Fax	=b.Fax,Phone2 =b.Phone2,Email2 =b.Email2,CityKey =b.CityKey
					FROM		[Address] A 
					INNER JOIN	#Address_temp B ON A.AddrKey = B.AddrKey
				END


			SELECT				@MarketLocation = MarketLocation, @IsActive = IsActive
			FROM				OPENJSON (@CustomerData,'$')
			WITH
			(
				MarketLocation		VARCHAR(100)	'$.MarketLocation',
				IsActive			BIT				'$.IsActive'
			);
			

			-- SELECT @IsActive
			
			IF(ISNULL(@MarketLocationKey,0) = 0)
				BEGIN
					INSERT INTO MarketLocation
								(MarketLocation,AddrKey,IsActive,IsDeleted,CreateDate,CreateUserKey,UpdateDate,UpdateUserKey)
					SELECT		@MarketLocation,@AddrKey,@IsActive,0,GETDATE(),@UserKey,GETDATE(),@UserKey

					SET			@MarketLocationKey = SCOPE_IDENTITY()
				END
			ELSE
				BEGIN
					UPDATE		MarketLocation
					SET			MarketLocation = @MarketLocation, AddrKey = @AddrKey, UpdateDate = GETDATE()
								,UpdateUserKey = @UserKey , IsActive = @IsActive
					WHERE		MarketLocationKey = @MarketLocationKey 
				END
			SET		@Status = 1
			SET		@Reason = 'Record Updated Successfully'
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
