CREATE PROCEDURE [dbo].[Get_CSRALL]
@MarketLocationKey	INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT C.CsrKey, C.CsrName,C.FirstName, C.LastName, C.CreateDate,C.StatusKey, S.StatusName, C.StatusDate, C.AddrKey,
		A.AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey, 
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
	ORDER BY CsrName;
END
