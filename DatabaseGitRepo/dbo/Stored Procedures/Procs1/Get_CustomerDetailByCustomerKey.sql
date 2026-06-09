


CREATE PROCEDURE [dbo].[Get_CustomerDetailByCustomerKey]
@CustomerKey INT
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		 C.CustKey, C.CustID, C.CustName, C.AddrKey, C.CreateDate, CustomerGroup, StatusName
		,C.StatusDate, C.CreditCheck, C.CreditLimit, C.CreditStatus, IsFactored
		, P.PaymentTermsID 
		,C.SalesPersonKey ,C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName, C.CSRKey
	FROM dbo.Customer C  with ( NOLOCK) 
		LEFT JOIN PaymentTerms P  with ( NOLOCK)  ON P.PaymentTermsKey=C.PaymentTermsKey
		LEFT JOIN [Status] S  with ( NOLOCK) ON S.Statuskey=C.StatusKey
		LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
		Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
	WHERE C.CustKey =  @CustomerKey AND  S.StatusName='Active'
END
