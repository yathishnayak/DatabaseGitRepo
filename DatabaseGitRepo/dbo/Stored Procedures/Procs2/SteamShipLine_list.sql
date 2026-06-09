CREATE proc [dbo].[SteamShipLine_list]
as
begin
	select LineKey,ScacCode,LineName, IsActive, CreateUser, CreateDate, UpdateUser, UpdateDate,
	u.UserName as CreateUserName, u1.UserName as UpdateUserName
	from SteamShipLine A
	left join [User] U on A.CreateUser = U.UserKey
	left join [User] U1 on A.UpdateUser = U1.UserKey
	order by LineName
end
