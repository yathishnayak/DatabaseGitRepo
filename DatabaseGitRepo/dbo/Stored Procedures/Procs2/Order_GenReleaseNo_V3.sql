/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderKey" : 36888}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Order_GenReleaseNo_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Order_GenReleaseNo_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
		@OrderKey	INT,
		@ReleaseNo	VARCHAR(10)

	SELECT 
		@OrderKey		=	OrderKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderKey		INT			'$.OrderKey'
	)

	select @ReleaseNo = ReleaseNo from OrderHeader where OrderKey = @OrderKey
	if (isnull(@ReleaseNo,'') <> '')
	BEGIN
		SET @Status = 0
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
			set @Status = 1
			set @Reason = 'Release No Generated Successfully'
		end
	end
	SELECT @ReleaseNo AS ReleaseNo FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
