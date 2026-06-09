/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DriverKey" : 912}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [DeleteCarrier_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[DeleteCarrier_V2] -- DRIVER  DELETE
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS
BEGIN
  SET NOCOUNT ON;

	DECLARE @CNTDriver INT = 0,
		  	@UserName varchar(30),
			@DriverName varchar(50),
			@DriverId varchar(20),
			@DriverKey INT

    SET @Status = 0;
	SET @Reason  = 'Something went wrong, Contact system administrator';
	

		SELECT @DriverKey =  DriverKey
	FROM OpenJSON(@JSONString)
	WITH (
		DriverKey			INT				'$.DriverKey'
	)
	
	SET @CNTDriver = (select count(1) FROM Driver WITH (NOLOCK) WHERE DriverKey= @DriverKey)	
	 
	IF(@CNTDriver =0)
	BEGIN
		SET @Reason = 'No record found for the given Driver'
		SET @Status = 0;
		RETURN
	END

ELSE
	BEGIN
		UPDATE			Driver 
		SET				IsActive = 0 , IsDelete = 1, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UserKey 
		WHERE			DriverKey= @DriverKey
		SET				@Status = 1;
		SET				@Reason = 'Driver Deleted Sucessfully'
		

		SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
		SELECT @DriverName=ISNULL(FirstName, '')+ISNULL(LastName, '') FROM Driver WITH(NOLOCK) WHERE DriverKey = @DriverKey
		SELECT @DriverId=ISNULL(DriverID, '') FROM Driver WITH(NOLOCK) WHERE DriverKey = @DriverKey

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Driver',@DriverId,@DriverKey,null,'Text','Driver(Carrier) ' + @DriverName + ' deleted by ' + @UserName
		RETURN
	END
END


--select * from driver