
create Proc InsertUpdate_Version
(
	@VersionNumber	varchar(10),
	@VersionDate	datetime,
	@VersionDetail	varchar(max),
	@UserKey		int,
	@Output			Bit = 0 OUTPUT
)
as
BEGIN
	set nocount on
	set fmtonly off

	set @Output = convert(bit,0)

	declare @cnt int = 0
	
	select @cnt = count(1) 
	from VersionHistory
	where ltrim(rtrim(replace(upper(VersionNumber),'V',''))) = ltrim(rtrim(replace(upper(@VersionNumber),'V','')))

	if(isnull(@cnt,0) = 0)
	BEGIN
		insert into VersionHistory (VersionNumber, VersionDate, VersionDetail, CreateUserKey, CreateDate)
		Select @VersionNumber, @VersionDate, @VersionDetail, @UserKey, GETDATE()

		set @Output = convert(bit,1) 
		return
	END
	ELSE
	BEGIN
		UPDATE VersionHistory SET
		VersionDate = @VersionDate, 
		VersionDetail = @VersionDetail,
		UpdateDate = GETDATE(),
		UpdateUserKey = @UserKey
		WHERE ltrim(rtrim(replace(upper(VersionNumber),'V',''))) = ltrim(rtrim(replace(upper(@VersionNumber),'V',''))) 

		set @Output = convert(bit,1)
		return
	END
END
