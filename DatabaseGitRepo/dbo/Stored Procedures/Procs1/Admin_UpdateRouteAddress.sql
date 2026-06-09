/**
declare @UserKey		int=953,
	@JSONString		nvarchar(max)='{"RouteKey":352069,"SourceAddrKey":0,"DestinationAddrKey":18876,"UpdateSource":false,"UpdateDestination":true}',
	@Status			bit	= 0 ,
	@Reason			varchar(1000) = '' 
	exec [Route_UpdateAddress] @UserKey,@JSONString,@Status output,@Reason output
	select @Reason,@Status
	**/
 
CREATE PROCEDURE [dbo].[Admin_UpdateRouteAddress]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	DECLARE @UserName varchar(100),
			@CommentKey int,
			@Comment varchar(max),
            @OrderDetailKey int,
			@ContainerNo varchar(20),
			@PreviousSourceAddrKey int,
			@PreviousDestinationAddrKey int,
			@ChangedSourceAddrKey int,
			@ChangedDestinationAddrKey int,
			@Routekey int ,
			@SourceAddrKey int,
			@DestinationAddrKey int,
			@UpdateSource BIT=0,
			@UpdateDestination BIT=0
	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END
CREATE TABLE #ParamData 
	(
		RouteKey			INT,
		OrderDetailKey      INT,
		SourceAddrKey		INT,
		DestinationAddrKey	INT,
		UpdateSource		BIT,
		UpdateDestination   BIT
	)
	INSERT INTO #ParamData(RouteKey,OrderDetailKey, SourceAddrKey, DestinationAddrKey,UpdateSource,UpdateDestination)
	SELECT RouteKey,OrderDetailKey,SourceAddrKey,DestinationAddrKey,UpdateSource,UpdateDestination
	FROM OPENJSON(@JsonString, '$')
	WITH (
			RouteKey			int		'$.RouteKey',
			OrderDetailKey		int		'$.OrderDetailKey',
			SourceAddrKey		int		'$.SourceAddrKey',
			DestinationAddrKey	int		'$.DestinationAddrKey',
			UpdateSource        bit		'$.UpdateSource',
			UpdateDestination	bit		'$.UpdateDestination'
			)

		--select * from #ParamData
 
	    SELECT @UserName = ISNULL(UserName,'') from [User] where UserKey = @UserKey
		SELECT @RouteKey = RouteKey From #ParamData 

		SELECT @OrderDetailKey = OrderDetailKey From  #ParamData

		SET @PreviousSourceAddrKey =(Select RT.SourceAddrKey 
	    from Routes RT where routekey=@RouteKey)

		SET @PreviousDestinationAddrKey =(Select RT.DestinationAddrKey
	    from Routes  RT where routekey=@RouteKey)

		SELECT @ChangedSourceAddrKey = SourceAddrKey
		 from #ParamData 

		SELECT @ChangedDestinationAddrKey = DestinationAddrKey
		 from  #ParamData 

		 print 'BeforeUpdate'  
		 print @ChangedDestinationAddrKey

		set @UpdateSource = (select UpdateSource from #ParamData)
		set @UpdateDestination = (select UpdateDestination from #ParamData)

	BEGIN TRANSACTION 
 
	BEGIN TRY
	IF @UpdateSource=1
	BEGIN
		UPDATE RT SET RT.SourceAddrKey=@ChangedSourceAddrKey FROM Routes RT
		WHERE  RT.RouteKey= @RouteKey
	END
	IF @UpdateDestination=1
	BEGIN
		UPDATE RT SET RT.DestinationAddrKey=@ChangedDestinationAddrKey FROM Routes RT
		WHERE RT.RouteKey=@RouteKey

		print 'AlterUpdate' 
		print @ChangedDestinationAddrKey
	END
		set @Comment ='Source Address changed From' +  convert(varchar,@PreviousSourceAddrKey) +'To' + convert(varchar,@ChangedSourceAddrKey)+'Destination Address changed From' +  convert(varchar,@PreviousDestinationAddrKey) +'To' + convert(varchar,@ChangedDestinationAddrKey)+  +' by '+@UserName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
 
 
		INSERT INTO  AuditLogDetail (DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	    VALUES(GETDATE(),@UserName,'Container',@ContainerNo,null,'Text',@Comment,@OrderDetailKey)
		SET @Status = 1
		SET @Reason = 'Success'
		print 'successs'
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		print 'error'
		ROLLBACK TRANSACTION;
		select ERROR_MESSAGE()
		SET @Status = 0
		SET @Reason = 'error'
	END CATCH
END
