CREATE PROCEDURE [dbo].[Get_CustomerCredit]
/*
dbo.fn_get_cust_credit
*/
@CustKey INT,
@Amount DECIMAL(18,2)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT CASE WHEN CreditCheck=1 AND CreditLimit>=@Amount THEN 1 ELSE 0 END AS CreditCheck   --INTO #CreditCheck
	FROM dbo.Customer C	
		INNER JOIN [Status] S ON S.Statuskey=C.StatusKey 
	WHERE CustKey = @CustKey AND S.StatusName='Active'
END
