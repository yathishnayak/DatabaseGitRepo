--EXEC Order_Bulk
CREATE procedure [dbo].[Order_Bulk]
(
	@UserKey      INT=0,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT	  
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;

	SET @Reason='Success';
	SET @Status=1;

	--DECLARE @ReturnValue INT ,@dropdown bit, @Name varchar ='',@Key INT=0;
		
	SELECT [Key], [Name], IsDropDown, IsTextBox, IsRadioButton, IsCheckBox, IsContainer, IsOrder, IsScheduler
	FROM Bulk_Orders WITH(NOLOCK)
	WHERE IsOrder = 1 FOR JSON PATH
	
END