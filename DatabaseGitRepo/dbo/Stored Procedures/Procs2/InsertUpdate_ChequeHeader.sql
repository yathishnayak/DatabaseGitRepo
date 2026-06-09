CREATE Procedure [dbo].[InsertUpdate_ChequeHeader]
(
	@CustKey			Int,
	@ChequeRef			Varchar(50),
	@ChequeDate			datetime,
	@ChequeAmount		decimal(18,4),
	@CreateUser			Varchar(50),
	@OutPut				BIT=0 OUTPUT,  -- @Result 1 - sucess, 0 - failure
	@ChequeKey			int	OUTPUT
)
as
BEGIN
  SET NOCOUNT ON;
  SET FMTONLY OFF;

  	IF( @ChequeRef = '' )
	BEGIN
		SET @output = 0
		RETURN;
	END;

	If @ChequeKey = 0
	BEGIN
		Insert into Cheque_Header (CustKey, ChequeRef, ChequeDate, ChequeAmount, Balance, 
					CreateUser, CreateDate)
		SELECT @CustKey, @ChequeRef, @ChequeDate, @ChequeAmount, @ChequeAmount, @CreateUser, Getdate()
		select @ChequeKey = scope_identity()
		SET @OutPut=1
		return
	END
	Else
	BEGIN
		Update Cheque_Header
		Set CustKey=@CustKey, 
			ChequeRef=@ChequeRef, 
			ChequeDate=@ChequeDate,  
			ChequeAmount=@ChequeAmount, 
			UpdateUser=@CreateUser, 
			UpdateDate=Getdate()
		where ChequeKey=@ChequeKey

		SET @OutPut=1
		return
	END
		

END


