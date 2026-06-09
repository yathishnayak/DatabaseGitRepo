/*
select top 100 Weight, WeightUnit, UpdateUserKey, LastUpdateDate, * from orderdetail
where 
--OrderDetailKey = 177907
OrderKey = '144918'

*/

/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":177907,"ContainerNo":"AUII25091000"}',
	@Status			BIT=0, @IsDebug		BIT = 1, @Reason			VARCHAR(100)=''
	EXec [Update_ContainerNo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason

*/

CREATE PROCEDURE [dbo].[Update_ContainerNo_V2]
(
	@UserKey		INT=0,
	@JSONString		NVARCHAR(MAX)='',
	@Status			BIT = 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @OrderDetailKey INT=0,
			@ContainerNo	NVARCHAR(20)='',
			@OldContainerNo	NVARCHAR(20)='',
			@UserName		NVARCHAR(100)=''

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	
		
	IF (@IsDebug = 1)
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'In Debug Mode'
	END	

	SELECT @OrderDetailKey = OrderDetailKey, @ContainerNo = ContainerNo
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderDetailKey		INT					'$.OrderDetailKey',
			ContainerNo			NVARCHAR(20)		'$.ContainerNo'
		)	

	SELECT @OldContainerNo=ISNULL(ContainerNo,'') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
	SELECT @UserName=ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey

	BEGIN TRY
	BEGIN TRANSACTION
		UPDATE OrderDetail
		SET ContainerNo = @ContainerNo, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey
		where OrderDetailKey = @OrderDetailKey

		UPDATE Invoicedetail
		SET Container=@ContainerNo 
		Where OrderDetailKey = @OrderDetailKey

		UPDATE InvoiceContainers
		SET ContainerNo=@ContainerNo 
		Where OrderDetailsKey = @OrderDetailKey

		INSERT INTO AuditLogDetail 
				(DateCreated, CreateUser, RefType, RefId, RefKey, 
				 Stage, CommentType, Comments)
		Select   GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 
				 'Container No', 'Text' , 'Container no Updated from '+@OldContainerNo+ ' to '+@ContainerNo+ ' by '+@UserName

		SET @Status=1;
		SET @Reason='Success';
	COMMIT TRANSACTION	
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @Status=0;
		SET @Reason='Update failed';
		Print ERROR_MESSAGE();
		Print ERROR_LINE();
	END CATCH
END
