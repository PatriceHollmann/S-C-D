IF OBJECT_ID('Hardware.GetReleaseCosts') IS NOT NULL
  DROP FUNCTION Hardware.GetReleaseCosts;
GO

CREATE FUNCTION Hardware.GetReleaseCosts (
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
    with ReinsuranceCte as (
        select r.Wg
             , ta.ReactionTimeId
             , ta.AvailabilityId
             , r.ReinsuranceFlatfee_norm_Approved / er.Value as Cost
        from Hardware.Reinsurance r

        JOIN Dependencies.ReactionTime_Avalability ta on ta.Id = r.ReactionTimeAvailability and ta.IsDisabled = 0

        JOIN [References].ExchangeRate er on er.CurrencyId = r.CurrencyReinsurance_Approved

        where r.Duration = (select id from Dependencies.Duration where IsProlongation = 1 and Value = 1)
              and r.DeactivatedDateTime is null
    )
    , CostCte as (
        select    m.*

                , coalesce(m.AvailabilityFee, 0) as AvailabilityFeeOrZero

                , (1 - m.TimeAndMaterialShare) * (m.TravelCost + m.LabourCost + m.PerformanceRate) + m.TimeAndMaterialShare * ((m.TravelTime + m.repairTime) * m.OnsiteHourlyRates + m.PerformanceRate) as FieldServicePerYear

                , m.StandardHandling + m.HighAvailabilityHandling + m.StandardDelivery + m.ExpressDelivery + m.TaxiCourierDelivery + m.ReturnDeliveryFactory as LogisticPerYear

                , m.LocalRemoteAccessSetup + m.Year * (m.LocalPreparation + m.LocalRegularUpdate + m.LocalRemoteCustomerBriefing + m.LocalOnsiteCustomerBriefing + m.Travel + m.CentralExecutionReport) as ProActive

                , coalesce(r.Cost, 0) as ReinsuranceProlCost
       
        from Hardware.GetCalcMember(1, @cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m
        left join ReinsuranceCte r on r.Wg = m.WgId and r.ReactionTimeId = m.ReactionTimeId and r.AvailabilityId = m.AvailabilityId
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

        from CostCte m
    )
    , CostCte3 as (
        select    m.*

                , Hardware.MarkupOrFixValue(m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.ReinsuranceProlCost + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1
                , Hardware.MarkupOrFixValue(m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.ReinsuranceProlCost + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect2
                , Hardware.MarkupOrFixValue(m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.ReinsuranceProlCost + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect3
                , Hardware.MarkupOrFixValue(m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.ReinsuranceProlCost + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect4
                , Hardware.MarkupOrFixValue(m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.ReinsuranceProlCost + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect5
                , Hardware.MarkupOrFixValue(m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.ReinsuranceProlCost + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1P

        from CostCte2 m
    )
    , CostCte5 as (
        select m.*

             , m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.TaxAndDuties1  + m.ReinsuranceProlCost + m.OtherDirect1  + m.AvailabilityFeeOrZero - m.Credit1 as ServiceTP1
             , m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.TaxAndDuties2  + m.ReinsuranceProlCost + m.OtherDirect2  + m.AvailabilityFeeOrZero - m.Credit2 as ServiceTP2
             , m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.TaxAndDuties3  + m.ReinsuranceProlCost + m.OtherDirect3  + m.AvailabilityFeeOrZero - m.Credit3 as ServiceTP3
             , m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.TaxAndDuties4  + m.ReinsuranceProlCost + m.OtherDirect4  + m.AvailabilityFeeOrZero - m.Credit4 as ServiceTP4
             , m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.TaxAndDuties5  + m.ReinsuranceProlCost + m.OtherDirect5  + m.AvailabilityFeeOrZero - m.Credit5 as ServiceTP5
             , m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.TaxAndDuties1P + m.ReinsuranceProlCost + m.OtherDirect1P + m.AvailabilityFeeOrZero             as ServiceTP1P

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
    select m.Id

         --SLA

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
       
         , m.Credits

         , Hardware.PositiveValue(Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTC1, m.ServiceTC2, m.ServiceTC3, m.ServiceTC4, m.ServiceTC5, m.ServiceTC1P)) as ServiceTC
         , Hardware.PositiveValue(Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTP1, m.ServiceTP2, m.ServiceTP3, m.ServiceTP4, m.ServiceTP5, m.ServiceTP1P)) as ServiceTP

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
         , m.ServiceTP_Released

         , m.ReleaseDate
         , m.ChangeUserName
         , m.ChangeUserEmail

       from CostCte6 m
)

go

ALTER PROCEDURE [Hardware].[SpReleaseCosts]
    @usr          int, 
    @cnt          dbo.ListID readonly,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly,
    @portfolioIds dbo.ListID readonly
AS
BEGIN

    SET NOCOUNT ON;
    

	SELECT * INTO #temp 
	FROM Hardware.GetReleaseCosts(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, 0, 0) costs
	WHERE (not exists(select 1 from @portfolioIds) or costs.Id in (select Id from @portfolioIds))   
	--TODO: @portfolioIds case to be fixed in a future release 

	UPDATE mc
	SET [ServiceTP1_Released]  = case when dur.Value >= 1 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP1) end,
		[ServiceTP2_Released]  = case when dur.Value >= 2 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP2) end,
		[ServiceTP3_Released]  = case when dur.Value >= 3 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP3) end,
		[ServiceTP4_Released]  = case when dur.Value >= 4 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP4) end,
		[ServiceTP5_Released]  = case when dur.Value >= 5 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP5) end,
		[ServiceTP1P_Released] = case when dur.IsProlongation = 1                    then  COALESCE(costs.ServiceTPManual, costs.ServiceTP1P)            end,
		[ChangeUserId] = @usr,
        [ReleaseDate] = getdate()
	FROM [Hardware].[ManualCost] mc
	JOIN #temp costs on mc.PortfolioId = costs.Id
	JOIN Dependencies.Duration dur on costs.DurationId = dur.Id
	where costs.ServiceTPManual is not null or costs.ServiceTP is not null

	INSERT INTO [Hardware].[ManualCost] 
				([PortfolioId], 
				[ChangeUserId], 
                [ReleaseDate],
				[ServiceTP1_Released], [ServiceTP2_Released], [ServiceTP3_Released], [ServiceTP4_Released], [ServiceTP5_Released], [ServiceTP1P_Released])
	SELECT  costs.Id, 
			@usr, 
            getdate(),
			case when dur.Value >= 1 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP1) end,
			case when dur.Value >= 2 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP2) end,
			case when dur.Value >= 3 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP3) end,
			case when dur.Value >= 4 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP4) end,
			case when dur.Value >= 5 and dur.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / dur.Value, costs.ServiceTP5) end,
			case when dur.IsProlongation = 1                    then  COALESCE(costs.ServiceTPManual, costs.ServiceTP1P)            end
	FROM [Hardware].[ManualCost] mc
	RIGHT JOIN #temp costs on mc.PortfolioId = costs.Id
	JOIN Dependencies.Duration dur on costs.DurationId = dur.Id
	where mc.PortfolioId is null and (costs.ServiceTPManual is not null or costs.ServiceTP is not null)

	DROP table #temp
   
END

GO

ALTER FUNCTION [Report].[GetCosts]
(
    @cnt bigint,
    @wg bigint,
    @av bigint,
    @dur bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc bigint,
    @pro bigint
)
RETURNS @tbl TABLE (
           Id                                bigint
         , Fsp                               nvarchar(255)
         , FspDescription                    nvarchar(255)
         , CountryId                         bigint
         , Country                           nvarchar(255)
         , CurrencyId                        bigint
         , Currency                          nvarchar(255)
         , ExchangeRate                      float
         , WgId                              bigint
         , Wg                                nvarchar(255)
         , AvailabilityId                    bigint
         , Availability                      nvarchar(255)
         , DurationId                        bigint
         , Duration                          nvarchar(255)
         , Year                              int
         , IsProlongation                    bit
         , ReactionTimeId                    bigint
         , ReactionTime                      nvarchar(255)
         , ReactionTypeId                    bigint
         , ReactionType                      nvarchar(255)
         , ServiceLocationId                 bigint
         , ServiceLocation                   nvarchar(255)
         , ProActiveSlaId                    bigint
         , ProActiveSla                      nvarchar(255)
         , Sla                               nvarchar(255)
         , SlaHash                           int
         , StdWarranty                       float
         , AvailabilityFee                   float
         , TaxAndDutiesW                     float
         , TaxAndDutiesOow                   float
         , Reinsurance                       float
         , ProActive                         float
         , ServiceSupportCost                float
         , MaterialW                         float
         , MaterialOow                       float
         , FieldServiceCost                  float
         , Logistic                          float
         , OtherDirect                       float
         , LocalServiceStandardWarranty      float
         , Credits                           float
         , ServiceTC                         float
         , ServiceTP                         float
         , ServiceTC1                        float
         , ServiceTC2                        float
         , ServiceTC3                        float
         , ServiceTC4                        float
         , ServiceTC5                        float
         , ServiceTC1P                       float
         , ServiceTP1                        float
         , ServiceTP2                        float
         , ServiceTP3                        float
         , ServiceTP4                        float
         , ServiceTP5                        float
         , ServiceTP1P                       float
         , ListPrice                         float
         , DealerDiscount                    float
         , DealerPrice                       float
         , ServiceTCManual                   float
         , ServiceTPManual                   float
         , ServiceTP_Released                float
         , ChangeUserName                    nvarchar(255)
         , ChangeUserEmail                   nvarchar(255)
)
AS
begin

    declare @cntTable dbo.ListId; insert into @cntTable(id) values(@cnt);

    declare @wgTable dbo.ListId; if @wg is not null insert into @wgTable(id) values(@wg);

    declare @avTable dbo.ListId; if @av is not null insert into @avTable(id) values(@av);

    declare @durTable dbo.ListId; if @dur is not null insert into @durTable(id) values(@dur);

    declare @rtimeTable dbo.ListId; if @reactiontime is not null insert into @rtimeTable(id) values(@reactiontime);

    declare @rtypeTable dbo.ListId; if @reactiontype is not null insert into @rtypeTable(id) values(@reactiontype);

    declare @locTable dbo.ListId; if @loc is not null insert into @locTable(id) values(@loc);

    declare @proTable dbo.ListId; if @pro is not null insert into @proTable(id) values(@pro);
    
    insert into @tbl 
    select 
              c.Id                               
            , fsp.Name as Fsp                              
            , fsp.ServiceDescription as FspDescription                   
            , c.CountryId                        
            , c.Country                          
            , c.CurrencyId                       
            , c.Currency
            , c.ExchangeRate                     
            , c.WgId                             
            , c.Wg                               
            , c.AvailabilityId                   
            , c.Availability                     
            , c.DurationId                       
            , c.Duration                         
            , c.Year                             
            , c.IsProlongation                   
            , c.ReactionTimeId                   
            , c.ReactionTime                     
            , c.ReactionTypeId                   
            , c.ReactionType                     
            , c.ServiceLocationId                
            , c.ServiceLocation                  
            , c.ProActiveSlaId                   
            , c.ProActiveSla                     
            , c.Sla                              
            , c.SlaHash                          
            , c.StdWarranty                      
            , c.AvailabilityFee                  
            , c.TaxAndDutiesW                    
            , c.TaxAndDutiesOow                  
            , c.Reinsurance                      
            , c.ProActive                        
            , c.ServiceSupportCost               
            , c.MaterialW                        
            , c.MaterialOow                      
            , c.FieldServiceCost                 
            , c.Logistic                         
            , c.OtherDirect                      
            , c.LocalServiceStandardWarranty     
            , c.Credits                          
            , c.ServiceTC                        
            , c.ServiceTP                        
            , c.ServiceTC1                       
            , c.ServiceTC2                       
            , c.ServiceTC3                       
            , c.ServiceTC4                       
            , c.ServiceTC5                       
            , c.ServiceTC1P                      
            , c.ServiceTP1                       
            , c.ServiceTP2                       
            , c.ServiceTP3                       
            , c.ServiceTP4                       
            , c.ServiceTP5                       
            , c.ServiceTP1P                      
            , c.ListPrice                        
            , c.DealerDiscount                   
            , c.DealerPrice                      
            , c.ServiceTCManual                  
            , c.ServiceTPManual                  
            , c.ServiceTP_Released               
            , c.ChangeUserName                   
            , c.ChangeUserEmail                  
    from Hardware.GetCosts(1, @cntTable, @wgTable, @avTable, @durTable, @rtimeTable, @rtypeTable, @locTable, @proTable, null, null) c
    left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = c.SlaHash and fsp.Sla = c.Sla    
    return;
end

go

ALTER FUNCTION Report.Contract
(
    @cnt          bigint,
    @wg           bigint,
    @av           bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint
)
RETURNS TABLE 
AS
RETURN (
        WITH CountryCte as (
        select c.*, cur.Name as Currency, er.Value as ExchangeRate
        from InputAtoms.Country c 
        left join [References].Currency cur on cur.Id = c.CurrencyId
        left join [References].ExchangeRate er on er.CurrencyId = c.CurrencyId

        where c.id = @cnt        
    )
    select 
           m.Id
         , c.Name              as Country
         , wg.Name             as Wg
         , wg.Description      as WgDescription
         , null                as SLA
         , loc.Name            as ServiceLocation
         , rtime.Name          as ReactionTime
         , rtype.Name          as ReactionType
         , av.Name             as Availability
         , prosla.ExternalName as ProActiveSla

         , mc.ServiceTP1_Released * c.ExchangeRate      as ServiceTP1
         , mc.ServiceTP2_Released * c.ExchangeRate      as ServiceTP2
         , mc.ServiceTP3_Released * c.ExchangeRate      as ServiceTP3
         , mc.ServiceTP4_Released * c.ExchangeRate      as ServiceTP4
         , mc.ServiceTP5_Released * c.ExchangeRate      as ServiceTP5

         , mc.ServiceTP1_Released * c.ExchangeRate / 12 as ServiceTPMonthly1
         , mc.ServiceTP2_Released * c.ExchangeRate / 12 as ServiceTPMonthly2
         , mc.ServiceTP3_Released * c.ExchangeRate / 12 as ServiceTPMonthly3
         , mc.ServiceTP4_Released * c.ExchangeRate / 12 as ServiceTPMonthly4
         , mc.ServiceTP5_Released * c.ExchangeRate / 12 as ServiceTPMonthly5
         , c.Currency
       
          , stdw.DurationValue as WarrantyLevel
          , null               as PortfolioType
          , wg.Sog             as Sog

    FROM Portfolio.GetBySlaSingle(@cnt, @wg, @av, (select id from Dependencies.Duration where IsProlongation = 0 and Value = 5), @reactiontime, @reactiontype, @loc, @pro) m

    INNER JOIN CountryCte c on c.Id = m.CountryId

    INNER JOIN InputAtoms.WgSogView wg on wg.id = m.WgId

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    LEFT JOIN Fsp.HwStandardWarranty stdw ON stdw.Country = m.CountryId and stdw.Wg = m.WgId

    left join Hardware.ManualCost mc on mc.PortfolioId = m.Id
)
GO
