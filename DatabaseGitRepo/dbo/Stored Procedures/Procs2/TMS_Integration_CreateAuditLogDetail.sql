CREATE Proc [dbo].[TMS_Integration_CreateAuditLogDetail]
(
	@LogKey			int,
	@EditGroup		varchar(5), -- 990, 997, 214S, 214A, 210, Doc
	@ActionHead		varchar(50),
	@DataType		varchar(10), -- ERROR / SUCCESS
	@ActionDetail	nvarchar(max),
	@LogDetailKey	bigint OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(@LogKey = 0 OR ISNULL(@EditGroup,'') = '' OR ISNULL(@ActionHead,'') = '' OR 
		ISNULL(@DataType,'')= '' OR ISNULL(@ActionDetail,'') = '')
	BEGIN
		SET @LogDetailKey = 0
		return
	END

	insert into TMS_Integration_AuditLogDetail(LogKey, EDIGroup, ActionHead, DataType, ActionDetail)
	select @LogKey, @EditGroup, @ActionHead, @DataType, @ActionDetail
	set @LogDetailKey = SCOPE_IDENTITY()
	return
END
