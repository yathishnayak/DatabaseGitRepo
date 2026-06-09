
CREATE PROCEDURE [dbo].[Insert_CSR]
@CSRKey		INT,
--@CSRName	VARCHAR(50),
@CSRFirstName	varchar(50),
@CSRLastName	varchar(50),
@IsManager			Bit,
@CSRManagerKey		int,
@LinkedUserKey		int,
@TerminalLocationKey	int,
@OutPut		BIT OUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	INSERT INTO dbo.CSR (CsrKey,FirstName, LastName, LinkedUserKey, IsManager, CSRManagerKey,CreateDate,StatusKey,StatusDate, TerminalLocationKey)
	VALUES(@CSRKey,@CSRFirstName, @CSRLastName, @LinkedUserKey, @IsManager, @CSRManagerKey,GETDATE(),1,GETDATE(), @TerminalLocationKey)

	SET @OutPut=1;
END;
