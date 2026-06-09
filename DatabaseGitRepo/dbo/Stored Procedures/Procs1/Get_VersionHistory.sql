
CREATE Proc [dbo].[Get_VersionHistory]
as
Select 
	VersionNumber, VersionDate, VersionDetail, isnull(U1.UserName,'NA') LastUpdateUser, 
	isnull(V.UpdateDate,V.CreateDate) as LastUpdateDate
from VersionHistory V WITH(NOLOCK)
Left join [User] U1  WITH(NOLOCK) on isnull(V.UpdateUserKey, V.CreateUserKey) = U1.userKey
order by VersionDate Desc
