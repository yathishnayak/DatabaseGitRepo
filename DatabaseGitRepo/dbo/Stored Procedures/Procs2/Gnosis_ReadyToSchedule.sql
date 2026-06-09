CREATE PROCEDURE [dbo].[Gnosis_ReadyToSchedule]
(
	
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	DECLARE 
	@OrderDetailKey INT=0,
	@UUID VARCHAR(200)

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select @OrderDetailKey = OrderDetailKey, @UUID = isnull(UUID,0)
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey			INT		'$.OrderDetailKey',
		UUID			VARCHAR(200)				'$.UUID'
		)

	UPDATE OD
	SET OD.Status=3
	from OrderDetail OD
	LEFT JOIN Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
	WHERE OD.OrderDetailKey=@OrderDetailKey AND UUID=@UUID

	UPDATE Gnosis_Integration_Container_Final
	SET IsAutoMove=0,
	MovedBy=@UserKey,
	MovedOn=GETDATE()
	WHERE OrderDetailKey=@OrderDetailKey AND UUID=@UUID

	Set @Status = 1
    Set @Reason = 'SUCCESS'
END