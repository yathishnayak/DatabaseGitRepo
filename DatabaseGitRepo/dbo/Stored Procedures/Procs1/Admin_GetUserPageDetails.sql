
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"UserKey":"714","MenuKey":"4"}'
SET	@IsDebug  = 0

EXEC [Admin_GetUserPageDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

CREATE PRocEDURE [dbo].[Admin_GetUserPageDetails]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '{"UserKey":"897","MenuKey":"1"}',
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
	DECLARE @AssignUserKey INT = 0, @MenuKey INT = 0, @JsonResult NVARCHAR(MAX) = ''

	SELECT		@AssignUserKey = UserKey , @MenuKey = MenuKey
	FROM		OPENJSON(@JSONString, '$')
				WITH (
						UserKey	INT				'$.UserKey',
						MenuKey	INT				'$.MenuKey'
					)

	SET @JsonResult = (SELECT		PD.PageName, PD.PageKey, CASE WHEN UPD.PageKey IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END IsPageSelected
						FROM		Admin_MenuDetails MD
						INNER JOIN	Admin_PageDetails PD ON MD.MenuKey = PD.MenuKey
						LEFT JOIN	Admin_UserPageDetails UPD ON PD.PageKey = UPD.PageKey AND UserKey = @AssignUserKey
						WHERE		MD.MenuKey = @MenuKey FOR JSON PATH )

	SELECT @JsonResult AS JsonResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'

END
