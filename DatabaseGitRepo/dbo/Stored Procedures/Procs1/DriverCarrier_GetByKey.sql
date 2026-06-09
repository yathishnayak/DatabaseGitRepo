CREATE Proc [dbo].[DriverCarrier_GetByKey] --DriverCarrier_GetByKey 456
(
	@DriverKey	int = 0
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
		SELECT DriverKey, DriverID, FirstName,LastName, AddrKey,CarrierKey, 
			DrivingLicenseNo, DrivingLicenseExpiryDate, CreateDate, StatusKey, 
			StatusDate, VendKey, CompanyKey, HireDate, Plate, YearMake, VINId, 
			RFID, ContactNo, OrgName, OrgZipCode, FuelCardNo, OrgCity, OrgState, 
			OrgCountry, LastUpdateDate, CreateUserKey, LastUpdateUserKey, 
			TractorLicenseNo, DriverHubKey, PhysicalAddrKey, TelePhone, 
			BusinessNumber, CellNumber, FaxNumber, EmailAddress, DOTNumber, 
			MCNumber, TaxIDNumber, YearsUnderCurrentName, FactoringCompany, 
			InsuranceCompany, PolicyNumber, PolicyExpDate, insuranceAgentName, 
			ExpiryDays = DATEDIFF(dd, isnull(PolicyExpDate, Getdate()-365), GETDATE()) ,
			InsuranceAgentNumber, PayTypeKey,NoOfTrucks,
			BillingAddress = (
				select AddrKey, AddrName, Address1, Address2, City, State, ZipCode as Zip, 
					Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey
				from address A
				where A.AddrKey = D.AddrKey
				For JSON Path, without_array_wrapper
			),
			PhysicalAddress = (
				select AddrKey, AddrName, Address1, Address2, City, State, ZipCode as Zip, 
					Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey
				from address A
				where A.AddrKey = D.PhysicalAddrKey
				For JSON Path, without_array_wrapper
			),
			ContactNames = (
				select DriverContactKey, DriverKey,  ContactName, 
					ContactDesignation, ContactNumber, ContactEmail
				from DriverContacts A
				where A.DriverKey = D.DriverKey
				For JSON Path
			), MarketLocationKey,TruckTypeKey
		FROM Driver D 	
		WHERE DriverKey = @DriverKey
	) A
	For JSON PAth, without_array_Wrapper
END
