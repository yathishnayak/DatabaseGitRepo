/*
select top 100 Weight, WeightUnit, UpdateUserKey, LastUpdateDate, * from orderdetail
where OrderKey = '144918'

*/

/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":177907,"ContainerNo":"AUII2509123","WeightUnitKey":1}',
	@Status			BIT=0, @IsDebug		BIT = 1, @Reason			VARCHAR(100)=''
	EXec [Container_Update_WeightUnit] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason

*/

CREATE PROCEDURE [dbo].[Container_Update_WeightUnit]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @OrderDetailKey INT=0,
			@ContainerNo NVARCHAR(20)='', 
			@WeightUnitKey INT,
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

	SELECT @OrderDetailKey = OrderDetailKey, @ContainerNo = ContainerNo, @WeightUnitKey = WeightUnit
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderDetailKey		INT					'$.OrderDetailKey',
			ContainerNo			NVARCHAR(20)		'$.ContainerNo',
			WeightUnit			INT					'$.WeightUnitKey'
		)	

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey

	BEGIN TRY
		UPDATE OrderDetail 
		SET WeightUnit = @WeightUnitKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey AND ContainerNo = @ContainerNo;

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'Container Weight Unit', 'Text' , 'Container Weight Unit Updated'

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
