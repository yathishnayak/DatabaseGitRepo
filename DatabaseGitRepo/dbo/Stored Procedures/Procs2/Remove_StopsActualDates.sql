
/*
Declare @UserKey int=486,@JsonString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '', @IsDebug bit = 1
set @JsonString = '{"OrderDetailKey":131659,"OrderDetailStopKey":333785,"PickupOrDeliveryDate":"P"}'
exec Remove_StopsActualDates @UserKey, @JSONString,@IsDebug, @Status output, @Reason output
select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Remove_StopsActualDates]
(
	@UserKey	INT = 486,
	@JsonString	VARCHAR(MAX) = '',
	@IsDebug	BIT = 0,
	@Status		BIT	= 0 OUTPUT,
	@Reason		NVARCHAR(300) = '' OUTPUT
)AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF(ISNULL(@JsonString,'') = '')
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Parameter not found';
		RETURN;
	END

	DECLARE @OrderDetailKey		   INT,
			@OrderDetailStopKey	   INT,
			@PickupOrDeliveryDate  VARCHAR(20) = '',
			@UserName              VARCHAR(100) = '',
			@ContainerNo           VARCHAR(20) 

	SELECT @UserName = ISNULL(UserName,'') from [User] WHERE UserKey = @UserKey
	SELECT TOP 1 @ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey

	SELECT @OrderDetailKey = OrderDetailKey,@OrderDetailStopKey = OrderDetailStopKey,@PickupOrDeliveryDate = PickupOrDeliveryDate
	FROM OPENJSON(@JsonString,'$')
	WITH(
	     OrderDetailKey		   INT         '$.OrderDetailKey',
		 OrderDetailStopKey	   INT         '$.OrderDetailStopKey', 
		 PickupOrDeliveryDate  VARCHAR(20) '$.PickupOrDeliveryDate'
	    )
	
	IF(@PickupOrDeliveryDate = 'P')
	BEGIN
		UPDATE OrderDetailStops
		SET ActualPickupDate = NULL
		WHERE OrderDetailKey = @OrderDetailKey AND OrderDetailStopKey = @OrderDetailStopKey

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Actual pickup date removed by '+@UserName
	END

	IF(@PickupOrDeliveryDate = 'D')
	BEGIN
		UPDATE OrderDetailStops
		SET ActualDeliveryDate = NULL
		WHERE OrderDetailKey = @OrderDetailKey AND OrderDetailStopKey = @OrderDetailStopKey

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Actual delivery date removed by '+@UserName
	END
	SET @Status=1;
	SET @Reason='Success';
END

--select ActualPickupDate,ActualDeliveryDate, * from OrderDetailStops where OrderDetailKey = 131659 and OrderDetailStopKey = 333785