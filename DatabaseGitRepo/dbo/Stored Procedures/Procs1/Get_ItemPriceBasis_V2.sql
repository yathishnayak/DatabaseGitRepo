
CREATE PROCEDURE [dbo].[Get_ItemPriceBasis_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '{}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)

AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

		select PriceBasisKey,	PriceBasisID,	[Description],	StatusKey,	StatusDate,	CreateUserKey,	CreateDate,	CompanyKey 
	from ItemPriceBasis
	FOR JSON PATH


		SET @Status = 1
		SET @Reason = 'Success'
END
