CREATE Proc [dbo].[Get_ContainerTypeForOrderDetail]  -- Get_ContainerTypeForLeg 352
(
	@OrderDetailKey		INT = 0
)
AS
BEGIN
	set nocount on
	set fmtonly off
	SELECT @orderDetailKey as orderDetailKey, 0 as RouteKey,
		CT.ContainerTypeKey, CT.TypeID, Ct.ItemKey, CT.isActive,
		CONVERT(BIT,ISNULL(CASE WHEN ISNULL(A.OrderDetailKey,0) = 0 THEN 0 ELSE 1 END,0)) AS IsSelected
	FROM ContainerTypes CT
	LEFT JOIN (
	SELECT 
		OC.orderdetailkey,0 as RouteKey,OC.commentkey,LTRIM(RTRIM([value])) AS 'Comment', OD.ContainerNo,LEFT([value],3) AS ShortComment
		FROM [dbo].[Comment] C  WITH (NOLOCK) 
			CROSS APPLY STRING_SPLIT(C.description,',')  
			INNER JOIN 
				[dbo].[OrderDetailComments] OC   WITH (NOLOCK)  ON  OC.CommentKey = C.CommentKey
			INNER JOIN Orderdetail OD   WITH (NOLOCK)  on OD.OrderDetailKey = OC.OrderDetailKey
--			INNER JOIN ROUTES RT   WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
		WHERE OC.OrderDetailKey = @OrderDetailKey
		) A ON A.Comment = CT.TypeID
END
