CREATE proc [dbo].[testA]
as
Begin
	Begin Tran Abcd 
	update Orderheader_Deleted set  CreateUserKey = 29 where orderkey = 185253 -- 2025-07-29 00:01:00
	select top 100 * from Orderheader_Deleted order by orderkey  desc
End
