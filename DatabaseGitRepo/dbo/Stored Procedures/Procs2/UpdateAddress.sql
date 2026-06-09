/*

	Declare @AddrKey INT = 1, @Address1 VARCHAR(255) = 'Chelsea', @Address2 VARCHAR(255) = 'JCT', @City VARCHAR(255) = 'Chelsea', @State VARCHAR(255) 'MA', @ZipCode VARCHAR(50) = '02150', @Country CHAR(3) = 'USA', @IsValid BIT = 0
	Exec UpdateAddress @AddrKey, @Address1, @Address1, @City, @State, @ZipCode, @Country, @IsValid

*/

CREATE PROCEDURE [dbo].[UpdateAddress]
    @AddrKey INT,
	@Address1 VARCHAR(255),
    @Address2 VARCHAR(255),
    @City VARCHAR(255),
    @State VARCHAR(255),
    @ZipCode VARCHAR(50),
    @Country CHAR(3),
	--@F_Address NVARCHAR(MAX) = '614 Terminal Way, Abc Xyz, San Pedro, CA 90731-7453, USA',
	@IsValid BIT
AS
BEGIN
	Begin Try
		Begin Transaction
		SET NOCOUNT ON;
		DECLARE
			@Status BIT = 0,
			@Reason VARCHAR(MAX) = ''

		IF(@IsValid = 0)
		BEGIN 
			UPDATE Address
			SET IsValid = 0
			WHERE AddrKey = @AddrKey
			SET @Reason = 'IsValid = 0 for ' + cast(@AddrKey as  varchar(500))
			Select @Status Status, @Reason Reason
			Commit Transaction
			RETURN
		END

		-- Check if the adress exists in ValidAddress
		IF EXISTS (SELECT 1 FROM ValidAddress 
		           WHERE Address1 = @Address1 
		             AND Address2 = @Address2 
		             AND City = @City 
		             AND State = @State 
		             AND ZipCode = @ZipCode 
		             AND Country = @Country)
		BEGIN
		        -- If it exists, update the ValidAddressKey in the [Address] table
		        UPDATE [Address]
		        SET ValidAddressKey = (SELECT ValidAddressKey FROM ValidAddress 
		                               WHERE Address1 = @Address1 
		                                 AND Address2 = @Address2 
		                                 AND City = @City 
		                                 AND State = @State 
		                                 AND ZipCode = @ZipCode 
		                                 AND Country = @Country),
					IsValid = 1
		        WHERE AddrKey = @AddrKey;

				SET @Status = 1;
		        SET @Reason = 'Address updated successfully.';
		END
		ELSE
		BEGIN
		        -- If it does not exist, insert into ValidAddress table
		        INSERT INTO ValidAddress (Address1, Address2, City, State, ZipCode, Country)
		        VALUES (@Address1, @Address2, @City, @State, @ZipCode, @Country);

		        -- Update the ValidAddressKey in the [Address] table after insertion
		        UPDATE [Address]
		        SET ValidAddressKey = SCOPE_IDENTITY(),-- Get the last inserted ID from ValidAddress
				IsValid = 1
		        WHERE AddrKey = @AddrKey;
				
				SET @Status = 1;
		        SET @Reason = 'New valid address added successfully.';
		END

		Select @Status Status , @Reason Reason --for json path
		Commit Transaction;
		End Try
		Begin Catch 
			print @@ERROR
			print ERROR_NUMBER()  
			print ERROR_SEVERITY() 
			print ERROR_STATE() 
			print ERROR_PROCEDURE()  
			print ERROR_LINE() 
			print ERROR_MESSAGE()
		Rollback Transaction
	End Catch
END;
