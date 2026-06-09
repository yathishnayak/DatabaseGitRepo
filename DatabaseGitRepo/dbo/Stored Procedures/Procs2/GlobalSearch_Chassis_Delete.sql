/*
Declare @UserKey INT = 486, @JsonString NVARCHAR(MAX) = '', @Status BIT = 0, @Reason VARCHAR(100) = '', @IsDebug BIT = 0
Set @JsonString = '[{"ChassisNo":"100049","OrderDetailKey": 0,"ActualDate":"All"}]' 
Exec GlobalSearch_Chassis @UserKey, @JsonString, @Status output, @Reason output, @IsDebug
Select @Status Status, @Reason Reason
*/

CREATE PROCEDURE [dbo].[GlobalSearch_Chassis_Delete]
(
	@UserKey	 INT = 0,
	@JSONString  NVARCHAR(MAX) = '',
	@Status      BIT = 0 OUTPUT,
	@Reason		 VARCHAR(100) = '' OUTPUT,
	@IsDebug     BIT = 0
)AS 
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @ChassisNo VARCHAR(50),
	        @OrderDetailKey INT,
			@ActualDate     VARCHAR(25);

	IF(@IsDebug = 1)
	BEGIN
		SET @Status = 0
		SET @Reason = 'In Debug mode'
	END

	SELECT @ChassisNo = ChassisNo, @OrderDetailKey  = OrderDetailKey, @ActualDate = ActualDate

	FROM OPENJSON(@JSONString, '$')
	WITH ( ChassisNo	  VARCHAR(50) 	'$.ChassisNo',
	       OrderDetailKey INT           '$.OrderDetailKey',
		   ActualDate     VARCHAR(25)   '$.ActualDate' 
	     )
	IF(ISNULL(@ChassisNo, '') = '' AND ISNULL(@OrderDetailKey,0) = 0 )
	BEGIN
		SET @Status = 0
		SET @Reason = 'filter is null'
	  RETURN
	END

	IF(ISNULL(@OrderDetailKey,0) <> 0)
	BEGIN 
	   SET @ChassisNo = null
	   SET @ActualDate  = 'All'
	END
	--IF(ISNULL(@OrderDetailKey,0) = 0)
	--BEGIN 
	--   SET @OrderDetailKey = null
	--   SET @ActualDate  = 'All'
	--END

   DECLARE @PickUpDateRange VARCHAR(50) 
 --  set  @PickUpDateRange = PickUpDateRange



	SELECT
  *
FROM (
  SELECT DISTINCT 
    OD.OrderDetailKey,
    ContainerNo,
    OH.OrderKey,
    OH.OrderNo,
    R.ChassisNo,
    OS.[Description] AS ContainerStatus,
    CustName,
    ODS.ActualPickupDate,
    DATEDIFF(DAY, ODS.ActualPickupDate, GETDATE()) AS Days,
    PickUpDateRange = CASE 
      WHEN DATEDIFF(DAY, ODS.ActualPickupDate, GETDATE()) = 0 THEN 'Today'
      WHEN DATEDIFF(DAY, ODS.ActualPickupDate, GETDATE()) BETWEEN 1 AND 7 THEN 'This Week'
      WHEN DATEDIFF(DAY, ODS.ActualPickupDate, GETDATE()) BETWEEN 8 AND 14 THEN 'Last Two Weeks'
      WHEN DATEDIFF(DAY, ODS.ActualPickupDate, GETDATE()) BETWEEN 15 AND 30 THEN 'This Month'
      WHEN DATEDIFF(DAY, ODS.ActualPickupDate, GETDATE()) BETWEEN 31 AND 60 THEN 'Last Month'
      WHEN DATEDIFF(DAY, ODS.ActualPickupDate, GETDATE()) BETWEEN 61 AND 180 THEN 'Last 6 Months'
      WHEN YEAR(ODS.ActualPickupDate) = YEAR(GETDATE()) THEN 'This Year'
      ELSE 'All' 
    END,
    InvoiceInfo = (
      SELECT DISTINCT ih.InvoiceKey, InvoiceNo
      FROM InvoiceHeader IH
      INNER JOIN InvoiceContainers IC WITH(NOLOCK) 
        ON IC.InvoiceKey = IH.InvoiceKey
      WHERE IH.OrderKey = OH.OrderKey 
        AND OD.OrderDetailKey = IC.OrderDetailsKey
      FOR JSON PATH
    )
  FROM [Routes] R 
  INNER JOIN OrderDetail OD WITH(NOLOCK) ON OD.OrderDetailKey = R.OrderDetailKey
  INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = OD.OrderKey
  LEFT JOIN OrderDetailStatus OS WITH(NOLOCK) ON OS.Status = OD.Status
  LEFT JOIN OrderDetailStops ODS WITH(NOLOCK) ON ODS.OrderDetailKey = OD.OrderDetailKey
  LEFT JOIN Customer C WITH(NOLOCK) ON C.CustKey = OH.CustKey
) AS Sub
WHERE 
  ( CASE WHEN @ChassisNo = '' THEN '' ELSE Sub.ChassisNo END  LIKE '%' + @ChassisNo + '%')
    AND (CASE WHEN @OrderDetailKey = 0 THEN 0 ELSE OrderDetailKey END  = @OrderDetailKey)
    AND (@ActualDate IS NULL OR PickUpDateRange = @ActualDate)
-- FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END


--SELECT * FROM ROUTES WHERE ChassisNo = 'hdmz412932'

--SELECT * FROM OrderDetailStops WHERE OrderDetailKey =  168685      177963
--SELECT * FROM StopsMaster

--SELECT ActualPickupDate, * FROM orderdetail 

--SELECT * FROM OrderDetailStops WHERE ActualPickupDate is not null
--SELECT * FROM OrderDetailStops WHERE ActualDeliveryDate is not null
