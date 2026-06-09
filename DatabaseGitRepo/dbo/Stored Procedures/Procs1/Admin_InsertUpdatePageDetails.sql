
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"PageKey":14,"PageName":"New Tab","MenuKey":"1","RouteName":"Compare","OrderBy":"1","IsUpdate":true}'
SET	@IsDebug  = 0

EXEC [Admin_InsertUpdatePageDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/


CREATE PRocEDURE [dbo].[Admin_InsertUpdatePageDetails]  
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
	DECLARE 	@PageKey		INT		,
				@PageName		VARCHAR(50),
				@MenuKey		INT,
				@RouteName		VARCHAR(50),
				@OrderBy		INT,
				@IsUpdate		BIT


	SELECT	@PageKey = PageKey, @PageName = PageName, @MenuKey = MenuKey, @RouteName = RouteName, @OrderBy = OrderBy , @IsUpdate = IsUpdate
	FROM	OPENJSON(@JSONString, '$')
			WITH (
					PageKey			INT				'$.Pagekey',
					PageName		VARCHAR(50)		'$.PageName',
					MenuKey			INT				'$.MenuKey',
					RouteName		VARCHAR(50)		'$.RouteName',
					OrderBy			INT				'$.OrderBy',
					IsUpdate		BIT				'$.IsUpdate'
				)

	DECLARE @Message VARCHAR(2000) = ''
	SET @PageName = LTRIM(RTRIM(ISNULL(@PageName,'')))
	SET @MenuKey = LTRIM(RTRIM(ISNULL(@MenuKey,0)))
	SET @RouteName = LTRIM(RTRIM(ISNULL(@RouteName,'')))
	SET @OrderBy = LTRIM(RTRIM(ISNULL(@OrderBy,0)))
	SET @PageKey = LTRIM(RTRIM(ISNULL(@PageKey,0)))


	DECLARE @IsPageExists BIT = 0, @PageKeyofPageName INT  = 0

	SET @PageKeyofPageName = ISNULL((SELECT PageKey FROM Admin_PageDetails WHERE PageName = @PageName),0)


	SET @IsPageExists = (case when @PageKeyofPageName > 0 then 1 else 0 end)

	IF(@PageName = '' OR @MenuKey = 0 OR @RouteName = '' OR @OrderBy = 0)
		BEGIN
			SET @IntMessage = 'Param Values cannot be blank or null'
		END
	ELSE IF (@IsPageExists = 1 and @IsUpdate = 0)
		BEGIN
			SET @IntMessage = 'Page Name already Exists'
		END	
	ELSE IF(@IsUpdate = 1)
		IF(ISNULL(@PageKey,0) = 0)
			BEGIN
				SET @IntMessage = 'Pagekey cannot be null or Zero'
			END
		ELSE IF (@IsPageExists = 1 AND @PageKeyofPageName <> @PageKey)
			BEGIN
				SET @IntMessage = 'Page Name already Exists'
			END	
		ELSE IF((SELECT COUNT(*) FROM Admin_PageDetails WHERE PageKey  =  ISNULL(@PageKey,0)) = 0 )
			BEGIN
				SET @IntMessage = 'Check PageKey Value'
			END
		ELSE
			BEGIN
				UPDATE		Admin_PageDetails
				SET			PageName = @PageName, RouteName = @RouteName,OrderBy = @OrderBy
				WHERE		PageKey = @PageKey
				SET			@IntMessage = 'Updated Successfully'
			END
	ELSE 
		BEGIN
			INSERT INTO Admin_PageDetails
						(PageName,MenuKey,RouteName,OrderBy)
			SELECT		@PageName,@MenuKey,@RouteName,@OrderBy

			SET @IntMessage = 'Created Successfully'
		END

	
	SET @Status = 1
	SET @ExtMessage = @IntMessage

	--DECLARE @JsonResult NVARCHAR(MAX)
	--SET @JsonResult = (SELECT * FROM (
	--SELECT PageName, RouteName FROm Admin_PageDetails
	--WHERE MenuKey = @MenuKey ) A
	--FOR JSON PATH)

	-- SELECT @Message AS Result for json path
END
