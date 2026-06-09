
CREATE PROCEDURE [dbo].[Update_CustomerSegmentBasePercent]
(
	@CustomerSegmentKey int,
	@BasePercent numeric (18,2),
	@UserKey int,
	@Output bit output,
	@Remarks varchar(100) output
)
AS
BEGIN
	BEGIN  TRY
		UPDATE CustomerSegments
		SET BasePercent = @BasePercent, UpdateUser=@UserKey
		WHERE CustomerSegmentKey= @CustomerSegmentKey
		SET @Output=1
		SET @Remarks='SUCCESS'
	END TRY
	BEGIN CATCH
		SET @Output=0
		SET @Remarks='Error in data save'
	END CATCH
END
