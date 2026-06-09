CREATE TABLE [dbo].[Int_IntegrationUser] (
    [IntSource]        VARCHAR (50)   NOT NULL,
    [IntUserName]      VARCHAR (50)   NOT NULL,
    [intSecret]        NVARCHAR (500) NOT NULL,
    [IntToken]         NVARCHAR (MAX) NULL,
    [intTokenDateFrom] DATETIME       NULL,
    [IntTokenDateTo]   DATETIME       NULL,
    CONSTRAINT [PK_IntegrationUser] PRIMARY KEY CLUSTERED ([IntSource] ASC, [IntUserName] ASC)
);

