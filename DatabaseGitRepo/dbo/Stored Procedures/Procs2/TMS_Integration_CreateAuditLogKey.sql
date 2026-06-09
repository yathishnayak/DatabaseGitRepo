

/*
DECLARE @SITEID VARCHAR(20) = 'ACER', @LogKey	bigint =0
exec TMS_Integration_CreateAuditLogKey @siteid, @LogKey output
select @LogKey
select * from TMS_Integration_AuditLog
*/
CREATE proc [dbo].[TMS_Integration_CreateAuditLogKey]  
(
	@SiteID			varchar(20),
	@LogKey			int = 0 OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	Delete from TMS_Integration_AuditLogDetail where LogKey in (
	select Logkey from TMS_Integration_AuditLog where DateCreated < Getdate() -10)

	insert into TMS_Integration_AuditLog (SiteID, DateCreated)
	SELECT @SiteID, GETDATE()
	SET @LogKey = SCOPE_IDENTITY()
	RETURN
END
