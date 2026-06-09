/*

 Declare @UserKey		INT=952,
	@JsonString		VARCHAR(MAX)='{"RouteKey":728150,"MiscReason":"Text2"}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 

	EXEC [Routes_InsertUpdate_MiscReason] @UserKey,@JsonString,@IsDebug,@Status output, @Reason output
	select @Reason Reason,@Status Status

*/

CREATE PROCEDURE [dbo].[Routes_InsertUpdate_MiscReason]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	
	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter missing';
	END

	DECLARE @RouteKey INT=0, @MiscReason NVARCHAR(300)

	SELECT @RouteKey=RouteKey,@MiscReason=MiscReason
	
	FROM OPENJSON(@JSONString,'$')
    WITH (
			RouteKey			INT				'$.RouteKey',
			MiscReason			NVARCHAR(300)	'$.MiscReason'
		)
		
	Update [Routes] 
		SET MiscReason	=	CASE WHEN ISNULL(@MiscReason,'')<>'' THEN @MiscReason ELSE MiscReason END,
			MiscSetBy	=	CASE WHEN ISNULL(@MiscReason,'')<>'' THEN @UserKey ELSE MiscSetBy END,
			MiscSetDate	=	CASE WHEN ISNULL(@MiscReason,'')<>'' THEN GETDATE() ELSE MiscSetDate END
	WHERE RouteKey=@RouteKey

	--Select MiscReason, MiscSetBy from [Routes] WHERE RouteKey=@RouteKey

	SET @Status=1;
	SET @Reason='Success';
END