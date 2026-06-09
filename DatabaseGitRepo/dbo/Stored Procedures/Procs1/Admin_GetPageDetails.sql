
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"MenuKey":1}'
SET	@IsDebug  = 0

EXEC [Admin_GetPageDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

CREATE PRocEDURE [dbo].[Admin_GetPageDetails] -- Admin_GetPageDetails 2
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

	DECLARE @MenuKey INT = 0, @JsonResult NVARCHAR(MAX) = ''

	SELECT		@MenuKey = MenuKey 
	FROM		OPENJSON(@JSONString, '$')
				WITH (
						MenuKey	INT				'$.MenuKey'
					)
	
	SET @JsonResult = (SELECT * FROM (
	SELECT Pagekey,PageName, RouteName, OrderBy, MenuKey FROm Admin_PageDetails
	WHERE MenuKey = @MenuKey
	) A
	Order By OrderBy
	FOR JSON PATH)

	SELECT @JsonResult AS JsonResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'
END
