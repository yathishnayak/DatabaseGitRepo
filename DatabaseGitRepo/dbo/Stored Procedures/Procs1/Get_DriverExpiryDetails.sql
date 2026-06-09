/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Get_DriverExpiryDetails] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PRocedure [dbo].[Get_DriverExpiryDetails] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 
	DriverKey				   ,
	DriverID				   ,
	FirstName				   ,
	LastName				   ,
	OrgName					   ,
	DriverTypeName			   ,
	DrivingLicenseExpiryDate   ,
	DriverMedicalCardExpDate   ,
	CoLiabInsuEndDate		   ,
	CoOccuInsuEndDate		   ,
	DriverLiabInsuranceExpDate ,
	CHPInspectionDate		   ,
	SmokeCheckDate			   ,
	TruckInspectionDate		   ,
	InspectionDate			   ,
	TruckRegExpiryDate		   ,
	TwicExpiryDate			   ,
	ScreenDate				   ,
	ApportionedPlateExpiry	   ,
	LeaseDateExpiry			   ,
	PDTRLA					   ,
	PDTRLB					   ,
	StatusKey				   ,
	TruckValidityDays		   ,
	TruckExpiry				   ,
	CHPValididyDays			   ,
	CHPExpiryDate			   ,
	SmokeCheckValididyDays	   ,
	SmokeCheckExpiry
	FROM DriverExpiryDetails WITH(NOLOCK)
	
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END
