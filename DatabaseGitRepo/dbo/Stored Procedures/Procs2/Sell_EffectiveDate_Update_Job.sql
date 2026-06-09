CREATE PROCEDURE [dbo].[Sell_EffectiveDate_Update_Job]
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	UPDATE A SET EffectiveDate=SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4)
	--SELECT SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4),EffectiveDate, *
	FROM SELL_NAC_Accessorial_FinalDataOutput a
	WHERE ISDATE(EffectiveDate) = 0 AND ISDATE(SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4))=1

	UPDATE A SET ExpiryDate=SUBSTRING(ExpiryDate,4,2) + '/' +LEFT(ExpiryDate,2) + '/' +  RIGHT(ExpiryDate,4)
	--SELECT SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4),EffectiveDate, *
	FROM SELL_NAC_Accessorial_FinalDataOutput a
	WHERE ISDATE(ExpiryDate) = 0 AND ISDATE(SUBSTRING(ExpiryDate,4,2) + '/' +LEFT(ExpiryDate,2) + '/' +  RIGHT(ExpiryDate,4))=1

	UPDATE A SET EffectiveDate=SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4),
	ExpiryDate=SUBSTRING(ExpiryDate,4,2) + '/' +LEFT(ExpiryDate,2) + '/' +  RIGHT(ExpiryDate,4)
	--SELECT SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4),EffectiveDate, *
	FROM SELL_NAC_Draybase_FinalDataOutput a
	WHERE ISDATE(EffectiveDate) = 0 AND ISDATE(SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4))=1

	UPDATE A SET ExpiryDate=SUBSTRING(ExpiryDate,4,2) + '/' +LEFT(ExpiryDate,2) + '/' +  RIGHT(ExpiryDate,4)
	--SELECT SUBSTRING(EffectiveDate,4,2) + '/' +LEFT(EffectiveDate,2) + '/' +  RIGHT(EffectiveDate,4),EffectiveDate, *
	FROM SELL_NAC_Draybase_FinalDataOutput a
	WHERE ISDATE(ExpiryDate) = 0 AND ISDATE(SUBSTRING(ExpiryDate,4,2) + '/' +LEFT(ExpiryDate,2) + '/' +  RIGHT(ExpiryDate,4))=1
END