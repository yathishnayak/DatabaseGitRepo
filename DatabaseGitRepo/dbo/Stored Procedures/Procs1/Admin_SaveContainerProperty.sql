/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"OrderDetailKey":47674,"ContainerTypeKey":7,"CommentKey":0,"IsSelected":1}'
SET	@IsDebug  = 0

EXEC [Admin_SaveContainerProperty] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

CREATE procedure [dbo].[Admin_SaveContainerProperty]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	--@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	--@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	--@Result1		VARCHAR(1000)	= ''	OUTPUT,
	--@Result2		VARCHAR(1000)	= ''	OUTPUT,
	--@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@Reason    NVARCHAR(100)   OUTPUT,
	@JSONOutput NVARCHAR(MAX)=''    OUTPUT,
	@IsDebug		BIT				= 0
)
as
Begin
	DECLARE		@OrderDetailKey		INT,
				@ContainerTypeKey	INT,
				@CommentKey			INT,
				@IsSelected			INT
				

	SELECT		@OrderDetailKey = OrderDetailKey, @ContainerTypeKey = ContainerTypeKey,@CommentKey = CommentKey,@IsSelected=IsSelected
	FROM		OPENJSON(@JSONString, '$')
			WITH (
			OrderDetailKey		INT		'$.OrderDetailKey',
			ContainerTypeKey	INT		'$.ContainerTypeKey',
			CommentKey			INT		'$.CommentKey',
			IsSelected			INT		'$.IsSelected',
			IsUpdate			BIT		'$.IsUpdate'
			)
				
	DECLARE @Message VARCHAR(2000) = ''

	SET @OrderDetailKey = LTRIM(RTRIM(ISNULL(@OrderDetailKey,0)))
	SET @ContainerTypeKey = LTRIM(RTRIM(ISNULL(@ContainerTypeKey,0)))
	SET @CommentKey = LTRIM(RTRIM(ISNULL(@ContainerTypeKey,0)))
	SET @IsSelected = LTRIM(RTRIM(ISNULL(@IsSelected,0)))
	

	DECLARE @IsContainerExists BIT = 0, @DescriptionofContainerPageKey INT  = 0

	SET @DescriptionofContainerPageKey = ISNULL((SELECT ContainerTypeKey FROM ContainerTypesLink WHERE OrderDetailKey = @OrderDetailKey AND ContainerTypeKey=@ContainerTypeKey),0)

	SET @IsContainerExists = (case when @DescriptionofContainerPageKey > 0 then 1 else 0 end)
		
	IF(@ContainerTypeKey = 0 )
		BEGIN
			--SET @IntMessage = 'Param Values cannot be blank or null'
			SET @Reason = 'Param Values cannot be blank or null'
			SET @Status = 0
	    --SET @ExtMessage = @IntMessage
			return;
		END
		ELSE IF (@IsContainerExists = 1)
		BEGIN
			SET @Reason = 'Container Description is already Exists'
			SET @Status = 0
	    --SET @ExtMessage = @IntMessage
			return;
		END			 
		ELSE 
		BEGIN
			INSERT INTO ContainerTypesLink
						(ContainerTypeKey,OrderDetailKey,CommentKey,IsSelected)
			SELECT		@ContainerTypeKey,@OrderDetailKey,0,1

			SET @Reason = 'Created Successfully'
		END

		SET @Status = 1
		SET @Reason ='Success'
	    --SET @ExtMessage = @IntMessage
End
