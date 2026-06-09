/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"IsActive" : 0, "IsDeleted" : 1, "DriverKey" : 868}'
		EXEC [Get_VDriver] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
		SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_VDriver]   
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

    select TOP 100000 
	D.DriverKey, 
	D.DriverID, 
	FirstName, 
	LastName, 
	a.AddrKey, 
	CarrierKey, 
	DrivingLicenseNo, 
	DrivingLicenseExpiryDate,
	D.CreateDate, 
	d.StatusKey, 
	StatusDate, 
	VendKey, 
	D.CompanyKey, 
	HireDate, 
	Plate, 
	YearMake, 
	VINId, 
	RFID, 
	ContactNo, 
	OrgName, 
	OrgZipCode, 
	FuelCardNo, 
	OrgCity, 
	OrgState, 
	OrgCountry, 
	A.AddrName, 
	A.Address1, 
	A.Address2, 
	A.City, 
	A.State, 
	A.Country, 
	A.ZipCode,
	I.SSNNo, 
	I.BirthDate, 
	I.DateLeftCompany, 
	I.Notes, 
	I.EmmContactName, 
	I.EmmContactPhone,
	II.DriverLiabInsuranceNo, 
	II.DriverMedicalCardNo,
	TI.DriverType, 
	TI.TruckOwnerFirstName, 
	TI.TruckOwnerLastName, 
	TI.TruckOwnerPhoneNo, 
	TI.EIN,
	LI.TractorLicenseNo, 
	LI.TwicExpiryDate, 
	LI.TruckRegExpiryDate, 
	LI.ApportionedPlateExpiry, 
	LI.GPSSerialNo, 
	LI.LeaseDateExpiry, 
	LI.PDTRLB, 
	LI.PDTRLA, 
	LI.DMVPNDateAdd, 
	LI.DMVPNDateDelete,
	L.displayname,
	'0' AS DriverID1,
	D.PayTypeKey, 
	PT.PayTypeName,
	STUFF((SELECT distinct ', ' + CMT.MoveTypeName
			 from CarrierMoveType CMT
			 INNER JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey=CMT.MoveTypeKey AND IsSelected=1
			 where D.DriverKey = DM.DriverKey
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,2,'') MoveTypes,
	TruckTypeKey,
	MarketLocationKey
	from Driver D  WITH (NOLOCK) 
	inner join Address A WITH (NOLOCK)  on D.AddrKey = A.AddrKey
	Left join DriverInfo I WITH (NOLOCK)  on D.DriverKey = I.DriverKey
	Left join DriverInsuranceInfo II WITH (NOLOCK)  on D.DriverKey = II.DriverKey
	LEft join DriverTruckInfo TI WITH (NOLOCK)  on D.DriverKey = TI.DriverKey
	LEft join DriverLicenseInfo LI WITH (NOLOCK)  on D.DriverKey = LI.DriverKey
	LEft join DriverLicences L WITH (NOLOCK)  on D.DriverKey = L.DriverKey
	LEFT JOIN [Status] S WITH (NOLOCK)  ON S.StatusKey=D.StatusKey
	LEFT JOIN Carrier_PayTypes PT WITH (NOLOCK) ON D.PayTypeKey = PT.PayTypeKey
	WHERE
	(@IsActive IS NULL OR ISNULL(D.IsActive,0) = @IsActive)
	AND (@IsDeleted IS NULL OR ISNULL(D.IsDelete,0) = @IsDeleted)
	AND (@DriverKey IS NULL OR D.DriverKey = @DriverKey)
	ORDER BY DRIVERID1 
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END