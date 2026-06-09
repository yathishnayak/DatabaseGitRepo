/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_InvoiceCustApprovedReasonCode] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_InvoiceCustApprovedReasonCode]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT AprovedReasonCodeKey,ApprovedReasonCode
		FROM InvoiceCustApprovedReasonCode WITH(NOLOCK)
	WHERE IsActive=1
	FOR JSON PATH;
	SET @Status=1
	SET @Reason='Success'
END