/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{
    "FileName": "ACC_109.xlsx",
    "SheetData": "{\"Sheet1\":[{\"RecordSL\":1,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"B\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"},{\"RecordSL\":2,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"COI\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"},{\"RecordSL\":3,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"Out of State\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"},{\"RecordSL\":4,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"Out of State\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"},{\"RecordSL\":5,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"Past Scale\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"},{\"RecordSL\":6,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"Past Scale\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"},{\"RecordSL\":7,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"Past Scale\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"},{\"RecordSL\":8,\"Line Item\":\"\",\"Market\":\"Long Beach\",\"Terminal\":\"LA/LB\",\"Truck Type\":\"\",\"Yard Port\":\"\",\"Group\":\"Valley\",\"Fix Vs NonFix\":\"\",\"Per\":\"\",\"UnitCost\":\"\",\"Effective Date\":\"12/30/1899 12:00:00 AM\",\"Effective Date From\":\"\",\"FreePer\":\"\",\"Split Percent\":\"\",\"Record Remarks\":\"Line Item Cannot be blank;Group Cannot be blank;Fixed Vs Non-Fixed column Cannot be blank;\"}]}"
}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [COSTACC_InsertFileProcessInfo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[COSTACC_InsertFileProcessInfo_V2] -- COSTACC_InsertFileProcessInfo 'ert','',''
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	
	
	DECLARE 
		@FileName			VARCHAR(100),
		@JSOnData			NVARCHAR(MAX)

	SELECT 
		@FileName	= FileName,
		@JSOnData	= JSOnData

	FROM OPENJSON(@JSONString)
	WITH
	(
		FileName		VARCHAR(100)		'$.FileName',
		JSOnData		NVARCHAR(MAX)		'$.SheetData'  
	)

	SET			@Status = 1 
	SET			@Reason  = 'Record Saved Successfully'
	DECLARE				@ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '
	DECLARE			@FileProcessKey INT = 0

	If(ISNULL(@FileName,'') = '')
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '101'
		END
	ELSE IF (@UserKey = 0)
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '103'
		END

	IF(@Status = 1)
		BEGIN
			INSERT INTO		COSTACC_FileProcessInfo
							(FileName,DateUploaded,FileUploadStatus,FileProcessStatus,IsEmailSent,UserKey)
			SELECT			@FileName,GETDATE(),0,0,0,@UserKey

			SET				@FileProcessKey = @@IDENTITY

		EXEC COSTACC_InsertFileProcessData 
		@FileProcessKey = @FileProcessKey,@JSOnData = @JSOnData, @Status=@Status OUTPUT
		END

	SELECT @Status AS Status, @Reason AS Reason, @FileProcessKey AS FileProcessKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END