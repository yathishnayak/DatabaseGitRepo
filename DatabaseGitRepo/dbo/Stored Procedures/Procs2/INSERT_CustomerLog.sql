


CREATE PROCEDURE [dbo].[INSERT_CustomerLog]
(
	@Type	varchar(10) = 'Update'
)
AS
BEGIN	
	DECLARE @User		VARCHAR(50)
	SET @User=( SELECT SYSTEM_USER )	
--***************Insert Only******************	
	if(@Type = 'Update' OR @Type = 'Insert')
	Begin
		INSERT INTO [Table_Log].dbo.[Customer_log]
					 ([CustKey],[CustID],[CustName],[AddrKey],[CreateDate],[CustomerGroup],[StatusKey],[StatusDate],[CreditCheck],[CreditLimit],[CreditStatus],
					 [Ach_Required],[PaymentTermsKey],[CompanyKey],[BillToAddrKey],[IsFactored],[Notes],[IsActive],[IsDelete],[CSRKey],[CSRManagerKey],
					 [SalesPersonKey],[MarketLocationKey],[CustomerSegmentKey],[CustomerNotes],[CustomerCompanyKey],[RateTypeKey],[IncludeFSF],[RatePercent],
					 [IsMaster],[MasterCustKey],[IsKeyAccount],[ExpiryMonths],[Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [CustKey],[CustID],[CustName],[AddrKey],[CreateDate],[CustomerGroup],[StatusKey],[StatusDate],[CreditCheck],[CreditLimit],[CreditStatus],
					 [Ach_Required],[PaymentTermsKey],[CompanyKey],[BillToAddrKey],[IsFactored],[Notes],[IsActive],[IsDelete],[CSRKey],[CSRManagerKey],
					 [SalesPersonKey],[MarketLocationKey],[CustomerSegmentKey],[CustomerNotes],[CustomerCompanyKey],[RateTypeKey],[IncludeFSF],[RatePercent],
					 [IsMaster],[MasterCustKey],[IsKeyAccount],[ExpiryMonths],'INSERT',
					 GETDATE(),@User, @Type
		FROM #inserted 
	END

			
	if(@Type = 'Update' OR @Type = 'Delete')
	Begin

		INSERT INTO [Table_Logs].dbo.[Customer_Log]
					([CustKey],[CustID],[CustName],[AddrKey],[CreateDate],[CustomerGroup],[StatusKey],[StatusDate],[CreditCheck],[CreditLimit],[CreditStatus],
					 [Ach_Required],[PaymentTermsKey],[CompanyKey],[BillToAddrKey],[IsFactored],[Notes],[IsActive],[IsDelete],[CSRKey],[CSRManagerKey],
					 [SalesPersonKey],[MarketLocationKey],[CustomerSegmentKey],[CustomerNotes],[CustomerCompanyKey],[RateTypeKey],[IncludeFSF],[RatePercent],
					 [IsMaster],[MasterCustKey],[IsKeyAccount],[ExpiryMonths],[Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [CustKey],[CustID],[CustName],[AddrKey],[CreateDate],[CustomerGroup],[StatusKey],[StatusDate],[CreditCheck],[CreditLimit],[CreditStatus],
					 [Ach_Required],[PaymentTermsKey],[CompanyKey],[BillToAddrKey],[IsFactored],[Notes],[IsActive],[IsDelete],[CSRKey],[CSRManagerKey],
					 [SalesPersonKey],[MarketLocationKey],[CustomerSegmentKey],[CustomerNotes],[CustomerCompanyKey],[RateTypeKey],[IncludeFSF],[RatePercent],
					 [IsMaster],[MasterCustKey],[IsKeyAccount],[ExpiryMonths], 
					 'DELETE',GETDATE(), @User, @Type
		FROM #deleted 
	END
END
