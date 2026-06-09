
CREATE PROCEDURE [dbo].[DA_ValidateUserFireBaseID] --  DA_ValidateUserFireBaseID 0,''
(
	@UserKey		INT = 714,
	@FireBaseID		VARCHAR(500) = 'fssdfsfdsdfsdf',
	@ValidateUser	BIT = 0 OUTPUT,
	@InternalError	NVARCHAR(MAX) = '' OUTPUT,
	@ExternalError	VARCHAR(1000) = '' OUTPUT
)
AS 
BEGIN 
	-- SELECT * FROM DA_UserFireBaseID
	SET	@ValidateUser = 0
	DECLARE @UserCount INT = 0, @Serial1 VARCHAR(20)  , @Serial2 VARCHAR(20)  , @Serial3 VARCHAR(20) , @Serial4 VARCHAR(20)  
	DECLARE @JsonResult NVARCHAR(MAX) = ''

	IF(ISNULL(@UserKey,0)=0 OR ISNULL(@FireBaseID,'') = '' )
		BEGIN
			SET		@ValidateUser = 0
			SET		@InternalError = 'Userkey or FirebaseID cannot be Blank or NULL'
			SET		@ExternalError = 'Something went wrong, Contact System administrator'
		END
	ELSE IF(ISNULL(@FireBaseID,'') = 'NA' )
		BEGIN
			SET		@ValidateUser = 0
			SET		@InternalError = 'FirebaseID cannot be NA'
			SET		@ExternalError = 'Something went wrong, Contact System administrator'
		END
	ELSE
		BEGIN	
			SET		@UserCount = (SELECT COUNT(*) FROM DA_UserFireBaseID WHERE UserKey = @UserKey AND FireBaseID = @FireBaseID)
			SET		@ValidateUser  =  CASE WHEN @UserCount = 0 THEN 0 ELSE 1 END
			SET		@InternalError = 'You have logged into a New Device'
			SET		@ExternalError = @InternalError
		END

	SET @JsonResult = (SELECT	@Serial1 AS Serial1, @Serial2 AS Serial2, @Serial3 AS Serial3, @Serial4 AS Serial4 FOR JSON PATH)

	--SELECT @JsonResult AS JsonResult 

END

























