/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"StatusKey": 0}',
	@Status BIT = 0,  
	@IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetCustomersByStatus_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[GetCustomersByStatus_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"StatusKey": 0}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @StatusKey INT = 0;		-- 0 = ALL, 1 = Active, 2 = Inactive, 3 = Deleted
    
    -- Parse JSON input
    SELECT @StatusKey = ISNULL(StatusKey, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        StatusKey INT '$.StatusKey'
    );
	
	if @StatusKey > 0
	BEGIN
		SELECT
			 C.Custkey, C.Custid, C.CustName, C.Addrkey, C.CreateDate, CustomerGroup, StatusName, C.StatusKey
			,c.StatusDate, C.CreditCheck, C.CreditLimit, C.CreditStatus, C.Ach_Required, 
			PT.[Description] AS paymentterms, C.PaymentTermsKey, IsFactored
			,C.SalesPersonKey ,C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName, C.CSRKey as CsrKey
		FROM dbo.Customer C  with ( NOLOCK) 
			LEFT JOIN PaymentTerms PT  with ( NOLOCK)  ON PT.PaymentTermsKey=C.PaymentTermsKey
			LEFT JOIN [Status] S  with ( NOLOCK) ON S.Statuskey=C.StatusKey
			LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
			Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
			Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
		WHERE C.StatusKey =  @StatusKey
			FOR JSON PATH
	END

	if @StatusKey = 0
	BEGIN
		SELECT
			 C.Custkey, C.Custid, C.CustName, C.Addrkey, C.CreateDate, CustomerGroup, StatusName, C.StatusKey
			,c.StatusDate, C.CreditCheck, C.CreditLimit, C.CreditStatus, C.Ach_Required, 
			PT.[Description] AS paymentterms, C.PaymentTermsKey, IsFactored
			,C.SalesPersonKey ,C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName, C.CSRKey as CsrKey
		FROM dbo.Customer C  with ( NOLOCK) 
			LEFT JOIN PaymentTerms PT  with ( NOLOCK)  ON PT.PaymentTermsKey=C.PaymentTermsKey
			LEFT JOIN [Status] S  with ( NOLOCK) ON S.Statuskey=C.StatusKey
			LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
			Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
			Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
				FOR JSON PATH
	END

	SET @Status = 1;
    SET @Reason = 'Success';
END