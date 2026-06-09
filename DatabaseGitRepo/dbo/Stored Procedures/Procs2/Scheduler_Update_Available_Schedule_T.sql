/**
DECLARE 
	@UserKey INT=953,
	@JSONString NVARCHAR(3999)='{"OrderDetailKey":226819,"ScheduleOrAvailableT":"D","IsSelected":true}',
	@IsDebug bit = 0, @Status BIT=0, 
	@Reason VARCHAR(100)=''
EXec Scheduler_Update_Available_Schedule_T @UserKey, @JSONString, @IsDebug, @Status OUTPUT, @Reason OUTPUT
Select @Status as Status, @Reason as Reason
**/

CREATE PROCEDURE [dbo].[Scheduler_Update_Available_Schedule_T]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END

	DECLARE @OrderDetailKey			INT,
			@ScheduleOrAvailableT	CHAR(2),
			@IsSelected				BIT,
			@UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)

	SELECT  @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey	;		


	SELECT @OrderDetailKey = OrderDetailKey,@ScheduleOrAvailableT=ScheduleOrAvailableT,@IsSelected=IsSelected
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderDetailKey				INT		'$.OrderDetailKey',
			ScheduleOrAvailableT		CHAR(2)	'$.ScheduleOrAvailableT',
			IsSelected					BIT		'$.IsSelected'
		)


			
	SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey;

	IF(@ScheduleOrAvailableT='S')
	BEGIN
		UPDATE OrderDetail 
			SET ScheduleT=@IsSelected,
			ScheduleTSetUserKey=@UserKey,
			ScheduleTSetDateTime=GETDATE()
		WHERE OrderDetailKey=@OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','Schedule T is updated by '+@UserName
	END
	IF(@ScheduleOrAvailableT='A')
	BEGIN
		UPDATE OrderDetail 
			SET AvailableT=@IsSelected,
			AvailableTSetUserKey=@UserKey,
			AvailableTSetDateTime=GETDATE()
		WHERE OrderDetailKey=@OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','Available T is updated by '+@UserName
	END
	IF(@ScheduleOrAvailableT='D')
	BEGIN
		UPDATE OrderDetail 
			SET DemCheck=@IsSelected,
			DemCheckSetUserKey=@UserKey,
			DemCheckSetDateTime=GETDATE()
		WHERE OrderDetailKey=@OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','DemCheck is updated by '+@UserName
	END
	IF(@ScheduleOrAvailableT='I')
	BEGIN
		UPDATE OrderDetail 
			SET Issues=@IsSelected,
			IssuesSetUserKey=@UserKey,
			IssuesSetDateTime=GETDATE()
		WHERE OrderDetailKey=@OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','Issues Check is updated by '+@UserName
	END
	IF(@ScheduleOrAvailableT='O')
	BEGIN
		UPDATE OrderDetail 
			SET OnSiteSent=@IsSelected,
			OnSiteSentSetUserKey=@UserKey,
			OnSiteSentSetDateTime=GETDATE()
		WHERE OrderDetailKey=@OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','OnSiteSent Check is updated by '+@UserName
	END
	IF(@ScheduleOrAvailableT='P')
	BEGIN
		UPDATE OrderDetail 
			SET PODSent=@IsSelected,
			PODSentSetUserKey=@UserKey,
			PODSentSetDateTime=GETDATE()
		WHERE OrderDetailKey=@OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','PODSent Check is updated by '+@UserName
	END
	SET @Status=1;
	SET @Reason='Success';
END
