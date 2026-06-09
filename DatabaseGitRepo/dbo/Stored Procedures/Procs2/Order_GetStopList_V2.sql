/**

DECLARE @UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"OrderKey":0}',@Status BIT = 0, @IsDebug BIT = 0, 
	@JsonOutput nvarchar(max) ='', 	@Reason VARCHAR(100)=''
EXec Order_GetStopList @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @JsonOutput, @Status, @Reason

**/
CREATE PROC [dbo].[Order_GetStopList_V2]
(
	@UserKey			INT,
	@JsonString			NVARCHAR(MAX) = '',
	@JsonOutput			NVARCHAR(MAX) = '' OUTPUT,
	@Status				BIT = 0 OUTPUT,
	@Reason				VARCHAR(500) = '' OUTPUT,
	@IsDebug			BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OrderKey INT;

	-- Extract OrderKey
	SELECT @OrderKey = JSON_VALUE(@JsonString, '$.OrderKey');

	IF @OrderKey IS NULL
	BEGIN
		SET @Status = 0;
		SET @Reason = 'OrderKey not provided';
		RETURN;
	END

	IF (@IsDebug = 1)
	BEGIN
		SELECT @OrderKey AS OrderKey;
	END

	-- Check order exists
	IF NOT EXISTS (SELECT 1 FROM OrderHeader WHERE OrderKey = @OrderKey)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Order not found';
		RETURN;
	END

	-- Build JSON output
	SET @JsonOutput =
	(
		SELECT 
			OH.OrderKey,
			JSON_QUERY(
			(
				SELECT 
					SM.StopTypeKey,
					SM.StopTypeName,
					SM.StopTypeShortcode,
					OS.StopName,
					OS.StopAddrKey,
					A.AddrName AS StopAddress,
					A.Address1 AS AddressLine1,
					A.Address2 AS AddressLine2,
					A.City,
					A.State,
					A.ZipCode,
					A.Country,
					OS.StopNumber,
					OS.LocationType,
					OS.StatusKey,
					SM.IsFoundationStop,
					SM.OrderBy,
					OS.CreateDate,
					U.UserName AS CreateUserName,
					OS.UpdateDate,
					OS.UpdateUserKey,
					OS.OrderStopKey
				FROM StopsMaster SM
				LEFT JOIN OrderStops OS 
					ON SM.StopTypeKey = OS.StopTypeKey 
					AND OS.OrderKey = OH.OrderKey
				LEFT JOIN Address A 
					ON OS.StopAddrKey = A.AddrKey
				LEFT JOIN [User] U 
					ON SM.CreateUserKey = U.UserKey
				ORDER BY SM.OrderBy
				FOR JSON PATH
			)
			) AS StopDetails
		FROM OrderHeader OH
		WHERE OH.OrderKey = @OrderKey
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	);

	-- If no stops found
	IF JSON_QUERY(@JsonOutput, '$.StopDetails') IS NULL
	BEGIN
		SET @Status = 0;
		SET @Reason = 'No stops found';
		RETURN;
	END

	SELECT @JsonOutput;

	SET @Status = 1;
	SET @Reason = 'Success';
END