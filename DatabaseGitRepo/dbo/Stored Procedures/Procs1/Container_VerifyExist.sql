/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"ContainerNo" : "CMAU4883799"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Container_VerifyExist] @UserKey,@JSONString, @IsDebug, @Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Container_VerifyExist]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	DECLARE @ContainerNo VARCHAR(20) = ''

	SELECT @ContainerNo=ContainerNo
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			ContainerNo		VARCHAR(20)		'$.ContainerNo'
		)

	IF (@ContainerNo IS NULL OR LTRIM(RTRIM(@ContainerNo)) = '')
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Container number is empty';
		RETURN;
	END

	SELECT TOP 1 ContainerNo,OrderDetailKey 
	FROM OrderDetail WITH (NOLOCK) WHERE Containerno=@ContainerNo
	ORDER BY OrderDetailKey DESC
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Reason='Success'
	SET @Status = 1
END