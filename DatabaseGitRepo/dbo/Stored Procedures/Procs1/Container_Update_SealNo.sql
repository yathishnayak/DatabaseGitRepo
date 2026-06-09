/*
SELECT SealNo, UpdateUserKey, LastUpdateDate, * FROM orderdetail
WHERE OrderDetailKey = '144918'
*/

/*
DECLARE 
	@UserKey INT=951,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":144918,"ContainerNo":"MSKU7493563", "SealNo":1AB}',
	@Status	BIT=0, @IsDebug	BIT = 1, @Reason VARCHAR(100)=''
EXEC [Container_Update_SealNo] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
SELECT @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Container_Update_SealNo]
(
	@UserKey      INT=951,
	@JSONString   NVARCHAR(MAX)='',
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT,
	@IsDebug	  BIT = 0
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @OrderDetailKey INT=0,
			@ContainerNo NVARCHAR(20)='', 
			@SealNo VARCHAR(50),
			@USerName VARCHAR(100)

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

	SELECT @OrderDetailKey = OrderDetailKey, @ContainerNo = ContainerNo, @SealNo = SealNo
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderDetailKey		INT				'$.OrderDetailKey',
			ContainerNo			NVARCHAR(20)    '$.ContainerNo',
			SealNo			    VARCHAR(50)		'$.SealNo'
		)	

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey

	BEGIN TRY
		UPDATE OrderDetail 
		SET SealNo= @SealNo, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey AND ContainerNo = @ContainerNo;

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'Container SealNo', 'Text' , 'Container Seal Number Updated'

		-- Check if the update was successful  
        IF @@ROWCOUNT > 0  
        BEGIN 
			SET @Status=1;
			SET @Reason='Success'; 
        END  
        ELSE  
        BEGIN   
			SET @Status=0;
			SET @Reason='No records updated. Check Ordedetailkey or ContainerNo.';
        END 
	END TRY
	BEGIN CATCH
		SET @Status=0;
		SET @Reason='Update failed';
		Print ERROR_MESSAGE();
		Print ERROR_LINE();
	END CATCH
END
