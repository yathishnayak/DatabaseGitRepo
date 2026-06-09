create Proc ValidateContainerNoExists
(
	@ContainerNo	varchar(20),
	@Output			Bit = 0 Output
)
as
BEGIN
	set nocount on
	SET FMTONLY OFF
	SET @Output = 0
	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM ORDERDETAIL WHERE CONTAINERNO = @CONTAINERNO
	IF(@CNT > 0)
	BEGIN
		SET @Output = 1
	END
END
