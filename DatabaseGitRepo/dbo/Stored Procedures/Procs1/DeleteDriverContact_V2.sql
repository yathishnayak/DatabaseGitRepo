/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverContactKey" : 12, "DriverKey" : 1838}'
	EXEC [DeleteDriverContact_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[DeleteDriverContact_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
	@DriverContactKey	INT = 0,
	@DriverKey			INT = 0

	SELECT
	@DriverContactKey	=		DriverContactKey	,
	@DriverKey			= 		DriverKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	DriverContactKey		INT				'$.DriverContactKey',
	DriverKey				INT				'$.DriverKey'		
	)

	DECLARE @cnt int = 0
	--SELECT @cnt = COUNT(1) FROM DriverContacts WITH (NOLOCK) WHERE DriverContactKey = @DriverContactKey and DriverKey = @DriverKey
	SELECT @cnt = COUNT(1) FROM DriverContacts WITH (NOLOCK) WHERE DriverContactKey = @DriverContactKey and DriverKey = @DriverKey
	IF(ISNULL(@cnt,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Contact Not Exists'
		RETURN;
		
	END
	BEGIN TRY
		DELETE FROM DriverContacts
		WHERE DriverContactKey  = @DriverContactKey and DriverKey  = @DriverKey
	--	set @Status = 1
	--	set @Reason = 'Contact Deleted Successfully'
	--END try
	--begin catch
	--	set @Status = 0
	--	set @Reason = 'Technical Error'
	--END catch

	 IF @cnt = 0
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Delete Failed';
            RETURN;
        END

        SET @Status = 1;
        SET @Reason = 'Contact Deleted Successfully';
    END TRY
    BEGIN CATCH
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END