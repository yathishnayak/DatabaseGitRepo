CREATE PROCEDURE [dbo].[Insert_Rate]
/*
dbo.fn_insert_rate
*/
@CustomerKey	INT,
@ItemKey		INT,
@UnitPrice		DECIMAL(18,5),
@CreateUserKey INT,
@OriginalFileType VARCHAR(50),
@FileSizeinMB	INT,
@OrderNo		VARCHAR(20),
@RateKey		INT OUTPUT
AS
BEGIN	
	 INSERT INTO dbo.ratesheet(CustomerKey, Itemkey, UnitPrice,CreateUserKey,CreateDate) 
	 VALUES (@CustomerKeY,	@ItemKey,	@UnitPrice,	@CreateUserKey,GETDATE())  

	SET @RateKey= ( SELECT SCOPE_IDENTITY())
END

/****** Object:  StoredProcedure [dbo].[INSERT_ScheduleDetail]    Script Date: 8/9/2020 8:27:58 AM ******/
SET ANSI_NULLS ON
