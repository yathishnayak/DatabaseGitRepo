
CREATE Proc [dbo].[Get_ContainerTypeForContainer]  -- Get_ContainerTypeForContainer 47693, ''
(
	@OrderDetailKey	INT = 0,
	@Container		VARCHAR(20) = ''
)
AS
BEGIN
	SELECT A.*
	FROM (
	SELECT 
		OC.orderdetailkey,OC.commentkey,LTRIM(RTRIM([value])) AS 'Comment', OD.ContainerNo,LEFT([value],3) AS ShortComment
		FROM [dbo].[Comment] C  
			CROSS APPLY STRING_SPLIT(C.description,',')  
			INNER JOIN 
				[dbo].[OrderDetailComments] OC   ON  OC.CommentKey = C.CommentKey
			INNER JOIN Orderdetail OD on OD.OrderDetailKey = OC.OrderDetailKey
		WHERE (@OrderDetailKey = 0 OR OD.OrderDetailKey = @OrderDetailKey)
			AND (@Container = 'NA' OR OD.ContainerNo = @Container OR @Container='')
		) A 
		INNER JOIN ContainerTypes CT ON A.Comment = CT.TypeID OR A.Comment = CT.ShortCode
END


