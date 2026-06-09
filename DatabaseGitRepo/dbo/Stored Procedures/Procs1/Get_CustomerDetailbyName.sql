
CREATE PROCEDURE [dbo].[Get_CustomerDetailbyName] -- [Get_CustomerDetailbyName] 'la'
@CustName VARCHAR(100)=''
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	Select
	c.CustKey, CustID, CustName, c.AddrKey, C.CreateDate, CustomerGroup, S.StatusName, Ach_Required,
		BillToAddrKey, C.Notes, C.PaymentTermsKey,C.StatusKey
		,c.StatusDate, CreditCheck, CreditLimit, CreditStatus,P.PaymentTermsID, IsFactored,
		C.SalesPersonKey ,C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName, C.CSRKey,
		a1.AddrName,a1.Address1,a1.Address2,a1.City,a1.State,a1.ZipCode,a1.Country,a1.Website,a1.Phone
		,a1.Email,a1.Fax,a1.Phone2,a1.Email2,a1.CityKey, CA1.AddrType,
		A2.AddrName,A2.Address1,A2.Address2,A2.City,A2.State,A2.ZipCode,A2.Country,A2.Website,A2.Phone
		,A2.Email,A2.Fax,A2.Phone2,A2.Email2,A2.CityKey, CA2.AddrType
	FROM dbo.Customer C  with ( NOLOCK) 
		LEFT JOIN PaymentTerms P  with ( NOLOCK)  ON P.PaymentTermsKey=C.PaymentTermsKey
		LEFT JOIN [Status] S  with ( NOLOCK) ON S.Statuskey=C.StatusKey
		LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
		Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
		LEft join Address A1 WITH (NOLOCK) ON C.AddrKey = A1.AddrKey
		leFT JOIN CustomerAddress CA1 with (nolock) on C.AddrKey = CA1.AddrKey and C.CustKey = CA1.CustKey
		LEft join Address A2 WITH (NOLOCK) ON C.AddrKey = A2.AddrKey
		leFT JOIN CustomerAddress CA2 with (nolock) on C.AddrKey = CA2.AddrKey and C.CustKey = CA2.CustKey
	WHERE CustName LIKE ''+@CustName+'%'	and S.StatusName='Active'
	ORDER BY CustName
END
