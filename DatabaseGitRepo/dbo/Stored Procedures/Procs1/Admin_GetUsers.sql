
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = ''
SET	@IsDebug  = 0

EXEC [Admin_GetUsers] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/


CREATE PRocEDURE [dbo].[Admin_GetUsers]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	@Result1		VARCHAR(1000)	= ''	OUTPUT,
	@Result2		VARCHAR(1000)	= ''	OUTPUT,
	@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@IsDebug		BIT				= 0
)
AS
BEGIN
	DECLARE @JsonResult NVARCHAR(MAX)
	SET @JsonResult = (SELECT UserKey,UserName FROm [User]
	WHERE UserKey IN (714,897,29,512,886,519,27,954,950,530,418)
	FOR JSON PATH)

	SELECT @JsonResult AS JsonResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'
END

 
