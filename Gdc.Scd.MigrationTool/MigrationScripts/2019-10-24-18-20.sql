exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_Availability_AvailabilityId]        ;
exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_Country_CountryId]                  ;
exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_Duration_DurationId]                ;
exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_ProActiveSla_ProactiveSlaId]        ;
exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_ReactionTime_ReactionTimeId]        ;
exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_ReactionType_ReactionTypeId]        ;
exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_ServiceLocation_ServiceLocationId]  ;
exec spDropConstaint '[Fsp].[HwFspCodeTranslation]', [FK_HwFspCodeTranslation_Wg_WgId]                            ;
go

exec spDropColumn'[Fsp].[HwFspCodeTranslation]', 'ShortFsp' ;
go

alter table [Fsp].[HwFspCodeTranslation] add ShortFsp as RIGHT(Name, 3) + SUBSTRING(Name, 7, 4) persisted not null;
go

ALTER PROCEDURE [Temp].[CopyHwFspCodeTranslations]
AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION


		TRUNCATE TABLE [Fsp].[HwFspCodeTranslation];

		INSERT INTO [Fsp].[HwFspCodeTranslation]
				   ([AvailabilityId]
					   ,[CountryId]
					   ,[CreatedDateTime]
					   ,[DurationId]
					   ,[EKKey]
					   ,[EKSAPKey]
					   ,[Name]
					   ,[ProactiveSlaId]
					   ,[ReactionTimeId]
					   ,[ReactionTypeId]
					   ,[SCD_ServiceType]
					   ,[SecondSLA]
					   ,[ServiceDescription]
					   ,[ServiceLocationId]
					   ,[ServiceType]
					   ,[Status]
					   ,[WgId]
					   ,[IsStandardWarranty]
					   ,[LUT])
		SELECT      [AvailabilityId]
				   ,[CountryId]
				   ,[CreatedDateTime]
				   ,[DurationId]
				   ,[EKKey]
				   ,[EKSAPKey]
				   ,[Name]
				   ,[ProactiveSlaId]
				   ,[ReactionTimeId]
				   ,[ReactionTypeId]
				   ,[SCD_ServiceType]
				   ,[SecondSLA]
				   ,[ServiceDescription]
				   ,[ServiceLocationId]
				   ,[ServiceType]
				   ,[Status]
				   ,[WgId]
				   ,[IsStandardWarranty]
				   ,[LUT]
		 FROM [Temp].[HwFspCodeTranslation];

        exec Fsp.spUpdateHwStandardWarranty;

		COMMIT
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	END CATCH

end
GO

ALTER FUNCTION [Portfolio].[GetBySlaFsp](
    @cnt          dbo.ListID readonly,
    @fsp          nvarchar(255),
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly
)
RETURNS TABLE 
AS
RETURN 
(
    select    m.*
            , fsp.ShortFsp
            , fsp.Name               as Fsp
            , fsp.ServiceDescription as FspDescription
    from Portfolio.GetBySla(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    left JOIN Fsp.HwFspCodeTranslation fsp  on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla 
    where     (@fsp is null or fsp.Name like '%' + @fsp + '%')
)

go

ALTER FUNCTION [Portfolio].[GetBySlaFspPaging](
    @cnt          dbo.ListID readonly,
    @fsp          nvarchar(255),
    @hasFsp       bit,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly,
    @lastid       bigint,
    @limit        int
)
RETURNS @tbl TABLE 
            (   
                [rownum] [int] NOT NULL,
                [Id] [bigint] NOT NULL,
                [CountryId] [bigint] NOT NULL,
                [WgId] [bigint] NOT NULL,
                [AvailabilityId] [bigint] NOT NULL,
                [DurationId] [bigint] NOT NULL,
                [ReactionTimeId] [bigint] NOT NULL,
                [ReactionTypeId] [bigint] NOT NULL,
                [ServiceLocationId] [bigint] NOT NULL,
                [ProActiveSlaId] [bigint] NOT NULL,
                [Sla] nvarchar(255) NOT NULL,
                [SlaHash] [int] NOT NULL,
                [ReactionTime_Avalability] [bigint] NOT NULL,
                [ReactionTime_ReactionType] [bigint] NOT NULL,
                [ReactionTime_ReactionType_Avalability] [bigint] NOT NULL,
                [Fsp] nvarchar(255) NULL,
                [FspDescription] nvarchar(255) NULL
            )
AS
BEGIN

    if @hasFsp = 0 set @fsp = null;
    
    if @limit > 0
    begin
        insert into @tbl
        select rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , Fsp
              , FspDescription
        from (
                select ROW_NUMBER() over(
                            order by  m.CountryId
                                    , m.ShortFsp
                                    , m.WgId
                                    , m.AvailabilityId
                                    , m.DurationId
                                    , m.ReactionTimeId
                                    , m.ReactionTypeId
                                    , m.ServiceLocationId
                                    , m.ProActiveSlaId
                        ) as rownum
                        , m.*
                from Portfolio.GetBySlaFsp(@cnt, @fsp, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m    
                where case when @hasFsp is null                   then 1 
                           when @hasFsp = 1 and m.Fsp is not null then 1
                           when @hasFsp = 0 and m.Fsp is null     then 1
                           else 0
                        end = 1
        ) t
        where rownum > @lastid and rownum <= @lastid + @limit;
    end
    else
    begin
        insert into @tbl 
        select -1 as rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , m.Fsp
              , m.FspDescription
        from Portfolio.GetBySlaFsp(@cnt, @fsp, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
        where case when @hasFsp is null                   then 1 
                    when @hasFsp = 1 and m.Fsp is not null then 1
                    when @hasFsp = 0 and m.Fsp is null     then 1
                    else 0
                end = 1
    end 

    RETURN;
END;
go

ALTER FUNCTION [Hardware].[GetCalcMember] (
    @approved       bit,
    @cnt            dbo.ListID readonly,
    @wg             dbo.ListID readonly,
    @av             dbo.ListID readonly,
    @dur            dbo.ListID readonly,
    @reactiontime   dbo.ListID readonly,
    @reactiontype   dbo.ListID readonly,
    @loc            dbo.ListID readonly,
    @pro            dbo.ListID readonly,
    @lastid         bigint,
    @limit          int
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT    m.rownum
            , m.Id

            --SLA

            , m.Fsp
            , m.CountryId          
            , std.Country
            , std.CurrencyId
            , std.Currency
            , std.ExchangeRate
            , m.WgId
            , std.Wg
            , std.SogId
            , std.Sog
            , m.DurationId
            , dur.Name             as Duration
            , dur.Value            as Year
            , dur.IsProlongation   as IsProlongation
            , m.AvailabilityId
            , av.Name              as Availability
            , m.ReactionTimeId
            , rtime.Name           as ReactionTime
            , m.ReactionTypeId
            , rtype.Name           as ReactionType
            , m.ServiceLocationId
            , loc.Name             as ServiceLocation
            , m.ProActiveSlaId
            , prosla.ExternalName  as ProActiveSla

            , m.Sla
            , m.SlaHash

            , std.StdWarranty
            , std.StdWarrantyLocation

            --Cost values

            , std.AFR1  
            , std.AFR2  
            , std.AFR3  
            , std.AFR4  
            , std.AFR5  
            , std.AFRP1 

            , std.MatCost1
            , std.MatCost2
            , std.MatCost3
            , std.MatCost4
            , std.MatCost5
            , std.MatCost1P

            , std.MatOow1 
            , std.MatOow2 
            , std.MatOow3 
            , std.MatOow4 
            , std.MatOow5 
            , std.MatOow1p

            , std.MaterialW

            , std.TaxAndDuties1
            , std.TaxAndDuties2
            , std.TaxAndDuties3
            , std.TaxAndDuties4
            , std.TaxAndDuties5
            , std.TaxAndDuties1P

            , std.TaxOow1 
            , std.TaxOow2 
            , std.TaxOow3 
            , std.TaxOow4 
            , std.TaxOow5 
            , std.TaxOow1P
            
            , std.TaxAndDutiesW

            , ISNULL(case when @approved = 0 then r.Cost else r.Cost_approved end, 0) as Reinsurance

            --##### FIELD SERVICE COST #########                                                                                               
            , case when @approved = 0 

                   then (1 - fst.TimeAndMaterialShare_norm) * (fsc.TravelCost + fsc.LabourCost + fst.PerformanceRate) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm * ((fsc.TravelTime + fsc.repairTime) * std.OnsiteHourlyRates + fst.PerformanceRate / std.ExchangeRate) 

                   else (1 - fst.TimeAndMaterialShare_norm_Approved) * (fsc.TravelCost_Approved + fsc.LabourCost_Approved + fst.PerformanceRate_Approved) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm_Approved * ((fsc.TravelTime_Approved + fsc.repairTime_Approved) * std.OnsiteHourlyRates + fst.PerformanceRate_Approved / std.ExchangeRate) 

               end as FieldServicePerYear

            --##### SERVICE SUPPORT COST #########                                                                                               
            , std.ServiceSupportPerYear

            --##### LOGISTICS COST #########                                                                                               
            , case when @approved = 0 
                   then lc.ExpressDelivery          +
                        lc.HighAvailabilityHandling +
                        lc.StandardDelivery         +
                        lc.StandardHandling         +
                        lc.ReturnDeliveryFactory    +
                        lc.TaxiCourierDelivery      
                   else lc.ExpressDelivery_Approved          +
                        lc.HighAvailabilityHandling_Approved +
                        lc.StandardDelivery_Approved         +
                        lc.StandardHandling_Approved         +
                        lc.ReturnDeliveryFactory_Approved    +
                        lc.TaxiCourierDelivery_Approved     
                end / std.ExchangeRate as LogisticPerYear

                                                                                                                       
            , case when afEx.id is not null then std.Fee else 0 end as AvailabilityFee

            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.Markup else moc.ProlongationMarkup end)                             
                    else (case when dur.IsProlongation = 0 then moc.Markup_Approved else moc.ProlongationMarkup_Approved end)                      
                end / std.ExchangeRate as MarkupOtherCost                      
            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm else moc.ProlongationMarkupFactor_norm end)                             
                    else (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm_Approved else moc.ProlongationMarkupFactor_norm_Approved end)                      
                end as MarkupFactorOtherCost                

            --####### PROACTIVE COST ###################
            , std.LocalRemoteAccessSetup + dur.Value * (
                          std.LocalRegularUpdate * proSla.LocalRegularUpdateReadyRepetition                
                        + std.LocalPreparation * proSla.LocalPreparationShcRepetition                      
                        + std.LocalRemoteCustomerBriefing * proSla.LocalRemoteShcCustomerBriefingRepetition
                        + std.LocalOnsiteCustomerBriefing * proSla.LocalOnsiteShcCustomerBriefingRepetition
                        + std.Travel * proSla.TravellingTimeRepetition                                     
                        + std.CentralExecutionReport * proSla.CentralExecutionShcReportRepetition          
                    ) as ProActive

            , std.LocalServiceStandardWarranty
            , std.LocalServiceStandardWarrantyManual
            , std.Credit1
            , std.Credit2
            , std.Credit3
            , std.Credit4
            , std.Credit5
            , std.Credits

            --########## MANUAL COSTS ################
            , man.ListPrice          / std.ExchangeRate as ListPrice                   
            , man.DealerDiscount                        as DealerDiscount              
            , man.DealerPrice        / std.ExchangeRate as DealerPrice                 
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTC     / std.ExchangeRate) end as ServiceTCManual                   
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTP     / std.ExchangeRate) end as ServiceTPManual                   
            , man.ServiceTP_Released / std.ExchangeRate as ServiceTP_Released                  
            , man.ReleaseDate                           as ReleaseDate
            , man.ChangeDate                            
            , u.Name                                    as ChangeUserName
            , u.Email                                   as ChangeUserEmail

    FROM Hardware.CalcStdw(@approved, @cnt, @wg) std 

    INNER JOIN Portfolio.GetBySlaPaging(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m on std.CountryId = m.CountryId and std.WgId = m.WgId 

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    LEFT JOIN Hardware.ReinsuranceCalc r on r.Wg = m.WgId AND r.Duration = m.DurationId AND r.ReactionTimeAvailability = m.ReactionTime_Avalability

    LEFT JOIN Hardware.FieldServiceCalc fsc ON fsc.Country = m.CountryId AND fsc.Wg = m.WgId AND fsc.ServiceLocation = m.ServiceLocationId
    LEFT JOIN Hardware.FieldServiceTimeCalc fst ON fst.Country = m.CountryId AND fst.Wg = m.WgId AND fst.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTimeType = m.ReactionTime_ReactionType and lc.Deactivated = 0

    LEFT JOIN Hardware.MarkupOtherCosts moc on moc.Country = m.CountryId AND moc.Wg = m.WgId AND moc.ReactionTimeTypeAvailability = m.ReactionTime_ReactionType_Avalability and moc.Deactivated = 0

    LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

    LEFT JOIN Hardware.ManualCost man on man.PortfolioId = m.Id

    LEFT JOIN dbo.[User] u on u.Id = man.ChangeUserId
)
GO

if OBJECT_ID('[Hardware].[GetCalcMember2]') is not null
    drop function [Hardware].[GetCalcMember2];
go

create FUNCTION [Hardware].[GetCalcMember2] (
    @approved       bit,
    @cnt            dbo.ListID readonly,
    @fsp            nvarchar(255),
    @hasFsp         bit,
    @wg             dbo.ListID readonly,
    @av             dbo.ListID readonly,
    @dur            dbo.ListID readonly,
    @reactiontime   dbo.ListID readonly,
    @reactiontype   dbo.ListID readonly,
    @loc            dbo.ListID readonly,
    @pro            dbo.ListID readonly,
    @lastid         bigint,
    @limit          int
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT    m.rownum
            , m.Id

            --SLA

            , m.Fsp
            , m.CountryId          
            , std.Country
            , std.CurrencyId
            , std.Currency
            , std.ExchangeRate
            , m.WgId
            , std.Wg
            , std.SogId
            , std.Sog
            , m.DurationId
            , dur.Name             as Duration
            , dur.Value            as Year
            , dur.IsProlongation   as IsProlongation
            , m.AvailabilityId
            , av.Name              as Availability
            , m.ReactionTimeId
            , rtime.Name           as ReactionTime
            , m.ReactionTypeId
            , rtype.Name           as ReactionType
            , m.ServiceLocationId
            , loc.Name             as ServiceLocation
            , m.ProActiveSlaId
            , prosla.ExternalName  as ProActiveSla

            , m.Sla
            , m.SlaHash

            , std.StdWarranty
            , std.StdWarrantyLocation

            --Cost values

            , std.AFR1  
            , std.AFR2  
            , std.AFR3  
            , std.AFR4  
            , std.AFR5  
            , std.AFRP1 

            , std.MatCost1
            , std.MatCost2
            , std.MatCost3
            , std.MatCost4
            , std.MatCost5
            , std.MatCost1P

            , std.MatOow1 
            , std.MatOow2 
            , std.MatOow3 
            , std.MatOow4 
            , std.MatOow5 
            , std.MatOow1p

            , std.MaterialW

            , std.TaxAndDuties1
            , std.TaxAndDuties2
            , std.TaxAndDuties3
            , std.TaxAndDuties4
            , std.TaxAndDuties5
            , std.TaxAndDuties1P

            , std.TaxOow1 
            , std.TaxOow2 
            , std.TaxOow3 
            , std.TaxOow4 
            , std.TaxOow5 
            , std.TaxOow1P
            
            , std.TaxAndDutiesW

            , ISNULL(case when @approved = 0 then r.Cost else r.Cost_approved end, 0) as Reinsurance

            --##### FIELD SERVICE COST #########                                                                                               
            , case when @approved = 0 

                   then (1 - fst.TimeAndMaterialShare_norm) * (fsc.TravelCost + fsc.LabourCost + fst.PerformanceRate) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm * ((fsc.TravelTime + fsc.repairTime) * std.OnsiteHourlyRates + fst.PerformanceRate / std.ExchangeRate) 

                   else (1 - fst.TimeAndMaterialShare_norm_Approved) * (fsc.TravelCost_Approved + fsc.LabourCost_Approved + fst.PerformanceRate_Approved) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm_Approved * ((fsc.TravelTime_Approved + fsc.repairTime_Approved) * std.OnsiteHourlyRates + fst.PerformanceRate_Approved / std.ExchangeRate) 

               end as FieldServicePerYear

            --##### SERVICE SUPPORT COST #########                                                                                               
            , std.ServiceSupportPerYear

            --##### LOGISTICS COST #########                                                                                               
            , case when @approved = 0 
                   then lc.ExpressDelivery          +
                        lc.HighAvailabilityHandling +
                        lc.StandardDelivery         +
                        lc.StandardHandling         +
                        lc.ReturnDeliveryFactory    +
                        lc.TaxiCourierDelivery      
                   else lc.ExpressDelivery_Approved          +
                        lc.HighAvailabilityHandling_Approved +
                        lc.StandardDelivery_Approved         +
                        lc.StandardHandling_Approved         +
                        lc.ReturnDeliveryFactory_Approved    +
                        lc.TaxiCourierDelivery_Approved     
                end / std.ExchangeRate as LogisticPerYear

                                                                                                                       
            , case when afEx.id is not null then std.Fee else 0 end as AvailabilityFee

            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.Markup else moc.ProlongationMarkup end)                             
                    else (case when dur.IsProlongation = 0 then moc.Markup_Approved else moc.ProlongationMarkup_Approved end)                      
                end / std.ExchangeRate as MarkupOtherCost                      
            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm else moc.ProlongationMarkupFactor_norm end)                             
                    else (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm_Approved else moc.ProlongationMarkupFactor_norm_Approved end)                      
                end as MarkupFactorOtherCost                

            --####### PROACTIVE COST ###################
            , std.LocalRemoteAccessSetup + dur.Value * (
                          std.LocalRegularUpdate * proSla.LocalRegularUpdateReadyRepetition                
                        + std.LocalPreparation * proSla.LocalPreparationShcRepetition                      
                        + std.LocalRemoteCustomerBriefing * proSla.LocalRemoteShcCustomerBriefingRepetition
                        + std.LocalOnsiteCustomerBriefing * proSla.LocalOnsiteShcCustomerBriefingRepetition
                        + std.Travel * proSla.TravellingTimeRepetition                                     
                        + std.CentralExecutionReport * proSla.CentralExecutionShcReportRepetition          
                    ) as ProActive

            , std.LocalServiceStandardWarranty
            , std.LocalServiceStandardWarrantyManual
            , std.Credit1
            , std.Credit2
            , std.Credit3
            , std.Credit4
            , std.Credit5
            , std.Credits

            --########## MANUAL COSTS ################
            , man.ListPrice          / std.ExchangeRate as ListPrice                   
            , man.DealerDiscount                        as DealerDiscount              
            , man.DealerPrice        / std.ExchangeRate as DealerPrice                 
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTC     / std.ExchangeRate) end as ServiceTCManual                   
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTP     / std.ExchangeRate) end as ServiceTPManual                   
            , man.ServiceTP_Released / std.ExchangeRate as ServiceTP_Released                  
            , man.ReleaseDate                           as ReleaseDate
            , man.ChangeDate                            
            , u.Name                                    as ChangeUserName
            , u.Email                                   as ChangeUserEmail

    FROM Hardware.CalcStdw(@approved, @cnt, @wg) std 

    INNER JOIN Portfolio.GetBySlaFspPaging(@cnt, @fsp, @hasFsp, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m on std.CountryId = m.CountryId and std.WgId = m.WgId 

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    LEFT JOIN Hardware.ReinsuranceCalc r on r.Wg = m.WgId AND r.Duration = m.DurationId AND r.ReactionTimeAvailability = m.ReactionTime_Avalability

    LEFT JOIN Hardware.FieldServiceCalc fsc ON fsc.Country = m.CountryId AND fsc.Wg = m.WgId AND fsc.ServiceLocation = m.ServiceLocationId
    LEFT JOIN Hardware.FieldServiceTimeCalc fst ON fst.Country = m.CountryId AND fst.Wg = m.WgId AND fst.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTimeType = m.ReactionTime_ReactionType and lc.Deactivated = 0

    LEFT JOIN Hardware.MarkupOtherCosts moc on moc.Country = m.CountryId AND moc.Wg = m.WgId AND moc.ReactionTimeTypeAvailability = m.ReactionTime_ReactionType_Avalability and moc.Deactivated = 0

    LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

    LEFT JOIN Hardware.ManualCost man on man.PortfolioId = m.Id

    LEFT JOIN dbo.[User] u on u.Id = man.ChangeUserId
)
GO

ALTER FUNCTION [Hardware].[GetCosts](
    @approved bit,
    @cnt dbo.ListID readonly,
    @wg dbo.ListID readonly,
    @av dbo.ListID readonly,
    @dur dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc dbo.ListID readonly,
    @pro dbo.ListID readonly,
    @lastid bigint,
    @limit int
)
RETURNS TABLE 
AS
RETURN 
(
    with CostCte as (
        select    m.*

                , ISNULL(m.AvailabilityFee, 0) as AvailabilityFeeOrZero
       
        from Hardware.GetCalcMember(@approved, @cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m
    )
    , CostCte2 as (
        select    m.*

                , m.FieldServicePerYear * m.AFR1  as FieldServiceCost1
                , m.FieldServicePerYear * m.AFR2  as FieldServiceCost2
                , m.FieldServicePerYear * m.AFR3  as FieldServiceCost3
                , m.FieldServicePerYear * m.AFR4  as FieldServiceCost4
                , m.FieldServicePerYear * m.AFR5  as FieldServiceCost5
                , m.FieldServicePerYear * m.AFRP1 as FieldServiceCost1P

                , m.LogisticPerYear * m.AFR1  as Logistic1
                , m.LogisticPerYear * m.AFR2  as Logistic2
                , m.LogisticPerYear * m.AFR3  as Logistic3
                , m.LogisticPerYear * m.AFR4  as Logistic4
                , m.LogisticPerYear * m.AFR5  as Logistic5
                , m.LogisticPerYear * m.AFRP1 as Logistic1P

                , isnull(case when m.DurationId = 1 then m.Reinsurance end, 0) as Reinsurance1
                , isnull(case when m.DurationId = 2 then m.Reinsurance end, 0) as Reinsurance2
                , isnull(case when m.DurationId = 3 then m.Reinsurance end, 0) as Reinsurance3
                , isnull(case when m.DurationId = 4 then m.Reinsurance end, 0) as Reinsurance4
                , isnull(case when m.DurationId = 5 then m.Reinsurance end, 0) as Reinsurance5
                , isnull(case when m.DurationId = 6 then m.Reinsurance end, 0) as Reinsurance1P

        from CostCte m
    )
    , CostCte3 as (
        select    m.*

                , Hardware.MarkupOrFixValue(m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.Reinsurance1 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1
                , Hardware.MarkupOrFixValue(m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.Reinsurance2 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect2
                , Hardware.MarkupOrFixValue(m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.Reinsurance3 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect3
                , Hardware.MarkupOrFixValue(m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.Reinsurance4 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect4
                , Hardware.MarkupOrFixValue(m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.Reinsurance5 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect5
                , Hardware.MarkupOrFixValue(m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.Reinsurance1P + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1P

        from CostCte2 m
    )
    , CostCte5 as (
        select m.*

             , m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.TaxAndDuties1  + m.Reinsurance1 + m.OtherDirect1  + m.AvailabilityFeeOrZero - m.Credit1 as ServiceTP1
             , m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.TaxAndDuties2  + m.Reinsurance2 + m.OtherDirect2  + m.AvailabilityFeeOrZero - m.Credit2 as ServiceTP2
             , m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.TaxAndDuties3  + m.Reinsurance3 + m.OtherDirect3  + m.AvailabilityFeeOrZero - m.Credit3 as ServiceTP3
             , m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.TaxAndDuties4  + m.Reinsurance4 + m.OtherDirect4  + m.AvailabilityFeeOrZero - m.Credit4 as ServiceTP4
             , m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.TaxAndDuties5  + m.Reinsurance5 + m.OtherDirect5  + m.AvailabilityFeeOrZero - m.Credit5 as ServiceTP5
             , m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.TaxAndDuties1P + m.Reinsurance1P + m.OtherDirect1P + m.AvailabilityFeeOrZero             as ServiceTP1P

        from CostCte3 m
    )
    , CostCte6 as (
        select m.*

                , m.ServiceTP1  - m.OtherDirect1  as ServiceTC1
                , m.ServiceTP2  - m.OtherDirect2  as ServiceTC2
                , m.ServiceTP3  - m.OtherDirect3  as ServiceTC3
                , m.ServiceTP4  - m.OtherDirect4  as ServiceTC4
                , m.ServiceTP5  - m.OtherDirect5  as ServiceTC5
                , m.ServiceTP1P - m.OtherDirect1P as ServiceTC1P

        from CostCte5 m
    )    
    select m.rownum
         , m.Id

         --SLA

         , m.Fsp
         , m.CountryId
         , m.Country
         , m.CurrencyId
         , m.Currency
         , m.ExchangeRate
         , m.SogId
         , m.Sog
         , m.WgId
         , m.Wg
         , m.AvailabilityId
         , m.Availability
         , m.DurationId
         , m.Duration
         , m.Year
         , m.IsProlongation
         , m.ReactionTimeId
         , m.ReactionTime
         , m.ReactionTypeId
         , m.ReactionType
         , m.ServiceLocationId
         , m.ServiceLocation
         , m.ProActiveSlaId

         , m.ProActiveSla

         , m.Sla
         , m.SlaHash

         , m.StdWarranty
         , m.StdWarrantyLocation

         --Cost

         , m.AvailabilityFee * m.Year as AvailabilityFee
         , m.TaxAndDutiesW
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.TaxOow1, m.TaxOow2, m.TaxOow3, m.TaxOow4, m.TaxOow5, m.TaxOow1P) as TaxAndDutiesOow


         , m.Reinsurance
         , m.ProActive
         , m.Year * m.ServiceSupportPerYear as ServiceSupportCost

         , m.MaterialW
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.MatOow1, m.MatOow2, m.MatOow3, m.MatOow4, m.MatOow5, m.MatOow1P) as MaterialOow

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.FieldServiceCost1, m.FieldServiceCost2, m.FieldServiceCost3, m.FieldServiceCost4, m.FieldServiceCost5, m.FieldServiceCost1P) as FieldServiceCost
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.Logistic1, m.Logistic2, m.Logistic3, m.Logistic4, m.Logistic5, m.Logistic1P) as Logistic
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.OtherDirect1, m.OtherDirect2, m.OtherDirect3, m.OtherDirect4, m.OtherDirect5, m.OtherDirect1P) as OtherDirect
       
         , m.LocalServiceStandardWarranty
         , m.LocalServiceStandardWarrantyManual
       
         , m.Credits

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTC1, m.ServiceTC2, m.ServiceTC3, m.ServiceTC4, m.ServiceTC5, m.ServiceTC1P) as ServiceTC
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTP1, m.ServiceTP2, m.ServiceTP3, m.ServiceTP4, m.ServiceTP5, m.ServiceTP1P) as ServiceTP

         , m.ServiceTC1
         , m.ServiceTC2
         , m.ServiceTC3
         , m.ServiceTC4
         , m.ServiceTC5
         , m.ServiceTC1P

         , m.ServiceTP1
         , m.ServiceTP2
         , m.ServiceTP3
         , m.ServiceTP4
         , m.ServiceTP5
         , m.ServiceTP1P

         , m.ListPrice
         , m.DealerDiscount
         , m.DealerPrice
         , m.ServiceTCManual
         , m.ServiceTPManual
         , coalesce(m.ServiceTCManual, Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTC1, m.ServiceTC2, m.ServiceTC3, m.ServiceTC4, m.ServiceTC5, m.ServiceTC1P)) as ServiceTCResult
         , coalesce(m.ServiceTPManual, Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTP1, m.ServiceTP2, m.ServiceTP3, m.ServiceTP4, m.ServiceTP5, m.ServiceTP1P)) as ServiceTPResult
         , m.ServiceTP_Released

         , m.ReleaseDate
         , m.ChangeDate
         , m.ChangeUserName
         , m.ChangeUserEmail

       from CostCte6 m
)
GO

if OBJECT_ID('[Hardware].[GetCosts2]') is not null
    drop function [Hardware].[GetCosts2];
go

create FUNCTION [Hardware].[GetCosts2](
    @approved                bit,
    @cnt dbo.ListID          readonly,
    @fsp                     nvarchar(255),
    @hasFsp                  bit,
    @wg dbo.ListID           readonly,
    @av dbo.ListID           readonly,
    @dur dbo.ListID          readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc dbo.ListID          readonly,
    @pro dbo.ListID          readonly,
    @lastid                  bigint,
    @limit                   int
)
RETURNS TABLE 
AS
RETURN 
(
    with CostCte as (
        select    m.*

                , ISNULL(m.AvailabilityFee, 0) as AvailabilityFeeOrZero
       
        from Hardware.GetCalcMember2(@approved, @cnt, @fsp, @hasFsp, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m
    )
    , CostCte2 as (
        select    m.*

                , m.FieldServicePerYear * m.AFR1  as FieldServiceCost1
                , m.FieldServicePerYear * m.AFR2  as FieldServiceCost2
                , m.FieldServicePerYear * m.AFR3  as FieldServiceCost3
                , m.FieldServicePerYear * m.AFR4  as FieldServiceCost4
                , m.FieldServicePerYear * m.AFR5  as FieldServiceCost5
                , m.FieldServicePerYear * m.AFRP1 as FieldServiceCost1P

                , m.LogisticPerYear * m.AFR1  as Logistic1
                , m.LogisticPerYear * m.AFR2  as Logistic2
                , m.LogisticPerYear * m.AFR3  as Logistic3
                , m.LogisticPerYear * m.AFR4  as Logistic4
                , m.LogisticPerYear * m.AFR5  as Logistic5
                , m.LogisticPerYear * m.AFRP1 as Logistic1P

                , isnull(case when m.DurationId = 1 then m.Reinsurance end, 0) as Reinsurance1
                , isnull(case when m.DurationId = 2 then m.Reinsurance end, 0) as Reinsurance2
                , isnull(case when m.DurationId = 3 then m.Reinsurance end, 0) as Reinsurance3
                , isnull(case when m.DurationId = 4 then m.Reinsurance end, 0) as Reinsurance4
                , isnull(case when m.DurationId = 5 then m.Reinsurance end, 0) as Reinsurance5
                , isnull(case when m.DurationId = 6 then m.Reinsurance end, 0) as Reinsurance1P

        from CostCte m
    )
    , CostCte3 as (
        select    m.*

                , Hardware.MarkupOrFixValue(m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.Reinsurance1 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1
                , Hardware.MarkupOrFixValue(m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.Reinsurance2 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect2
                , Hardware.MarkupOrFixValue(m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.Reinsurance3 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect3
                , Hardware.MarkupOrFixValue(m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.Reinsurance4 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect4
                , Hardware.MarkupOrFixValue(m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.Reinsurance5 + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect5
                , Hardware.MarkupOrFixValue(m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.Reinsurance1P + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1P

        from CostCte2 m
    )
    , CostCte5 as (
        select m.*

             , m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.TaxAndDuties1  + m.Reinsurance1 + m.OtherDirect1  + m.AvailabilityFeeOrZero - m.Credit1 as ServiceTP1
             , m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.TaxAndDuties2  + m.Reinsurance2 + m.OtherDirect2  + m.AvailabilityFeeOrZero - m.Credit2 as ServiceTP2
             , m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.TaxAndDuties3  + m.Reinsurance3 + m.OtherDirect3  + m.AvailabilityFeeOrZero - m.Credit3 as ServiceTP3
             , m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.TaxAndDuties4  + m.Reinsurance4 + m.OtherDirect4  + m.AvailabilityFeeOrZero - m.Credit4 as ServiceTP4
             , m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.TaxAndDuties5  + m.Reinsurance5 + m.OtherDirect5  + m.AvailabilityFeeOrZero - m.Credit5 as ServiceTP5
             , m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.TaxAndDuties1P + m.Reinsurance1P + m.OtherDirect1P + m.AvailabilityFeeOrZero             as ServiceTP1P

        from CostCte3 m
    )
    , CostCte6 as (
        select m.*

                , m.ServiceTP1  - m.OtherDirect1  as ServiceTC1
                , m.ServiceTP2  - m.OtherDirect2  as ServiceTC2
                , m.ServiceTP3  - m.OtherDirect3  as ServiceTC3
                , m.ServiceTP4  - m.OtherDirect4  as ServiceTC4
                , m.ServiceTP5  - m.OtherDirect5  as ServiceTC5
                , m.ServiceTP1P - m.OtherDirect1P as ServiceTC1P

        from CostCte5 m
    )    
    select m.rownum
         , m.Id

         --SLA

         , m.Fsp
         , m.CountryId
         , m.Country
         , m.CurrencyId
         , m.Currency
         , m.ExchangeRate
         , m.SogId
         , m.Sog
         , m.WgId
         , m.Wg
         , m.AvailabilityId
         , m.Availability
         , m.DurationId
         , m.Duration
         , m.Year
         , m.IsProlongation
         , m.ReactionTimeId
         , m.ReactionTime
         , m.ReactionTypeId
         , m.ReactionType
         , m.ServiceLocationId
         , m.ServiceLocation
         , m.ProActiveSlaId

         , m.ProActiveSla

         , m.Sla
         , m.SlaHash

         , m.StdWarranty
         , m.StdWarrantyLocation

         --Cost

         , m.AvailabilityFee * m.Year as AvailabilityFee
         , m.TaxAndDutiesW
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.TaxOow1, m.TaxOow2, m.TaxOow3, m.TaxOow4, m.TaxOow5, m.TaxOow1P) as TaxAndDutiesOow


         , m.Reinsurance
         , m.ProActive
         , m.Year * m.ServiceSupportPerYear as ServiceSupportCost

         , m.MaterialW
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.MatOow1, m.MatOow2, m.MatOow3, m.MatOow4, m.MatOow5, m.MatOow1P) as MaterialOow

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.FieldServiceCost1, m.FieldServiceCost2, m.FieldServiceCost3, m.FieldServiceCost4, m.FieldServiceCost5, m.FieldServiceCost1P) as FieldServiceCost
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.Logistic1, m.Logistic2, m.Logistic3, m.Logistic4, m.Logistic5, m.Logistic1P) as Logistic
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.OtherDirect1, m.OtherDirect2, m.OtherDirect3, m.OtherDirect4, m.OtherDirect5, m.OtherDirect1P) as OtherDirect
       
         , m.LocalServiceStandardWarranty
         , m.LocalServiceStandardWarrantyManual
       
         , m.Credits

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTC1, m.ServiceTC2, m.ServiceTC3, m.ServiceTC4, m.ServiceTC5, m.ServiceTC1P) as ServiceTC
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTP1, m.ServiceTP2, m.ServiceTP3, m.ServiceTP4, m.ServiceTP5, m.ServiceTP1P) as ServiceTP

         , m.ServiceTC1
         , m.ServiceTC2
         , m.ServiceTC3
         , m.ServiceTC4
         , m.ServiceTC5
         , m.ServiceTC1P

         , m.ServiceTP1
         , m.ServiceTP2
         , m.ServiceTP3
         , m.ServiceTP4
         , m.ServiceTP5
         , m.ServiceTP1P

         , m.ListPrice
         , m.DealerDiscount
         , m.DealerPrice
         , m.ServiceTCManual
         , m.ServiceTPManual
         , coalesce(m.ServiceTCManual, Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTC1, m.ServiceTC2, m.ServiceTC3, m.ServiceTC4, m.ServiceTC5, m.ServiceTC1P)) as ServiceTCResult
         , coalesce(m.ServiceTPManual, Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTP1, m.ServiceTP2, m.ServiceTP3, m.ServiceTP4, m.ServiceTP5, m.ServiceTP1P)) as ServiceTPResult
         , m.ServiceTP_Released

         , m.ReleaseDate
         , m.ChangeDate
         , m.ChangeUserName
         , m.ChangeUserEmail

       from CostCte6 m
)
GO

ALTER PROCEDURE [Hardware].[SpGetCosts]
    @approved     bit,
    @local        bit,
    @cnt          dbo.ListID readonly,
    @fsp          nvarchar(255),
    @hasFsp       bit,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly,
    @lastid       bigint,
    @limit        int
AS
BEGIN

    SET NOCOUNT ON;

    if @local = 1
    begin
    
        --convert values from EUR to local

        select 
               rownum
             , Id

             , Fsp
             , Country
             , Currency
             , ExchangeRate

             , Sog
             , Wg
             , Availability
             , Duration
             , ReactionTime
             , ReactionType
             , ServiceLocation
             , ProActiveSla

             , StdWarranty
             , StdWarrantyLocation

             --Cost

             , AvailabilityFee               * ExchangeRate  as AvailabilityFee 
             , TaxAndDutiesW                 * ExchangeRate  as TaxAndDutiesW
             , TaxAndDutiesOow               * ExchangeRate  as TaxAndDutiesOow
             , Reinsurance                   * ExchangeRate  as Reinsurance
             , ProActive                     * ExchangeRate  as ProActive
             , ServiceSupportCost            * ExchangeRate  as ServiceSupportCost

             , MaterialW                     * ExchangeRate  as MaterialW
             , MaterialOow                   * ExchangeRate  as MaterialOow
             , FieldServiceCost              * ExchangeRate  as FieldServiceCost
             , Logistic                      * ExchangeRate  as Logistic
             , OtherDirect                   * ExchangeRate  as OtherDirect
             , LocalServiceStandardWarranty  * ExchangeRate  as LocalServiceStandardWarranty
             , LocalServiceStandardWarrantyManual  * ExchangeRate  as LocalServiceStandardWarrantyManual
             , Credits                       * ExchangeRate  as Credits
             , ServiceTC                     * ExchangeRate  as ServiceTC
             , ServiceTP                     * ExchangeRate  as ServiceTP

             , ServiceTCManual               * ExchangeRate  as ServiceTCManual
             , ServiceTPManual               * ExchangeRate  as ServiceTPManual

             , ServiceTP_Released            * ExchangeRate  as ServiceTP_Released

             , ListPrice                     * ExchangeRate  as ListPrice
             , DealerPrice                   * ExchangeRate  as DealerPrice
             , DealerDiscount                                as DealerDiscount
                                                       
             , ReleaseDate                                    
             , ChangeUserName                                as ChangeUserName
             , ChangeUserEmail                               as ChangeUserEmail

        from Hardware.GetCosts2(@approved, @cnt, @fsp, @hasFsp, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) 
        order by rownum
        
    end
    else
    begin

        select                
               rownum
             , Id

             , Fsp
             , Country
             , 'EUR' as Currency
             , ExchangeRate

             , Sog
             , Wg
             , Availability
             , Duration
             , ReactionTime
             , ReactionType
             , ServiceLocation
             , ProActiveSla

             , StdWarranty
             , StdWarrantyLocation

             --Cost

             , AvailabilityFee               
             , TaxAndDutiesW                 
             , TaxAndDutiesOow               
             , Reinsurance                   
             , ProActive                     
             , ServiceSupportCost            

             , MaterialW                     
             , MaterialOow                   
             , FieldServiceCost              
             , Logistic                      
             , OtherDirect                   
             , LocalServiceStandardWarranty  
             , LocalServiceStandardWarrantyManual
             , Credits                       
             , ServiceTC                     
             , ServiceTP                     

             , ServiceTCManual               
             , ServiceTPManual               

             , ServiceTP_Released            

             , ListPrice                     
             , DealerPrice                   
             , DealerDiscount                
                                             
             , ReleaseDate                                    
             , ChangeUserName                
             , ChangeUserEmail               

        from Hardware.GetCosts2(@approved, @cnt, @fsp, @hasFsp, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) 
        order by rownum
    end
END
go

ALTER FUNCTION [SoftwareSolution].[GetSwSpMaintenancePaging] (
    @approved bit,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly,
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
            [TotalInstalledBaseSog] [float] NULL,
            [ReinsuranceFlatfee] [float] NULL,
            [CurrencyReinsurance] [bigint] NULL,
            [RecommendedSwSpMaintenanceListPrice] [float] NULL,
            [MarkupForProductMarginSwLicenseListPrice] [float] NULL,
            [ShareSwSpMaintenanceListPrice] [float] NULL,
            [DiscountDealerPrice] [float] NULL,
            [FspId] bigint,
            [Fsp] nvarchar(255)
        )
AS
BEGIN
        declare @isEmptyDigit    bit = Portfolio.IsListEmpty(@digit);
        declare @isEmptyAV    bit = Portfolio.IsListEmpty(@av);
        declare @isEmptyYear    bit = Portfolio.IsListEmpty(@year);

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
                      , fsp.Id as FspId
                      , fsp.Name as Fsp
                FROM SoftwareSolution.SwSpMaintenance ssm
                JOIN Dependencies.Duration_Availability ya on ya.Id = ssm.DurationAvailability
                LEFT JOIN Fsp.SwFspCodeTranslation fsp on fsp.SwDigitId = ssm.SwDigit
                                    and fsp.AvailabilityId = ssm.Availability
                                    and fsp.DurationId = ya.YearId
                WHERE (@isEmptyDigit = 1 or ssm.SwDigit in (select id from @digit))
                    AND (@isEmptyAV = 1 or ya.AvailabilityId in (select id from @av))
                    AND (@isEmptyYear = 1 or ya.YearId in (select id from @year))
                    and ssm.Deactivated = 0
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
                  , case when @approved = 0 then ssm.TotalIB else ssm.TotalIB_Approved end

                  , case when @approved = 0 then ssm.ReinsuranceFlatfee else ssm.ReinsuranceFlatfee_Approved end
                  , case when @approved = 0 then ssm.CurrencyReinsurance else ssm.CurrencyReinsurance_Approved end
                  , case when @approved = 0 then ssm.RecommendedSwSpMaintenanceListPrice else ssm.RecommendedSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.MarkupForProductMarginSwLicenseListPrice else ssm.MarkupForProductMarginSwLicenseListPrice_Approved end
                  , case when @approved = 0 then ssm.ShareSwSpMaintenanceListPrice else ssm.ShareSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.DiscountDealerPrice else ssm.DiscountDealerPrice_Approved end

                  , ssm.FspId
                  , ssm.Fsp

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
                  , case when @approved = 0 then ssm.TotalIB else ssm.TotalIB_Approved end

                  , case when @approved = 0 then ssm.ReinsuranceFlatfee else ssm.ReinsuranceFlatfee_Approved end
                  , case when @approved = 0 then ssm.CurrencyReinsurance else ssm.CurrencyReinsurance_Approved end
                  , case when @approved = 0 then ssm.RecommendedSwSpMaintenanceListPrice else ssm.RecommendedSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.MarkupForProductMarginSwLicenseListPrice else ssm.MarkupForProductMarginSwLicenseListPrice_Approved end
                  , case when @approved = 0 then ssm.ShareSwSpMaintenanceListPrice else ssm.ShareSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.DiscountDealerPrice else ssm.DiscountDealerPrice_Approved end

                , fsp.Id as FspId
                , fsp.Name as Fsp

            FROM SoftwareSolution.SwSpMaintenance ssm
            JOIN Dependencies.Duration_Availability ya on ya.Id = ssm.DurationAvailability
            LEFT JOIN Fsp.SwFspCodeTranslation fsp on fsp.SwDigitId = ssm.SwDigit
                                and fsp.AvailabilityId = ssm.Availability
                                and fsp.DurationId = ya.YearId

            WHERE (@isEmptyDigit = 1 or ssm.SwDigit in (select id from @digit))
                AND (@isEmptyAV = 1 or ya.AvailabilityId in (select id from @av))
                AND (@isEmptyYear = 1 or ya.YearId in (select id from @year))
                and ssm.Deactivated = 0

        end

    RETURN;
END
go

if object_id('[SoftwareSolution].[GetSwSpMaintenancePaging2]') is not null
    drop function [SoftwareSolution].[GetSwSpMaintenancePaging2];
go

create FUNCTION [SoftwareSolution].[GetSwSpMaintenancePaging2] (
    @approved bit,
    @fsp nvarchar(255),
    @hasFsp bit,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly,
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
            [TotalInstalledBaseSog] [float] NULL,
            [ReinsuranceFlatfee] [float] NULL,
            [CurrencyReinsurance] [bigint] NULL,
            [RecommendedSwSpMaintenanceListPrice] [float] NULL,
            [MarkupForProductMarginSwLicenseListPrice] [float] NULL,
            [ShareSwSpMaintenanceListPrice] [float] NULL,
            [DiscountDealerPrice] [float] NULL,
            [FspId] bigint,
            [Fsp] nvarchar(255)
        )
AS
BEGIN
        declare @isEmptyDigit    bit = Portfolio.IsListEmpty(@digit);
        declare @isEmptyAV    bit = Portfolio.IsListEmpty(@av);
        declare @isEmptyYear    bit = Portfolio.IsListEmpty(@year);

        if @hasFsp = 0 set @fsp = null;

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
                      , fsp.Id as FspId
                      , fsp.Name as Fsp
                FROM SoftwareSolution.SwSpMaintenance ssm
                JOIN Dependencies.Duration_Availability ya on ya.Id = ssm.DurationAvailability
                LEFT JOIN Fsp.SwFspCodeTranslation fsp on fsp.SwDigitId = ssm.SwDigit
                                    and fsp.AvailabilityId = ssm.Availability
                                    and fsp.DurationId = ya.YearId
                WHERE (@isEmptyDigit = 1 or ssm.SwDigit in (select id from @digit))
                    AND (@isEmptyAV = 1 or ya.AvailabilityId in (select id from @av))
                    AND (@isEmptyYear = 1 or ya.YearId in (select id from @year))
                    and (@fsp is null or fsp.Name like '%' + @fsp + '%')
                    AND case when @hasFsp is null                    then 1 
                             when @hasFsp = 1 and fsp.Id is not null then 1
                             when @hasFsp = 0 and fsp.Id is null     then 1
                          else 0
                        end = 1
                    and ssm.Deactivated = 0
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
                  , case when @approved = 0 then ssm.TotalIB else ssm.TotalIB_Approved end

                  , case when @approved = 0 then ssm.ReinsuranceFlatfee else ssm.ReinsuranceFlatfee_Approved end
                  , case when @approved = 0 then ssm.CurrencyReinsurance else ssm.CurrencyReinsurance_Approved end
                  , case when @approved = 0 then ssm.RecommendedSwSpMaintenanceListPrice else ssm.RecommendedSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.MarkupForProductMarginSwLicenseListPrice else ssm.MarkupForProductMarginSwLicenseListPrice_Approved end
                  , case when @approved = 0 then ssm.ShareSwSpMaintenanceListPrice else ssm.ShareSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.DiscountDealerPrice else ssm.DiscountDealerPrice_Approved end

                  , ssm.FspId
                  , ssm.Fsp

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
                  , case when @approved = 0 then ssm.TotalIB else ssm.TotalIB_Approved end

                  , case when @approved = 0 then ssm.ReinsuranceFlatfee else ssm.ReinsuranceFlatfee_Approved end
                  , case when @approved = 0 then ssm.CurrencyReinsurance else ssm.CurrencyReinsurance_Approved end
                  , case when @approved = 0 then ssm.RecommendedSwSpMaintenanceListPrice else ssm.RecommendedSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.MarkupForProductMarginSwLicenseListPrice else ssm.MarkupForProductMarginSwLicenseListPrice_Approved end
                  , case when @approved = 0 then ssm.ShareSwSpMaintenanceListPrice else ssm.ShareSwSpMaintenanceListPrice_Approved end
                  , case when @approved = 0 then ssm.DiscountDealerPrice else ssm.DiscountDealerPrice_Approved end

                , fsp.Id as FspId
                , fsp.Name as Fsp

            FROM SoftwareSolution.SwSpMaintenance ssm
            JOIN Dependencies.Duration_Availability ya on ya.Id = ssm.DurationAvailability
            LEFT JOIN Fsp.SwFspCodeTranslation fsp on fsp.SwDigitId = ssm.SwDigit
                                and fsp.AvailabilityId = ssm.Availability
                                and fsp.DurationId = ya.YearId

            WHERE (@isEmptyDigit = 1 or ssm.SwDigit in (select id from @digit))
                AND (@isEmptyAV = 1 or ya.AvailabilityId in (select id from @av))
                AND (@isEmptyYear = 1 or ya.YearId in (select id from @year))
                and (@fsp is null or fsp.Name like '%' + @fsp + '%')
                AND case when @hasFsp is null                    then 1 
                         when @hasFsp = 1 and fsp.Id is not null then 1
                         when @hasFsp = 0 and fsp.Id is null     then 1
                         else 0
                    end = 1
                and ssm.Deactivated = 0

        end

    RETURN;
END
go

ALTER FUNCTION [SoftwareSolution].[GetCosts] (
    @approved bit,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly,
    @lastid bigint,
    @limit int
)
RETURNS TABLE 
AS
RETURN 
(
    with GermanyServiceCte as (
        SELECT top(1)
                  case when @approved = 0 then ssc.[1stLevelSupportCostsCountry] else ssc.[1stLevelSupportCostsCountry_Approved] end / er.Value as [1stLevelSupportCosts]
                , case when @approved = 0 then ssc.TotalIb else TotalIb_Approved end as TotalIb

        FROM Hardware.ServiceSupportCost ssc
        JOIN InputAtoms.Country c on c.Id = ssc.Country and c.ISO3CountryCode = 'DEU' --install base by Germany!
        LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId
    )
    , SwSpMaintenanceCte0 as (
            SELECT  ssm.rownum
                    , ssm.Id
                    , ssm.SwDigit
                    , ssm.Sog
                    , ssm.Pla
                    , ssm.Sfab
                    , ssm.Availability
                    , ssm.Year
                    , y.Value as YearValue
                    , y.IsProlongation

                    , ssm.FspId
                    , ssm.Fsp

                    , ssm.[2ndLevelSupportCosts]
                    , ssm.InstalledBaseSog
                    , ssm.TotalInstalledBaseSog
           
                    , case when ssm.ReinsuranceFlatfee is null 
                            then ssm.ShareSwSpMaintenanceListPrice / 100 * ssm.RecommendedSwSpMaintenanceListPrice 
                            else ssm.ReinsuranceFlatfee / er.Value
                       end as Reinsurance

                    , ssm.ShareSwSpMaintenanceListPrice / 100                      as ShareSwSpMaintenance

                    , ssm.RecommendedSwSpMaintenanceListPrice                      as MaintenanceListPrice

                    , ssm.MarkupForProductMarginSwLicenseListPrice / 100           as MarkupForProductMargin

                    , ssm.DiscountDealerPrice / 100                                as DiscountDealerPrice

            FROM SoftwareSolution.GetSwSpMaintenancePaging(@approved, @digit, @av, @year, @lastid, @limit) ssm
            INNER JOIN Dependencies.Year y on y.Id = ssm.Year
            LEFT JOIN [References].ExchangeRate er on er.CurrencyId = ssm.CurrencyReinsurance    
    )
    , SwSpMaintenanceCte as (
        select    m.*
                , ssc.[1stLevelSupportCosts]
                , ssc.TotalIb

                , SoftwareSolution.CalcSrvSupportCost(ssc.[1stLevelSupportCosts], m.[2ndLevelSupportCosts], ssc.TotalIb, m.InstalledBaseSog) as ServiceSupportPerYear

        from SwSpMaintenanceCte0 m, GermanyServiceCte ssc 
    )
    , SwSpMaintenanceCte2 as (
        select m.*

                , m.ServiceSupportPerYear * m.YearValue as ServiceSupport

                , SoftwareSolution.CalcTransferPrice(m.Reinsurance, m.ServiceSupportPerYear * m.YearValue) as TransferPrice

            from SwSpMaintenanceCte m
    )
    , SwSpMaintenanceCte3 as (
        select m.rownum
                , m.Id
                , m.SwDigit
                , m.Sog
                , m.Pla
                , m.Sfab
                , m.Availability
                , m.Year

                , m.FspId
                , m.Fsp

                , m.[1stLevelSupportCosts]
                , m.[2ndLevelSupportCosts]
                , m.InstalledBaseSog
                , m.TotalIb as InstalledBaseCountry
                , m.TotalInstalledBaseSog
                , m.Reinsurance
                , m.ShareSwSpMaintenance
                , m.DiscountDealerPrice
                , m.ServiceSupport
                , m.TransferPrice

            , case when m.MaintenanceListPrice is null 
                        then SoftwareSolution.CalcMaintenanceListPrice(m.TransferPrice, m.MarkupForProductMargin)
                        else m.MaintenanceListPrice
                end as MaintenanceListPrice

        from SwSpMaintenanceCte2 m
    )
    select m.*
            , SoftwareSolution.CalcDealerPrice(m.MaintenanceListPrice, m.DiscountDealerPrice) as DealerPrice 
    from SwSpMaintenanceCte3 m
)
go

if OBJECT_ID('[SoftwareSolution].[GetCosts2]') is not null
    drop function [SoftwareSolution].[GetCosts2];
go

create FUNCTION [SoftwareSolution].[GetCosts2] (
    @approved bit,
    @fsp nvarchar(255),
    @hasFsp bit,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly,
    @lastid bigint,
    @limit int
)
RETURNS TABLE 
AS
RETURN 
(
    with GermanyServiceCte as (
        SELECT top(1)
                  case when @approved = 0 then ssc.[1stLevelSupportCostsCountry] else ssc.[1stLevelSupportCostsCountry_Approved] end / er.Value as [1stLevelSupportCosts]
                , case when @approved = 0 then ssc.TotalIb else TotalIb_Approved end as TotalIb

        FROM Hardware.ServiceSupportCost ssc
        JOIN InputAtoms.Country c on c.Id = ssc.Country and c.ISO3CountryCode = 'DEU' --install base by Germany!
        LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId
    )
    , SwSpMaintenanceCte0 as (
            SELECT  ssm.rownum
                    , ssm.Id
                    , ssm.SwDigit
                    , ssm.Sog
                    , ssm.Pla
                    , ssm.Sfab
                    , ssm.Availability
                    , ssm.Year
                    , y.Value as YearValue
                    , y.IsProlongation

                    , ssm.FspId
                    , ssm.Fsp

                    , ssm.[2ndLevelSupportCosts]
                    , ssm.InstalledBaseSog
                    , ssm.TotalInstalledBaseSog
           
                    , case when ssm.ReinsuranceFlatfee is null 
                            then ssm.ShareSwSpMaintenanceListPrice / 100 * ssm.RecommendedSwSpMaintenanceListPrice 
                            else ssm.ReinsuranceFlatfee / er.Value
                       end as Reinsurance

                    , ssm.ShareSwSpMaintenanceListPrice / 100                      as ShareSwSpMaintenance

                    , ssm.RecommendedSwSpMaintenanceListPrice                      as MaintenanceListPrice

                    , ssm.MarkupForProductMarginSwLicenseListPrice / 100           as MarkupForProductMargin

                    , ssm.DiscountDealerPrice / 100                                as DiscountDealerPrice

            FROM SoftwareSolution.GetSwSpMaintenancePaging2(@approved, @fsp, @hasFsp, @digit, @av, @year, @lastid, @limit) ssm
            INNER JOIN Dependencies.Year y on y.Id = ssm.Year
            LEFT JOIN [References].ExchangeRate er on er.CurrencyId = ssm.CurrencyReinsurance    
    )
    , SwSpMaintenanceCte as (
        select    m.*
                , ssc.[1stLevelSupportCosts]
                , ssc.TotalIb

                , SoftwareSolution.CalcSrvSupportCost(ssc.[1stLevelSupportCosts], m.[2ndLevelSupportCosts], ssc.TotalIb, m.InstalledBaseSog) as ServiceSupportPerYear

        from SwSpMaintenanceCte0 m, GermanyServiceCte ssc 
    )
    , SwSpMaintenanceCte2 as (
        select m.*

                , m.ServiceSupportPerYear * m.YearValue as ServiceSupport

                , SoftwareSolution.CalcTransferPrice(m.Reinsurance, m.ServiceSupportPerYear * m.YearValue) as TransferPrice

            from SwSpMaintenanceCte m
    )
    , SwSpMaintenanceCte3 as (
        select m.rownum
                , m.Id
                , m.SwDigit
                , m.Sog
                , m.Pla
                , m.Sfab
                , m.Availability
                , m.Year

                , m.FspId
                , m.Fsp

                , m.[1stLevelSupportCosts]
                , m.[2ndLevelSupportCosts]
                , m.InstalledBaseSog
                , m.TotalIb as InstalledBaseCountry
                , m.TotalInstalledBaseSog
                , m.Reinsurance
                , m.ShareSwSpMaintenance
                , m.DiscountDealerPrice
                , m.ServiceSupport
                , m.TransferPrice

            , case when m.MaintenanceListPrice is null 
                        then SoftwareSolution.CalcMaintenanceListPrice(m.TransferPrice, m.MarkupForProductMargin)
                        else m.MaintenanceListPrice
                end as MaintenanceListPrice

        from SwSpMaintenanceCte2 m
    )
    select m.*
            , SoftwareSolution.CalcDealerPrice(m.MaintenanceListPrice, m.DiscountDealerPrice) as DealerPrice 
    from SwSpMaintenanceCte3 m
)
go

ALTER PROCEDURE [SoftwareSolution].[SpGetCosts]
    @approved bit,
    @fsp nvarchar(255),
    @hasFsp bit,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly,
    @lastid bigint,
    @limit int
AS
BEGIN

    SET NOCOUNT ON;

    select  m.rownum
          , m.Id
          , m.Fsp
          , d.Name as SwDigit
          , sog.Name as Sog
          , av.Name as Availability 
          , dr.Name as Duration
          , m.[1stLevelSupportCosts]
          , m.[2ndLevelSupportCosts]
          , m.InstalledBaseCountry
          , m.InstalledBaseSog
          , m.TotalInstalledBaseSog
          , m.Reinsurance
          , m.ServiceSupport
          , m.TransferPrice
          , m.MaintenanceListPrice
          , m.DealerPrice
          , m.DiscountDealerPrice
    from SoftwareSolution.GetCosts2(@approved, @fsp, @hasFsp, @digit, @av, @year, @lastid, @limit) m
    join InputAtoms.SwDigit d on d.Id = m.SwDigit
    join InputAtoms.Sog sog on sog.Id = m.Sog
    join Dependencies.Availability av on av.Id = m.Availability
    join Dependencies.Duration dr on dr.Id = m.Year

    order by m.rownum

END
go

ALTER FUNCTION [SoftwareSolution].[GetProActivePaging] (
     @approved bit,
     @cnt dbo.ListID readonly,
     @digit dbo.ListID readonly,
     @av dbo.ListID readonly,
     @year dbo.ListID readonly,
     @lastid bigint,
     @limit int
)
RETURNS @tbl TABLE 
        (   
            rownum                                  int NOT NULL,
            Id                                      bigint,
            Country                                 bigint,
            Pla                                     bigint,
            Sog                                     bigint,
                                                    
            SwDigit                                 bigint,
                                                    
            FspId                                   bigint,
            Fsp                                     nvarchar(30),
            FspServiceDescription                   nvarchar(max),
            AvailabilityId                          bigint,
            DurationId                              bigint,
            ReactionTimeId                          bigint,
            ReactionTypeId                          bigint,
            ServiceLocationId                       bigint,
            ProactiveSlaId                          bigint,

            LocalRemoteAccessSetupPreparationEffort float,
            LocalRegularUpdateReadyEffort           float,
            LocalPreparationShcEffort               float,
            CentralExecutionShcReportCost           float,
            LocalRemoteShcCustomerBriefingEffort    float,
            LocalOnSiteShcCustomerBriefingEffort    float,
            TravellingTime                          float,
            OnSiteHourlyRate                        float
        )
AS
BEGIN
		declare @isEmptyCnt    bit = Portfolio.IsListEmpty(@cnt);
		declare @isEmptyDigit    bit = Portfolio.IsListEmpty(@digit);
		declare @isEmptyAV    bit = Portfolio.IsListEmpty(@av);
		declare @isEmptyYear    bit = Portfolio.IsListEmpty(@year);

        if @limit > 0
        begin
            with FspCte as (
                select fsp.*
                from fsp.SwFspCodeTranslation fsp
                join Dependencies.ProActiveSla pro on pro.id = fsp.ProactiveSlaId and pro.Name <> '0'
				where (@isEmptyDigit = 1 or fsp.SwDigitId in (select id from @digit))
					AND (@isEmptyAV = 1 or fsp.AvailabilityId in (select id from @av))
					AND (@isEmptyYear = 1 or fsp.DurationId in (select id from @year))
            )
            , cte as (
                select ROW_NUMBER() over(
                            order by
                               pro.SwDigit
                             , fsp.AvailabilityId
                             , fsp.DurationId
                             , fsp.ReactionTimeId
                             , fsp.ReactionTypeId
                             , fsp.ServiceLocationId
                             , fsp.ProactiveSlaId
                         ) as rownum
                     , pro.Id
                     , pro.Country
                     , pro.Pla
                     , pro.Sog

                     , pro.SwDigit

                     , fsp.id as FspId
                     , fsp.Name as Fsp
                     , fsp.ServiceDescription as FspServiceDescription
                     , fsp.AvailabilityId
                     , fsp.DurationId
                     , fsp.ReactionTimeId
                     , fsp.ReactionTypeId
                     , fsp.ServiceLocationId
                     , fsp.ProactiveSlaId

                     , case when @approved = 0 then pro.LocalRemoteAccessSetupPreparationEffort  else pro.LocalRemoteAccessSetupPreparationEffort       end as LocalRemoteAccessSetupPreparationEffort
                     , case when @approved = 0 then pro.LocalRegularUpdateReadyEffort            else pro.LocalRegularUpdateReadyEffort_Approved        end as LocalRegularUpdateReadyEffort           
                     , case when @approved = 0 then pro.LocalPreparationShcEffort                else pro.LocalPreparationShcEffort_Approved            end as LocalPreparationShcEffort
                     , case when @approved = 0 then pro.CentralExecutionShcReportCost            else pro.CentralExecutionShcReportCost_Approved        end as CentralExecutionShcReportCost
                     , case when @approved = 0 then pro.LocalRemoteShcCustomerBriefingEffort     else pro.LocalRemoteShcCustomerBriefingEffort_Approved end as LocalRemoteShcCustomerBriefingEffort
                     , case when @approved = 0 then pro.LocalOnSiteShcCustomerBriefingEffort     else pro.LocalOnSiteShcCustomerBriefingEffort_Approved end as LocalOnSiteShcCustomerBriefingEffort
                     , case when @approved = 0 then pro.TravellingTime                           else pro.TravellingTime_Approved                       end as TravellingTime
                     , case when @approved = 0 then pro.OnSiteHourlyRate                         else pro.OnSiteHourlyRate_Approved                     end as OnSiteHourlyRate

                    FROM SoftwareSolution.ProActiveSw pro
                    LEFT JOIN FspCte fsp ON fsp.SwDigitId = pro.SwDigit

				    WHERE pro.Deactivated = 0
                    and (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))
				    AND (@isEmptyDigit = 1 or pro.SwDigit in (select id from @digit))
					AND (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))

            )
            INSERT @tbl
            SELECT *
            from cte pro where pro.rownum > @lastid
        end
    else
        begin
            with FspCte as (
                select fsp.*
                from fsp.SwFspCodeTranslation fsp
                join Dependencies.ProActiveSla pro on pro.id = fsp.ProactiveSlaId and pro.Name <> '0'
				where (@isEmptyDigit = 1 or fsp.SwDigitId in (select id from @digit))
				AND (@isEmptyAV = 1 or fsp.AvailabilityId in (select id from @av))
				AND (@isEmptyYear = 1 or fsp.DurationId in (select id from @year))
            )
            INSERT @tbl
            SELECT -1 as rownum
                 , pro.Id
                 , pro.Country
                 , pro.Pla
                 , pro.Sog

                 , pro.SwDigit

                 , fsp.id as FspId
                 , fsp.Name as Fsp
                 , fsp.ServiceDescription as FspServiceDescription
                 , fsp.AvailabilityId
                 , fsp.DurationId
                 , fsp.ReactionTimeId
                 , fsp.ReactionTypeId
                 , fsp.ServiceLocationId
                 , fsp.ProactiveSlaId

                 , case when @approved = 0 then pro.LocalRemoteAccessSetupPreparationEffort  else pro.LocalRemoteAccessSetupPreparationEffort       end as LocalRemoteAccessSetupPreparationEffort
                 , case when @approved = 0 then pro.LocalRegularUpdateReadyEffort            else pro.LocalRegularUpdateReadyEffort_Approved        end as LocalRegularUpdateReadyEffort           
                 , case when @approved = 0 then pro.LocalPreparationShcEffort                else pro.LocalPreparationShcEffort_Approved            end as LocalPreparationShcEffort
                 , case when @approved = 0 then pro.CentralExecutionShcReportCost            else pro.CentralExecutionShcReportCost_Approved        end as CentralExecutionShcReportCost
                 , case when @approved = 0 then pro.LocalRemoteShcCustomerBriefingEffort     else pro.LocalRemoteShcCustomerBriefingEffort_Approved end as LocalRemoteShcCustomerBriefingEffort
                 , case when @approved = 0 then pro.LocalOnSiteShcCustomerBriefingEffort     else pro.LocalOnSiteShcCustomerBriefingEffort_Approved end as LocalOnSiteShcCustomerBriefingEffort
                 , case when @approved = 0 then pro.TravellingTime                           else pro.TravellingTime_Approved                       end as TravellingTime
                 , case when @approved = 0 then pro.OnSiteHourlyRate                         else pro.OnSiteHourlyRate_Approved                     end as OnSiteHourlyRate

                FROM SoftwareSolution.ProActiveSw pro
                LEFT JOIN FspCte fsp ON fsp.SwDigitId = pro.SwDigit

				WHERE pro.Deactivated = 0
                and (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))
				AND (@isEmptyDigit = 1 or pro.SwDigit in (select id from @digit))
				AND (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))

        end

    RETURN;
END
go

if OBJECT_ID('[SoftwareSolution].[GetProActivePaging2]') is not null
    drop function [SoftwareSolution].[GetProActivePaging2];
go

create FUNCTION [SoftwareSolution].[GetProActivePaging2] (
     @approved bit,
     @cnt dbo.ListID readonly,
     @fsp nvarchar(255),
     @hasFsp bit,
     @digit dbo.ListID readonly,
     @av dbo.ListID readonly,
     @year dbo.ListID readonly,
     @lastid bigint,
     @limit int
)
RETURNS @tbl TABLE 
        (   
            rownum                                  int NOT NULL,
            Id                                      bigint,
            Country                                 bigint,
            Pla                                     bigint,
            Sog                                     bigint,
                                                    
            SwDigit                                 bigint,
                                                    
            FspId                                   bigint,
            Fsp                                     nvarchar(30),
            FspServiceDescription                   nvarchar(max),
            AvailabilityId                          bigint,
            DurationId                              bigint,
            ReactionTimeId                          bigint,
            ReactionTypeId                          bigint,
            ServiceLocationId                       bigint,
            ProactiveSlaId                          bigint,

            LocalRemoteAccessSetupPreparationEffort float,
            LocalRegularUpdateReadyEffort           float,
            LocalPreparationShcEffort               float,
            CentralExecutionShcReportCost           float,
            LocalRemoteShcCustomerBriefingEffort    float,
            LocalOnSiteShcCustomerBriefingEffort    float,
            TravellingTime                          float,
            OnSiteHourlyRate                        float
        )
AS
BEGIN
		declare @isEmptyCnt    bit = Portfolio.IsListEmpty(@cnt);
		declare @isEmptyDigit    bit = Portfolio.IsListEmpty(@digit);
		declare @isEmptyAV    bit = Portfolio.IsListEmpty(@av);
		declare @isEmptyYear    bit = Portfolio.IsListEmpty(@year);

        if @hasFsp = 0 set @fsp = null;

        if @limit > 0
        begin
            with FspCte as (
                select fsp.*
                from fsp.SwFspCodeTranslation fsp
                join Dependencies.ProActiveSla pro on pro.id = fsp.ProactiveSlaId and pro.Name <> '0'
				where (@isEmptyDigit = 1 or fsp.SwDigitId in (select id from @digit))
					AND (@isEmptyAV = 1 or fsp.AvailabilityId in (select id from @av))
					AND (@isEmptyYear = 1 or fsp.DurationId in (select id from @year))
            )
            , cte as (
                select ROW_NUMBER() over(
                            order by
                               pro.SwDigit
                             , fsp.AvailabilityId
                             , fsp.DurationId
                             , fsp.ReactionTimeId
                             , fsp.ReactionTypeId
                             , fsp.ServiceLocationId
                             , fsp.ProactiveSlaId
                         ) as rownum
                     , pro.Id
                     , pro.Country
                     , pro.Pla
                     , pro.Sog

                     , pro.SwDigit

                     , fsp.id as FspId
                     , fsp.Name as Fsp
                     , fsp.ServiceDescription as FspServiceDescription
                     , fsp.AvailabilityId
                     , fsp.DurationId
                     , fsp.ReactionTimeId
                     , fsp.ReactionTypeId
                     , fsp.ServiceLocationId
                     , fsp.ProactiveSlaId

                     , case when @approved = 0 then pro.LocalRemoteAccessSetupPreparationEffort  else pro.LocalRemoteAccessSetupPreparationEffort       end as LocalRemoteAccessSetupPreparationEffort
                     , case when @approved = 0 then pro.LocalRegularUpdateReadyEffort            else pro.LocalRegularUpdateReadyEffort_Approved        end as LocalRegularUpdateReadyEffort           
                     , case when @approved = 0 then pro.LocalPreparationShcEffort                else pro.LocalPreparationShcEffort_Approved            end as LocalPreparationShcEffort
                     , case when @approved = 0 then pro.CentralExecutionShcReportCost            else pro.CentralExecutionShcReportCost_Approved        end as CentralExecutionShcReportCost
                     , case when @approved = 0 then pro.LocalRemoteShcCustomerBriefingEffort     else pro.LocalRemoteShcCustomerBriefingEffort_Approved end as LocalRemoteShcCustomerBriefingEffort
                     , case when @approved = 0 then pro.LocalOnSiteShcCustomerBriefingEffort     else pro.LocalOnSiteShcCustomerBriefingEffort_Approved end as LocalOnSiteShcCustomerBriefingEffort
                     , case when @approved = 0 then pro.TravellingTime                           else pro.TravellingTime_Approved                       end as TravellingTime
                     , case when @approved = 0 then pro.OnSiteHourlyRate                         else pro.OnSiteHourlyRate_Approved                     end as OnSiteHourlyRate

                    FROM SoftwareSolution.ProActiveSw pro
                    LEFT JOIN FspCte fsp ON fsp.SwDigitId = pro.SwDigit

				    WHERE pro.Deactivated = 0
                    and (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))
				    AND (@isEmptyDigit = 1 or pro.SwDigit in (select id from @digit))
					AND (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))
                    and (@fsp is null or fsp.Name like '%' + @fsp + '%')
                    and case when @hasFsp is null                    then 1 
                             when @hasFsp = 1 and fsp.Id is not null then 1
                             when @hasFsp = 0 and fsp.Id is null     then 1
                             else 0
                          end = 1

            )
            INSERT @tbl
            SELECT *
            from cte pro where pro.rownum > @lastid
        end
    else
        begin
            with FspCte as (
                select fsp.*
                from fsp.SwFspCodeTranslation fsp
                join Dependencies.ProActiveSla pro on pro.id = fsp.ProactiveSlaId and pro.Name <> '0'
				where (@isEmptyDigit = 1 or fsp.SwDigitId in (select id from @digit))
				AND (@isEmptyAV = 1 or fsp.AvailabilityId in (select id from @av))
				AND (@isEmptyYear = 1 or fsp.DurationId in (select id from @year))
            )
            INSERT @tbl
            SELECT -1 as rownum
                 , pro.Id
                 , pro.Country
                 , pro.Pla
                 , pro.Sog

                 , pro.SwDigit

                 , fsp.id as FspId
                 , fsp.Name as Fsp
                 , fsp.ServiceDescription as FspServiceDescription
                 , fsp.AvailabilityId
                 , fsp.DurationId
                 , fsp.ReactionTimeId
                 , fsp.ReactionTypeId
                 , fsp.ServiceLocationId
                 , fsp.ProactiveSlaId

                 , case when @approved = 0 then pro.LocalRemoteAccessSetupPreparationEffort  else pro.LocalRemoteAccessSetupPreparationEffort       end as LocalRemoteAccessSetupPreparationEffort
                 , case when @approved = 0 then pro.LocalRegularUpdateReadyEffort            else pro.LocalRegularUpdateReadyEffort_Approved        end as LocalRegularUpdateReadyEffort           
                 , case when @approved = 0 then pro.LocalPreparationShcEffort                else pro.LocalPreparationShcEffort_Approved            end as LocalPreparationShcEffort
                 , case when @approved = 0 then pro.CentralExecutionShcReportCost            else pro.CentralExecutionShcReportCost_Approved        end as CentralExecutionShcReportCost
                 , case when @approved = 0 then pro.LocalRemoteShcCustomerBriefingEffort     else pro.LocalRemoteShcCustomerBriefingEffort_Approved end as LocalRemoteShcCustomerBriefingEffort
                 , case when @approved = 0 then pro.LocalOnSiteShcCustomerBriefingEffort     else pro.LocalOnSiteShcCustomerBriefingEffort_Approved end as LocalOnSiteShcCustomerBriefingEffort
                 , case when @approved = 0 then pro.TravellingTime                           else pro.TravellingTime_Approved                       end as TravellingTime
                 , case when @approved = 0 then pro.OnSiteHourlyRate                         else pro.OnSiteHourlyRate_Approved                     end as OnSiteHourlyRate

                FROM SoftwareSolution.ProActiveSw pro
                LEFT JOIN FspCte fsp ON fsp.SwDigitId = pro.SwDigit

				WHERE pro.Deactivated = 0
                AND (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))
				AND (@isEmptyDigit = 1 or pro.SwDigit in (select id from @digit))
				AND (@isEmptyCnt = 1 or pro.Country in (select id from @cnt))
                AND (@fsp is null or fsp.Name like '%' + @fsp + '%')
                AND case when @hasFsp is null                   then 1 
                         when @hasFsp = 1 and fsp.Id is not null then 1
                         when @hasFsp = 0 and fsp.Id is null     then 1
                         else 0
                      end = 1
        end

    RETURN;
END
go

ALTER FUNCTION [SoftwareSolution].[GetProActiveCosts] (
     @approved bit,
     @cnt dbo.ListID readonly,
     @digit dbo.ListID readonly,
     @av dbo.ListID readonly,
     @year dbo.ListID readonly,
     @lastid bigint,
     @limit int
)
RETURNS TABLE 
AS
RETURN 
(
    with ProActiveCte as (
        select    pro.rownum                
                , pro.Id                    
                , pro.Country               
                , pro.Pla                   
                , pro.Sog                   
                , pro.SwDigit               
                , pro.FspId                 
                , pro.Fsp                   
                , pro.FspServiceDescription 
                , pro.AvailabilityId        
                , pro.DurationId            
                , pro.ReactionTimeId        
                , pro.ReactionTypeId        
                , pro.ServiceLocationId     
                , pro.ProactiveSlaId        

                , pro.LocalPreparationShcEffort * pro.OnSiteHourlyRate * sla.LocalPreparationShcRepetition as LocalPreparation

                , pro.LocalRegularUpdateReadyEffort * pro.OnSiteHourlyRate * sla.LocalRegularUpdateReadyRepetition as LocalRegularUpdate

                , pro.LocalRemoteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * sla.LocalRemoteShcCustomerBriefingRepetition as LocalRemoteCustomerBriefing
                
                , pro.LocalOnsiteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * sla.LocalOnsiteShcCustomerBriefingRepetition as LocalOnsiteCustomerBriefing
                
                , pro.TravellingTime * pro.OnSiteHourlyRate * sla.TravellingTimeRepetition as Travel

                , pro.CentralExecutionShcReportCost * sla.CentralExecutionShcReportRepetition as CentralExecutionReport

                , pro.LocalRemoteAccessSetupPreparationEffort * pro.OnSiteHourlyRate as Setup

        FROM SoftwareSolution.GetProActivePaging(@approved, @cnt, @digit, @av, @year, @lastid, @limit) pro
        LEFT JOIN Dependencies.ProActiveSla sla on sla.id = pro.ProactiveSlaId
    )
    , ProActiveCte2 as (
         select pro.*

               , pro.LocalPreparation + 
                 pro.LocalRegularUpdate + 
                 pro.LocalRemoteCustomerBriefing +
                 pro.LocalOnsiteCustomerBriefing +
                 pro.Travel +
                 pro.CentralExecutionReport as Service

        from ProActiveCte pro
    )
    select pro.*
         , Hardware.CalcProActive(pro.Setup, pro.Service, dur.Value) as ProActive
    from ProActiveCte2 pro
    LEFT JOIN Dependencies.Duration dur on dur.Id = pro.DurationId
);
go

if OBJECT_ID('[SoftwareSolution].[GetProActiveCosts2]') is not null
    drop function [SoftwareSolution].[GetProActiveCosts2];
go

create FUNCTION [SoftwareSolution].[GetProActiveCosts2] (
     @approved bit,
     @cnt dbo.ListID readonly,
     @fsp nvarchar(255),
     @hasFsp bit,
     @digit dbo.ListID readonly,
     @av dbo.ListID readonly,
     @year dbo.ListID readonly,
     @lastid bigint,
     @limit int
)
RETURNS TABLE 
AS
RETURN 
(
    with ProActiveCte as (
        select    pro.rownum                
                , pro.Id                    
                , pro.Country               
                , pro.Pla                   
                , pro.Sog                   
                , pro.SwDigit               
                , pro.FspId                 
                , pro.Fsp                   
                , pro.FspServiceDescription 
                , pro.AvailabilityId        
                , pro.DurationId            
                , pro.ReactionTimeId        
                , pro.ReactionTypeId        
                , pro.ServiceLocationId     
                , pro.ProactiveSlaId        

                , pro.LocalPreparationShcEffort * pro.OnSiteHourlyRate * sla.LocalPreparationShcRepetition as LocalPreparation

                , pro.LocalRegularUpdateReadyEffort * pro.OnSiteHourlyRate * sla.LocalRegularUpdateReadyRepetition as LocalRegularUpdate

                , pro.LocalRemoteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * sla.LocalRemoteShcCustomerBriefingRepetition as LocalRemoteCustomerBriefing
                
                , pro.LocalOnsiteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * sla.LocalOnsiteShcCustomerBriefingRepetition as LocalOnsiteCustomerBriefing
                
                , pro.TravellingTime * pro.OnSiteHourlyRate * sla.TravellingTimeRepetition as Travel

                , pro.CentralExecutionShcReportCost * sla.CentralExecutionShcReportRepetition as CentralExecutionReport

                , pro.LocalRemoteAccessSetupPreparationEffort * pro.OnSiteHourlyRate as Setup

        FROM SoftwareSolution.GetProActivePaging2(@approved, @cnt, @fsp, @hasFsp, @digit, @av, @year, @lastid, @limit) pro
        LEFT JOIN Dependencies.ProActiveSla sla on sla.id = pro.ProactiveSlaId
    )
    , ProActiveCte2 as (
         select pro.*

               , pro.LocalPreparation + 
                 pro.LocalRegularUpdate + 
                 pro.LocalRemoteCustomerBriefing +
                 pro.LocalOnsiteCustomerBriefing +
                 pro.Travel +
                 pro.CentralExecutionReport as Service

        from ProActiveCte pro
    )
    select pro.*
         , Hardware.CalcProActive(pro.Setup, pro.Service, dur.Value) as ProActive
    from ProActiveCte2 pro
    LEFT JOIN Dependencies.Duration dur on dur.Id = pro.DurationId
);
go

ALTER PROCEDURE [SoftwareSolution].[SpGetProActiveCosts]
    @approved bit,
    @cnt dbo.ListID readonly,
    @fsp nvarchar(255),
    @hasFsp bit,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly,
    @lastid bigint,
    @limit int
AS
BEGIN

    SET NOCOUNT ON;

    select    m.rownum
            , m.Fsp
            , c.Name as Country               
            , sog.Name as Sog                   
            , d.Name as SwDigit               

            , av.Name as Availability
            , y.Name as Year
            , pro.ExternalName as ProactiveSla

            , m.ProActive

    FROM SoftwareSolution.GetProActiveCosts2(@approved, @cnt, @fsp, @hasFsp, @digit, @av, @year, @lastid, @limit) m
    JOIN InputAtoms.Country c on c.id = m.Country
    join InputAtoms.SwDigit d on d.Id = m.SwDigit
    join InputAtoms.Sog sog on sog.Id = d.SogId
    left join Dependencies.Availability av on av.Id = m.AvailabilityId
    left join Dependencies.Year y on y.Id = m.DurationId
    left join Dependencies.ProActiveSla pro on pro.Id = m.ProactiveSlaId

    order by m.rownum;

END


