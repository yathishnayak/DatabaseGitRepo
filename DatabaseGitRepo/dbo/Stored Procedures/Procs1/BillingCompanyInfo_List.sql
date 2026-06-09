
CREATE procedure [dbo].[BillingCompanyInfo_List]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT Companykey,CompanyName,CreateDate,CreateUser,UpdateDate,UpdateUser,IsActive
	FROM BillingCompanyInfo WITH(NOLOCK)
	FOR JSON PATH
END


