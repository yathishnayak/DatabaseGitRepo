CREATE FUNCTION [dbo].[FnSplitstrung]
(
	@ListValue VARCHAR(2000),
	@Len SMALLINT
	
)
RETURNS 
@ParsedList TABLE
(
	[Value] VARCHAR(2000)
)	
AS 
BEGIN
	DECLARE @Param VARCHAR(500), @List INT	
	DECLARE @Count smallint
	declare @Param2 VARCHAR(200)

	set @Param2=''

	--SET  @ListValue='G:\Data\Accounting\acctshar\&Adrienne Rogers\PROPERTY SCHEDULES\p1951 The Boulders\AUDIT\p1951 Coll'
	SET @Count=0

	SET @ListValue = LTRIM(RTRIM(@ListValue))+ '\'
	SET @List = CHARINDEX('\', @ListValue, 1)

	IF REPLACE(@ListValue, '\', '') <> ''
		BEGIN
			WHILE @List > 0
			BEGIN
				SET @Count=@Count+1
				if @Count> @Len break

				SET @Param = LTRIM(RTRIM(LEFT(@ListValue, @List - 1)))
				IF @Param <> ''
				BEGIN
					--insert into #temp
					SET @Param2=@Param2+(SELECT @Param+'\') --AS valuest

					--select @Param2
				END
				SET @ListValue = RIGHT(@ListValue, LEN(@ListValue) - @List)
				SET @List = CHARINDEX('\', @ListValue, 1)
				--select @Count AS countt				
			END
		END	

		insert into @ParsedList
		select @Param2
	RETURN
END

