/** 
	DECLARE 
		@UserKey		INT = 1144,
		@Status			BIT	= 0,
		@Reason			VARCHAR(1000) = '',
		@IsDebug		BIT = 0,
		@JSONSTRING NVARCHAR(MAX) = '{"IsActive" : 0, "IsDeleted" : 1}'
	EXEC [Get_VDriver_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_VDriver_V2]   
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
    SET NOCOUNT ON;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'JSON should not be empty'
			RETURN
	END	

	DECLARE 
		@IsActive   BIT = NULL,
		@IsDeleted  BIT = NULL,
		@DriverKey  INT = NULL

	SELECT 
		@IsActive   =	    IsActive ,
		@IsDeleted  =	    IsDeleted,
		@DriverKey  =	    DriverKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		IsActive			BIT				'$.IsActive', 
		IsDeleted			BIT				'$.IsDeleted',
		DriverKey			INT				'$.DriverKey'
	)

    SELECT
		D.DriverKey, 
		D.DriverID, 
		D.FirstName, 
		D.LastName, 
		A.AddrKey, 
		D.DrivingLicenseNo, 
		D.DrivingLicenseExpiryDate,
		D.CreateDate, 
		D.StatusKey, 
		D.CompanyKey, 
		D.ContactNo, 
		D.OrgName,
		STUFF((SELECT DISTINCT ', ' + CMT.MoveTypeName
				FROM dbo.CarrierMoveType CMT
				INNER JOIN dbo.Driver_MoveType DM WITH (NOLOCK) 
					ON DM.MoveTypeKey = CMT.MoveTypeKey 
					AND DM.IsSelected = 1
				WHERE D.DriverKey = DM.DriverKey
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1, 2, '') AS MoveTypes,
		D.TruckTypeKey,
		D.MarketLocationKey
	FROM dbo.Driver D WITH (NOLOCK) 
	INNER JOIN dbo.Address A WITH (NOLOCK) ON D.AddrKey = A.AddrKey
	WHERE (@IsActive IS NULL OR D.IsActive = @IsActive OR (D.IsActive IS NULL AND @IsActive = 0))
	  AND (@IsDeleted IS NULL OR D.IsDelete = @IsDeleted OR (D.IsDelete IS NULL AND @IsDeleted = 0))
	  AND (@DriverKey IS NULL OR D.DriverKey = @DriverKey)
	ORDER BY D.FirstName 
	FOR JSON PATH;

	IF(@@ROWCOUNT = 0)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'No records found';
	END

	SET @Status = 1
	SET @Reason = 'Success'
END