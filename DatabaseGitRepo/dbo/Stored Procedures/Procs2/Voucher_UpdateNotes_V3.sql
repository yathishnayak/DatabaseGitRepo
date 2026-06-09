/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"VoucherKey" : 299433, "DriverNotes" : "Test1", "InternalNotes" : "Test2"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Voucher_UpdateNotes_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Voucher_UpdateNotes_V3]
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
		@VoucherKey		INT,
		@DriverNotes	VARCHAR(MAX),
		@InternalNotes	VARCHAR(MAX)

	SELECT
		@VoucherKey				=	VoucherKey		,
		@DriverNotes				=	DriverNotes		,
		@InternalNotes			=	InternalNotes	
	FROM OPENJSON(@JSONString)
	WITH
	(
		VoucherKey			INT					'$.VoucherKey'		,
		DriverNotes			VARCHAR(MAX)		'$.DriverNotes'		,
		InternalNotes		VARCHAR(MAX)		'$.InternalNotes'	
	)

	UPDATE VoucherHeader SET
		DriverNote = @DriverNotes,
		InternalNote = @InternalNotes
	WHERE VoucherKey = @VoucherKey

	SET @Status = 1
	SET @Reason = 'Updated Successfully'
END