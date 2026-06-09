
CREATE PROCEDURE [dbo].[Get_AllCustomerDetail]
AS
BEGIN   
    SELECT
        c.Custkey, C.CustId, C.CustName, C.Addrkey, C.CreateDate, C.CustomerGroup, C.StatusKey, F.StatusName
        ,C.StatusDate, C.CreditCheck, C.Ach_Required, C.CreditLimit, C.CreditStatus, PT.[Description] AS paymentterms
		, C.SalesPersonKey, C.CSRKey, C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName
    FROM dbo.Customer C (nolock)
        INNER JOIN [Status] F (nolock) ON F.Statuskey=C.StatusKey
        INNER JOIN PaymentTerms PT (nolock) ON PT.PaymentTermsKey=C.PaymentTermsKey
		LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
		Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
    WHERE StatusName='Active' 
	order  by CustName 

END
