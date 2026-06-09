

create Proc Validate_VersionNumber
(
	@VersionNumber		varchar(10)='',
	@IsValid			Bit = 0 OUTPUT
)
as
BEGIN
	set nocount on
	set fmtonly off

	declare @cnt int = 0
	set @IsValid = CONVERT(bit,0)
	
	select @cnt = count(1) 
	from VersionHistory
	where ltrim(rtrim(replace(upper(VersionNumber),'V',''))) = ltrim(rtrim(replace(upper(@VersionNumber),'V','')))

	if(ISNULL(@cnt,0) = 0)
	begin
		set @IsValid = CONVERT(bit,1)
	end
END
