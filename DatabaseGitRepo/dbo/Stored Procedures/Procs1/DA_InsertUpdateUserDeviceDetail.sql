 
/*


SELECT * FROM DA_DeviceDetails
SELECT * FROM DA_UserDeviceDetails
 
EXEC [DA_InsertUpdateUserDeviceDetail] NULL,NULL
EXEC [DA_InsertUpdateUserDeviceDetail] NULL,'{"UniqueID":"","Model":"","DeviceName":"","Brand":"","HardWare":"","DeviceProduct":"","DeviceVersion":"","Manufacturer":"","AndroidSDK":"","Machine":"","SystemName":"","LocalizedModel":""}'
EXEC [DA_InsertUpdateUserDeviceDetail] 1,'{"UniqueID":"wecrgfggr_fgrf","Model":"rytec","DeviceName":"UAV","Brand":"mcod","HardWare":"er4","DeviceProduct":"","DeviceVersion":"1.0.13","Manufacturer":"samsung","AndroidSDK":"","Machine":"rog15","SystemName":"ghost","LocalizedModel":""}'
EXEC [DA_InsertUpdateUserDeviceDetail] 714,'{"Model":"SM-G990E","Manufacturer":"samsung","Device":"r9s","Brand":"samsung","Hardware":"exynos2100","Product":"r9sxxx","Android Version":"14","Android SDK":"34","UniqueID":"UP1A.231005.007"}'
EXEC [DA_InsertUpdateUserDeviceDetail] 342,'{"System Name":"iOS","System Version":"18.1.1","Model":"iPhone","Localized Model":"iPhone","Machine":"iPhone15,5","UniqueID":"4BECD302-6623-490E-8344-8B1C40E27E24"}'
SELECT * FROM DA_DeviceDetails
SELECT * FROM DA_UserDeviceDetails

*/

CREATE PROCEDURE [dbo].[DA_InsertUpdateUserDeviceDetail](
	@UserKey INT,
	@DriverKey INT,
	@JsonString NVARCHAR(MAX),
	@FirebaseID	VARCHAR(500)
)AS 
BEGIN
	--SET @JsonString = REPLACE(@JsonString,'"System Version"','"Android Version"')
	DECLARE @IsApproved		BIT = 0
	SET @IsApproved = 0

	DECLARE 
		@UniqueID			VARCHAR(200),
		@Model				VARCHAR(100),
		@DeviceName			VARCHAR(100),
		@Brand				VARCHAR(100),
		@HardWare			VARCHAR(100),
		@DeviceProduct		VARCHAR(100),
		@DeviceVersion		VARCHAR(50)	,
		@Manufacturer		VARCHAR(100),
		@AndroidSDK			VARCHAR(50)	,
		@Machine			VARCHAR(100),
		@SystemName			VARCHAR(100),
		@LocalizedModel		VARCHAR(100)
 
	DECLARE
		@DeviceKey		INT,
		@DeviceUserKey	INT = 0,
		@Response		VARCHAR(100)
		
 
	
 
	--json param
	
 
 
	SELECT 
		@UniqueID		= jUniqueID			,
		@Model			= jModel			,		
		@DeviceName		= jDeviceName		,
		@Brand			= jBrand			,	
		@HardWare		= jHardWare			,
		@DeviceProduct	= jDeviceProduct	,
		@DeviceVersion	= jDeviceVersion	,	
		@Manufacturer	= jManufacturer		,
		@AndroidSDK		= jAndroidSDK		,
		@Machine		= jMachine			,
		@SystemName		= jSystemName		,
		@LocalizedModel	= jLocalizedModel	
	FROM OPENJSON(@JsonString,'$')
		WITH(
			jUniqueID		VARCHAR(200)	'$.UniqueID',
			jModel			VARCHAR(100)	'$.Model',
			jDeviceName		VARCHAR(100)	'$.Device',
			jBrand			VARCHAR(100)	'$.Brand',
			jHardWare		VARCHAR(100)	'$.Hardware',
			jDeviceProduct	VARCHAR(100)	'$.Product',
			jDeviceVersion	VARCHAR(50)		'$."Android Version"',
			jManufacturer	VARCHAR(100)	'$.Manufacturer',
			jAndroidSDK		VARCHAR(50)		'$."Android SDK"',
			jMachine		VARCHAR(100)	'$.Machine',
			jSystemName		VARCHAR(100)	'$."System Name"',
			jLocalizedModel	VARCHAR(100)	'$."Localized Model"'
		)

	SET @DeviceVersion = ISNULL(@DeviceVersion,JSON_VALUE(@JsonString,'$."System Version"'))


	IF(ISNULL(@UserKey,0)=0 OR ISNULL(@JsonString,'')='' OR ISNULL(@DriverKey,0)=0 OR ISNULL(@FirebaseID,'') = '' )
		BEGIN
			SET @Response =  'Userkey, JsonData, FirebaseID Cannot be NULL OR NA'
		END
	ELSE IF(ISNULL(@FirebaseID,'') = 'NA')
		BEGIN
			SET @Response =  'Valid Permissions required'
		END
	ELSE IF(
		ISNULL(@UniqueID		,'') = '' AND		
		ISNULL(@Model			,'') = '' AND			
		ISNULL(@DeviceName		,'') = '' AND
		ISNULL(@Brand			,'') = '' AND	
		ISNULL(@HardWare		,'') = '' AND		
		ISNULL(@DeviceProduct	,'') = '' AND
		ISNULL(@DeviceVersion	,'') = '' AND	
		ISNULL(@Manufacturer	,'') = '' AND
		ISNULL(@AndroidSDK		,'') = '' AND
		ISNULL(@Machine			,'') = '' AND
		ISNULL(@SystemName		,'') = '' AND
		ISNULL(@LocalizedModel	,'') = ''
	)	
		BEGIN
			SET @Response = 'Fields cannot be NULL or EMPTY'
		END
	ELSE
		BEGIN
			Select @DeviceKey = DeviceKey FROM DA_DeviceDetails 
			WHERE 
					ISNULL(UniqueID,'')			= ISNULL(@UniqueID,'')			AND
					ISNULL(Model,'')			= ISNULL(@Model	,'')			AND
					ISNULL(DeviceName,'')		= ISNULL(@DeviceName,'')		AND
					ISNULL(Brand,'')			= ISNULL(@Brand,'')				AND
					ISNULL(HardWare,'')			= ISNULL(@HardWare,'')			AND
					ISNULL(DeviceProduct,'')	= ISNULL(@DeviceProduct,'')		AND
					ISNULL(DeviceVersion,'')	= ISNULL(@DeviceVersion,'')		AND
					ISNULL(Manufacturer,'')		= ISNULL(@Manufacturer,'')		AND
					ISNULL(AndroidSDK,'')		= ISNULL(@AndroidSDK,'')		AND
					ISNULL(Machine,'')			= ISNULL(@Machine,'')			AND
					ISNULL(SystemName,'')		= ISNULL(@SystemName,'')		AND
					ISNULL(LocalizedModel,'')	= ISNULL(@LocalizedModel,'')		
			
 
			IF(ISNULL(@DeviceKey,0) = 0)
				BEGIN
					INSERT INTO DA_DeviceDetails(
						UniqueID,Model,DeviceName,Brand,HardWare,DeviceProduct,DeviceVersion,Manufacturer,AndroidSDK,Machine,SystemName,LocalizedModel,CreatedDate
					)
					VALUES (
						@UniqueID,@Model,@DeviceName,@Brand,@HardWare,@DeviceProduct,@DeviceVersion,@Manufacturer,@AndroidSDK,@Machine,@SystemName,@LocalizedModel,GETDATE()
					)
					SET @DeviceKey = @@IDENTITY
					--SET @Response = 'Record Inserted Successfully:[DA_DeviceDetails]'
				END
		
 
	-- check UserDeviceDetails table
			
			UPDATE	DD SET IsApproved = 1
			FROM DA_UserDeviceDetails  DD
			WHERE UserKey = @UserKey AND DeviceKey = @DeviceKey

 
			SELECT	@DeviceUserKey = UserKey,
					@IsApproved =    IsApproved
			FROM DA_UserDeviceDetails 
			WHERE UserKey = @UserKey AND DeviceKey = @DeviceKey
 
			IF(ISNULL(@DeviceUserKey,0) = 0)
				BEGIN
					INSERT INTO DA_UserDeviceDetails(UserKey,DeviceKey,IsApproved,DriverKey,ApprovedBy,ApprovedDate,CreatedDate)
					VALUES(@UserKey,@DeviceKey,1,@DriverKey,0,GETDATE(),GETDATE())
 
					--SET @Response = @Response + ',Record Inserted Successfully:[DA_UserDeviceDetails]'
				END

			SET @Response = CASE WHEN @IsApproved = 0 THEN 'Device is pending for approval' ELSE 'Success' END
		END
	
	-- SET @IsApproved = ISNULL(@IsApproved,0);

	SET @IsApproved = 1
	
	SELECT -- 
		@IsApproved AS IsApproved,
		@DeviceKey AS DeviceKey,
		@Response AS Response
 
END
