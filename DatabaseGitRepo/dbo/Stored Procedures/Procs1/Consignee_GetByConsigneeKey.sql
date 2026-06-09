
CREATE PROC [dbo].[Consignee_GetByConsigneeKey]
(
	@ConsigneeKey	int
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	select C.CompanyKey, C.ConsigneeID, C.Name, C.AddrKey, Address = (
		select  A.AddrKey, A.Address1, A.Address2, A.AddrName, A.City, A.State, A.Country, A.ZipCode,
		A.ZipCode as Zip, Website, Phone, Email, Fax, Phone2, Email2, CityKey
		from Address AA where AA.AddrKey = C.AddrKey
		for JSON PATH, without_array_wrapper
		),
		CU.CustKey, CU.CustID, CU.CustName, CA.CSRName, CM.CSRName as CSRManagerName,
		C.CSRKey, C.CSRManagerKey
	from Consignee C WITH (NOLOCK)
	inner join Customer CU WITH (NOLOCK) on C.CustKey = CU.CustKey
	LEFT JOIN Address A  WITH (NOLOCK) ON C.AddrKey = A.AddrKey
	LEft Join CSR CA with(NOLOCK) ON C.CSRKey = CA.CsrKey
	LEft Join CSR CM with (nolock) on C.CSRManagerKey = CM.CSRKey
	WHERE C.ConsigneeKey = @ConsigneeKey
	for JSON Path, without_array_wrapper
END
