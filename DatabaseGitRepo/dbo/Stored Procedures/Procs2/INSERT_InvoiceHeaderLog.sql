


CREATE PROCEDURE [dbo].[INSERT_InvoiceHeaderLog]
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
		INSERT INTO [Table_Log].dbo.[InvoiceHeader_log]
					 ([InvoiceKey],[InvoiceNo],[InvoiceDate],[CustKey],[BillToAddrKey],[InvoiceAmount],[DueDate],[InvoiceType],[CompanyKey],[StatusKey],
					 [CreateUserKey],[IsInvoiceApproved],[IsPaymentReceived],[CreateDate],[UpdateUserKey],[UpdateDate],[InvoiceApprovedUserKey],[InvoiceApprovedDate],
					 [OrderKey],[CustomerNote],[InternalNote],[IsPrinted],[PrintedUserKey],[PrintedDate],[PaymentRecdUserKey],[PaymentRecdDate],[IsRevised],
					 [RevisionDate],[RevisionUserKey],[BrokerRefNo],[InvoiceCompanyKey],[DestinationAddrKey],[ReasoncodeKey],[CustApproved],[AprovedReasonCodeKey],
					 [Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [InvoiceKey],[InvoiceNo],[InvoiceDate],[CustKey],[BillToAddrKey],[InvoiceAmount],[DueDate],[InvoiceType],[CompanyKey],[StatusKey],
					 [CreateUserKey],[IsInvoiceApproved],[IsPaymentReceived],[CreateDate],[UpdateUserKey],[UpdateDate],[InvoiceApprovedUserKey],[InvoiceApprovedDate],
					 [OrderKey],[CustomerNote],[InternalNote],[IsPrinted],[PrintedUserKey],[PrintedDate],[PaymentRecdUserKey],[PaymentRecdDate],[IsRevised],
					 [RevisionDate],[RevisionUserKey],[BrokerRefNo],[InvoiceCompanyKey],[DestinationAddrKey],[ReasoncodeKey],[CustApproved],[AprovedReasonCodeKey],'INSERT',
					 GETDATE(),isnull(UpdateUserKey, CreateUserKey), @Type
		FROM #inserted 
	END

			
	if(@Type = 'Update' OR @Type = 'Delete')
	Begin
		Declare @DeleteUserKey	int = 0
		if(@Type='Delete')
		Begin
			select @DeleteUserKey = IH.UpdateUserKey
			from #Deleted D
			inner join InvoiceHeader_Deleted IH WITH(NOLOCK) on D.InvoiceKey = IH.InvoiceKey
		End

		INSERT INTO [Table_Logs].dbo.[InvoiceHeader_Log]
					([InvoiceKey],[InvoiceNo],[InvoiceDate],[CustKey],[BillToAddrKey],[InvoiceAmount],[DueDate],[InvoiceType],[CompanyKey],[StatusKey],
					 [CreateUserKey],[IsInvoiceApproved],[IsPaymentReceived],[CreateDate],[UpdateUserKey],[UpdateDate],[InvoiceApprovedUserKey],[InvoiceApprovedDate],
					 [OrderKey],[CustomerNote],[InternalNote],[IsPrinted],[PrintedUserKey],[PrintedDate],[PaymentRecdUserKey],[PaymentRecdDate],[IsRevised],
					 [RevisionDate],[RevisionUserKey],[BrokerRefNo],[InvoiceCompanyKey],[DestinationAddrKey],[ReasoncodeKey],[CustApproved],[AprovedReasonCodeKey], 
					 [Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [InvoiceKey],[InvoiceNo],[InvoiceDate],[CustKey],[BillToAddrKey],[InvoiceAmount],[DueDate],[InvoiceType],[CompanyKey],[StatusKey],
					 [CreateUserKey],[IsInvoiceApproved],[IsPaymentReceived],[CreateDate],[UpdateUserKey],[UpdateDate],[InvoiceApprovedUserKey],[InvoiceApprovedDate],
					 [OrderKey],[CustomerNote],[InternalNote],[IsPrinted],[PrintedUserKey],[PrintedDate],[PaymentRecdUserKey],[PaymentRecdDate],[IsRevised],
					 [RevisionDate],[RevisionUserKey],[BrokerRefNo],[InvoiceCompanyKey],[DestinationAddrKey],[ReasoncodeKey],[CustApproved],[AprovedReasonCodeKey], 
					 'DELETE',GETDATE(), Case when @Type = 'Delete' then @DeleteUserKey else  isnull(UpdateUserKey, CreateUserKey) end, @Type
		FROM #deleted 
	END
END

