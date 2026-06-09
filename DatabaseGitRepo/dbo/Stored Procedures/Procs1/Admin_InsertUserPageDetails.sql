
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '[{"PageName":"App Logs","PageKey":1,"IsPageSelected":true,"UserKey":"897","MenuKey":"1"},{"PageName":"Test Page 1","PageKey":6,"IsPageSelected":true,"UserKey":"897","MenuKey":"1"},{"PageName":"Test Page 2","PageKey":7,"IsPageSelected":true,"UserKey":"897","MenuKey":"1"}]'
SET	@IsDebug  = 0

EXEC [Admin_InsertUserPageDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

CREATE PRocEDURE [dbo].[Admin_InsertUserPageDetails]
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
	DECLARE   @JsonResult NVARCHAR(MAX) = '',@MenuKey INT = 0 

	CREATE TABLE #UserPageDetails
	(
		UserKey	INT,
		MenuKey	INT,
		Pagekey	INT,
		IsSelected	BIT
	)

	INSERT INTO	#UserPageDetails
	SELECT		UserKey , MenuKey, PageKey, IsSelected
	FROM		OPENJSON(@JSONString, '$')
				WITH (
						UserKey		INT		'$.UserKey',
						MenuKey		INT		'$.MenuKey',
						PageKey		INT		'$.PageKey',
						IsSelected	BIT		'$.IsPageSelected'
					)
	SET @MenuKey = (SELECT Menukey FROM Admin_PageDetails WHERE Pagekey IN (SELECT TOP 1 PageKey FROM #UserPageDetails))
	SET @UserKey = (SELECT TOP 1 Userkey FROM #UserPageDetails)

	IF(@ISDebug = 1)
		BEGIN
			SELECT * FROM #UserPageDetails
		END

	DELETE		UPD
	FROM		Admin_UserPageDetails UPD
	INNER JOIN	Admin_PageDetails PD ON PD.PageKey = UPD.PageKey
	INNER JOIN	#UserPageDetails TPD ON UPD.UserKey = TPD.UserKey AND UPD.Pagekey = TPD.PageKey
	WHERE		UPD.UserKey = TPD.UserKey AND PD.MenuKey = TPD.MenuKey  AND  TPD.IsSelected = 0

	DELETE		TPD
	FROM		#UserPageDetails TPD
	INNER JOIN	Admin_UserPageDetails UPD ON UPD.UserKey = TPD.UserKey AND UPD.Pagekey = TPD.PageKey
				AND TPD.UserKey = TPD.UserKey 

	INSERT INTO	Admin_UserPageDetails
				(UserKey,PageKey)
	SELECT		UserKey,PageKey
	FROM		#UserPageDetails
	WHERE		IsSelected = 1


	SET @JsonResult = (SELECT		PageName, CASE WHEN UPD.PageKey IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END IsPageSelected
						FROM		Admin_MenuDetails MD
						INNER JOIN	Admin_PageDetails PD ON MD.MenuKey = PD.MenuKey
						LEFT JOIN	Admin_UserPageDetails UPD ON PD.PageKey = UPD.PageKey AND UserKey = @UserKey
						WHERE		MD.MenuKey = @MenuKey FOR JSON PATH )

	SELECT @JsonResult AS JsonResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'
END
