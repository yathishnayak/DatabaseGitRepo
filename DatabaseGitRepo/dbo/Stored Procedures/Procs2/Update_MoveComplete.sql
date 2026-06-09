


CREATE PROCEDURE [dbo].[Update_MoveComplete]
/*
Dispatch Screen Container move Complete
*/
@OrderDetailKey   VARCHAR(100),
@UserKey	      INT,
@ConfirmDate	  DATETIME,
@OutPut		      BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	CREATE TABLE #TempData
	(
		OrderDetailKey INT
	);

	INSERT INTO #TempData (OrderDetailKey)
	SELECT * FROM Fn_SplitParamCol (@OrderDetailKey);

	SELECT OrderDetailKey INTO #IncomplCont
	FROM dbo.[Routes] A 
		INNER JOIN dbo.RouteStatus RS ON RS.[Status]=A.[Status]
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM dbo.#TempData ) 
	AND a.Status <> 5;

	DELETE FROM #TempData 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #IncomplCont );
	
	UPDATE dbo.OrderDetail
	SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Move Complete' ),
		CompleteDate = @ConfirmDate
	where OrderDetailKey IN
	(	
		 SELECT REPLACE(OrderDetailKey,':','') FROM dbo.#TempData
	);

	DECLARE @UserName varchar(100),
			@Comment varchar(500)

		--SET @UserName=ISNULL((SELECT Firstname+ ' ' +ISNULL(Lastname,'') From UserInfo WHERE UserKey=@UserKey),'')
		select @UserName = isnull(UserName,'') from [user] where UserKey = @UserKey
 	set @Comment = 'Container Move Completed  ' --+ @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);

	INSERT INTO  AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
			VALUES(GETDATE(),@USerName,'Container',
			(SELECT ContainerNo FROM OrderDetail WHERE OrderDetailKey IN
				(	
					SELECT OrderDetailKey FROM #TempData
				)
			),null,'Text',@Comment,(SELECT OrderDetailKey FROM #TempData))
	--****************************************************************

--	exec UpdateContainerStatus @OrderDetailKey

	declare @OrdDetailKey int
	declare tempCursor cursor  FOR
	select orderdetailkey from #TempData

	Open tempcursor
	Fetch next from TempCursor into @OrdDetailKey

	while @@FETCH_STATUS = 0
	begin
		print '-------'
		print @OrdDetailKey
		exec UpdateContainerStatus @OrdDetailKey
		Fetch next from TempCursor into @OrdDetailKey
	end

	close TempCursor
	deallocate TempCursor

	SET @OutPut=1;
END


