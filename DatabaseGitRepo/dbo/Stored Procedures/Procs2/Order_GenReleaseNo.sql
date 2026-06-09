create Proc Order_GenReleaseNo
(
	@OrderKey	int,
	@ReleaseNo	varchar(10) output,
	@Output		bit = 0 output,
	@Reason		varchar(100) = '' output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	select @ReleaseNo = ReleaseNo from OrderHeader where OrderKey = @OrderKey
	if (isnull(@ReleaseNo,'') <> '')
	BEGIN
		SET @Output = 0
		SET @Reason = 'Release No. already exists'
		return
	END

	DECLARE @IsMatching bit = 1, @NoCount int = 0
	
	while (@IsMatching = 1)
	begin
		SET @RELEASENO = RIGHT(REPLACE(CONVERT(VARCHAR(36),NEWID()),'-',''),6)
		Select @NoCount = count(1) from OrderHeader where ReleaseNo = @RELEASENO
		if(@NoCount = 0)
		begin
			update OrderHeader set ReleaseNo = @ReleaseNo where OrderKey = @OrderKey
			set @IsMatching = 0
			set @Output = 1
			set @Reason = 'Release No Generated Successfully'
		end
	end
END
