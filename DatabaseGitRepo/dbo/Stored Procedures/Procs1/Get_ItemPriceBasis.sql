
CREATE PROCEDURE [dbo].[Get_ItemPriceBasis]

AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	select PriceBasisKey,	PriceBasisID,	[Description],	StatusKey,	StatusDate,	CreateUserKey,	CreateDate,	CompanyKey 
	from [dbo].[ItemPriceBasis] nolock
END
