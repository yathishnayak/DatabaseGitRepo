/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Get_PrePullReasonCodes] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_PrePullReasonCodes]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET @Status=1
	SET @Reason='Success'
	SELECT CodeKey, Code, IsActive, IsDeleted FROM PrePullReasonCodes WITH (NOLOCK)
	WHERE IsActive=1
	FOR JSON PATH
END