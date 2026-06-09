
CREATE proc [dbo].[Consignee_GetListForCustomer] -- [Consignee_GetListForCustomer] 1555
(
	@CustKey	int = 0
)
as
begin
	set nocount on
	set fmtonly off

	select C.ConsigneeKey , C.CompanyKey, C.ConsigneeID, C.Name, C.AddrKey, AddressStr = (
		select A.AddrKey, A.Address1, A.Address2, A.AddrName, A.AddrName as Name, A.City, A.ZipCode,
		A.State, A.Country, A.ZipCode as Zip,  Website, Phone, Email, Fax, Phone2, Email2, CityKey
		from Address AA where AA.AddrKey = C.AddrKey
		for JSON PATH, without_array_wrapper
		),
		CU.CustKey, CU.CustID, CU.CustName,
		 CA.CSRName, CM.CSRName as CSRManagerName,C.CSRKey, C.CSRManagerKey
	from Consignee C WITH (NOLOCK)
	inner join Customer CU WITH (NOLOCK) on C.CustKey = CU.CustKey
	LEFT JOIN Address A  WITH (NOLOCK) ON C.AddrKey = A.AddrKey
	LEft Join CSR CA with(NOLOCK) ON C.CSRKey = CA.CsrKey
	LEft Join CSR CM with (nolock) on C.CSRManagerKey = CM.CSRKey
	WHERE C.CustKey = @CustKey
	for JSON Path
end
