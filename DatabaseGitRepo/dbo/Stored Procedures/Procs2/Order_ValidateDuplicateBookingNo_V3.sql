/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"BookingNo" : "2716339700"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Order_ValidateDuplicateBookingNo_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Order_ValidateDuplicateBookingNo_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@BookingNo	varchar(50)=''

	SELECT 
		@BookingNo		=		BookingNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		BookingNo		VARCHAR(50)		'$.BookingNo'
	)

	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader WITH(NOLOCK) WHERE LTRIM(RTRIM(BookingNo)) = LTRIM(RTRIM(@BookingNo))

	IF(@CNT > 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Duplicate Booking Number Exists'
	END
	ELSE
	BEGIN
		SET @Status = 1
		SET @Reason = 'Booking Number is Unique'
	END
END
