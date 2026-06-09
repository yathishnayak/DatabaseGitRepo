
/*
DECLARE @UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='{"MarketLocationKey":0}',
	@JSONOutput   NVARCHAR(MAX) = '' ,
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = '' 
    exec Get_CSRManagerList_V2 @UserKey,@Jsonstring,@Jsonoutput output, @Status output,@Reason output
    select @Status AS Status,@Reason AS Reason
    */


CREATE PRocEDURE [dbo].[Get_CSRManagerList_V2]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	DECLARE @MarketLocationKey	INT = 0 
	SELECT  @MarketLocationKey = MarketLocationKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			MarketLocationKey		INT		'$.MarketLocationKey'
		 )

	IF(@MarketLocationKey NOT IN (2,3,16,0))
	BEGIN
		SET @MarketLocationKey=16
	END

	SELECT C.CsrKey, C.CsrName, C.FirstName, C.LastName, ISNULL(IsDefault,0) IsDefault, C.TerminalLocationKey AS MarketLocationKey
	FROM dbo.CSR C WITH (NOLOCK)
	INNER JOIN [Status] S WITH (NOLOCK) ON S.Statuskey= C.StatusKey 
	WHERE  S.StatusName='Active' and isnull(C.IsManager,0) = 1
			AND (ISNULL(@MarketLocationKey,0)=0 OR C.TerminalLocationKey=@MarketLocationKey)
	ORDER BY CsrName
	FOR JSON PATH;

	SET @Status = 1;
	SET @Reason = 'Success';
END
