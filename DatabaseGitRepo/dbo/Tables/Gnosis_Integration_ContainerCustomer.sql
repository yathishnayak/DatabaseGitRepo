CREATE TABLE [dbo].[Gnosis_Integration_ContainerCustomer] (
    [DataKey]         INT          NULL,
    [Field_name]      VARCHAR (50) NULL,
    [Field_value]     VARCHAR (50) NULL,
    [Field_value_str] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_ContainerCustomer_DataKey]
    ON [dbo].[Gnosis_Integration_ContainerCustomer]([DataKey] ASC);

