CREATE TABLE [dbo].[Bulk_Orders] (
    [Key]           INT            NOT NULL,
    [Name]          NVARCHAR (100) NULL,
    [IsDropDown]    BIT            CONSTRAINT [DF__Bulk_Orde__IsDro__45DFEDE8] DEFAULT ((0)) NULL,
    [IsTextBox]     BIT            CONSTRAINT [DF__Bulk_Orde__IsTex__46D41221] DEFAULT ((0)) NULL,
    [IsRadioButton] BIT            CONSTRAINT [DF__Bulk_Orde__IsRad__47C8365A] DEFAULT ((0)) NULL,
    [IsCheckBox]    BIT            CONSTRAINT [DF__Bulk_Orde__IsChe__48BC5A93] DEFAULT ((0)) NULL,
    [IsContainer]   BIT            NULL,
    [IsOrder]       BIT            NULL,
    [IsScheduler]   BIT            NULL,
    [pkEY]          INT            IDENTITY (1, 1) NOT NULL
);

