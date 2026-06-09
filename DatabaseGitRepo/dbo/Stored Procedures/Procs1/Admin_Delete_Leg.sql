
/**Admin_Container_RouteDetails
DECLARE @UserKey		INT=897,
	@JsonString		VARCHAR(MAX)='{"RouteKey" : 179675,"OrderDetailKey" :47835}',
	@Status			BIT	= 0 ,
	@Reason			VARCHAR(1000) = '' 
exec Admin_Delete_Leg @UserKey, @JsonString,@Status output, @Reason output
**/

CREATE PROC [dbo].[Admin_Delete_Leg]
(
	@UserKey		INT=897,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
as 

BEGIN 
	DECLARE @RouteKey INT = 0 , @OrderDetailKey INT =0, @JsonResult NVARCHAR(MAX) = ''
	DECLARE @ISPresent BIT = 0 
	SELECT		@RouteKey = RouteKey, @OrderDetailKey = OrderDetailKey
	FROM		OPENJSON(@JsonString, '$')
				WITH(
						RouteKey INT			'$.RouteKey',	
						OrderDetailKey	INT		'$.OrderDetailKey'
					)

	Select @ISPresent = CASE WHEN (Select Count(*) from OrderExpense where Routekey = @RouteKey )>0 THEN 1 ELSE 0 END

	IF(@ISPresent=1)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Already Expense Added'
		
		--Select @Status Status, @Reason Reason
		print @Status 
	print @Reason
		RETURN

END

	Select @ISPresent = CASE WHEN (Select Count(*) from InvoiceDetail where OrderDetailKey = @OrderDetailKey )>0 THEN 1 ELSE 0 END

	IF(@ISPresent=1)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Already Invoiced'
		
		--Select @Status Status, @Reason Reason
		print @Status 
	print @Reason
		RETURN

	END

	Delete  FROM Routes where RouteKey = @RouteKey AND OrderDetailKey = @OrderDetailKey
	
	SET @Status = 1
	SET @Reason = 'Success'
	print @Status 
	print @Reason
	
End
