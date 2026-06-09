/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 38388, "CustomerNotes" : "BILLED UNDER M-FLEX-1961758", "InternalNotes" : "Hello"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_InvoiceHeaders_Notes] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_InvoiceHeaders_Notes]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
    @InvoiceKey     INT,
    @CustomerNotes  VARCHAR(1000),
    @InternalNotes  VARCHAR(1000)

    SELECT
    @InvoiceKey         =   InvoiceKey,
    @CustomerNotes      =   CustomerNotes,
    @InternalNotes      =   InternalNotes
    FROM OPENJSON(@JSONString)
    WITH
    (
    InvoiceKey          INT                 '$.InvoiceKey',   
    CustomerNotes       VARCHAR(1000)       '$.CustomerNotes',
    InternalNotes       VARCHAR(1000)       '$.InternalNotes'
    )

    BEGIN TRY
        UPDATE InvoiceHeader
        SET 
            CustomerNote = @CustomerNotes,
            InternalNote = @InternalNotes,
            UpdateUserKey = @UserKey
        WHERE InvoiceKey = @InvoiceKey;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @Status = 1;
            SET @Reason = 'Notes updated successfully';
        END
        ELSE
        BEGIN
            SET @Status = 0;
            SET @Reason = 'No changes detected';
        END
    END TRY
    BEGIN CATCH
        SET @Status = 0;

        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END