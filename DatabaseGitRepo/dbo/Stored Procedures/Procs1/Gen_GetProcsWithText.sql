
/*
DECLARE @Text varchar(100)= 'EffectiveDate'
--ExpiryDate
exec [Gen_GetProcsWithText] @Text
*/

CREATE proc [dbo].[Gen_GetProcsWithText] -- 
(
@Text varchar(100)= ''
)
As
BEGIN
	SELECT		OBJECT_NAME(id)  
	FROM		SYSCOMMENTS  
	WHERE		[text] LIKE '%'+@Text+'%'  
	AND			OBJECTPROPERTY(id, 'IsProcedure') = 1  
	GROUP BY	OBJECT_NAME(id)
END
