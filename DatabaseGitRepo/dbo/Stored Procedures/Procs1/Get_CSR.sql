
CREATE PROCEDURE [dbo].[Get_CSR]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT C.CsrKey, C.CsrName, C.FirstName, C.LastName, C.CreateDate,C.StatusKey, S.StatusName, C.StatusDate, C.AddrKey,
		A.AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey, 
		C.CreateUser, C.UpdateDate, C.UpdateUser, U1.UserName AS CreateUserName, U2.UserName as UpdateUserName,
		C.CSRManagerKey, CM.CsrName AS ManagerName, C.LinkedUserKey, C.IsManager, U3.UserName as LinkedUserName,
		C.TerminalLocationKey, TL.TerminalLocation
	FROM dbo.CSR C WITH (NOLOCK)
	INNER JOIN [Status] S WITH (NOLOCK) ON S.Statuskey= C.StatusKey 
	LEFT join Address A WITH (NOLOCK) on C.AddrKey = A.AddrKey
	LEFT JOIN [User] U1 WITH (NOLOCK) ON C.CreateUser = U1.UserKey
	LEFT JOIN [User] U2 WITH (NOLOCK) ON C.CreateUser = U2.UserKey
	LEFT JOIN CSR CM WITH (NOLOCK) ON C.CSRManagerKey = CM.CsrKey
	LEft Join [User] U3  with (nolock) on C.LinkedUserKey = U3.UserKey
	LEft join TerminalLocation TL WITH (NOLOCK) ON C.TerminalLocationKey = TL.TerminalLocationKey
	WHERE  S.StatusName='Active' 
	ORDER BY CsrName;
END
