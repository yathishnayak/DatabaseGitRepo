
CREATE PROCEDURE [dbo].[GetCommentorInforForMail]  -- GetCommentorInforForMail 300581,'396, 486',79811
(
	@ParenCommentKey	INT,
	@UserKeys			VARCHAR(300),
	@OrderDetailKey	INT=0
)
AS
BEGIN
	DECLARE @CommetorKey	INT=0, @ContainerNo VARCHAR(20), @OrderNo VARCHAR(20)=''
	SELECT @CommetorKey = CreateUserKey FROM Comment WHERE CommentKey=@ParenCommentKey
	SELECT @ContainerNo = ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey
	SELECT @OrderNo = OrderNo FROM OrderHeader WHERE OrderKey=(SELECT Top 1 OrderKey FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey)

	select * into #UserKeys from dbo.Fn_SplitParam(@UserKeys)
	INSERT INTO #UserKeys
	values(@CommetorKey)

	 SELECT @ParenCommentKey AS ParentCommentKey,@ContainerNo AS ContainerNo,@OrderNo AS OrderNo,
	 UserInfo=(SELECT ISNULL(Firstname,'') + ' ' +ISNULL(Lastname,'') AS UserName,Email FROM [UserInfo] U
	 INNER JOIN Address A WITH (NOLOCK) ON A.AddrKey=U.Addrkey
	 WHERE UserKey in (SELECT * FROM #UserKeys) FOR Json PATH)
	 FOR JSON PATH;
END