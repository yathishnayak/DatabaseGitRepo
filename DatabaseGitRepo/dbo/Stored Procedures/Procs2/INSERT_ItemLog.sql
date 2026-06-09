


CREATE PROCEDURE [dbo].[INSERT_ItemLog]
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
		INSERT INTO [Table_Log].dbo.[Item_log]
					 ([ItemKey],[ItemID],[Description],[ItemTypeKey],[UnitCost],[StatusKey],[CompanyKey],[PriceBasisKey],[CreateDate],[StatusDate],[CategoryKey],
					 [InvoiceItemDesc],[EDICode],[ItemTypeMappingKey],[CostGrp],[InternalCost],[itemDescrOld],[Remarks],[ItemCostGroup],[MasterItemKey],
					 [DryRunType],[PrevItemTypeKey],[Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [ItemKey],[ItemID],[Description],[ItemTypeKey],[UnitCost],[StatusKey],[CompanyKey],[PriceBasisKey],[CreateDate],[StatusDate],[CategoryKey],
					 [InvoiceItemDesc],[EDICode],[ItemTypeMappingKey],[CostGrp],[InternalCost],[itemDescrOld],[Remarks],[ItemCostGroup],[MasterItemKey],
					 [DryRunType],[PrevItemTypeKey],'INSERT',
					 GETDATE(),@User, @Type
		FROM #inserted 
	END

			
	if(@Type = 'Update' OR @Type = 'Delete')
	Begin

		INSERT INTO [Table_Logs].dbo.[Item_Log]
					([ItemKey],[ItemID],[Description],[ItemTypeKey],[UnitCost],[StatusKey],[CompanyKey],[PriceBasisKey],[CreateDate],[StatusDate],[CategoryKey],
					 [InvoiceItemDesc],[EDICode],[ItemTypeMappingKey],[CostGrp],[InternalCost],[itemDescrOld],[Remarks],[ItemCostGroup],[MasterItemKey],
					 [DryRunType],[PrevItemTypeKey],[Action],[ActionDate],[ActionUser], [ActionMode])
		SELECT  	
					 [ItemKey],[ItemID],[Description],[ItemTypeKey],[UnitCost],[StatusKey],[CompanyKey],[PriceBasisKey],[CreateDate],[StatusDate],[CategoryKey],
					 [InvoiceItemDesc],[EDICode],[ItemTypeMappingKey],[CostGrp],[InternalCost],[itemDescrOld],[Remarks],[ItemCostGroup],[MasterItemKey],
					 [DryRunType],[PrevItemTypeKey], 
					 'DELETE',GETDATE(), @User, @Type
		FROM #deleted 
	END
END
