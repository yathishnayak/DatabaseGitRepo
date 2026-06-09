
CREATE PROCEDURE [dbo].[Get_PaymentTerms]
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT PaymentTermsKey,PaymentTermsID, [Days],[Description],CompanyKey,StatusKey  FROM dbo.PaymentTerms order by [Days]
END
