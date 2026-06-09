


CREATE PROCEDURE [dbo].[INSERT_OrderStopsLog]
(
	@Type	varchar(10) = 'Update'
)
AS
BEGIN	
	DECLARE @User		VARCHAR(50)
	SET @User=( SELECT SYSTEM_USER )	
--***************Insert Only******************	
	if(@Type = 'Update' OR @Type = 'Insert')
	Begin
		INSERT INTO [Table_Log].dbo.[OrderStops_Log]
					 ([OrderStopKey],[OrderKey],[StopTypeKey],[StopName],[StopAddrKey],[StopNumber],[LocationType],[StatusKey],[CreateDate],
					 [CreateUserKey],[UpdateDate],[UpdateUserKey],[IsDeleted],[DeleteUserKey],[DeleteDate],[Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [OrderStopKey],[OrderKey],[StopTypeKey],[StopName],[StopAddrKey],[StopNumber],[LocationType],[StatusKey],[CreateDate],
					 [CreateUserKey],[UpdateDate],[UpdateUserKey],[IsDeleted],[DeleteUserKey],[DeleteDate],'INSERT',
					 GETDATE(),isnull(UpdateUserKey, CreateUserKey), @Type
		FROM #inserted 
	END

			
	if(@Type = 'Update' OR @Type = 'Delete')
	Begin
		Declare @DeleteUserKey	int = 0
		if(@Type='Delete')
		Begin
			select @DeleteUserKey = OS.UpdateUserKey
			from #Deleted D
			inner join OrderStops_Deleted OS WITH(NOLOCK) on D.OrderStopKey = OS.OrderStopKey
		End

		INSERT INTO [Table_Logs].dbo.[OrderStops_Log]
					([OrderStopKey],[OrderKey],[StopTypeKey],[StopName],[StopAddrKey],[StopNumber],[LocationType],[StatusKey],[CreateDate],
					 [CreateUserKey],[UpdateDate],[UpdateUserKey],[IsDeleted],[DeleteUserKey],[DeleteDate],[Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [OrderStopKey],[OrderKey],[StopTypeKey],[StopName],[StopAddrKey],[StopNumber],[LocationType],[StatusKey],[CreateDate],
					 [CreateUserKey],[UpdateDate],[UpdateUserKey],[IsDeleted],[DeleteUserKey],[DeleteDate], 'DELETE',
					 GETDATE(), Case when @Type = 'Delete' then @DeleteUserKey else  isnull(UpdateUserKey, CreateUserKey) end, @Type
		FROM #deleted 
	END
END

