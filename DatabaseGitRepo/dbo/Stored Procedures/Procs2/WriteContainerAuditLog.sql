
CREATE procedure  [dbo].[WriteContainerAuditLog]
(
	@OrderDetailKey int,	
	@CreateUserKey as int,
	@Comments as nvarchar(max)
)
as
Begin
	Declare @ContainerNo as varchar(50)
	Declare @Name varchar(100) ='' 
	
	select @Name = isnull(UserName,'') from [User] where  UserKey =@CreateUserKey
	select  @ContainerNo  = ContainerNo from OrderDetail  where OrderDetailKey = @OrderDetailKey
	insert into AuditLogDetail (DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	select  getdate(),  @Name,  'Container', @ContainerNo,  @OrderDetailKey, '', '', @Comments
End

