sp_rename '[Dependencies].[Year_Availability]', 'Duration_Availability';
GO

ALTER TABLE [Dependencies].[Duration_Availability]
DROP CONSTRAINT [FK_Year_Availability_Year_YearId]
GO

ALTER TABLE [Dependencies].[Duration_Availability]
DROP CONSTRAINT [FK_Year_Availability_Availability_AvailabilityId]
GO

ALTER TABLE [Dependencies].[Duration_Availability]  WITH CHECK 
ADD  CONSTRAINT [FK_Duration_Availability_Duration_YearId] FOREIGN KEY([YearId])
REFERENCES [Dependencies].[Duration] ([Id])
GO

ALTER TABLE [Dependencies].[Duration_Availability] CHECK CONSTRAINT [FK_Duration_Availability_Duration_YearId]
GO

ALTER TABLE [Dependencies].[Duration_Availability]  WITH CHECK 
ADD  CONSTRAINT [FK_Duration_Availability_Availability_AvailabilityId] FOREIGN KEY([AvailabilityId])
REFERENCES [Dependencies].[Availability] ([Id])
GO

ALTER TABLE [Dependencies].[Duration_Availability] CHECK CONSTRAINT [FK_Duration_Availability_Availability_AvailabilityId]
GO

sp_rename '[Dependencies].[Duration_Availability].[PK_Year_Availability]', 'PK_Duration_Availability'
GO

DROP INDEX [IX_Year_Availability_AvailabilityId] ON [Dependencies].[Duration_Availability]
GO

DROP INDEX [IX_Year_Availability_YearId] ON [Dependencies].[Duration_Availability]
GO

CREATE NONCLUSTERED INDEX [IX_Duration_Availability_AvailabilityId] ON [Dependencies].[Duration_Availability]
(
	[AvailabilityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_Duration_Availability_YearId] ON [Dependencies].[Duration_Availability]
(
	[YearId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

sp_rename '[History].[SoftwareSolution_SwSpMaintenance].[YearAvailability]', 'DurationAvailability'
GO

sp_rename '[History_RelatedItems].[YearAvailability]', 'DurationAvailability';
GO

sp_rename '[History_RelatedItems].[DurationAvailability].[YearAvailability]', 'DurationAvailability';
GO

ALTER TABLE [History_RelatedItems].[DurationAvailability] DROP CONSTRAINT [FK_History_RelatedItemsYearAvailabilityCostBlockHistory_HistoryCostBlockHistory]
GO

ALTER TABLE [History_RelatedItems].[DurationAvailability]  WITH CHECK ADD  CONSTRAINT [FK_History_RelatedItemsDurationAvailabilityCostBlockHistory_HistoryCostBlockHistory] FOREIGN KEY([CostBlockHistory])
REFERENCES [History].[CostBlockHistory] ([Id])
GO

ALTER TABLE [History_RelatedItems].[DurationAvailability] CHECK CONSTRAINT [FK_History_RelatedItemsDurationAvailabilityCostBlockHistory_HistoryCostBlockHistory]
GO

sp_rename '[SoftwareSolution].[SwSpMaintenance].[YearAvailability]', 'DurationAvailability';
GO

ALTER TABLE [SoftwareSolution].[SwSpMaintenance] DROP CONSTRAINT [FK_SoftwareSolutionSwSpMaintenanceYearAvailability_DependenciesYear_Availability]
GO

ALTER TABLE [SoftwareSolution].[SwSpMaintenance]  WITH CHECK ADD  CONSTRAINT [FK_SoftwareSolutionSwSpMaintenanceDurationAvailability_DependenciesDuration_Availability] FOREIGN KEY([DurationAvailability])
REFERENCES [Dependencies].[Duration_Availability] ([Id])
GO

ALTER TABLE [SoftwareSolution].[SwSpMaintenance] CHECK CONSTRAINT [FK_SoftwareSolutionSwSpMaintenanceDurationAvailability_DependenciesDuration_Availability]
GO

DROP VIEW [Dependencies].[YearAvailability]
GO

CREATE VIEW [Dependencies].[DurationAvailability] AS
SELECT  [Id], (CASE [Name]
WHEN '' THEN 'none' ELSE [Name]
END) AS [Name], [YearId], [AvailabilityId], [IsDisabled] FROM (SELECT  [Duration_Availability].[Id] AS [Id], ((CASE [Duration].[Name]
WHEN 'none' THEN '' ELSE [Duration].[Name] + ' '
END) + (CASE [Availability].[Name]
WHEN 'none' THEN '' ELSE [Availability].[Name]
END)) AS [Name], [Duration_Availability].[YearId] AS [YearId], [Duration_Availability].[AvailabilityId] AS [AvailabilityId], [Duration_Availability].[IsDisabled] AS [IsDisabled] FROM [Dependencies].[Duration_Availability] INNER JOIN [Dependencies].[Duration] ON [Duration_Availability].[YearId] = [Duration].[Id] INNER JOIN [Dependencies].[Availability] ON [Duration_Availability].[AvailabilityId] = [Availability].[Id]) AS [t]
GO

ALTER FUNCTION [SoftwareSolution].[GetSwSpMaintenancePaging] (
    @approved bit,
    @digit bigint,
    @av bigint,
    @year bigint,
    @lastid bigint,
    @limit int
)
RETURNS @tbl TABLE 
        (   
            [rownum] [int] NOT NULL,
            [Id] [bigint] NOT NULL,
            [Pla] [bigint] NOT NULL,
            [Sfab] [bigint] NOT NULL,
            [Sog] [bigint] NOT NULL,
            [SwDigit] [bigint] NOT NULL,
            [Availability] [bigint] NOT NULL,
            [Year] [bigint] NOT NULL,
            [2ndLevelSupportCosts] [float] NULL,
            [InstalledBaseSog] [float] NULL,
            [ReinsuranceFlatfee] [float] NULL,
            [CurrencyReinsurance] [bigint] NULL,
            [RecommendedSwSpMaintenanceListPrice] [float] NULL,
            [MarkupForProductMarginSwLicenseListPrice] [float] NULL,
            [ShareSwSpMaintenanceListPrice] [float] NULL,
            [DiscountDealerPrice] [float] NULL
        )
AS
BEGIN

        if @limit > 0
        begin
            with cte as (
                select ROW_NUMBER() over(
                            order by ssm.SwDigit
                                   , ya.AvailabilityId
                                   , ya.YearId
                        ) as rownum
                      , ssm.*
                      , ya.AvailabilityId
                      , ya.YearId
                FROM SoftwareSolution.SwSpMaintenance ssm
                JOIN Dependencies.Duration_Availability ya on ya.Id = ssm.DurationAvailability
                WHERE   (@digit is null or ssm.SwDigit = @digit)
                    and (@av is null or ya.AvailabilityId = @av)
                    and (@year is null or ya.YearId = @year)
            )
            insert @tbl
            select top(@limit)
                    rownum
                  , ssm.Id
                  , ssm.Pla
                  , ssm.Sfab
                  , ssm.Sog
                  , ssm.SwDigit
                  , ssm.AvailabilityId
                  , ssm.YearId
              
                  , case when @approved = 0 then ssm.[2ndLevelSupportCosts] else ssm.[2ndLevelSupportCosts_Approved] end
                  , case when @approved = 0 then ssm.InstalledBaseSog else ssm.InstalledBaseSog_Approved end
                  , case when @approved = 0 then ssm.ReinsuranceFlatfee else ssm.ReinsuranceFlatfee_Approved end
                  , case when @approved = 0 then ssm.CurrencyReinsurance else ssm.CurrencyReinsurance_Approved end
                  , case when @approved = 0 then ssm.RecommendedSwSpMaintenanceListPrice else ssm.RecommendedSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.MarkupForProductMarginSwLicenseListPrice else ssm.MarkupForProductMarginSwLicenseListPrice_Approved end
                  , case when @approved = 0 then ssm.ShareSwSpMaintenanceListPrice else ssm.ShareSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.DiscountDealerPrice else ssm.DiscountDealerPrice_Approved end

            from cte ssm where rownum > @lastid
        end
    else
        begin
            insert @tbl
            select -1 as rownum
                  , ssm.Id
                  , ssm.Pla
                  , ssm.Sfab
                  , ssm.Sog
                  , ssm.SwDigit
                  , ya.AvailabilityId
                  , ya.YearId

                  , case when @approved = 0 then ssm.[2ndLevelSupportCosts] else ssm.[2ndLevelSupportCosts_Approved] end
                  , case when @approved = 0 then ssm.InstalledBaseSog else ssm.InstalledBaseSog_Approved end
                  , case when @approved = 0 then ssm.ReinsuranceFlatfee else ssm.ReinsuranceFlatfee_Approved end
                  , case when @approved = 0 then ssm.CurrencyReinsurance else ssm.CurrencyReinsurance_Approved end
                  , case when @approved = 0 then ssm.RecommendedSwSpMaintenanceListPrice else ssm.RecommendedSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.MarkupForProductMarginSwLicenseListPrice else ssm.MarkupForProductMarginSwLicenseListPrice_Approved end
                  , case when @approved = 0 then ssm.ShareSwSpMaintenanceListPrice else ssm.ShareSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.DiscountDealerPrice else ssm.DiscountDealerPrice_Approved end

            FROM SoftwareSolution.SwSpMaintenance ssm
            JOIN Dependencies.Duration_Availability ya on ya.Id = ssm.DurationAvailability

            WHERE   (@digit is null or ssm.SwDigit = @digit)
                and (@av is null or ya.AvailabilityId = @av)
                and (@year is null or ya.YearId = @year)

        end

    RETURN;
END;
GO

ALTER PROCEDURE [SoftwareSolution].[SpGetCosts]
    @approved bit,
    @digit bigint,
    @av bigint,
    @year bigint,
    @lastid bigint,
    @limit int,
    @total int output
AS
BEGIN

    SET NOCOUNT ON;

    SELECT @total = COUNT(m.id)

        FROM SoftwareSolution.SwSpMaintenance m 
        JOIN Dependencies.Duration_Availability yav on yav.Id = m.DurationAvailability

        WHERE    (@digit is null or m.SwDigit = @digit)
             and (@av is null    or yav.AvailabilityId = @av)
             and (@year is null  or yav.YearId = @year);

    select  m.rownum
          , m.Id
          , d.Name as SwDigit
          , sog.Name as Sog
          , av.Name as Availability 
          , y.Name as Year
          , m.[1stLevelSupportCosts]
          , m.[2ndLevelSupportCosts]
          , m.InstalledBaseCountry
          , m.InstalledBaseSog
          , m.Reinsurance
          , m.ServiceSupport
          , m.TransferPrice
          , m.MaintenanceListPrice
          , m.DealerPrice
          , m.DiscountDealerPrice
    from SoftwareSolution.GetCosts(@approved, @digit, @av, @year, @lastid, @limit) m
    join InputAtoms.SwDigit d on d.Id = m.SwDigit
    join InputAtoms.Sog sog on sog.Id = m.Sog
    join Dependencies.Availability av on av.Id = m.Availability
    join Dependencies.Year y on y.Id = m.Year

    order by m.SwDigit, m.Availability, m.Year

END
GO




