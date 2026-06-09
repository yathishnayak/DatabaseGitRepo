/*
DECLARE 
	@UserKey INT=952,
	@JSONString		NVARCHAR(MAX)=  '{"StatusKey":3,"OrderDetailKey":156634}',
	@Status			BIT=0, 
	@Reason			VARCHAR(100)='',
	@JSONOutput   NVARCHAR(MAX) = ''
	EXEC [StatusKey_Update] @UserKey, @JSONString,@JSONOutput output, @Status output, @Reason output
	Select @Status, @Reason
*/

CREATE Procedure [dbo].[Admin_UpdateWarehouseStatusKey]
(
	@UserKey      INT=0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' output,
	@Status       BIT = 0 output,
	@Reason       VARCHAR(1000) = '' output
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
		DECLARE @StatusKey INT,@OrderDetailKey INT, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='',@ContainerNo NVARCHAR(20)='',@OrderKey INT;

		SELECT @StatusKey=StatusKey,@OrderDetailKey=OrderDetailKey 
		FROM OPENJSON(@JSONString,'$')
		 WITH (
			StatusKey INT			'$.StatusKey',
			OrderDetailKey INT      '$.OrderDetailKey'
			)

		SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	
		SELECT @ContainerNo=ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey

		IF @StatusKey IS NULL
		BEGIN
			SET @Status=0;
			SET @Reason='Failed to Update Status';
			RETURN 
		END
		
		ELSE
		BEGIN
		 UPDATE Warehouse_ContainerDetails SET StatusKey=@StatusKey WHERE OrderDetailKey=@OrderDetailKey;
		END 
		SET @Comment='Warehouse status changed by, '+ISNULL(@USerName,'')
		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @USerName,'Container', @ContainerNo, @OrderDetailKey, 'WareHouse', 'Text' , @Comment
	

		SET @Status=1;
		SET @Reason='Success'
END
