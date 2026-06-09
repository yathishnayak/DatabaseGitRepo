/*
DECLARE @CustKey	       int=16,
	@OrderTypeKey       int=1,
    @UserKey			int=486,
	@ContainerNo		varchar(50) = ''
	exec ContainerNo_AutoGen @CustKey ,@OrderTypeKey ,@UserKey, @ContainerNo OUTPUT

	select @ContainerNo
	*/
CREATE PROCEDURE [dbo].[ContainerNo_AutoGen] --ContainerNo_AutoGen 16 , 2 ,486
(
    @CustKey	       int,
	@OrderTypeKey       int,
    @UserKey			int,
	@ContainerNo		varchar(50) = '' output
	--@Output				Bit = 0 output
)
AS
 BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	declare 
	        @CustName VARCHAR(50),
			@CustId VARCHAR(50),
			@OrderType CHAR(1), 
			@LastValue INT,
			@count INt
	if(isnull(@CustKey,0) = 0 OR isnull(@OrderTypeKey,0) = 0)
	begin
		Set @ContainerNo = 'ERROR'
		return;
	end
	SELECT @OrderType=OrderType FROM OrderType WHERE OrderTypeKey=@OrderTypeKey
	SELECT @CustId=CustId FROM Customer WHERE CustKey=@CustKey
	SELECT @CustName=CustName FROM Customer WHERE CustKey=@CustKey

	insert into ContainerNum_AutoGen (ContainerNo,CustKey,OrderTypeKey,UserKey,GenDateTime)
	values(@ContainerNo,@CustKey,@OrderTypeKey,@UserKey,GETDATE())

	SET @LastValue=Scope_Identity();
	SET @count = (SELECT COUNT(1) FROM ContainerNum_AutoGen WHERE YEAR(GETDATE()) = (SELECT TOP 1 YEAR(GenDateTime) FROM ContainerNum_AutoGen ORDER BY GenDateTime DESC) )
	if(@count=0)
	BEGIN
		SET @LastValue=1
	END
	print @OrderTypeKey
	IF(@OrderTypeKey=1)
	BEGIN
		SET @ContainerNo=(SELECT 'IMPT'+RIGHT(YEAR(GETDATE()),2)+RIGHT('0000' + CONVERT(varchar(5),@LastValue),5))
	END
	else IF(@OrderTypeKey=2)
	BEGIN
		SET @ContainerNo=(SELECT 'UUUU'+RIGHT(YEAR(GETDATE()),2)+RIGHT('0000' + CONVERT(varchar(5),@LastValue),5))
	END
	else IF(@OrderTypeKey=3)
	BEGIN
		SET @ContainerNo=(SELECT 'JFTL'+RIGHT(YEAR(GETDATE()),2)+RIGHT('0000' + CONVERT(varchar(5),@LastValue),5))
	END
	else IF(@OrderTypeKey=4)
	BEGIN
		SET @ContainerNo=(SELECT 'EMPT'+RIGHT(YEAR(GETDATE()),2)+RIGHT('0000' + CONVERT(varchar(5),@LastValue),5))
	END
	else IF(@OrderTypeKey=5)
	BEGIN
		SET @ContainerNo=(SELECT 'BOBT'+RIGHT(YEAR(GETDATE()),2)+RIGHT('0000' + CONVERT(varchar(5),@LastValue),5))
	END
	ELSE
	BEGIN
		SET @ContainerNo=(SELECT LEFT(@CustId+@CustName,3) + LEFT(@OrderType,1)+RIGHT(YEAR(GETDATE()),2)+RIGHT('0000' + CONVERT(varchar(5),@LastValue),5))
	END 

	UPDATE ContainerNum_AutoGen
	SET Containerno=@ContainerNo
	WHERE AutoGenKey=@LastValue
	--SET @ContainerNo=(SELECT LEFT(@CustId+@CustName,3) + LEFT(@OrderType,1)+RIGHT(YEAR(GETDATE()),2)+RIGHT('0000' + CONVERT(varchar(5),@LastValue),5))

	
	--select @ContainerNo

END
