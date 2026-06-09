CREATE TABLE [dbo].[ContainerTypesLink] (
    [OrderDetailKey]   INT      NOT NULL,
    [CommentKey]       INT      NOT NULL,
    [ContainerTypeKey] SMALLINT NOT NULL,
    [IsSelected]       BIT      CONSTRAINT [DF__Container__IsSel__2B9F624A] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ContainerTypesLink] PRIMARY KEY CLUSTERED ([OrderDetailKey] ASC, [CommentKey] ASC, [ContainerTypeKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_ContainerTypesLink]
    ON [dbo].[ContainerTypesLink]([OrderDetailKey] ASC, [ContainerTypeKey] ASC);

