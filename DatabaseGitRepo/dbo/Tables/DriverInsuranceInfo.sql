CREATE TABLE [dbo].[DriverInsuranceInfo] (
    [DriverKey]                  INT          NOT NULL,
    [CoOccuInsuStartDate]        DATE         NULL,
    [CoOccuInsuEndDate]          DATE         NULL,
    [CoLiabInsuStartDate]        DATE         NULL,
    [CoLiabInsuEndDate]          DATE         NULL,
    [DriverLiabInsuranceNo]      VARCHAR (50) NULL,
    [DriverLiabInsuranceExpDate] DATE         NULL,
    [DriverMedicalCardNo]        VARCHAR (50) NULL,
    [DriverMedicalCardExpDate]   DATE         NULL,
    [CreateUserKey]              INT          NULL,
    [UpdateUserKey]              INT          NULL,
    [CreateDate]                 DATETIME     NULL,
    [LastUpdateDate]             DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([DriverKey] ASC) WITH (FILLFACTOR = 90)
);

