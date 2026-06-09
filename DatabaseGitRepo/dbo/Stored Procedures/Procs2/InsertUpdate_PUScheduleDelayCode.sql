/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"OrderDetailKey":226479,"CodeKey":"2:3:4","IsNew":false}'
exec InsertUpdate_PUScheduleDelayCode @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[InsertUpdate_PUScheduleDelayCode]
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	DECLARE @UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)

	CREATE TABLE #CodeData
	(
		OrderDetailKey	INT,
		CodeKey			VARCHAR(100),
		Code			VARCHAR(500),
		IsNew			BIT
	)

	INSERT INTO #CodeData(OrderDetailKey, CodeKey,Code,IsNew)
	SELECT OrderDetailKey,CodeKey,Code,IsNew
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey	int				'$.OrderDetailKey',
			CodeKey			VARCHAR(100)	'$.CodeKey',
			Code			VARCHAR(500)	'$.Code',
			IsNew			BIT				'$.IsNew'
		)
	CREATE TABLE #CodeKeys
			(
				SLNo		INT,
				CodeKey		int,
			)

	SELECT  @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey			
	SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=(SELECT TOP 1 OrderDetailKey FROM #CodeData)

	BEGIN TRY
		BEGIN TRANSACTION
			--DECLARE @IsNew BIT,@CodeKey INT=0
			--SELECT @IsNew=  IsNew FROM #CodeData
			--IF(@IsNew=1)
			--BEGIN
			--	INSERT INTO PUScheduleDelayCode
			--	(Code,IsActive,IsDeleted,CreatedBy,CreatedDate)
			--	SELECT (SELECT Code FROM #CodeData),1,0,512,GETDATE()

			--	SET @CodeKey=SCOPE_IDENTITY();

			--	UPDATE #CodeData
			--	SET CodeKey=@CodeKey
			--END

			--UPDATE OD
			--SET OD.PUDelayedCodeKEy=T.CodeKey
			--FROM OrderDetail OD 
			--INNER JOIN #CodeData T ON OD.OrderDetailKey=T.OrderDetailKey


			if((SELECT Isnull(CodeKey,'') FROM #CodeData) <> '')
			Begin
				DECLARE @CodeKeys VARCHAR(100),@OrderDetailKey INT=0
				SET @OrderDetailKey=(SELECT TOP 1 OrderDetailKey FROM #CodeData)
				print 1
				SELECT @CodeKeys= CodeKey FROM #CodeData
				select @CodeKeys
				print 2
				--insert into #CodeKeys(CodeKey)
				--select value from dbo.Fn_SplitParamCol(@CodeKeys)
				insert into #CodeKeys(SLNo,CodeKey)
				select ROW_NUMBER() OVER(Order BY value),value from dbo.Fn_SplitParamCol(@CodeKeys)
				select * from #CodeKeys
			End
			DELETE FROM OrderDetail_Prepull_PUDelayed_RCKeys
			WHERE PUScheduleRCKey IS NOT NULL AND PrepullRCKey IS NULL AND OrderDetailKey=@OrderDetailKey

			DECLARE @Counter INT=1, @TotalCount INT=0
			SELECT @TotalCount  =Count(1) FROM #CodeKeys
			WHILE(@Counter<=@TotalCount)
			BEGIN
				INSERT INTO OrderDetail_Prepull_PUDelayed_RCKeys
				(OrderDetailKey,PUScheduleRCKey)
				SELECT @OrderDetailKey, CodeKey FROM #CodeKeys WHERE SLNo=@Counter
				SET @Counter=@Counter+1;
			END
			
		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','PUScheduleDelayCode is updated by '+@UserName

		COMMIT TRANSACTION
		SET @Status = 1
		SET @Reason = 'SUCCESS'
		
		SELECT CodeKey, Code, IsActive, IsDeleted
		FROM PUScheduleDelayCode WITH (NOLOCK)
		WHERE IsActive=1 AND IsDeleted=0
		FOR JSON PATH
	END TRY
	BEGIN CATCH
		SET @Status = 0
		SET @Reason = ERROR_MESSAGE()
		--SELECT CodeKey, Code, IsActive, IsDeleted
		--FROM PUScheduleDelayCode WITH (NOLOCK)
		--WHERE IsActive=1 AND IsDeleted=0
		--FOR JSON PATH
		PRINT ERROR_LINE()
		PRINT ERROR_NUMBER()
		PRINT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
	
END