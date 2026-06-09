/*

DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),  @Status BIT = 0,  @Reason VARCHAR(1000)


SET @JSONString = '[{ "RouteKey": 380531,"OrderDetailKey": 110134, "SelectStatus": 4 }]'

EXEC [dbo].[Reopen_CompletedLeg]   @UserKey, @JSONString, @Status OUTPUT,  @Reason OUTPUT
SELECT @Status AS Status, @Reason AS Reason
*/


CREATE PROCEDURE [dbo].[Reopen_CompletedLeg]
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

	DECLARE @USerName varchar(100),
			@CommentKey int,
			@Comment varchar(500),
            @OrderDetailKey int,
			@ContainerNo varchar(20),
			@PreviousRouteStatus VARCHAR(100),
			@PreviousContainerStatus varchar(100),
			@ChangedRouteStatus VARCHAR(100),
			@ChangedContainerStatus varchar(100)
	
	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END
	CREATE TABLE #ParamData
	(
		RouteKey			INT,
		OrderDetailKey		INT,
		SelectStatus		INT
	)

	

	INSERT INTO #ParamData(RouteKey, OrderDetailKey, SelectStatus)
	SELECT RouteKey,OrderDetailKey, SelectStatus
	FROM OPENJSON(@JsonString, '$')
	WITH (
			RouteKey			int		'$.RouteKey',
			OrderDetailKey		int		'$.OrderDetailKey',
			SelectStatus		int		'$.SelectStatus'
		)

	

	    select @USerName = ISNULL(UserName,'') from [User] WITH (NOLOCK) where UserKey = @UserKey

		SET @OrderDetailKey =(select OD.OrderDetailKey 
	    From OrderDetail OD WITH (NOLOCK)
		inner join #ParamData T on OD.OrderDetailKey = T.OrderDetailKey
		)
		SET @ContainerNo =(select OD.ContainerNo 
	    From OrderDetail OD WITH (NOLOCK)
		inner join #ParamData T on OD.OrderDetailKey = T.OrderDetailKey
		)

		SET @PreviousRouteStatus =(Select Description 
	    from [routes] RT WITH (NOLOCK)
		INNER JOIN #ParamData PD ON PD.RouteKey=RT.RouteKey
		inner join  RouteStatus rs WITH (NOLOCK) on rs.Status = RT.Status
		
		 )

		SET @ChangedRouteStatus =(Select Description 
	    from RouteStatus rs WITH (NOLOCK)
		INNER JOIN #ParamData PD ON Rs.Status=PD.SelectStatus
		 )

		SET @PreviousContainerStatus = ( select Description
	    from OrderDetailStatus os  WITH (NOLOCK)
	    INNER JOIN OrderDetail Od WITH (NOLOCK) ON OS.Status=OD.Status 
	    inner join #ParamData T on OD.OrderDetailKey = T.OrderDetailKey)

		SET @ChangedContainerStatus =(Select Description 
	    from OrderDetailStatus rs WITH (NOLOCK) WHERE Status=7
		 )
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE OD SET Status=7
		From OrderDetail OD
		inner join #ParamData T on OD.OrderDetailKey = T.OrderDetailKey

		UPDATE RT SET Status= T.SelectStatus, 
			ActualDeparture =  null,
			ActualArrival = case when T.SelectStatus = 4 then  null else ActualArrival end
		From routes RT 
		inner join #ParamData T on Rt.RouteKey = T.RouteKey and RT.OrderDetailKey = T.OrderDetailKey

		set @Comment = 'Route status changed From' +  @PreviousRouteStatus +'To' + @ChangedRouteStatus +' and Container status changed from' +  @PreviousContainerStatus +'To' + @ChangedContainerStatus +' by '+@USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);


		PRINT @Comment
PRINT @ContainerNo
PRINT @OrderDetailKey

		INSERT INTO  AuditLogDetail (DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	    VALUES(GETDATE(),@USerName,'Container',@ContainerNo,null,'Text',@Comment,@OrderDetailKey)

		SET @Status = 1
		SET @Reason = 'Success'

		

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		
    SET @Status = 0
    SET @Reason = ERROR_MESSAGE()

    SELECT ERROR_MESSAGE() AS ErrorMessage
	END CATCH
END

--select top 10 * from AuditLogDetail order by comments desc