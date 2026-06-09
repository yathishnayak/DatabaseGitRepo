CREATE Proc [dbo].[DriverCarrier_List] -- DriverCarrier_List 0
(
	@StatusKey	int	= 0,
	@MarketLocationKey	INT=0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	Select *,
	ExpiryPeriod = Case when ExpiryDays = 0 then 'Expiring Today'
		 when ExpiryDays between -30 and -1 then 'Expiring within a Month'
		 when ExpiryDays between -60 and -31 then 'Expiring within two Months'
		 when ExpiryDays between -90 and -61 then 'Expiring within three Months'
		 when ExpiryDays between -180 and -91 then 'Expiring within six Months'
		 when ExpiryDays between -240 and -181 then 'Expiring within nine Months'
		 when ExpiryDays between -365 and -240 then 'Insurance Valid for almost a year'
		 else 'Expired' end,
	ExpiryCode = Case when ExpiryDays = 0 then 'rgb(255, 0, 0)'
		 when ExpiryDays between -30 and -1 then 'rgb(152, 51, 0)'
		 when ExpiryDays between -60 and -31 then 'rgb(255, 153, 0)'
		 when ExpiryDays between -90 and -61 then 'rgb(255, 102, 0)'
		 when ExpiryDays between -180 and -91 then 'rgb(255, 204, 153)'
		 when ExpiryDays between -240 and -181 then 'rgb(255, 165, 0)'
		 when ExpiryDays between -365 and -240 then 'rgb(0, 255, 0)'
		 else 'rgb(139, 0, 0)' end
	from (
	SELECT DriverKey, DriverID, FirstName,LastName, AddrKey,CarrierKey, D.IsActive,
		DrivingLicenseNo, DrivingLicenseExpiryDate, D.CreateDate, D.StatusKey, 
		StatusDate, VendKey, D.CompanyKey, HireDate, Plate, YearMake, VINId, 
		REPLACE(RFID,'"','') RFID, Replace(ContactNo,'"','') ContactNo, REPLACE(OrgName,'"','') OrgName, OrgZipCode, FuelCardNo, OrgCity, OrgState, 
		OrgCountry, LastUpdateDate, CreateUserKey, LastUpdateUserKey, 
		TractorLicenseNo, DriverHubKey, PhysicalAddrKey, TelePhone, 
		BusinessNumber, CellNumber, FaxNumber, EmailAddress, DOTNumber, 
		MCNumber, TaxIDNumber, YearsUnderCurrentName, FactoringCompany, 
		InsuranceCompany, PolicyNumber, PolicyExpDate, insuranceAgentName, 
		InsuranceAgentNumber, D.PayTypeKey, PayTypeName, S.StatusName,
		ExpiryDays = DATEDIFF(dd, isnull(PolicyExpDate, Getdate()-365), GETDATE()) , MarketLocationKey,D.TruckTypeKey,TT.TruckType

	FROM Driver D 	with (nolock)
	LEft join Carrier_PayTypes PT WITH (NOLOCK) on D.PayTypeKey = PT.PayTypeKey
	LEFT JOIN StatUS S WITH (NOLOCK) ON D.StatusKey = S.StatusKey
	LEFT OUTER JOIN TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey=D.TruckTypeKey
	where (ISNULL(@StatusKey,0) = 0  OR D.StatusKey = @StatusKey) AND
	(@MarketLocationKey=0 OR ISNULL(D.MarketLocationKey,0)=@MarketLocationKey)
	 AND d.IsDelete = 0 
	) A
	ORDER BY DriverID, OrgName
	For JSON PAth
END
