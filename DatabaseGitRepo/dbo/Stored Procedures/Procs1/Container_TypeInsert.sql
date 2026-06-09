CREATE proc [dbo].[Container_TypeInsert] -- [Container_TypeInsert] 186330, 796583 
(
	@OrderDetailKey		INT,
	@CommentKey			int			
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	--BEGIN TRANSACTION
	--BEGIN TRY
		DELETE FROM [ContainerTypesLink] WHERE [OrderDetailKey] = @OrderDetailKey

		insert into ContainerTypesLink (OrderDetailKey, CommentKey, ContainerTypeKey, IsSelected)
		SELECT A.OrderDetailKey, @CommentKey, ct.ContainerTypeKey, 1
			FROM (
				SELECT 
						OC.orderdetailkey,[value] as 'Comment',LEFT([value],3) AS ShortComment
				FROM [dbo].[Comment] C  WITH (NOLOCK) 
					CROSS APPLY STRING_SPLIT(C.[description],',')  
					INNER JOIN 
						[dbo].[OrderDetailComments] OC   WITH (NOLOCK) ON  OC.CommentKey = C.CommentKey					
				WHERE OC.OrderDetailKey = @OrderDetailKey and C.CommentKey = @CommentKey
			) A 
		INNER JOIN ContainerTypes CT WITH (NOLOCK) ON ltrim(rtrim(A.Comment)) = ltrim(rtrim(CT.TypeDescription)) OR ltrim(rtrim(A.Comment)) = ltrim(rtrim(CT.ShortCode))
		LEFT join ContainerTypesLink CTL WITH (NOLOCK) ON A.OrderDetailKey = CTL.OrderDetailKey 
			and CTL.ContainerTypeKey = CT.ContainerTypeKey
		WHERE CTL.OrderDetailKey IS NULL

		Exec Auto_ChargeContainerProps @Orderdetailkey

	--	COMMIT TRANSACTION
	--END TRY
	--BEGIN CATCH
	--	print Error_line()
	--	print Error_message()
	--	ROLLBACK TRANSACTION
	--END CATCH
END
