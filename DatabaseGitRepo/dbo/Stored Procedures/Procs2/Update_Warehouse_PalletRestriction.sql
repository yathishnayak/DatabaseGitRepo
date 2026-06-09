/*
Declare 
	@UserKey		INT = 488,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"OrderDetailKey" : 225336, "PalletRestriction":"hfg56"}'
EXEC [Update_Warehouse_PalletRestriction] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_Warehouse_PalletRestriction]
/*
Update for Pallet Restrictions column in warehouse screen
*/
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
			@PalletRestriction VARCHAR(400),
			@USerName VARCHAR(100),
			@ContainerNo VARCHAR(20)

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

	SELECT @OrderDetailKey = OrderDetailKey, @PalletRestriction = PalletRestriction
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderDetailKey		INT					'$.OrderDetailKey',			
			PalletRestriction	VARCHAR(400)	    '$.PalletRestriction'
		)	

	BEGIN TRY
		UPDATE Warehouse_ContainerDetails 
		SET PalletRestriction = @PalletRestriction, UpdateUserKey = @UserKey  
		WHERE OrderDetailKey= @OrderDetailKey;
		Select @ContainerNo = ContainerNo from OrderDetail WITH(NOLOCK) where orderdetailkey = @OrderDetailKey

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'Pallet Restriction', 'Text' , 'Pallet Restriction Updated'

		-- Check if the update was successful  
        IF @@ROWCOUNT > 0  
        BEGIN 
			SET @Status=1;
			SET @Reason='Success'; 
        END  
        ELSE  
        BEGIN   
			SET @Status=0;
			SET @Reason='No records updated. Check Ordedetailkey.';
        END 
	END TRY
	BEGIN CATCH
		SET @Status=0;
		SET @Reason='Update failed';
		Print ERROR_MESSAGE();
		Print ERROR_LINE();
	END CATCH
END