/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"CustAddress":{"Address1":"ABC","Address2":"-","AddrName":"Test321","City":"Albany","CityKey":36333,"State":"NY","Zip":"12234","Phone":"1","Phone2":null,"Fax":null,"Email":null,"Email2":null,"Country":"USA","Website":null,"AddrKey":0,"AddressType":"Pickup","CustKey":3241,"OrderTypeKey":0,"LegKey":0,"LoationType":null,"UserKey":0},"IsConsignee":true,"CustName":"1UP Cargo (JCB-IPG)"}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@IsDebug  BIT = 0,
	@Status BIT=0,
	@Reason VARCHAR(100)=''
    EXec [CustomerAddress_InsertUpdate] @UserKey,@JSONString,@JSONOutput OUTPUT,@IsDebug,@Status OUTPUT,@Reason OUTPUT
    Select @Status, @Reason, @JSONOutput  AS JSONOutput

*/

/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"CustAddress":{"CustKey":0,"AddressType":"Pickup","AddrName":"test","Address1":"angd","Zip":"12234","City":"Albany","State":"NY","Country":"USA","CityKey":36333,"Phone":1,"Address2":"-"},"IsConsignee":true,"CustName":"1836 TOTAL COMMERCE LLC (JCT)"}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@IsDebug  BIT = 0,
	@Status BIT=0,
	@Reason VARCHAR(100)=''
    EXec [CustomerAddress_InsertUpdate] @UserKey,@JSONString,@JSONOutput OUTPUT,@IsDebug,@Status OUTPUT,@Reason OUTPUT
    Select @Status, @Reason, @JSONOutput  AS JSONOutput

*/
CREATE proc [dbo].[CustomerAddress_InsertUpdate]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@IsDebug	  BIT = 0,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
as
BEGIN
    SET NOCOUNT ON
    SET FMTONLY OFF

    IF(ISNULL(@JSONString,'') = '')
	BEGIN
        SET @Status = 0
        SET @Reason = 'Customer Address Data not received'
        return;
    END

	DECLARE @CustomerKey INT = 0, @CustAddressData NVARCHAR(MAX), @AddressType NVARCHAR(200),
			@ReturnAddrKey NVARCHAR(100) = '', @AddressKey INT=0,
			@AddrStatus BIT,@AddrReason VARCHAR(1000);

	SELECT @CustAddressData=CustAddressData --@AddressKey=AddressKey, @AddressType = AddressType
	FROM OPENJSON(@JsonString, '$')
	WITH(
			CustAddressData		NVARCHAR(MAX)		'$.CustAddress' AS JSON
	)

	IF(@IsDebug =1)
	BEGIN
		SELECT 'CustAddress', @CustAddressData
	END

	SELECT @CustomerKey=CustomerKey, @AddressType=AddressType
	FROM OPENJSON(@CustAddressData, '$')
	WITH(
			CustomerKey			INT					'$.CustKey',
			AddressType			NVARCHAR(100)		'$.AddressType'
	)

	BEGIN TRAN
		BEGIN TRY

			--EXEC Address_InsertUpdate @UserKey, @CustAddressData, @ReturnAddrKey OUTPUT, 0, ''
			EXEC Address_InsertUpdate
				@UserKey = @UserKey,
				@JSONString = @CustAddressData,
				@JSONOutput = @ReturnAddrKey OUTPUT,
				@Status = @AddrStatus OUTPUT,
				@Reason = @AddrReason OUTPUT;
				--print 'AddressStatus'
				--print @AddrStatus
			IF(@AddrStatus = 0)
			BEGIN
			    SET @Status = 0
			    SET @Reason = @AddrReason
			    ROLLBACK TRAN
			    RETURN
			END
			--print '@ReturnAddrKey' print @ReturnAddrKey
			Select @AddressKey = AddressKey
			from OpenJson(@ReturnAddrKey,'$')
			With(
				AddressKey INT '$.AddrKey' 
			)
			--print '@AddressKey' print @AddressKey
			IF(SELECT Count(1) FROM CustomerAddress WHERE AddrKey = @AddressKey AND CustKey = @CustomerKey)>0
			BEGIN
				--update
				Update CustomerAddress SET AddrType = @AddressType
				WHERE AddrKey = @AddressKey AND CustKey = @CustomerKey
			END
			ELSE
			BEGIN
				--insert
				INSERT INTO CustomerAddress
					(CustKey, AddrKey, AddrType)
				Select
					@CustomerKey, @AddressKey, @AddressType
			END

			COMMIT TRAN

			SELECT (
				SELECT @AddressKey AS AddressKey
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) AS JSONOutput
			SET @Status = 1
			SET @Reason = 'Customer Address Saved Successfully'
	END TRY
	BEGIN CATCH  
		SET @Status=0;    
		SET @Reason='Failed to save data';    
		ROLLBACK TRAN;
	END CATCH
END