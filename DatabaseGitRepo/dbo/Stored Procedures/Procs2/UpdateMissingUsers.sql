CREATE Proc [dbo].[UpdateMissingUsers]
(
	@JsonText varchar(max) = ''
)
as
Begin
	set nocount on
	set fmtonly off
	create table #UserKeys
	(
		UserKey		int,
		UserName	varchar(100)
	)

	insert into #UserKeys (UserKey, UserName)
	select UserKey, UserName from openJSON(@JsonText, '$')
	with (
		UserKey		int				'$.UserKey',
		UserName	varchar(100)	'$.UserName'
	)

	insert into [User] (UserKey, UserName)
	select A.UserKey, A.UserName
	from #UserKeys A
	LEft join [User] B on A.UserKey = B.UserKey
	where B.UserKey is null

end
