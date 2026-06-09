/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"CsrKey":67}'
 
EXEC [Get_CSRbyKey_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_CSRbyKey_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @CSRKey	INT;

	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	SELECT @CSRKey =  CSRKey
	FROM OpenJSON(@JSONString, '$')
	WITH (
		CSRKey		INT		'$.CsrKey'
	)

	DECLARE @JSONOutput NVARCHAR(MAX) = ''

	SET @JSONOutput = (
			SELECT C.CsrKey, C.CsrName,C.FirstName, C.LastName, C.CreateDate,C.StatusKey, S.StatusName, C.StatusDate, C.AddrKey,
			[Address] = (
			SELECT A.AddrKey, A.AddrName, Address1, Address2, City, State, ZipCode as Zip, Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), 
			C.CreateUser, C.UpdateDate, C.UpdateUser, U1.UserName AS CreateUserName, U2.UserName as UpdateUserName,
			C.CSRManagerKey, CM.CsrName AS ManagerName, C.IsManager, C.LinkedUserKey, U3.UserName as LinkedUserName,
			C.TerminalLocationKey, TL.MarketLocation TerminalLocation
		FROM dbo.CSR C WITH (NOLOCK)
		INNER JOIN [Status] S WITH (NOLOCK) ON S.Statuskey= C.StatusKey 
		LEFT join Address A WITH (NOLOCK) on C.AddrKey = A.AddrKey
		LEFT JOIN [User] U1 WITH (NOLOCK) ON C.CreateUser = U1.UserKey
		LEFT JOIN [User] U2 WITH (NOLOCK) ON C.CreateUser = U2.UserKey
		LEFT JOIN CSR CM WITH (NOLOCK) ON C.CSRManagerKey = CM.CsrKey
		LEft Join [User] U3  with (nolock) on C.LinkedUserKey = U3.UserKey
		LEft join MarketLocation TL WITH (NOLOCK) ON C.TerminalLocationKey = TL.MarketLocationKey
		where C.CsrKey = @CSRKey
		FOR JSON PATH
	);

	SELECT @JSONOutput AS JSONOutput

	SET @Status = 1;
	SET @Reason = 'Success';
END