/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{}'
	EXEC [Get_DryRunTypeList_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status Status, @Reason Reason
**/
CREATE PROCEDURE [dbo].[Get_DryRunTypeList_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
As
BEGIN
SELECT DryRunTypeKey,DryRunType FROM DryRunType WITH (NOLOCK)
WHERE IsActive=1 AND IsDeleted=0 
FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END