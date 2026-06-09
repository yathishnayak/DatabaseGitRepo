/*

DECLARE 
	@UserKey INT = 714,
	@JSONString NVARCHAR(MAX) = '{"YardId":4}',
	@Status BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Yard_GetByKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status AS Status, @Reason AS Reason

*/
CREATE PROCEDURE [dbo].[Yard_GetByKey_V2]
(
    @UserKey    INT = 0,
    @JSONString NVARCHAR(MAX) = '',
    @Status     BIT = 0 OUTPUT,
    @Reason     VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

	IF(@JSONString = '' OR @JSONString IS NULL)
	BEGIN
        SET @Reason = 'Parameter not Present';
        SET @Status = 0
		SET @Reason = 'Failure';
        RETURN;
    END    

	DECLARE @YardId  INT = 0
    SELECT @YardId = YardId
    FROM OPENJSON(@JSONString,'$')
	WITH 
    (
		YardId		INT		'$.YardId'
	)

	SELECT
        Yard = JSON_QUERY(( 
		Select YardId,ShortName,[Name],MarketLocationKey,IsActive,IsDeleted, AddrKey, YardType FROM Yard WITH(NOLOCK)
		WHERE (YardId = @YardId)FOR JSON PATH, Without_Array_Wrapper)),
		MarketLocationList = JSON_QUERY(
                (SELECT MarketLocationKey, MarketLocation, IsActive
                    FROM MarketLocation
                    WHERE IsActive = 1
                    FOR JSON PATH))
            FOR JSON PATH, Without_Array_Wrapper

	SET @Status = 1;
    SET @Reason = 'Success';
END
