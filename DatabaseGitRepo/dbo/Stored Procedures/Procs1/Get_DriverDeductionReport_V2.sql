/*
	DECLARE @UserKey INT = 1144, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 0
	SET @JSONString ='{"WeekNumber":18, "DriverKey":1287,"ItemKey":0,"VoucherNo": ""}'
 
	EXEC [Get_DriverDeductionReport_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	SELECT @Status Status, @Reason Reason 
*/


CREATE PROCEDURE [dbo].[Get_DriverDeductionReport_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @WeekNumber INT=0,
			@DriverKey	INT=0,	
			@ItemKey    INT=0,
			@VoucherNo	VARCHAR(50)='';

			IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	SELECT @WeekNumber = WeekNumber, @DriverKey = DriverKey, @ItemKey = ItemKey, @VoucherNo = VoucherNo
	from OPENJSON(@JSONString,'$')
	with (
			WeekNumber		 INT				'$.WeekNumber',
			DriverKey		 INT				'$.DriverKey',
			ItemKey			 INT				'$.ItemKey',
			VoucherNo		 VARCHAR(50)	    '$.VoucherNo'
		 )


	select H.WeekNumber, H.DriverKey, A.DriverID, a.OrgName, A.FirstName, A.LastName, A.City, A.OrgCity, A.OrgState, A.OrgCountry, A.OrgZipCode,
		D.ItemKey, I.ItemID, I.Description, D.UnitCost, D.Qty, D.ExtCost, H.DriverVoucherNumber, h.DriverVoucherdate, H.DriverVoucherAmount
		from DriverVoucherDeduction H  WITH (NOLOCK)
		inner join DriverVoucherDeductionDetail D  WITH (NOLOCK) on H.DriverVoucherKey = D.DriverVoucherKey
		inner join VDriverAll A  WITH (NOLOCK) on H.DriverKey = A.DriverKey
		inner join Item I  WITH (NOLOCK) on D.ItemKey = I.ItemKey
	where
		(@WeekNumber = 0 OR H.WeekNumber = @WeekNumber) AND
		(@DriverKey = 0  OR H.DriverKey = @DriverKey) And
		(@ItemKey = 0 OR D.ItemKey = @ItemKey ) AND
		--(@VoucherNo = '' OR convert(int,replace(H.DriverVoucherNumber,'D-','')) = @VoucherNo)
		(ISNULL(@VoucherNo,'') = ''  OR H.DriverVoucherNumber=@VoucherNo)
		FOR JSON PATH;

			SET @Status = 1
			SET @Reason = 'Success'
END