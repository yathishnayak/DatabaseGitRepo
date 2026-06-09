CREATE PROCEDURE [dbo].[SellContact_InsertUpdate]
(
	@CustomerKey	INT=0,
	@JsonData		NVARCHAR(MAX)='',
	@OutPut			BIT OUTPUT,
	@Reason			NVARCHAR(100)=''  OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@JsonData,'') = '')
	BEGIN
		SET @Output = 0
		SET @Reason = 'Data not received'
		set @CustomerKey = 0
		return;
	END

	CREATE TABLE #Contacts
	(
		ContactKey		INT,
		ContactName		VARCHAR(100),
		ContactEmail	VARCHAR(100),
		CustomerKey		INT
	)
	INSERT INTO #Contacts (ContactKey,ContactName,ContactEmail,CustomerKey)
	SELECT ContactKey,ContactName,ContactEmail,@CustomerKey
	FROM OPENJSON(@JsonData,'$')
	WITH
	(
		ContactKey			INT	'$.ContactKey',
		ContactName			VARCHAR(100)	'$.ContactName',
		ContactEmail		VARCHAR(100)	'$.ContactEmail',
		CustomerKey			INT	'$.CustomerKey'
	)
	DECLARE @cnt INT = 0
	SET @cnt=0
	SELECT @cnt = COUNT(1) FROM #Contacts
	IF(ISNULL(@cnt,0) = 0)
	BEGIN
		SET @Output = 0
		SET @Reason = 'Data not exists'
		SET @CustomerKey = 0
		RETURN;
	END
	DELETE FROM Customer_SellContacts WHERE CustomerKey=@CustomerKey
	INSERT INTO Customer_SellContacts (ContactName,ContactEmail,CustomerKey,IsActive,IsDeleted)
	SELECT ContactName,ContactEmail,CustomerKey,1,0 FROM #Contacts
	SET @OutPut = 1
	SET @Reason = 'Success'
END
