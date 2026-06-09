/*    
     
Declare @UserKey  INT=952,    
 @JsonString  VARCHAR(MAX)='{"OrderDetailKey":107766,"RouteKey":374462,"LinkedContainerNo":"CAIU4025919","ContainerType":"OSY"}',     
 @Status   BIT = 0 ,    
 @Reason   NVARCHAR(1000) = ''     
    
 EXEC Route_LinkContainer @UserKey,@JsonString,@Status OUTPUT, @Reason OUTPUT    
 select @Reason,@Status    
    
*/
CREATE proc [dbo].[Route_LinkContainer]  
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
	
)
AS
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	set @Status = 0
	Set @Reason = ''

	DECLARE @OrderDetailKey			int,
	@RouteKey				INT,
	@LinkedContainerNo		varchar(20),
	@ContainerType			NVARCHAR(10),
	@OutputResp		BIT = 0,
	@ShowStops		BIT = 0

	SELECT @OrderDetailKey=OrderDetailKey,@RouteKey=RouteKey,@LinkedContainerNo=LinkedContainerNo,@ContainerType=ContainerType
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey		INT			'$.OrderDetailKey',
			RouteKey			INT			'$.RouteKey',
			LinkedContainerNo	VARCHAR(20)	'$.LinkedContainerNo',
			ContainerType		NVARCHAR(10)	'$.ContainerType'
		)

	declare @cnt int = 0, @LinkedOrderdetailKey	int = 0, @ContainerNo varchar(20) = '', @cntLinked int = 0, @UserName VARCHAR(100)=''
	Select @cnt = count(1) from Routes WITH (NOLOCK) where RouteKey = @RouteKey
	Select @ContainerNo = ContainerNo from ORderDetail WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey
	select @cntLinked = count(1) from OrderDetail WITH (NOLOCK) where ContainerNo = @LinkedContainerNo and isnull(IsLinked,0) <> 0
	select top 1 @LinkedOrderdetailKey = OrderDetailKey from OrderDetail  WITH (NOLOCK)
		where ContainerNo = @LinkedContainerNo and isnull(LinkedContainerNo,'') = ''
	SELECT @UserName= UserName FROM [USER] WITH (NOLOCK) WHERE UserKey=@UserKey

	--select @cnt coun,@LinkedOrderdetailKey linkor

	DECLARE @jsonparam NVARCHAR(400)=''
	--SET @jsonparam='{"OrderDetailKey":'+@OrderDetailKey+',"RouteKey":'+@RouteKey+'}'
	SELECT @jsonparam = (
						SELECT 
							@OrderDetailKey AS OrderDetailKey,
							@RouteKey AS RouteKey
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					);

	IF(@LinkedContainerNo=@ContainerNo)
	begin
		Set @Status = 0
		Set @Reason = 'You cannot link the container to itself'
		return;
	end

	IF(isnull(@cntLinked ,0) > 0)
	begin
		Set @Status = 0
		Set @Reason = 'Linked Container is Already Linked with another Container'
	end

	Begin Try
		Begin Transaction
		
		If(@cnt > 0 and @LinkedOrderdetailKey > 0)
		Begin
			update OrderDetail set
				IsLinked = 1,
				LinkedContainerNo = @LinkedContainerNo,
				LinkedOrderDetailKey = @LinkedOrderdetailKey
			where  OrderDetailKey = @OrderDetailKey

			update OrderDetail set
				IsLinked = 1,
				LinkedContainerNo = @ContainerNo,
				LinkedOrderDetailKey = @OrderDetailKey
			where  OrderDetailKey = @LinkedOrderdetailKey

			
			update RT
			set LinkedContainer = @LinkedContainerNo,
			    LinkedBy = @UserKey,
				LinkedDate = GETDATE(),
				ContainerNoSource='JCB User',
				LinkedContainerType=@ContainerType
			from Routes RT	
			--inner join OrderDetail od on od.CurrentRouteKey = r.RouteKey
			where RT.RouteKey = @RouteKey
		

			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 

			UPDATE OrderDetail SET
				MarkedNoEmptyAvailable = 0,
				MarkedNoEmptyAvailableBY=null
			WHERE  OrderDetailKey = @OrderDetailKey

			UPDATE Routes SET
				NoEmptyAvailableMarked = 0,
				NoEmptyAvailableMarkedBY=null
			WHERE  RouteKey = @RouteKey

			Commit Transaction
			Set @Status = 1
			Set @Reason = 'Linked Successfully.'
			IF(@Status = 1)
			BEGIN
				EXEC Route_ValidateCreateStops @UserKey,@jsonparam, @OutputResp OUTPUT,@Reason
				Print '@OutputResp'
				Print @OutputResp
			END
				SET @ShowStops = CASE WHEN @OutputResp = 1 THEN 1 ELSE 0 END
				Select @ShowStops 'ShowStops' FOR JSON PATH, WITHOUT_ARRAY_Wrapper
			Return
		end
		ELSE IF(@cnt > 0 and @LinkedOrderdetailKey = 0)
		BEGIN
			update OrderDetail set
				IsLinked = 1,
				LinkedContainerNo = @LinkedContainerNo,
				LinkedOrderDetailKey = 0
			where  OrderDetailKey = @OrderDetailKey

			update RT
			set LinkedContainer = @LinkedContainerNo,
			    LinkedBy = @UserKey,
				LinkedDate = GETDATE(),
				ContainerNoSource='JCB User',
				LinkedContainerType=@ContainerType
			from Routes RT	
			--inner join OrderDetail od on od.CurrentRouteKey = r.RouteKey
			where RT.RouteKey = @RouteKey
		

			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 

			UPDATE OrderDetail SET
				MarkedNoEmptyAvailable = 0,
				MarkedNoEmptyAvailableBY=null
			WHERE  OrderDetailKey = @OrderDetailKey

			UPDATE Routes SET
				NoEmptyAvailableMarked = 0,
				NoEmptyAvailableMarkedBY=null
			WHERE  RouteKey = @RouteKey

			Commit Transaction
			Set @Status = 1
			Set @Reason = 'Linked Successfully.'
			IF(@Status = 1)
			BEGIN				
				EXEC Route_ValidateCreateStops @UserKey,@jsonparam,@OutputResp OUTPUT,@Reason
				Print '@OutputResp'
				Print @OutputResp
			END
				SET @ShowStops = CASE WHEN @OutputResp = 1 THEN 1 ELSE 0 END
				Select @ShowStops 'ShowStops' FOR JSON PATH, WITHOUT_ARRAY_Wrapper
			Return
		END
		Set @Status = 0
		Set @Reason = 'Error. Container nos. not found'
		
	End Try
	Begin Catch
		Set @Status = 0
		Set @Reason = 'Technical Error'
		Rollback Transaction
	End Catch
End