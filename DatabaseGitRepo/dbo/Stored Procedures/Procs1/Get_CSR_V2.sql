/*
declare @UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='{"MarketLocationKey":0}',
	@JSONOutput   NVARCHAR(MAX) = '' ,
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = '' 
	exec [Get_CSR_V2] @UserKey,@JSONString,@JSONOutput output,@Status output,@Reason output
	select @Status AS Status,@Reason AS Reason
	*/

CREATE PROCEDURE [dbo].[Get_CSR_V2] -- [Get_CSR_V2] 3
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

	SET @Reason='Success';
	SET @Status =1

	DECLARE @MarketLocationKey	INT = 0 
	SELECT  @MarketLocationKey = MarketLocationKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			MarketLocationKey		INT		'$.MarketLocationKey'
		 )

	IF(@MarketLocationKey = 0)
	BEGIN
		SET @MarketLocationKey=0
	END
	ELSE IF(@MarketLocationKey NOT IN (2,3,16,0))
	BEGIN
		SET @MarketLocationKey=16
	END
	SELECT C.CsrKey, C.CsrName, C.FirstName, C.LastName, C.CreateDate,C.StatusKey,
		C.IsActive,C.IsDelete, C.CSRManagerKey, 
		CASE WHEN ISNULL(CM.CsrName,'') <> '' THEN CM.CsrName 
		ELSE CASE WHEN C.IsManager = 1 THEN C.CsrName ELSE '' END END AS ManagerName, 
		C.IsManager, C.LinkedUserKey, 
		U3.UserName AS LinkedUserName,
		C.TerminalLocationKey , TL.MarketLocation AS TerminalLocation, ISNULL(C.IsDefault,0) IsDefault
	FROM dbo.CSR C WITH (NOLOCK)
	INNER JOIN [Status] S WITH (NOLOCK) ON S.Statuskey= C.StatusKey 
	LEFT JOIN [User] U2 WITH (NOLOCK) ON C.CreateUser = U2.UserKey
	LEFT JOIN CSR CM WITH (NOLOCK) ON C.CSRManagerKey = CM.CsrKey
	LEFT JOIN [User] U3  WITH (NOLOCK) ON C.LinkedUserKey = U3.UserKey
	LEFT JOIN MarketLocation TL WITH (NOLOCK) ON C.TerminalLocationKey = TL.MarketLocationKey
	WHERE ISNULL(C.IsActive,1) =1 AND ISNULL(C.IsDelete,0) = 0 AND
	(@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(C.TerminalLocationKey,0) END = @marketLocationKey)
	ORDER BY CsrName
	FOR JSON PATH;
END