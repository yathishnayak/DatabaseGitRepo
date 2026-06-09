
CREATE proc [dbo].[GetUserList]
as
Select CONVERT(varchar, UserKey) as UserKey from [user]
FOR JSON PATH
