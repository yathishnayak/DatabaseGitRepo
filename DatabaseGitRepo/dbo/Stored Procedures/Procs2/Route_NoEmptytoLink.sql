/*

Declare @UserKey  INT=952,    
 @JsonString  VARCHAR(MAX)='{"OrderDetailKey":221910,"RouteKey":729346,"LinkedContainerNo":"","ContainerType":"NoEmpty"}',     
 @Status   BIT = 0 ,    
 @Reason   NVARCHAR(1000) = ''     
    
 EXEC Route_NoEmptytoLink @UserKey,@JsonString,@Status OUTPUT, @Reason OUTPUT    
 select @Reason,@Status   

*/
CREATE PROCEDURE [dbo].[Route_NoEmptytoLink]
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	set nocount on
	set fmtonly off
	SET ARITHABORT ON;
	DECLARE @UserName VARCHAR(100)='',@ContainerNo VARCHAR(20)='',@OrderDetailKey			int,
	@RouteKey				INT,
	@OutputResp		BIT = 0,
	@ShowStops		BIT = 0

	SELECT @OrderDetailKey=OrderDetailKey,@RouteKey=RouteKey
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey		INT			'$.OrderDetailKey',
			RouteKey			INT			'$.RouteKey'
		)

	SELECT @UserName= UserName FROM [USER] WHERE UserKey=@UserKey
	SELECT @ContainerNo= ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey

	DECLARE @jsonparam NVARCHAR(400)=''
	--SET @jsonparam='{"OrderDetailKey":'+@OrderDetailKey+',"RouteKey":'+@RouteKey+'}'
	SELECT @jsonparam = (
							SELECT 
								@OrderDetailKey AS OrderDetailKey,
								@RouteKey AS RouteKey
							FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
						);

	print @jsonparam

	--UPDATE OrderDetail SET
	--			MarkedNoEmptyAvailable = 1,
	--			MarkedNoEmptyAvailableBY=@UserKey
	--WHERE  OrderDetailKey = @OrderDetailKey

	UPDATE Routes SET
				NoEmptyAvailableMarked = 1,
				NoEmptyAvailableMarkedBY=@UserKey,
				NoEmptyAvailableMarkedDate=GETDATE()
	WHERE  RouteKey = @RouteKey

	update RT
			set LinkedContainer = '',
			    LinkedBy = null,
				LinkedDate = null,
				LinkedContainerSource='',
				LinkedContainerType=''
			from Routes RT	
			--inner join OrderDetail od on od.CurrentRouteKey = r.RouteKey
			where RT.RouteKey = @RouteKey

	update OrderDetail set
				IsLinked = 0,
				LinkedContainerNo = null,
				LinkedOrderDetailKey = null
			where  OrderDetailKey = @OrderDetailKey

	Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' updated as no empty to link ' 

	SET @Status=1
	SET @Reason ='No Empty marked successfully'
	IF(@Status = 1)
	BEGIN
		EXEC Route_ValidateCreateStops @UserKey,@jsonparam,@OutputResp OUTPUT,@Reason
	END
				SET @ShowStops = CASE WHEN @OutputResp = 1 THEN 1 ELSE 0 END
				Select @ShowStops 'ShowStops' FOR JSON PATH, WITHOUT_ARRAY_Wrapper
END