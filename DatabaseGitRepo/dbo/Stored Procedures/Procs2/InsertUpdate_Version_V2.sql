/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"VersionNumber" : "v2.1", "VersionDate" : "2026-03-09 18:30:00.000", "VersionDetail" : "Inserted"}'
	EXEC [InsertUpdate_Version_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[InsertUpdate_Version_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	set nocount on
	set fmtonly off

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END

	DECLARE
	@VersionNumber	varchar(10),
	@VersionDate	datetime,
	@VersionDetail	varchar(max)

	SELECT 
	@VersionNumber	=	VersionNumber,	
	@VersionDate	= 	VersionDate,	
	@VersionDetail	= 	VersionDetail
	FROM OPENJSON(@JSONSTRING)
	WITH
	(
	VersionNumber			VARCHAR(10)			'$.VersionNumber',
	VersionDate				DATETIME			'$.VersionDate',
	VersionDetail			VARCHAR(MAX)		'$.VersionDetail'
	)

	set @Status = convert(bit,0)

	declare @cnt int = 0
	
	select @cnt = count(1) 
	from VersionHistory WITH(NOLOCK)
	where ltrim(rtrim(replace(upper(VersionNumber),'V',''))) = ltrim(rtrim(replace(upper(@VersionNumber),'V','')))

	if(isnull(@cnt,0) = 0)
	BEGIN
		insert into VersionHistory (VersionNumber, VersionDate, VersionDetail, CreateUserKey, CreateDate)
		Select @VersionNumber, @VersionDate, @VersionDetail, @UserKey, GETDATE()

		set @Status = convert(bit,1) 
		set @Reason = 'Success'
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

		set @Status = convert(bit,1)
		set @Reason = 'Success'
		return
	END
END