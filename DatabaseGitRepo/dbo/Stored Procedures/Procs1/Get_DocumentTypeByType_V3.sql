/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"Type" : "Driver"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_DocumentTypeByType_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DocumentTypeByType_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@Type varchar(20)='Order'

	SELECT 
		@Type		=		[Type]
	FROM OPENJSON(@JSONString)
	WITH
	(
		[Type]		VARCHAR(20)			'$.Type'
	)

	SELECT DocumentTypeKey,[Description] 
	FROM dbo.DocumenType WITH (NOLOCK)
	WHERE [LinkTo] = @Type

	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'

END
