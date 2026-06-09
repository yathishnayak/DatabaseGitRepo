/** 
Declare 
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0
	EXEC [Get_StatusList_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status as Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[Get_StatusList_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT [StatusKey]
      ,[StatusName]
      ,[CompanyKey]
      ,[IsActive]
      ,[CreateDate]
      ,[Type]
  FROM [dbo].[Status] WITH (NOLOCK)
  FOR JSON PATH;

SET @Status = 1
SET @Reason = 'Success'
END