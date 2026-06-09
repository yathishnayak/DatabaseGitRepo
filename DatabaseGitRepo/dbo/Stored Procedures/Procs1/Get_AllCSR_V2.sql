
/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"MarketLocationKey":0}'
 
EXEC [Get_AllCSR_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_AllCSR_V2] -- [Get_CSR_V2] 3
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
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

    DECLARE @JSONOutput NVARCHAR(MAX) = ''

	SET @JSONOutput = (
			SELECT C.CsrKey, C.CsrName,C.FirstName, C.LastName, C.CreateDate,C.StatusKey, S.StatusName, C.StatusDate,C.AddrKey,
			[Address] = JSON_QUERY(( 
				SELECT
				A.AddrName, Address1, Address2, City, State, ZipCode as Zip, Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)), 
				C.CreateUser, C.UpdateDate, C.UpdateUser, U1.UserName AS CreateUserName, U2.UserName as UpdateUserName,
				c.IsActive,c.IsDelete, C.CSRManagerKey,
				Case when isnull(CM.CsrName,'') <> '' then CM.CsrName 
				else Case when C.IsManager = 1 then C.CsrName else '' end end as ManagerName, 
				C.IsManager, C.LinkedUserKey, 
				U3.UserName as LinkedUserName,
				C.TerminalLocationKey , TL.MarketLocation as TerminalLocation
			FROM dbo.CSR C WITH (NOLOCK)
			INNER JOIN [Status] S WITH (NOLOCK) ON S.Statuskey= C.StatusKey 
			LEFT join Address A WITH (NOLOCK) on C.AddrKey = A.AddrKey
			LEFT JOIN [User] U1 WITH (NOLOCK) ON C.CreateUser = U1.UserKey
			LEFT JOIN [User] U2 WITH (NOLOCK) ON C.CreateUser = U2.UserKey
			LEFT JOIN CSR CM WITH (NOLOCK) ON C.CSRManagerKey = CM.CsrKey
			LEft Join [User] U3  with (nolock) on C.LinkedUserKey = U3.UserKey
			LEft join MarketLocation TL WITH (NOLOCK) ON C.TerminalLocationKey = TL.MarketLocationKey
			where ISNULL(c.IsDelete,0) = 0 AND
			(@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(C.TerminalLocationKey,0) END = @marketLocationKey)
			ORDER BY CsrName
		FOR JSON PATH
	);

	SELECT @JSONOutput AS JSONOutput

	SET @Status = 1;
	SET @Reason = 'Success';
END
