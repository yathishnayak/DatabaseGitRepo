
/*
DECLARE 
	@UserKey INT = 953,
	@JSONString NVARCHAR(MAX) = '',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@JSONOutput NVARCHAR(MAX)='';

EXEC [Get_DateRanges] @UserKey, @JSONString, @JSONOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT;

SELECT  @Status, @Reason ;
*/

CREATE PROCEDURE [dbo].[Get_DateRanges]
(
	@UserKey      INT=0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 output,
	@Reason       VARCHAR(100) = '' OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT RangeName,StartDate,EndDate from v_dateRanges 
	FOR JSON PATH


		SET @Status = 1;
		SET @Reason = 'Success';

END
