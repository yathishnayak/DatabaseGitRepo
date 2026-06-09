CREATE TABLE [dbo].[LocationData] (
    [CityKey]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Country]          VARCHAR (50)  NOT NULL,
    [State]            VARCHAR (100) NOT NULL,
    [City]             VARCHAR (100) NOT NULL,
    [ZipCode]          VARCHAR (100) NOT NULL,
    [StatusKey]        SMALLINT      CONSTRAINT [DF_City_StatusKey] DEFAULT ((1)) NOT NULL,
    [CreateDate]       DATETIME      NOT NULL,
    [IsActive]         BIT           NULL,
    [IsDelete]         BIT           NULL,
    [PriceGroupingKey] INT           NULL,
    CONSTRAINT [PK_City1_1] PRIMARY KEY CLUSTERED ([CityKey] ASC),
    CONSTRAINT [FK_City1_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_LocationData_City_ZipCode_6F77E]
    ON [dbo].[LocationData]([City] ASC, [ZipCode] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_LocationData_ZipCode]
    ON [dbo].[LocationData]([ZipCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_LocationData_State]
    ON [dbo].[LocationData]([State] ASC)
    INCLUDE([Country], [City], [ZipCode]);

