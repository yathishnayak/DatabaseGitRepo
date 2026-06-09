/*
DECLARE @UserKey	INT=488,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 0,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
SET @JsonString='{"BasePercent":43,"CustomerSegmentKey":1}'
exec [Update_CustomerSegmentBasePercent_V2] @UserKey,@JsonString,@IsDebug,@Status output,@Reason output
select @Status AS Status,@Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_CustomerSegmentBasePercent_V2]
(
	@UserKey		INT = 488,
	@JSONString		NVARCHAR(MAX),
	@IsDebug		BIT = 0,
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
	@CustomerSegmentKey int,
	@BasePercent numeric (18,2)

	SELECT @CustomerSegmentKey = CustomerSegmentKey, @BasePercent = BasePercent

	FROM OPENJSON(@JSONString, '$')
	WITH (
	CustomerSegmentKey			INT					     '$.CustomerSegmentKey',
	BasePercent					numeric (18,2)			 '$.BasePercent'
	)

	If(ISNULL(@CustomerSegmentKey,0) = 0)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'No CustomerSegmentKey in the input';
	END

  BEGIN  TRY
	UPDATE CustomerSegments
	SET BasePercent = @BasePercent, UpdateUser=@UserKey
	WHERE CustomerSegmentKey= @CustomerSegmentKey
	SET @Status=1
	SET @Reason='Updated Successfully'
 END TRY
 BEGIN CATCH
 	SET @Status=0
 	SET @Reason='Error in data save'
 END CATCH

END