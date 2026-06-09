/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX) = '{"RouteKey":177964}',
	@Status	BIT = 0, 
	@IsDebug BIT = 1, 
	@Reason	VARCHAR(100) = ''
	EXec [Get_ContainerTypeForLeg_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Get_ContainerTypeForLeg_V2]  -- Get_ContainerTypeForLeg 352
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT = 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	set nocount on
	set fmtonly off

	DECLARE @RouteKey		INT = 0

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	
		
	IF (@IsDebug = 1)
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'In Debug Mode'
	END	

	SELECT 
	@RouteKey = RouteKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	RouteKey		INT			'$.RouteKey'
	)

	declare @orderDetailKey	int
	select @orderDetailKey = OrderDetailKey from Routes WITH (NOLOCK)  where RouteKey = @RouteKey

	SELECT @orderDetailKey as OrderDetailKey, @RouteKey as RouteKey,
		CT.ContainerTypeKey, CT.TypeID, Ct.ItemKey, CT.IsActive,
		CONVERT(BIT,ISNULL(CASE WHEN ISNULL(A.OrderDetailKey,0) = 0 THEN 0 ELSE 1 END,0)) AS IsSelected
	FROM ContainerTypes CT  WITH (NOLOCK) 
	LEFT JOIN (
	SELECT 
		OC.Orderdetailkey,RT.RouteKey,OC.commentkey,LTRIM(RTRIM([value])) AS 'Comment', OD.ContainerNo,LEFT([value],3) AS ShortComment
		FROM [dbo].[Comment] C  WITH (NOLOCK) 
			CROSS APPLY STRING_SPLIT(C.description,',')  
			INNER JOIN 
				[dbo].[OrderDetailComments] OC   WITH (NOLOCK)  ON  OC.CommentKey = C.CommentKey
			INNER JOIN Orderdetail OD   WITH (NOLOCK)  on OD.OrderDetailKey = OC.OrderDetailKey
			INNER JOIN ROUTES RT   WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
		WHERE (@RouteKey = 0 OR RT.RouteKey = @RouteKey)
		) A ON A.Comment = CT.TypeID
		FOR JSON PATH
		SET @Status=1
		SET @Reason='Success'
END