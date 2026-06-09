CREATE PROCEDURE [dbo].[Insert_CustomerBaseRate]
@Brokerkey			INT,
@Customerkey		INT,
@Location			VARCHAR(50),
@BaseRate			DECIMAL(18,2),
@Email				VARCHAR(50),
@CreateUserKey		INT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	INSERT INTO [dbo].[CustomerBaseRateNew]
           (
		    [Custkey]
           ,[BrokerKey]
           ,[Location]
           ,[BaseRate]
           ,[Email]
           ,[EffectiveDate]
           ,[IsActive]
           ,[CreateDate]
           ,[CreateUserkey]
		   )
     VALUES (@Customerkey,@Brokerkey,@Location,@BaseRate,@Email,GETDATE(),1,GETDATE(),@CreateUserKey)

			
END
