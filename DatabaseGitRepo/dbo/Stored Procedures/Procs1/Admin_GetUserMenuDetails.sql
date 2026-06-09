
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"UserKey":"897"}'
SET	@IsDebug  = 0

EXEC [Admin_GetUserMenuDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/


CREATE PRocEDURE [dbo].[Admin_GetUserMenuDetails]
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
	DECLARE @AssignUserKey INT = 0, @MenuKey INT = 0, @JsonResult NVARCHAR(MAX) = ''

	SELECT		@AssignUserKey = UserKey 
	FROM		OPENJSON(@JSONString, '$')
				WITH (
						UserKey	INT				'$.UserKey'
					)
	SET @JsonResult =	(SELECT	* 
						FROM	(SELECT	*
										,PageDetails =  (SELECT		PD.PageKey,PD.PageName,PD.RouteName
														FROM		Admin_PageDetails PD 
														INNER JOIN	Admin_UserPageDetails UPD ON PD.PageKey = UPD.PageKey
														WHERE		UPD.UserKey = @AssignUserKey AND PD.MenuKey = MD.MenuKey
														Order By	PD.OrderBy FOR JSON PATH )
								FROM		Admin_MenuDetails MD) A
								WHERE PageDetails IS NOT NULL
								ORDER BY A.OrderBy
						FOR JSON PATH)

	SELECT @JsonResult AS JsonResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'

END
