--select * from OrderDetail where ContainerNo = 'QWWE235656'
CREATE PROC [dbo].[Get_ContainerAllDocuments] -- Get_ContainerAllDocuments 49
(
	@OrderDetailKey int = 13
)
as
	SET NOCOUNT ON
	SET FMTONLY OFF
	Select CD.* , U.UserName, DD.DocSource
	-- from ContainerDocuments CD
	from vContainerDocuments_V2 CD
	INNER JOIN [User] U ON (U.UserKey=CD.DocumentUserKey)
	LEFT JOIN DriverDocuments DD WITH (NOLOCK) ON DD.DocumentKey=CD.DocumentKey
	where OrderDetailKey = @OrderDetailKey
	order by CreateDate desc
