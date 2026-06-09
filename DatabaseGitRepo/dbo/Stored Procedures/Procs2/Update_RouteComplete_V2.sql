/*
-- Status was 10 - Changed to 6 in OrderDetail Table
DECLARE
@OrderDetailKey   VARCHAR(100) = 47706,
@UserKey	INT = 1144,
@ConfirmDate	DATETIME = GETDATE(),
@Status		BIT 
EXEC [Update_RouteComplete] @OrderDetailKey, @UserKey, @ConfirmDate, @Status OUTPUT
SELECT @Status
*/
/*
-- Status was 1 - Changed to 6 in OrderDetail Table
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey" : 183961, "ConfirmDate" : "2026-03-23 10:36:00"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_RouteComplete_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_RouteComplete_V2]
/*
Dispatch Screen Container Complete
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

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
	@OrderDetailKey   VARCHAR(100),--*****Colon Separated Values
	@ConfirmDate	DATETIME

	SELECT 
		@OrderDetailKey		=		OrderDetailKey,
		@ConfirmDate		=		ConfirmDate
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey			VARCHAR(200)	'$.OrderDetailKey',
		ConfirmDate				DATETIME		'$.ConfirmDate'
	)

	SET @Status=0;

	CREATE TABLE #TempData
	(
		OrderDetailKey INT
	);

	INSERT INTO #TempData (OrderDetailKey)
	SELECT * FROM Fn_SplitParamCol (@OrderDetailKey);

	SELECT OrderDetailKey INTO #IncomplCont
	FROM dbo.[Routes] A  WITH(NOLOCK)
		INNER JOIN dbo.RouteStatus RS WITH(NOLOCK) ON RS.[Status]=A.[Status]
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM dbo.#TempData ) 
	AND a.Status <> 5;

	DELETE FROM #TempData 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #IncomplCont );
	--**************Routes Status to Complete****************************
	/* AUTO ROUTE COMPLETTION IS REMOVED NOW. USER WILL MANUALLY COMPLETE THE LEGS
	UPDATE dbo.[Routes] 
	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready to Complete' ), 
			LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM dbo.#TempData );
	*/
	--*********************OrderDetail Status to Dispatch Confirmed*******
	UPDATE dbo.OrderDetail
	SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WITH(NOLOCK) WHERE [Description]='Dispatch Confirmed' ),
		CompleteDate = @ConfirmDate
	where OrderDetailKey IN
	(	
		 SELECT REPLACE(OrderDetailKey,':','') FROM dbo.#TempData
	);

	DECLARE @USerName varchar(100),
			@Comment varchar(500)
		--SET @UserName=ISNULL((SELECT Firstname+ ' ' +ISNULL(Lastname,'') From UserInfo WHERE UserKey=@UserKey),'')
		select @UserName = ISNULL(UserName,'')  from [User] WITH(NOLOCK) where UserKey = @UserKey
	set @Comment = 'Container Dispatch Confirmed by ' + @USerName --+ ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
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

	SET @Status=1
	SET @Reason = 'Success'
END