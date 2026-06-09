/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"OrderDetailKey" : 221997, "ConfirmDate" : "2026-03-18 00:00:00.000"}'
	EXEC [Update_MoveComplete_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_MoveComplete_V2]
/*
Dispatch Screen Container move Complete
*/
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@OrderDetailKey   VARCHAR(100),
		@ConfirmDate	  DATETIME

	SELECT 
		@OrderDetailKey 	= OrderDetailKey ,
		@ConfirmDate		= ConfirmDate	
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey	VARCHAR(100)	'$.OrderDetailKey', 
		ConfirmDate		DATETIME		'$.ConfirmDate'
	)

	SET @Status=0;

	CREATE TABLE #TempData
	(
		OrderDetailKey INT
	);

	INSERT INTO #TempData (OrderDetailKey)
	SELECT * FROM Fn_SplitParamCol (@OrderDetailKey);

	SELECT OrderDetailKey INTO #IncomplCont
	FROM dbo.[Routes] A WITH(NOLOCK)
		INNER JOIN dbo.RouteStatus RS WITH(NOLOCK) ON RS.[Status]=A.[Status]
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM dbo.#TempData ) 
	AND a.Status <> 5;

	DELETE FROM #TempData 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #IncomplCont );
	
	UPDATE dbo.OrderDetail
	SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus  WITH(NOLOCK) WHERE [Description]='Move Complete' ),
		CompleteDate = @ConfirmDate
	where OrderDetailKey IN
	(	
		 SELECT REPLACE(OrderDetailKey,':','') FROM dbo.#TempData
	);

	DECLARE @UserName varchar(100),
			@Comment varchar(500)

		--SET @UserName=ISNULL((SELECT Firstname+ ' ' +ISNULL(Lastname,'') From UserInfo WHERE UserKey=@UserKey),'')
		select @UserName = isnull(UserName,'') from [user] where UserKey = @UserKey
 	set @Comment = 'Container Move Completed by ' + @USerName --+ ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);

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

	SET @Status=1;
	SET @Reason = 'Success'
END