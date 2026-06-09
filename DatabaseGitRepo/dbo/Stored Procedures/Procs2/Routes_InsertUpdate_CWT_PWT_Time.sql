/*

 Declare @UserKey		INT=952,
	@JsonString		VARCHAR(MAX)='{"CWTFromTime":null,"CWTToTime":null,"PWTFromTime":"11:30","PWTToTime":"12:00"}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 

	EXEC [Routes_InsertUpdate_CWT_PWT_Time] @UserKey,@JsonString,@IsDebug,@Status output, @Reason output
	SELECT @Reason AS Reason,@Status AS Status

*/

CREATE PROCEDURE [dbo].[Routes_InsertUpdate_CWT_PWT_Time]
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

	DECLARE @RouteKey INT=0, @CWTFromTime NVARCHAR(20), @CWTToTime	NVARCHAR(20), @PWTFromTime NVARCHAR(20), @PWTToTime NVARCHAR(20)=''

	SELECT @RouteKey=RouteKey,@CWTFromTime=CWTFromTime, @CWTToTime=CWTToTime, @PWTFromTime=PWTFromTime, @PWTToTime=PWTToTime
	
	FROM OPENJSON(@JSONString,'$')
    WITH (
			RouteKey			INT				'$.RouteKey',
			CWTFromTime			NVARCHAR(20)	'$.CWTFromTime',
			CWTToTime			NVARCHAR(20)	'$.CWTToTime',
			PWTFromTime			NVARCHAR(20)	'$.PWTFromTime',
			PWTToTime			NVARCHAR(20)	'$.PWTToTime'
		)
		
	Update [Routes] 
		SET CWTFromTime	=	CASE WHEN ISNULL(@CWTFromTime,'')<>'' THEN @CWTFromTime ELSE CWTFromTime END,
			CWTToTime	=	CASE WHEN ISNULL(@CWTToTime,'')<>'' THEN @CWTToTime ELSE CWTToTime END,
			CWTToTimeSetBy	=	CASE WHEN ISNULL(@CWTFromTime,'')<>'' THEN @UserKey ELSE CWTToTimeSetBy END,
			CWTToTimeSetDate	=	CASE WHEN ISNULL(@CWTFromTime,'')<>'' THEN GETDATE() ELSE CWTToTimeSetDate END,
			PWTFromTime	=	CASE WHEN ISNULL(@PWTFromTime,'')<>'' THEN @PWTFromTime ELSE PWTFromTime END,
			PWTToTime	=	CASE WHEN ISNULL(@PWTToTime,'')<>'' THEN @PWTToTime ELSE PWTToTime END,
			PWTToTimeSetBy	=	CASE WHEN ISNULL(@PWTFromTime,'')<>'' THEN @UserKey ELSE PWTToTimeSetBy END,
			PWTToTimeSetDate	=	CASE WHEN ISNULL(@PWTFromTime,'')<>'' THEN GETDATE() ELSE PWTToTimeSetDate END
	WHERE RouteKey=@RouteKey

	--Select PWTFromTime, PWTToTime from [Routes] WHERE RouteKey=@RouteKey

	SET @Status=1;
	SET @Reason='Success';
END
