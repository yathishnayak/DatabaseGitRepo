
CREATE PROCEDURE [dbo].[Get_CustomerDetail]
@CustomerKey INT
AS
BEGIN	
	SELECT
		 C.Custkey, C.Custid, C.CustName, C.Addrkey, C.CreateDate, CustomerGroup, StatusName, C.StatusKey
		,c.StatusDate, C.CreditCheck, C.CreditLimit, C.CreditStatus, C.Ach_Required, PT.[Description] AS paymentterms, 
		C.PaymentTermsKey, IsFactored,c.IsActive,c.IsDelete,
		C.SalesPersonKey ,C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName, C.CSRKey
	FROM dbo.Customer C with ( NOLOCK)
		LEFT JOIN [Status] S with ( NOLOCK) ON S.Statuskey=C.StatusKey 
		INNER JOIN PaymentTerms PT with ( NOLOCK) ON PT.PaymentTermsKey=C.PaymentTermsKey
		LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
		Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
	WHERE C.Custkey =  @CustomerKey 
END
