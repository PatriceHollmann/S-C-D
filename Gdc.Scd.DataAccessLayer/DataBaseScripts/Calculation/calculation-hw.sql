IF OBJECT_ID('Hardware.StandardWarrantyManualCost', 'U') IS NOT NULL
  DROP TABLE Hardware.StandardWarrantyManualCost;
go

CREATE TABLE Hardware.StandardWarrantyManualCost (
    [Id] [bigint] primary key IDENTITY(1,1) NOT NULL,
    [CountryId] [bigint] NOT NULL foreign key references InputAtoms.Country(Id),
    [WgId] [bigint] NOT NULL foreign key references InputAtoms.Wg(Id),
    [ChangeUserId] [bigint] NOT NULL foreign key references dbo.[User](Id),
    [ChangeDate] [datetime] NOT NULL,
    [StandardWarranty] [float] NULL
)
GO

CREATE UNIQUE INDEX [ix_StandardWarrantyManualCost_Country_Wg] ON [Hardware].[StandardWarrantyManualCost]([CountryId] ASC, [WgId] ASC)
GO

ALTER TABLE Hardware.AvailabilityFee DROP COLUMN CostPerKit_Approved;
go
ALTER TABLE Hardware.AvailabilityFee DROP COLUMN CostPerKitJapanBuy_Approved;
go
ALTER TABLE Hardware.AvailabilityFee DROP COLUMN MaxQty_Approved;
go
ALTER TABLE Hardware.AvailabilityFee
   ADD   CostPerKit_Approved          as (CostPerKit)
       , CostPerKitJapanBuy_Approved  as (CostPerKitJapanBuy)
       , MaxQty_Approved              as (MaxQty)
go

IF OBJECT_ID('Hardware.MaterialCostWarrantyCalc', 'U') IS NOT NULL
  DROP TABLE Hardware.MaterialCostWarrantyCalc;
go

CREATE TABLE Hardware.MaterialCostWarrantyCalc (
    [Country] [bigint] NOT NULL foreign key references InputAtoms.Country(Id),
    [Wg] [bigint] NOT NULL foreign key references InputAtoms.Wg(Id),
    [MaterialCostOow] [float] NULL,
    [MaterialCostOow_Approved] [float] NULL,
	[MaterialCostIw] [float] NULL,
	[MaterialCostIw_Approved] [float] NULL,
    CONSTRAINT PK_MaterialCostOowCalc PRIMARY KEY NONCLUSTERED (Country, Wg)
)
GO

IF OBJECT_ID('Hardware.MaterialCostUpdated', 'TR') IS NOT NULL
  DROP TRIGGER Hardware.MaterialCostUpdated;
go

CREATE TRIGGER Hardware.MaterialCostUpdated
ON Hardware.MaterialCostWarranty
After INSERT, UPDATE
AS BEGIN
    exec Hardware.SpUpdateMaterialCostCalc;
END
go

IF OBJECT_ID('Hardware.MaterialCostWarrantyEmeiaUpdated', 'TR') IS NOT NULL
  DROP TRIGGER Hardware.MaterialCostWarrantyEmeiaUpdated;
go

CREATE TRIGGER Hardware.MaterialCostWarrantyEmeiaUpdated
ON Hardware.MaterialCostWarrantyEmeia
After INSERT, UPDATE
AS BEGIN
    exec Hardware.SpUpdateMaterialCostCalc;
END
go

exec Hardware.SpUpdateMaterialCostCalc;
go

ALTER TABLE Hardware.ManualCost
   DROP COLUMN DealerPrice;

ALTER TABLE Hardware.ManualCost
   ADD DealerPrice as (ListPrice - (ListPrice * DealerDiscount / 100));
GO

ALTER TABLE Hardware.ManualCost
   DROP COLUMN ServiceTP_Released;

ALTER TABLE Hardware.ManualCost
   ADD ServiceTP_Released AS ( ServiceTP1_Released + 
							COALESCE(ServiceTP2_Released, 0) + 
							COALESCE(ServiceTP3_Released, 0) + 
							COALESCE(ServiceTP4_Released, 0) + 
							COALESCE(ServiceTP5_Released, 0));
GO

ALTER TABLE Hardware.HddRetention
     ADD HddRet float,
         HddRet_Approved float
go

ALTER TABLE Hardware.ServiceSupportCost
    add   TotalIb                          float
        , TotalIb_Approved                 float
        , TotalIbClusterPla                float
        , TotalIbClusterPla_Approved       float
        , TotalIbClusterPlaRegion          float
        , TotalIbClusterPlaRegion_Approved float

CREATE NONCLUSTERED INDEX ix_Hardware_LogisticsCosts
    ON [Hardware].[LogisticsCosts] (Country, Wg, ReactionTimeType)
    INCLUDE ([StandardHandling],[HighAvailabilityHandling],[StandardDelivery],[ExpressDelivery],[TaxiCourierDelivery],[ReturnDeliveryFactory],[StandardHandling_Approved],[HighAvailabilityHandling_Approved],[StandardDelivery_Approved],[ExpressDelivery_Approved],[TaxiCourierDelivery_Approved],[ReturnDeliveryFactory_Approved])
GO

CREATE NONCLUSTERED INDEX [ix_MarkupStandardWaranty_Country_Wg] ON [Hardware].[MarkupStandardWaranty]
(
	[Country] ASC,
	[Wg] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [ix_RoleCodeHourlyRates_Country_RoleCode] ON [Hardware].[RoleCodeHourlyRates]
(
	[Country] ASC,
	[RoleCode] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX ix_Hardware_ProActive
    ON [Hardware].[ProActive] ([Country],[Wg])
GO

IF OBJECT_ID('Hardware.SpGetCosts') IS NOT NULL
  DROP PROCEDURE Hardware.SpGetCosts;
go

IF OBJECT_ID('Hardware.GetCosts') IS NOT NULL
  DROP FUNCTION Hardware.GetCosts;
go 

IF OBJECT_ID('Hardware.GetCalcMember') IS NOT NULL
  DROP FUNCTION Hardware.GetCalcMember;
go 

IF OBJECT_ID('Hardware.CalcFieldServiceCost') IS NOT NULL
  DROP FUNCTION Hardware.CalcFieldServiceCost;
go 

IF OBJECT_ID('Hardware.CalcMaterialCost') IS NOT NULL
  DROP FUNCTION Hardware.CalcMaterialCost;
go 

IF OBJECT_ID('Hardware.CalcSrvSupportCost') IS NOT NULL
  DROP FUNCTION Hardware.CalcSrvSupportCost;
go 

IF OBJECT_ID('Hardware.CalcTaxAndDutiesWar') IS NOT NULL
  DROP FUNCTION Hardware.CalcTaxAndDutiesWar;
go 

IF OBJECT_ID('Hardware.CalcLocSrvStandardWarranty') IS NOT NULL
  DROP FUNCTION Hardware.CalcLocSrvStandardWarranty;
go 

IF OBJECT_ID('Hardware.AvailabilityFeeCalcView', 'V') IS NOT NULL
  DROP VIEW Hardware.AvailabilityFeeCalcView;
go

IF OBJECT_ID('Hardware.AvailabilityFeeView', 'V') IS NOT NULL
  DROP VIEW Hardware.AvailabilityFeeView;
go

IF OBJECT_ID('Hardware.ServiceSupportCostView', 'V') IS NOT NULL
  DROP VIEW Hardware.ServiceSupportCostView;
go

IF OBJECT_ID('Hardware.LogisticsCostView', 'V') IS NOT NULL
  DROP VIEW Hardware.LogisticsCostView;
go

IF OBJECT_ID('Hardware.ReinsuranceView', 'V') IS NOT NULL
  DROP VIEW Hardware.ReinsuranceView;
go

IF OBJECT_ID('Hardware.FieldServiceCostView', 'V') IS NOT NULL
  DROP VIEW Hardware.FieldServiceCostView;
go

IF OBJECT_ID('Hardware.ProActiveView', 'V') IS NOT NULL
  DROP VIEW Hardware.ProActiveView;
go

IF OBJECT_ID('Hardware.TaxAndDutiesView', 'V') IS NOT NULL
  DROP VIEW Hardware.TaxAndDutiesView;
go

IF OBJECT_ID('InputAtoms.WgView', 'V') IS NOT NULL
  DROP VIEW InputAtoms.WgView;
go

IF OBJECT_ID('Hardware.CalcLogisticCost') IS NOT NULL
  DROP FUNCTION Hardware.CalcLogisticCost;
go 

IF OBJECT_ID('Hardware.CalcOtherDirectCost') IS NOT NULL
  DROP FUNCTION Hardware.CalcOtherDirectCost;
go 

IF OBJECT_ID('Hardware.CalcCredit') IS NOT NULL
  DROP FUNCTION Hardware.CalcCredit;
go 

IF OBJECT_ID('Hardware.CalcServiceTC') IS NOT NULL
  DROP FUNCTION Hardware.CalcServiceTC;
go 

IF OBJECT_ID('Hardware.CalcServiceTP') IS NOT NULL
  DROP FUNCTION Hardware.CalcServiceTP;
go 

IF OBJECT_ID('Hardware.AddMarkup') IS NOT NULL
  DROP FUNCTION Hardware.AddMarkup;
go 

IF OBJECT_ID('Hardware.MarkupOrFixValue') IS NOT NULL
  DROP FUNCTION Hardware.MarkupOrFixValue;
go 

IF OBJECT_ID('Hardware.CalcAvailabilityFee') IS NOT NULL
  DROP FUNCTION Hardware.CalcAvailabilityFee;
go 

IF OBJECT_ID('Hardware.CalcTISC') IS NOT NULL
  DROP FUNCTION Hardware.CalcTISC;
go 

IF OBJECT_ID('Hardware.CalcYI') IS NOT NULL
  DROP FUNCTION Hardware.CalcYI;
go 

IF OBJECT_ID('Hardware.CalcProActive') IS NOT NULL
  DROP FUNCTION Hardware.CalcProActive;
go 

IF OBJECT_ID('Hardware.ConcatByDur') IS NOT NULL
  DROP FUNCTION Hardware.ConcatByDur;
go 

IF OBJECT_ID('Hardware.CalcByDur') IS NOT NULL
  DROP FUNCTION Hardware.CalcByDur;
go 

IF OBJECT_ID('Hardware.PositiveValue') IS NOT NULL
    DROP FUNCTION [Hardware].[PositiveValue]
GO

CREATE FUNCTION [Hardware].[PositiveValue] (@value float)
RETURNS float 
AS
BEGIN

    if @value < 0
        begin
            return 0;
        end

    RETURN @value;

END
GO

IF OBJECT_ID('Hardware.AfrYear', 'U') IS NOT NULL
  DROP TABLE Hardware.AfrYear;
go

CREATE TABLE Hardware.AfrYear(
    [Wg] [bigint] NOT NULL PRIMARY KEY CLUSTERED foreign key references InputAtoms.Wg(Id),
    [AFR1] [float] NULL,
    [AFR2] [float] NULL,
    [AFR3] [float] NULL,
    [AFR4] [float] NULL,
    [AFR5] [float] NULL,
    [AFRP1] [float] NULL,
    [AFR1_Approved] [float] NULL,
    [AFR2_Approved] [float] NULL,
    [AFR3_Approved] [float] NULL,
    [AFR4_Approved] [float] NULL,
    [AFR5_Approved] [float] NULL,
    [AFRP1_Approved] [float] NULL
)
GO

alter table Hardware.Reinsurance
    add ReinsuranceFlatfee_norm          as (ReinsuranceFlatfee * coalesce(ReinsuranceUpliftFactor / 100, 1))
      , ReinsuranceFlatfee_norm_Approved as (ReinsuranceFlatfee_Approved * coalesce(ReinsuranceUpliftFactor_Approved / 100, 1))
GO

CREATE VIEW [Hardware].[ReinsuranceView] as
    SELECT r.Wg, 
           r.Duration,
           r.ReactionTimeAvailability,

           r.ReinsuranceFlatfee_norm / er.Value                    as Cost,
           r.ReinsuranceFlatfee_norm_Approved / er2.Value as Cost_Approved

    FROM Hardware.Reinsurance r
    LEFT JOIN [References].ExchangeRate er on er.CurrencyId = r.CurrencyReinsurance
    LEFT JOIN [References].ExchangeRate er2 on er2.CurrencyId = r.CurrencyReinsurance_Approved
GO

CREATE NONCLUSTERED INDEX ix_Hardware_Reinsurance_Sla ON [Hardware].[Reinsurance] ([Wg],[Duration],[ReactionTimeAvailability])
GO

IF OBJECT_ID('Hardware.GetReinsurance') IS NOT NULL
  DROP FUNCTION Hardware.GetReinsurance;
GO

CREATE FUNCTION Hardware.GetReinsurance (@approved bit)
RETURNS @tbl TABLE (   
           Wg                       bigint
         , Duration                 bigint
         , ReactionTimeAvailability bigint
         , Cost                     float
         , PRIMARY KEY (Wg, Duration, ReactionTimeAvailability)
    )
AS
BEGIN
    
    if @approved = 0
    begin
        insert into @tbl(Wg, Duration, ReactionTimeAvailability, Cost)
        SELECT  r.Wg, 
                r.Duration,
                r.ReactionTimeAvailability,
                r.ReinsuranceFlatfee_norm / er.Value                    
        FROM Hardware.Reinsurance r
        JOIN [References].ExchangeRate er on er.CurrencyId = r.CurrencyReinsurance
    end
    else
    begin
        insert into @tbl(Wg, Duration, ReactionTimeAvailability, Cost)
        SELECT  r.Wg, 
                r.Duration,
                r.ReactionTimeAvailability,
                r.ReinsuranceFlatfee_norm_Approved / er.Value 
        FROM Hardware.Reinsurance r
        JOIN [References].ExchangeRate er on er.CurrencyId = r.CurrencyReinsurance_Approved
    end

    RETURN;
END;
go

CREATE NONCLUSTERED INDEX [ix_Hardware_Reinsurance_Currency] ON [Hardware].[Reinsurance]
(
	[CurrencyReinsurance] ASC
)
INCLUDE ( 	[Wg],
	[Duration],
	[ReactionTimeAvailability],
	[ReinsuranceFlatfee_norm]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [ix_Hardware_Reinsurance_Currency_Appr] ON [Hardware].[Reinsurance]
(
	[CurrencyReinsurance_Approved] ASC
)
INCLUDE ( 	[Wg],
	[Duration],
	[ReactionTimeAvailability],
	[ReinsuranceFlatfee_norm_Approved]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF OBJECT_ID('Hardware.AFR_Updated', 'TR') IS NOT NULL
  DROP TRIGGER Hardware.AFR_Updated;
go

CREATE TRIGGER Hardware.AFR_Updated
ON Hardware.AFR
After INSERT, UPDATE
AS BEGIN

    truncate table Hardware.AfrYear;

    insert into Hardware.AfrYear(Wg, AFR1, AFR2, AFR3, AFR4, AFR5, AFRP1, AFR1_Approved, AFR2_Approved, AFR3_Approved, AFR4_Approved, AFR5_Approved, AFRP1_Approved)
        select afr.Wg
             , sum(case when y.IsProlongation = 0 and y.Value = 1 then afr.AFR / 100 end) as AFR1
             , sum(case when y.IsProlongation = 0 and y.Value = 2 then afr.AFR / 100 end) as AFR2
             , sum(case when y.IsProlongation = 0 and y.Value = 3 then afr.AFR / 100 end) as AFR3
             , sum(case when y.IsProlongation = 0 and y.Value = 4 then afr.AFR / 100 end) as AFR4
             , sum(case when y.IsProlongation = 0 and y.Value = 5 then afr.AFR / 100 end) as AFR5
             , sum(case when y.IsProlongation = 1 and y.Value = 1 then afr.AFR / 100 end) as AFRP1
             , sum(case when y.IsProlongation = 0 and y.Value = 1 then afr.AFR_Approved / 100 end) as AFR1_Approved
             , sum(case when y.IsProlongation = 0 and y.Value = 2 then afr.AFR_Approved / 100 end) as AFR2_Approved
             , sum(case when y.IsProlongation = 0 and y.Value = 3 then afr.AFR_Approved / 100 end) as AFR3_Approved
             , sum(case when y.IsProlongation = 0 and y.Value = 4 then afr.AFR_Approved / 100 end) as AFR4_Approved
             , sum(case when y.IsProlongation = 0 and y.Value = 5 then afr.AFR_Approved / 100 end) as AFR5_Approved
             , sum(case when y.IsProlongation = 1 and y.Value = 1 then afr.AFR_Approved / 100 end) as AFRP1_Approved
        from Hardware.AFR afr, Dependencies.Year y 
        where y.Id = afr.Year
        group by afr.Wg
END
GO

update Hardware.AFR set AFR = AFR + 0
GO

IF OBJECT_ID('Fsp.HwStandardWarranty', 'U') IS NOT NULL
  DROP TABLE Fsp.HwStandardWarranty;
go

CREATE TABLE Fsp.HwStandardWarranty(
    Country bigint NOT NULL foreign key references InputAtoms.Country(Id)
  , Wg bigint NOT NULL foreign key references InputAtoms.Wg(Id)

  , FspId bigint NOT NULL
  , Fsp nvarchar(255) NOT NULL

  , AvailabilityId bigint NOT NULL foreign key references Dependencies.Availability(Id)

  , DurationId bigint NOT NULL foreign key references Dependencies.Duration(Id)
  , Duration nvarchar(50)
  , IsProlongation bit
  , DurationValue int

  , ReactionTimeId bigint NOT NULL foreign key references Dependencies.ReactionTime(id)
  , ReactionTypeId bigint NOT NULL foreign key references Dependencies.ReactionType(id)

  , ServiceLocationId bigint NOT NULL foreign key references Dependencies.ServiceLocation(id)
  , ServiceLocation nvarchar(50)

  , ProActiveSlaId bigint NOT NULL foreign key references Dependencies.ProActiveSla(id)

  , ReactionTime_Avalability bigint
  , ReactionTime_ReactionType bigint
  , ReactionTime_ReactionType_Avalability bigint

  , CONSTRAINT PK_HwStandardWarranty PRIMARY KEY NONCLUSTERED (Country, Wg)
)
GO

CREATE VIEW [InputAtoms].[WgStdView] AS
    select *
    from InputAtoms.Wg
    where Id in (select Wg from Fsp.HwStandardWarranty) and WgType = 1
GO

if OBJECT_ID('Fsp.LutPriority', 'U') is not null
    drop table Fsp.LutPriority;
go

create table Fsp.LutPriority(
      LUT nvarchar(20) not null
    , Priority int not null
)
go

insert into Fsp.LutPriority(LUT, Priority) 
    values 
      ('ASP', 1)
    , ('BEL', 1)
    , ('CAM', 2)
    , ('CRE', 1)
    , ('D',   1)
    , ('DAN', 1)
    , ('FAM', 1)
    , ('FIN', 1)
    , ('FKR', 1)
    , ('FUJ', 3)
    , ('GBR', 1)
    , ('GRI', 1)
    , ('GSP', 1)
    , ('IND', 1)
    , ('INT', 1)
    , ('ISR', 1)
    , ('ITL', 1)
    , ('LUX', 1)
    , ('MDE', 1)
    , ('ND',  2)
    , ('NDL', 1)
    , ('NOA', 1)
    , ('NOR', 1)
    , ('OES', 1)
    , ('POL', 1)
    , ('POR', 1)
    , ('RSA', 1)
    , ('RUS', 1)
    , ('SEE', 1)
    , ('SPA', 1)
    , ('SWD', 1)
    , ('SWZ', 1)
    , ('TRK', 1)
    , ('UNG', 1);
go

IF OBJECT_ID('Fsp.HwFspCodeTranslation_Updated', 'TR') IS NOT NULL
  DROP TRIGGER Fsp.HwFspCodeTranslation_Updated;
go

CREATE TRIGGER [Fsp].[HwFspCodeTranslation_Updated]
ON [Fsp].[HwFspCodeTranslation]
After INSERT, UPDATE
AS BEGIN

    truncate table Fsp.HwStandardWarranty;

    -- Disable all table constraints
    ALTER TABLE Fsp.HwStandardWarranty NOCHECK CONSTRAINT ALL;

    with Std as (
        select  row_number() OVER(PARTITION BY fsp.CountryId, fsp.WgId ORDER BY lut.Priority) AS [rn]
              , fsp.*
        from fsp.HwFspCodeTranslation fsp
        join Fsp.LutPriority lut on lut.LUT = fsp.LUT

        where fsp.IsStandardWarranty = 1
    )
    insert into Fsp.HwStandardWarranty(
                          Country
                        , Wg
                        , FspId
                        , Fsp
                        , AvailabilityId

                        , DurationId 
                        , Duration
                        , IsProlongation
                        , DurationValue 

                        , ReactionTimeId
                        , ReactionTypeId

                        , ServiceLocationId
                        , ServiceLocation

                        , ProactiveSlaId
                        , ReactionTime_Avalability              
                        , ReactionTime_ReactionType             
                        , ReactionTime_ReactionType_Avalability)
        select    fsp.CountryId
                , fsp.WgId
                , fsp.Id
                , fsp.Name
                , fsp.AvailabilityId

                , fsp.DurationId
                , dur.Name
                , dur.IsProlongation
                , dur.Value as DurationValue

                , fsp.ReactionTimeId
                , fsp.ReactionTypeId

                , fsp.ServiceLocationId
                , loc.Name as ServiceLocation
        
                , fsp.ProactiveSlaId
                , rta.Id
                , rtt.Id
                , rtta.Id
        from Std fsp
        INNER JOIN Dependencies.ReactionTime_Avalability rta on rta.AvailabilityId = fsp.AvailabilityId and rta.ReactionTimeId = fsp.ReactionTimeId
        INNER JOIN Dependencies.ReactionTime_ReactionType rtt on rtt.ReactionTimeId = fsp.ReactionTimeId and rtt.ReactionTypeId = fsp.ReactionTypeId
        INNER JOIN Dependencies.ReactionTime_ReactionType_Avalability rtta on rtta.AvailabilityId = fsp.AvailabilityId and rtta.ReactionTimeId = fsp.ReactionTimeId and rtta.ReactionTypeId = fsp.ReactionTypeId

        INNER JOIN Dependencies.Duration dur on dur.Id = fsp.DurationId
        INNER JOIN Dependencies.ServiceLocation loc on loc.id = fsp.ServiceLocationId
        
        where fsp.rn = 1 ;

    -- Enable all table constraints
    ALTER TABLE Fsp.HwStandardWarranty CHECK CONSTRAINT ALL;

END
GO

update fsp.HwFspCodeTranslation set Name = Name where id  < 10
go

CREATE VIEW [Fsp].[HwStandardWarrantyView] AS
    SELECT std.Wg
         , std.Country
         , std.Duration
         , dur.Name
         , dur.IsProlongation
         , dur.Value as DurationValue
         , std.AvailabilityId
         , std.ReactionTimeId
         , std.ReactionTypeId
         , std.ServiceLocationId
         , loc.Name as ServiceLocation
         , std.ProActiveSlaId
         , std.ReactionTime_Avalability
         , std.ReactionTime_ReactionType
         , std.ReactionTime_ReactionType_Avalability
    FROM fsp.HwStandardWarranty std
    INNER JOIN Dependencies.Duration dur on dur.Id = std.Duration
    INNER JOIN Dependencies.ServiceLocation loc on loc.id = std.ServiceLocationId
GO

CREATE FUNCTION Hardware.CalcByDur
(
    @year int,
    @prolongation bit,
    @v1 float,
    @v2 float,
    @v3 float,
    @v4 float,
    @v5 float,
    @vp float
)
RETURNS float
AS
BEGIN

    return
        case
            when @prolongation = 0 and @year = 1 then @v1
            when @prolongation = 0 and @year = 2 then @v1 + @v2
            when @prolongation = 0 and @year = 3 then @v1 + @v2 + @v3
            when @prolongation = 0 and @year = 4 then @v1 + @v2 + @v3 + @v4
            when @prolongation = 0 and @year = 5 then @v1 + @v2 + @v3 + @v4 + @v5
            else @vp
        end

END
GO

CREATE FUNCTION Hardware.ConcatByDur
(
    @year int,
    @prolongation bit,
    @v1 float,
    @v2 float,
    @v3 float,
    @v4 float,
    @v5 float,
    @vp float
)
RETURNS nvarchar(500)
AS
BEGIN

    return
        case
            when @prolongation = 0 and @year = 1 then cast(@v1 as nvarchar(50))
            when @prolongation = 0 and @year = 2 then cast(@v1 as nvarchar(50)) + ';' + cast(@v2 as nvarchar(50))
            when @prolongation = 0 and @year = 3 then cast(@v1 as nvarchar(50)) + ';' + cast(@v2 as nvarchar(50)) + ';' + cast(@v3 as nvarchar(50))
            when @prolongation = 0 and @year = 4 then cast(@v1 as nvarchar(50)) + ';' + cast(@v2 as nvarchar(50)) + ';' + cast(@v3 as nvarchar(50)) + ';' + cast(@v4 as nvarchar(50))
            when @prolongation = 0 and @year = 5 then cast(@v1 as nvarchar(50)) + ';' + cast(@v2 as nvarchar(50)) + ';' + cast(@v3 as nvarchar(50)) + ';' + cast(@v4 as nvarchar(50)) + ';' + cast(@v5 as nvarchar(50))
            else cast(@vp as nvarchar(50))
        end

END
GO

CREATE FUNCTION [Hardware].[CalcProActive](@setupCost float, @yearCost float, @dur int)
RETURNS float
AS
BEGIN
	RETURN @setupCost + @yearCost * @dur;
END
GO

CREATE FUNCTION [Hardware].[CalcYI](@grValue float, @deprMo float)
RETURNS float
AS
BEGIN
    if @deprMo = 0
    begin
        RETURN null;
    end
	RETURN @grValue / @deprMo * 12;
END
GO

CREATE FUNCTION [Hardware].[CalcTISC](
    @tisc float,
    @totalIB float,
    @totalIB_VENDOR float
)
RETURNS float
AS
BEGIN
    if @totalIB = 0
    begin
        RETURN null;
    end
	RETURN @tisc / @totalIB * @totalIB_VENDOR;
END
GO

CREATE FUNCTION [Hardware].[CalcAvailabilityFee](
	@kc float,
    @mq float,
    @tisc float,
    @yi float,
    @totalIB float
)
RETURNS float
AS
BEGIN
    if @mq = 0 or @totalIB = 0
    begin
        RETURN NULL;
    end

	RETURN @kc/@mq * (@tisc + @yi) / @totalIB;
END
GO

CREATE FUNCTION [Hardware].[AddMarkup](
    @value float,
    @markupFactor float,
    @markup float
)
RETURNS float
AS
BEGIN

    if @markupFactor is not null
        begin
            set @value = @value * @markupFactor;
        end
    else if @markup is not null
        begin
            set @value = @value + @markup;
        end

    RETURN @value;

END
GO

CREATE FUNCTION Hardware.MarkupOrFixValue (
    @value float,
    @markupFactor float,
    @fixed float
)
RETURNS float 
AS
BEGIN

    if @markupFactor is not null
        begin
            return @value * @markupFactor;
        end
    else if @fixed is not null
        begin
            return @fixed;
        end

    RETURN 0;

END
GO

CREATE FUNCTION [Hardware].[CalcLogisticCost](
	@standardHandling float,
    @highAvailabilityHandling float,
    @standardDelivery float,
    @expressDelivery float,
    @taxiCourierDelivery float,
    @returnDelivery float,
    @afr float
)
RETURNS float
AS
BEGIN
	RETURN @afr * (
	            @standardHandling +
                @highAvailabilityHandling +
                @standardDelivery +
                @expressDelivery +
                @taxiCourierDelivery +
                @returnDelivery
           );
END
GO

CREATE FUNCTION [Hardware].[CalcFieldServiceCost] (
    @timeAndMaterialShare float,
    @travelCost float,
    @labourCost float,
    @performanceRate float,
    @travelTime float,
    @repairTime float,
    @onsiteHourlyRate float,
    @afr float
)
RETURNS float
AS
BEGIN
    return @afr * (
                   (1 - @timeAndMaterialShare) * (@travelCost + @labourCost + @performanceRate) + 
                   @timeAndMaterialShare * ((@travelTime + @repairTime) * @onsiteHourlyRate + @performanceRate)
                );
END
GO

CREATE FUNCTION [Hardware].[CalcMaterialCost](@cost float, @afr float)
RETURNS float
AS
BEGIN
    RETURN @cost * @afr;
END
GO

CREATE FUNCTION [Hardware].[CalcSrvSupportCost] (
    @firstLevelSupport float,
    @secondLevelSupport float,
    @ibCountry float,
    @ibPla float
)
returns float
as
BEGIN
    if @ibCountry = 0 or @ibPla = 0
    begin
        return null;
    end
    return @firstLevelSupport / @ibCountry + @secondLevelSupport / @ibPla;
END
GO

CREATE FUNCTION [Hardware].[CalcTaxAndDutiesWar](@cost float, @tax float)
RETURNS float
AS
BEGIN
    RETURN @cost * @tax;
END
GO

CREATE FUNCTION [Hardware].[CalcLocSrvStandardWarranty](
    @fieldServiceCost float,
    @srvSupportCost   float,
    @logisticCost     float,
    @taxAndDutiesW    float,
    @afr              float,
    @fee              float,
    @markupFactor     float,
    @markup           float
)
RETURNS float
AS
BEGIN
    return Hardware.AddMarkup(@fieldServiceCost + @srvSupportCost + @logisticCost, @markupFactor, @markup) + @taxAndDutiesW * @afr + @fee;
END
GO

CREATE FUNCTION [Hardware].[CalcOtherDirectCost](
    @fieldSrvCost float,
    @srvSupportCost float,
    @materialCost float,
    @logisticCost float,
    @reinsurance float,
    @markupFactor float,
    @markup float
)
RETURNS float
AS
BEGIN
    return Hardware.AddMarkup(@fieldSrvCost + @srvSupportCost + @materialCost + @logisticCost + @reinsurance, @markupFactor, @markup);
END
GO

CREATE FUNCTION [Hardware].[CalcServiceTC](
    @fieldSrvCost float,
    @srvSupprtCost float,
    @materialCost float,
    @logisticCost float,
    @taxAndDuties float,
    @reinsurance float,
    @fee float,
    @credits float
)
RETURNS float
AS
BEGIN
	RETURN @fieldSrvCost +
           @srvSupprtCost +
           @materialCost +
           @logisticCost +
           @taxAndDuties +
           @reinsurance +
           @fee -
           @credits;
END
GO

CREATE FUNCTION [Hardware].[CalcServiceTP](
    @serviceTC float,
    @markupFactor float,
    @markup float
)
RETURNS float
AS
BEGIN
	RETURN Hardware.AddMarkup(@serviceTC, @markupFactor, @markup);
END
GO

CREATE FUNCTION [Hardware].[CalcCredit](@materialCost float, @warrantyCost float)
RETURNS float
AS
BEGIN
	RETURN @materialCost + @warrantyCost;
END
GO

CREATE VIEW [Hardware].[AvailabilityFeeView] as 
    select   fee.Country
           , fee.Wg
           
           , case  when wg.WgType = 0 then 1 else 0 end as IsMultiVendor
           
           , fee.InstalledBaseHighAvailability as IB
           , fee.InstalledBaseHighAvailability_Approved as IB_Approved
           
           , fee.TotalLogisticsInfrastructureCost          / er.Value as TotalLogisticsInfrastructureCost
           , fee.TotalLogisticsInfrastructureCost_Approved / er.Value as TotalLogisticsInfrastructureCost_Approved
           
           , case when wg.WgType = 0 then fee.StockValueMv          else fee.StockValueFj          end / er.Value as StockValue
           , case when wg.WgType = 0 then fee.StockValueMv_Approved else fee.StockValueFj_Approved end / er.Value as StockValue_Approved
           
           , fee.AverageContractDuration
           , fee.AverageContractDuration_Approved
           
           , case when fee.JapanBuy = 1          then fee.CostPerKitJapanBuy else fee.CostPerKit end as CostPerKit
           , case when fee.JapanBuy_Approved = 1 then fee.CostPerKitJapanBuy else fee.CostPerKit end as CostPerKit_Approved
           
           , fee.MaxQty

    from Hardware.AvailabilityFee fee
    JOIN InputAtoms.Wg wg on wg.Id = fee.Wg
    JOIN InputAtoms.Country c on c.Id = fee.Country
    LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId
GO

CREATE VIEW [Hardware].[AvailabilityFeeCalcView] as 
     with InstallByCountryCte as (
        SELECT T.Country as CountryID, 
               T.Total_IB, 
               T.Total_IB_Approved, 

               T.Total_IB - coalesce(T.Total_IB_MVS, 0) as Total_IB_FTS, 
               T.Total_IB_Approved - coalesce(T.Total_IB_MVS_Approved, 0) as Total_IB_FTS_Approved, 

               T.Total_IB_MVS,
               T.Total_IB_MVS_Approved,

               T.Total_KC_MQ_IB_FTS,
               T.Total_KC_MQ_IB_FTS_Approved,

               T.Total_KC_MQ_IB_MVS,
               T.Total_KC_MQ_IB_MVS_Approved

         FROM (
            select fee.Country, 
                   sum(fee.IB) as Total_IB, 
                   sum(fee.IB_Approved) as Total_IB_Approved,
                    
                   sum(fee.IsMultiVendor * fee.IB) as Total_IB_MVS,
                   sum(fee.IsMultiVendor * fee.IB_Approved) as Total_IB_MVS_Approved,

                   sum(case when fee.MaxQty = 0 then 0 else fee.IsMultiVendor * fee.CostPerKit / fee.MaxQty * fee.IB end) as Total_KC_MQ_IB_MVS,
                   sum(case when fee.MaxQty = 0 then 0 else fee.IsMultiVendor * fee.CostPerKit_Approved / fee.MaxQty * fee.IB_Approved end) as Total_KC_MQ_IB_MVS_Approved,

                   sum(case when fee.MaxQty = 0 then 0 else (1 - fee.IsMultiVendor) * fee.CostPerKit / fee.MaxQty * fee.IB end) as Total_KC_MQ_IB_FTS,
                   sum(case when fee.MaxQty = 0 then 0 else (1 - fee.IsMultiVendor) * fee.CostPerKit_Approved / fee.MaxQty * fee.IB_Approved end) as Total_KC_MQ_IB_FTS_Approved

            from Hardware.AvailabilityFeeVIEW fee
            group by fee.Country 
        ) T
    )
    , AvFeeCte as (
        select fee.*,

               ib.Total_IB,
               ib.Total_IB_Approved,

               (case fee.IsMultiVendor 
                    when 1 then ib.Total_IB_MVS
                    else ib.Total_IB_FTS
                end) as Total_IB_VENDOR,               

               (case fee.IsMultiVendor 
                    when 1 then ib.Total_IB_MVS_Approved
                    else ib.Total_IB_FTS_Approved
                end) as Total_IB_VENDOR_Approved,               

               (case fee.IsMultiVendor
                    when 1 then ib.Total_KC_MQ_IB_MVS
                    else ib.Total_KC_MQ_IB_FTS
                end) as Total_KC_MQ_IB_VENDOR,

               (case fee.IsMultiVendor
                    when 1 then ib.Total_KC_MQ_IB_MVS_Approved
                    else ib.Total_KC_MQ_IB_FTS_Approved
                end) as Total_KC_MQ_IB_VENDOR_Approved

        from Hardware.AvailabilityFeeVIEW fee
        join InstallByCountryCte ib on ib.CountryID = fee.Country
    )
    , AvFeeCte2 as (
        select fee.*,

               Hardware.CalcYI(fee.StockValue, fee.AverageContractDuration) as YI,
               Hardware.CalcYI(fee.StockValue_Approved, fee.AverageContractDuration_Approved) as YI_Approved,
          
               Hardware.CalcTISC(fee.TotalLogisticsInfrastructureCost, fee.Total_IB, fee.Total_IB_VENDOR) as TISC,
               Hardware.CalcTISC(fee.TotalLogisticsInfrastructureCost_Approved, fee.Total_IB_Approved, fee.Total_IB_VENDOR_Approved) as TISC_Approved

        from AvFeeCte fee
    )
    select fee.*, 
           case when IB > 0 and fee.MaxQty > 0 then Hardware.CalcAvailabilityFee(fee.CostPerKit, fee.MaxQty, fee.TISC, fee.YI, fee.Total_KC_MQ_IB_VENDOR) else 0 end as Fee,
           case when IB_Approved > 0 and fee.MaxQty > 0 then Hardware.CalcAvailabilityFee(fee.CostPerKit_Approved, fee.MaxQty, fee.TISC_Approved, fee.YI_Approved, fee.Total_KC_MQ_IB_VENDOR_Approved) else 0 end as Fee_Approved
    from AvFeeCte2 fee
GO

IF OBJECT_ID('Hardware.AvailabilityFeeCalc', 'U') IS NOT NULL
  DROP TABLE Hardware.AvailabilityFeeCalc;
go

CREATE TABLE Hardware.AvailabilityFeeCalc (
    [Country] [bigint] NOT NULL FOREIGN KEY REFERENCES InputAtoms.Country(Id),
    [Wg] [bigint] NOT NULL FOREIGN KEY REFERENCES InputAtoms.Wg(Id),
    [Fee] [float] NULL,
    [Fee_Approved] [float] NULL
)

GO

CREATE NONCLUSTERED INDEX [ix_Hardware_AvailabilityFeeCalc] ON [Hardware].[AvailabilityFeeCalc]
(
	[Country] ASC,
	[Wg] ASC
)
INCLUDE ( 	[Fee],
	[Fee_Approved]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF OBJECT_ID('Hardware.UpdateAvailabilityFee') IS NOT NULL
  DROP PROCEDURE Hardware.UpdateAvailabilityFee;
go

CREATE PROCEDURE Hardware.UpdateAvailabilityFee
AS
BEGIN

    SET NOCOUNT ON;

    TRUNCATE TABLE Hardware.AvailabilityFeeCalc;

    -- Disable all table constraints
    ALTER TABLE Hardware.AvailabilityFeeCalc NOCHECK CONSTRAINT ALL;

    INSERT INTO Hardware.AvailabilityFeeCalc(Country, Wg, Fee, Fee_Approved)
    select Country, Wg, Fee, Fee_Approved
    from Hardware.AvailabilityFeeCalcView fee
    join InputAtoms.Wg wg on wg.id = fee.Wg
    where wg.DeactivatedDateTime is null

    ALTER INDEX ix_Hardware_AvailabilityFeeCalc ON Hardware.AvailabilityFeeCalc REBUILD;  

    -- Enable all table constraints
    ALTER TABLE Hardware.AvailabilityFeeCalc CHECK CONSTRAINT ALL;

END
go

IF OBJECT_ID('Hardware.AvailabilityFeeUpdated', 'TR') IS NOT NULL
  DROP TRIGGER Hardware.AvailabilityFeeUpdated;
go

CREATE TRIGGER Hardware.AvailabilityFeeUpdated
ON Hardware.AvailabilityFee
After INSERT, UPDATE
AS BEGIN

    exec Hardware.UpdateAvailabilityFee;

END
go

IF OBJECT_ID('[References].ExchangeRateUpdated', 'TR') IS NOT NULL
  DROP TRIGGER [References].ExchangeRateUpdated;
go

CREATE TRIGGER [References].ExchangeRateUpdated
ON [References].ExchangeRate
After INSERT, UPDATE
AS BEGIN

    exec Hardware.UpdateAvailabilityFee;

END
go

exec Hardware.UpdateAvailabilityFee;
go

IF OBJECT_ID('Hardware.InstallBaseUpdated', 'TR') IS NOT NULL
  DROP TRIGGER Hardware.InstallBaseUpdated;
go

CREATE TRIGGER [Hardware].[InstallBaseUpdated]
ON [Hardware].[InstallBase]
After INSERT, UPDATE
AS BEGIN

    with ibCte as (
        select ib.*
                , c.ClusterRegionId
                , pla.Id as PlaId
                , cpla.Id as ClusterPlaId 
        from Hardware.InstallBase ib
        JOIN InputAtoms.Country c on c.id = ib.Country
        JOIN InputAtoms.Wg wg on wg.id = ib.Wg
        JOIN InputAtoms.Pla pla on pla.id = wg.PlaId
        JOIN InputAtoms.ClusterPla cpla on cpla.Id = pla.ClusterPlaId

        where ib.DeactivatedDateTime is null and wg.DeactivatedDateTime is null
    )
    , totalIb_Cte as (
        select Country
                , sum(InstalledBaseCountry) as totalIb
                , sum(InstalledBaseCountry_Approved) as totalIb_Approved
        from ibCte
        group by Country
    )
    , totalIb_PLA_Cte as (
        select Country
                , ClusterPlaId
                , sum(InstalledBaseCountry) as totalIb
                , sum(InstalledBaseCountry_Approved) as totalIb_Approved
        from ibCte
        group by Country, ClusterPlaId
    )
    , totalIb_PLA_ClusterRegion_Cte as (
        select    ClusterRegionId
                , ClusterPlaId
                , sum(InstalledBaseCountry) as totalIb
                , sum(InstalledBaseCountry_Approved) as totalIb_Approved
        from ibCte
        group by ClusterRegionId, ClusterPlaId
    )
    UPDATE ssc
            SET   ssc.TotalIb                          = t1.totalIb
                , ssc.TotalIb_Approved                 = t1.totalIb_Approved
                , ssc.TotalIbClusterPla                = t2.totalIb
                , ssc.TotalIbClusterPla_Approved       = t2.totalIb_Approved
                , ssc.TotalIbClusterPlaRegion          = t3.totalIb
                , ssc.TotalIbClusterPlaRegion_Approved = t3.totalIb_Approved
    from Hardware.ServiceSupportCost ssc
    join totalIb_Cte t1 on t1.Country = ssc.Country
    join totalIb_PLA_Cte t2 on t2.Country = ssc.Country and t2.ClusterPlaId = ssc.ClusterPla
    join totalIb_PLA_ClusterRegion_Cte t3 on t3.ClusterRegionId = ssc.ClusterRegion and t3.ClusterPlaId = ssc.ClusterPla

END
GO

IF OBJECT_ID('Hardware.HddRetentionUpdated', 'TR') IS NOT NULL
  DROP TRIGGER Hardware.HddRetentionUpdated;
go

CREATE TRIGGER [Hardware].[HddRetentionUpdated]
ON [Hardware].[HddRetention]
After INSERT, UPDATE
AS BEGIN

    SET NOCOUNT ON;

    with cte as (
        select    h.Wg
                , sum(h.HddMaterialCost * h.HddFr / 100) as hddRet
                , sum(h.HddMaterialCost_Approved * h.HddFr_Approved / 100) as hddRet_Approved
        from Hardware.HddRetention h
        where h.Year in (select id from Dependencies.Year where IsProlongation = 0 and Value <= 5 )
        group by h.Wg
    )
    update h
        set h.HddRet = c.HddRet, HddRet_Approved = c.HddRet_Approved
    from Hardware.HddRetention h
    join cte c on c.Wg = h.Wg

END
go

update Hardware.HddRetention set HddFr = HddFr + 0;
go

IF OBJECT_ID('Hardware.HddRetentionView', 'U') IS NOT NULL
  DROP TABLE Hardware.HddRetentionView;
go

IF OBJECT_ID('Hardware.HddRetentionView', 'V') IS NOT NULL
  DROP VIEW Hardware.HddRetentionView;
go

CREATE VIEW [Hardware].[HddRetentionView] as 
    SELECT 
           h.Wg as WgId
         , wg.Name as Wg
         , sog.Name as Sog
         , h.HddRet
         , HddRet_Approved
         , hm.TransferPrice 
         , hm.ListPrice
         , hm.DealerDiscount
         , hm.DealerPrice
         , u.Name as ChangeUserName
         , u.Email as ChangeUserEmail
         , hm.ChangeDate

    FROM Hardware.HddRetention h
    JOIN InputAtoms.Wg wg on wg.id = h.Wg
    LEFT JOIN InputAtoms.Sog sog on sog.id = wg.SogId
    LEFT JOIN Hardware.HddRetentionManualCost hm on hm.WgId = h.Wg
    LEFT JOIN [dbo].[User] u on u.Id = hm.ChangeUserId
    WHERE h.DeactivatedDateTime is null 
      AND h.Year = (select id from Dependencies.Year where Value = 5 and IsProlongation = 0)

GO

alter table Hardware.FieldServiceCost
    add TimeAndMaterialShare_norm          as (TimeAndMaterialShare / 100)
      , TimeAndMaterialShare_norm_Approved as (TimeAndMaterialShare_Approved / 100)
GO

CREATE VIEW [Hardware].[FieldServiceCostView] AS
    SELECT  fsc.Country,
            fsc.Wg,
            case 
                when wg.WgType = 0 then 1
                else 0
            end as IsMultiVendor,
            
            hr.OnsiteHourlyRates,
            hr.OnsiteHourlyRates_Approved,

            fsc.ServiceLocation,
            rt.ReactionTypeId,
            rt.ReactionTimeId,

            fsc.RepairTime,
            fsc.RepairTime_Approved,
            
            fsc.TravelTime,
            fsc.TravelTime_Approved,

            fsc.LabourCost          / er.Value as LabourCost,
            fsc.LabourCost_Approved / er.Value as LabourCost_Approved,

            fsc.TravelCost          / er.Value as TravelCost,
            fsc.TravelCost_Approved / er.Value as TravelCost_Approved,

            fsc.PerformanceRate          / er.Value as PerformanceRate,
            fsc.PerformanceRate_Approved / er.Value as PerformanceRate_Approved,

            (fsc.TimeAndMaterialShare / 100) as TimeAndMaterialShare,
            (fsc.TimeAndMaterialShare_Approved / 100) as TimeAndMaterialShare_Approved

    FROM Hardware.FieldServiceCost fsc
    JOIN InputAtoms.Country c on c.Id = fsc.Country
    JOIN InputAtoms.Wg on wg.Id = fsc.Wg
    JOIN Dependencies.ReactionTime_ReactionType rt on rt.Id = fsc.ReactionTimeType
    LEFT JOIN Hardware.RoleCodeHourlyRates hr on hr.RoleCode = wg.RoleCodeId and hr.Country = fsc.Country
    LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId
GO

IF OBJECT_ID('Hardware.FieldServiceCalc', 'U') IS NOT NULL
  DROP TABLE Hardware.FieldServiceCalc;
go

CREATE TABLE Hardware.FieldServiceCalc (
      [Country]             bigint NOT NULL foreign key references InputAtoms.Country(Id)
    , [Wg]                  bigint NOT NULL foreign key references InputAtoms.Wg(Id)
    , [ServiceLocation]     bigint NOT NULL foreign key references Dependencies.ServiceLocation(Id)

    , [RepairTime]          float
    , [RepairTime_Approved] float
    , [TravelTime]          float
    , [TravelTime_Approved] float
    , [TravelCost]          float
    , [TravelCost_Approved] float
    , [LabourCost]          float
    , [LabourCost_Approved] float

    CONSTRAINT PK_FieldServiceCalc PRIMARY KEY NONCLUSTERED (Country, Wg, ServiceLocation)
)
GO

ALTER INDEX PK_FieldServiceCalc ON Hardware.FieldServiceCalc DISABLE;  
go

ALTER TABLE Hardware.FieldServiceCalc NOCHECK CONSTRAINT ALL
go

insert into Hardware.FieldServiceCalc(
            Country
          , Wg
          , ServiceLocation
          , RepairTime
          , RepairTime_Approved
          , TravelTime
          , TravelTime_Approved
          , TravelCost
          , TravelCost_Approved
          , LabourCost
          , LabourCost_Approved)
select    fsc.Country
        , fsc.Wg
        , fsc.ServiceLocation
        , MIN(fsc.RepairTime)
        , MIN(fsc.RepairTime_Approved)
        , MIN(fsc.TravelTime)
        , MIN(fsc.TravelTime_Approved)
        , MIN(fsc.TravelCost)
        , MIN(fsc.TravelCost_Approved)
        , MIN(fsc.LabourCost)
        , MIN(fsc.LabourCost_Approved)
from Hardware.FieldServiceCost fsc
group by fsc.Country, fsc.Wg, fsc.ServiceLocation;
go

ALTER INDEX PK_FieldServiceCalc ON Hardware.FieldServiceCalc REBUILD;  
GO

ALTER TABLE Hardware.FieldServiceCalc CHECK CONSTRAINT ALL
go

IF OBJECT_ID('Hardware.FieldServiceTimeCalc', 'U') IS NOT NULL
  DROP TABLE Hardware.FieldServiceTimeCalc;
go

CREATE TABLE Hardware.FieldServiceTimeCalc (
      [Country]                       bigint NOT NULL foreign key references InputAtoms.Country(Id)
    , [Wg]                            bigint NOT NULL foreign key references InputAtoms.Wg(Id)
    , [ReactionTimeType]              bigint NOT NULL foreign key references Dependencies.ReactionTime_ReactionType(Id)

    , [PerformanceRate]               float
    , [PerformanceRate_Approved]      float
    , [TimeAndMaterialShare]          float
    , [TimeAndMaterialShare_Approved] float

    , [TimeAndMaterialShare_norm]          as (TimeAndMaterialShare / 100)
    , [TimeAndMaterialShare_norm_Approved] as (TimeAndMaterialShare_Approved / 100)

    CONSTRAINT PK_FieldServiceTimeCalc PRIMARY KEY NONCLUSTERED (Country, Wg, ReactionTimeType)
)
GO

ALTER INDEX PK_FieldServiceTimeCalc ON Hardware.FieldServiceTimeCalc DISABLE;  
go

ALTER TABLE Hardware.FieldServiceTimeCalc NOCHECK CONSTRAINT ALL
go

insert into Hardware.FieldServiceTimeCalc(Country, Wg, ReactionTimeType, PerformanceRate, PerformanceRate_Approved, TimeAndMaterialShare, TimeAndMaterialShare_Approved)
select    fsc.Country
        , fsc.Wg
        , fsc.ReactionTimeType
        , MIN(fsc.PerformanceRate)
        , MIN(fsc.PerformanceRate_Approved)
        , MIN(fsc.TimeAndMaterialShare)
        , MIN(fsc.TimeAndMaterialShare_Approved)
from Hardware.FieldServiceCost fsc
join Dependencies.ReactionTimeType rtt on rtt.id = fsc.ReactionTimeType and rtt.IsDisabled = 0
group by fsc.Country, fsc.Wg, fsc.ReactionTimeType;
go

ALTER INDEX PK_FieldServiceTimeCalc ON Hardware.FieldServiceTimeCalc REBUILD;  
go

ALTER TABLE Hardware.FieldServiceTimeCalc CHECK CONSTRAINT ALL
go

CREATE NONCLUSTERED INDEX ix_FieldServiceCalc_Country
ON [Hardware].[FieldServiceCalc] ([Country])
INCLUDE ([Wg],[ServiceLocation],[RepairTime],[RepairTime_Approved],[TravelTime],[TravelTime_Approved],[TravelCost],[TravelCost_Approved],[LabourCost],[LabourCost_Approved])
GO

CREATE NONCLUSTERED INDEX ix_FieldServiceTimeCalc_Country
ON [Hardware].[FieldServiceTimeCalc] ([Country])
INCLUDE ([Wg],[ReactionTimeType],[PerformanceRate],[PerformanceRate_Approved],[TimeAndMaterialShare_norm],[TimeAndMaterialShare_norm_Approved])
GO

IF OBJECT_ID('[Hardware].[FieldServiceCost_Updated]', 'TR') IS NOT NULL
  DROP TRIGGER [Hardware].[FieldServiceCost_Updated];
go

CREATE TRIGGER [Hardware].[FieldServiceCost_Updated]
ON [Hardware].[FieldServiceCost]
After UPDATE
AS BEGIN

    with cte as (
        select i.*
        from inserted i
        join deleted d on d.Id = i.Id
    )
    update fsc 
            set RepairTime = c.RepairTime
              , RepairTime_Approved = c.RepairTime_Approved

              , TravelTime = c.TravelTime
              , TravelTime_Approved = c.TravelTime_Approved
              
              , TravelCost = c.TravelCost
              , TravelCost_Approved = c.TravelCost_Approved
              
              , LabourCost = c.LabourCost
              , LabourCost_Approved = c.LabourCost_Approved
    from Hardware.FieldServiceCalc fsc
    join cte c on c.Country = fsc.Country and c.Wg = fsc.Wg and c.ServiceLocation = fsc.ServiceLocation;

    with cte as (
        select i.*
        from inserted i
        join deleted d on d.Id = i.Id
    )
    update fst 
            set PerformanceRate = c.PerformanceRate
              , PerformanceRate_Approved = c.PerformanceRate_Approved

              , TimeAndMaterialShare = c.TimeAndMaterialShare
              , TimeAndMaterialShare_Approved = c.TimeAndMaterialShare_Approved
    from Hardware.FieldServiceTimeCalc fst
    join cte c on c.Country = fst.Country and c.Wg = fst.Wg and c.ReactionTimeType = fst.ReactionTimeType

END
go

alter table Hardware.TaxAndDuties
    add TaxAndDuties_norm          as (TaxAndDuties / 100)
      , TaxAndDuties_norm_Approved as (TaxAndDuties_Approved / 100)
GO

CREATE VIEW [Hardware].[TaxAndDutiesView] as
    select Country,
           TaxAndDuties_norm, 
           TaxAndDuties_norm_Approved
    from Hardware.TaxAndDuties
    where DeactivatedDateTime is null
GO

CREATE VIEW [InputAtoms].[WgView] WITH SCHEMABINDING as
    SELECT wg.Id, 
           wg.Name, 
           case 
                when wg.WgType = 0 then 1
                else 0
            end as IsMultiVendor, 
           pla.Id as Pla, 
           pla.ClusterPlaId as ClusterPla,
           wg.RoleCodeId
    from InputAtoms.Wg wg
    inner join InputAtoms.Pla pla on pla.id = wg.PlaId
    where wg.WgType = 1 and wg.DeactivatedDateTime is null
GO

CREATE VIEW [Hardware].[LogisticsCostView] AS
    SELECT lc.Country,
           lc.Wg, 
           rt.ReactionTypeId as ReactionType, 
           rt.ReactionTimeId as ReactionTime,
           
           lc.StandardHandling          / er.Value as StandardHandling,
           lc.StandardHandling_Approved / er.Value as StandardHandling_Approved,

           lc.HighAvailabilityHandling          / er.Value as HighAvailabilityHandling,
           lc.HighAvailabilityHandling_Approved / er.Value as HighAvailabilityHandling_Approved,

           lc.StandardDelivery          / er.Value as StandardDelivery,
           lc.StandardDelivery_Approved / er.Value as StandardDelivery_Approved,

           lc.ExpressDelivery          / er.Value as ExpressDelivery,
           lc.ExpressDelivery_Approved / er.Value as ExpressDelivery_Approved,

           lc.TaxiCourierDelivery          / er.Value as TaxiCourierDelivery,
           lc.TaxiCourierDelivery_Approved / er.Value as TaxiCourierDelivery_Approved,

           lc.ReturnDeliveryFactory          / er.Value as ReturnDeliveryFactory,
           lc.ReturnDeliveryFactory_Approved / er.Value as ReturnDeliveryFactory_Approved

    FROM Hardware.LogisticsCosts lc
    JOIN Dependencies.ReactionTime_ReactionType rt on rt.Id = lc.ReactionTimeType
    JOIN InputAtoms.Country c on c.Id = lc.Country
    LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId

    where lc.DeactivatedDateTime is null
GO

alter table Hardware.MarkupOtherCosts
    add
      [ProlongationMarkup]                float    
    , [ProlongationMarkup_Approved]       float
    , [ProlongationMarkupFactor]          float
    , [ProlongationMarkupFactor_Approved] float

    , [MarkupFactor_norm]  AS ([MarkupFactor]/(100)) PERSISTED
    , [MarkupFactor_norm_Approved]  AS ([MarkupFactor_Approved]/(100)) PERSISTED
    , [ProlongationMarkupFactor_norm]  AS ([ProlongationMarkupFactor]/(100)) PERSISTED
    , [ProlongationMarkupFactor_norm_Approved]  AS ([ProlongationMarkupFactor_Approved]/(100)) PERSISTED

    , Deactivated as cast(case when DeactivatedDateTime is null then 0 else 1 end as bit) PERSISTED not null;
go

alter table Hardware.MarkupStandardWaranty
    add MarkupFactorStandardWarranty_norm          as (MarkupFactorStandardWarranty / 100)
      , MarkupFactorStandardWarranty_norm_Approved as (MarkupFactorStandardWarranty_Approved / 100)
GO

CREATE VIEW [Hardware].[ServiceSupportCostView] as
    with cte as (
        select   ssc.Country
               , ssc.ClusterRegion
               , ssc.ClusterPla

               , ssc.[1stLevelSupportCostsCountry] / er.Value          as '1stLevelSupportCosts'
               , ssc.[1stLevelSupportCostsCountry_Approved] / er.Value as '1stLevelSupportCosts_Approved'
           
               , ssc.[2ndLevelSupportCostsLocal] / er.Value            as '2ndLevelSupportCostsLocal'
               , ssc.[2ndLevelSupportCostsLocal_Approved] / er.Value   as '2ndLevelSupportCostsLocal_Approved'

               , ssc.[2ndLevelSupportCostsClusterRegion]               as '2ndLevelSupportCostsClusterRegion'
               , ssc.[2ndLevelSupportCostsClusterRegion_Approved]      as '2ndLevelSupportCostsClusterRegion_Approved'

               , case when ssc.[2ndLevelSupportCostsLocal] > 0 then ssc.[2ndLevelSupportCostsLocal] / er.Value 
                        else ssc.[2ndLevelSupportCostsClusterRegion]
                   end as '2ndLevelSupportCosts'
                
               , case when ssc.[2ndLevelSupportCostsLocal_Approved] > 0 then ssc.[2ndLevelSupportCostsLocal_Approved] / er.Value 
                        else ssc.[2ndLevelSupportCostsClusterRegion_Approved]
                   end as '2ndLevelSupportCosts_Approved'

               , case when ssc.[2ndLevelSupportCostsLocal] > 0          then ssc.TotalIbClusterPla          else ssc.TotalIbClusterPlaRegion          end as Total_IB_Pla
               , case when ssc.[2ndLevelSupportCostsLocal_Approved] > 0 then ssc.TotalIbClusterPla_Approved else ssc.TotalIbClusterPlaRegion_Approved end as Total_IB_Pla_Approved

               , ssc.TotalIb
               , ssc.TotalIb_Approved
               , ssc.TotalIbClusterPla
               , ssc.TotalIbClusterPla_Approved
               , ssc.TotalIbClusterPlaRegion
               , ssc.TotalIbClusterPlaRegion_Approved

        from Hardware.ServiceSupportCost ssc
        join InputAtoms.Country c on c.Id = ssc.Country
        left join [References].ExchangeRate er on er.CurrencyId = c.CurrencyId
    )
    select ssc.Country
         , ssc.ClusterRegion
         , ssc.ClusterPla
         , ssc.[1stLevelSupportCosts]
         , ssc.[1stLevelSupportCosts_Approved]
         , ssc.[2ndLevelSupportCosts]
         , ssc.[2ndLevelSupportCosts_Approved]

         , case when ssc.TotalIb <> 0 and ssc.Total_IB_Pla <> 0 
                then ssc.[1stLevelSupportCosts] / ssc.TotalIb + ssc.[2ndLevelSupportCosts] / ssc.Total_IB_Pla
            end as ServiceSupport

         , case when ssc.TotalIb_Approved <> 0 and ssc.Total_IB_Pla_Approved <> 0 
                then ssc.[1stLevelSupportCosts_Approved] / ssc.TotalIb_Approved + ssc.[2ndLevelSupportCosts_Approved] / ssc.Total_IB_Pla_Approved
            end as ServiceSupport_Approved

    from cte ssc
GO

CREATE VIEW [Hardware].[ProActiveView] with schemabinding as 
    with ProActiveCte as 
    (
        select pro.Country,
               pro.Wg,
               sla.Id as ProActiveSla,
               (pro.LocalRemoteAccessSetupPreparationEffort * pro.OnSiteHourlyRate) as LocalRemoteAccessSetup,
               (pro.LocalRemoteAccessSetupPreparationEffort_Approved * pro.OnSiteHourlyRate_Approved) as LocalRemoteAccessSetup_Approved,

               (pro.LocalRegularUpdateReadyEffort * 
                pro.OnSiteHourlyRate * 
                sla.LocalRegularUpdateReadyRepetition) as LocalRegularUpdate,

               (pro.LocalRegularUpdateReadyEffort_Approved * 
                pro.OnSiteHourlyRate_Approved * 
                sla.LocalRegularUpdateReadyRepetition) as LocalRegularUpdate_Approved,

               (pro.LocalPreparationShcEffort * 
                pro.OnSiteHourlyRate * 
                sla.LocalPreparationShcRepetition) as LocalPreparation,

               (pro.LocalPreparationShcEffort_Approved * 
                pro.OnSiteHourlyRate_Approved * 
                sla.LocalPreparationShcRepetition) as LocalPreparation_Approved,

               (pro.LocalRemoteShcCustomerBriefingEffort * 
                pro.OnSiteHourlyRate * 
                sla.LocalRemoteShcCustomerBriefingRepetition) as LocalRemoteCustomerBriefing,

               (pro.LocalRemoteShcCustomerBriefingEffort_Approved * 
                pro.OnSiteHourlyRate_Approved * 
                sla.LocalRemoteShcCustomerBriefingRepetition) as LocalRemoteCustomerBriefing_Approved,

               (pro.LocalOnsiteShcCustomerBriefingEffort * 
                pro.OnSiteHourlyRate * 
                sla.LocalOnsiteShcCustomerBriefingRepetition) as LocalOnsiteCustomerBriefing,

               (pro.LocalOnsiteShcCustomerBriefingEffort_Approved * 
                pro.OnSiteHourlyRate_Approved * 
                sla.LocalOnsiteShcCustomerBriefingRepetition) as LocalOnsiteCustomerBriefing_Approved,

               (pro.TravellingTime * 
                pro.OnSiteHourlyRate * 
                sla.TravellingTimeRepetition) as Travel,

               (pro.TravellingTime_Approved * 
                pro.OnSiteHourlyRate_Approved * 
                sla.TravellingTimeRepetition) as Travel_Approved,

               (pro.CentralExecutionShcReportCost * 
                sla.CentralExecutionShcReportRepetition) as CentralExecutionReport,

               (pro.CentralExecutionShcReportCost_Approved * 
                sla.CentralExecutionShcReportRepetition) as CentralExecutionReport_Approved

        from Hardware.ProActive pro, 
             Dependencies.ProActiveSla sla
    )
    select  pro.Country,
            pro.Wg,
            pro.ProActiveSla,

            pro.LocalPreparation,
            pro.LocalPreparation_Approved,

            pro.LocalRegularUpdate,
            pro.LocalRegularUpdate_Approved,

            pro.LocalRemoteCustomerBriefing,
            pro.LocalRemoteCustomerBriefing_Approved,

            pro.LocalOnsiteCustomerBriefing,
            pro.LocalOnsiteCustomerBriefing_Approved,

            pro.Travel,
            pro.Travel_Approved,

            pro.CentralExecutionReport,
            pro.CentralExecutionReport_Approved,

           pro.LocalRemoteAccessSetup as Setup,
           pro.LocalRemoteAccessSetup_Approved  as Setup_Approved,

           (pro.LocalPreparation + 
            pro.LocalRegularUpdate + 
            pro.LocalRemoteCustomerBriefing +
            pro.LocalOnsiteCustomerBriefing +
            pro.Travel +
            pro.CentralExecutionReport) as Service,
       
           (pro.LocalPreparation_Approved + 
            pro.LocalRegularUpdate_Approved + 
            pro.LocalRemoteCustomerBriefing_Approved +
            pro.LocalOnsiteCustomerBriefing_Approved +
            pro.Travel_Approved +
            pro.CentralExecutionReport_Approved) as Service_Approved

    from ProActiveCte pro;
GO

IF OBJECT_ID('[Hardware].[GetCalcMember]') IS NOT NULL
  DROP FUNCTION [Hardware].[GetCalcMember];
go 

CREATE FUNCTION [Hardware].[GetCalcMember] (
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
    SELECT    m.Id

            --SLA

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

            , r.Cost as Reinsurance

            --##### FIELD SERVICE COST #########                                                                                               
            , case when @approved = 0 then fsc.LabourCost                     else fsc.LabourCost_Approved                 end / std.ExchangeRate as LabourCost             
            , case when @approved = 0 then fsc.TravelCost                     else fsc.TravelCost_Approved                 end / std.ExchangeRate as TravelCost             
            , case when @approved = 0 then fst.PerformanceRate                else fst.PerformanceRate_Approved            end / std.ExchangeRate as PerformanceRate        
            , case when @approved = 0 then fst.TimeAndMaterialShare_norm      else fst.TimeAndMaterialShare_norm_Approved  end as TimeAndMaterialShare   
            , case when @approved = 0 then fsc.TravelTime                     else fsc.TravelTime_Approved                 end as TravelTime             
            , case when @approved = 0 then fsc.RepairTime                     else fsc.RepairTime_Approved                 end as RepairTime             

            , std.OnsiteHourlyRates      
                       
            --##### SERVICE SUPPORT COST #########                                                                                               
            , std.ServiceSupportPerYear

            --##### LOGISTICS COST #########                                                                                               
            , case when @approved = 0 then lc.ExpressDelivery                 else lc.ExpressDelivery_Approved             end / std.ExchangeRate as ExpressDelivery         
            , case when @approved = 0 then lc.HighAvailabilityHandling        else lc.HighAvailabilityHandling_Approved    end / std.ExchangeRate as HighAvailabilityHandling
            , case when @approved = 0 then lc.StandardDelivery                else lc.StandardDelivery_Approved            end / std.ExchangeRate as StandardDelivery        
            , case when @approved = 0 then lc.StandardHandling                else lc.StandardHandling_Approved            end / std.ExchangeRate as StandardHandling        
            , case when @approved = 0 then lc.ReturnDeliveryFactory           else lc.ReturnDeliveryFactory_Approved       end / std.ExchangeRate as ReturnDeliveryFactory   
            , case when @approved = 0 then lc.TaxiCourierDelivery             else lc.TaxiCourierDelivery_Approved         end / std.ExchangeRate as TaxiCourierDelivery     
                                                                                                                       
            , case when afEx.id is not null then std.Fee else 0 end as AvailabilityFee

            , case when @approved = 0 then moc.Markup                              else moc.Markup_Approved                            end / std.ExchangeRate as MarkupOtherCost                      
            , case when @approved = 0 then moc.MarkupFactor_norm                   else moc.MarkupFactor_norm_Approved                 end as MarkupFactorOtherCost                

            --####### PROACTIVE COST ###################
            , std.LocalRemoteAccessSetup
            , std.LocalRegularUpdate * proSla.LocalRegularUpdateReadyRepetition                 as LocalRegularUpdate
            , std.LocalPreparation * proSla.LocalPreparationShcRepetition                       as LocalPreparation
            , std.LocalRemoteCustomerBriefing * proSla.LocalRemoteShcCustomerBriefingRepetition as LocalRemoteCustomerBriefing
            , std.LocalOnsiteCustomerBriefing * proSla.LocalOnsiteShcCustomerBriefingRepetition as LocalOnsiteCustomerBriefing
            , std.Travel * proSla.TravellingTimeRepetition                                      as Travel
            , std.CentralExecutionReport * proSla.CentralExecutionShcReportRepetition           as CentralExecutionReport

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

    FROM Portfolio.GetBySlaPaging(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    INNER JOIN Hardware.CalcStdw(@approved, @cnt, @wg) std on std.CountryId = m.CountryId and std.WgId = m.WgId

    LEFT JOIN Hardware.GetReinsurance(@approved) r on r.Wg = m.WgId AND r.Duration = m.DurationId AND r.ReactionTimeAvailability = m.ReactionTime_Avalability

    LEFT JOIN Hardware.FieldServiceCalc fsc ON fsc.Country = m.CountryId AND fsc.Wg = m.WgId AND fsc.ServiceLocation = m.ServiceLocationId
    LEFT JOIN Hardware.FieldServiceTimeCalc fst ON fst.Country = m.CountryId AND fst.Wg = m.WgId AND fst.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTimeType = m.ReactionTime_ReactionType and lc.DeactivatedDateTime is null

    LEFT JOIN Hardware.MarkupOtherCosts moc on moc.Wg = m.WgId AND moc.Country = m.CountryId AND moc.ReactionTimeTypeAvailability = m.ReactionTime_ReactionType_Avalability and moc.DeactivatedDateTime is null

    LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

    LEFT JOIN Hardware.ManualCost man on man.PortfolioId = m.Id

    LEFT JOIN dbo.[User] u on u.Id = man.ChangeUserId
)
go


IF OBJECT_ID('[Hardware].[GetCosts]') IS NOT NULL
    DROP FUNCTION [Hardware].[GetCosts]
GO

CREATE FUNCTION [Hardware].[GetCosts](
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

                , coalesce(m.AvailabilityFee, 0) as AvailabilityFeeOrZero

                , (1 - m.TimeAndMaterialShare) * (m.TravelCost + m.LabourCost + m.PerformanceRate) + m.TimeAndMaterialShare * ((m.TravelTime + m.repairTime) * m.OnsiteHourlyRates + m.PerformanceRate) as FieldServicePerYear

                , m.StandardHandling + m.HighAvailabilityHandling + m.StandardDelivery + m.ExpressDelivery + m.TaxiCourierDelivery + m.ReturnDeliveryFactory as LogisticPerYear

                , m.LocalRemoteAccessSetup + m.Year * (m.LocalPreparation + m.LocalRegularUpdate + m.LocalRemoteCustomerBriefing + m.LocalOnsiteCustomerBriefing + m.Travel + m.CentralExecutionReport) as ProActive
       
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

                , coalesce(case when m.DurationId = 1 then m.Reinsurance else 0 end, 0) as Reinsurance1
                , coalesce(case when m.DurationId = 2 then m.Reinsurance else 0 end, 0) as Reinsurance2
                , coalesce(case when m.DurationId = 3 then m.Reinsurance else 0 end, 0) as Reinsurance3
                , coalesce(case when m.DurationId = 4 then m.Reinsurance else 0 end, 0) as Reinsurance4
                , coalesce(case when m.DurationId = 5 then m.Reinsurance else 0 end, 0) as Reinsurance5
                , coalesce(case when m.DurationId = 6 then m.Reinsurance else 0 end, 0) as Reinsurance1P

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
go

IF OBJECT_ID('Hardware.SpGetCosts') IS NOT NULL
  DROP PROCEDURE Hardware.SpGetCosts;
go

CREATE PROCEDURE [Hardware].[SpGetCosts]
    @approved     bit,
    @local        bit,
    @cnt          dbo.ListID readonly,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly,
    @lastid       bigint,
    @limit        int,
    @total        int output
AS
BEGIN

    SET NOCOUNT ON;

    select @total = COUNT(Id) from Portfolio.GetBySla(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro);

    if @local = 1
    begin
    
        --convert values from EUR to local

        select Id

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

        from Hardware.GetCosts(@approved, @cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) 
        order by Id
        
    end
    else
    begin

        select Id

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

        from Hardware.GetCosts(@approved, @cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) 
        order by Id
    end
END
go

IF OBJECT_ID('Hardware.GetCostsSlaSog') IS NOT NULL
  DROP FUNCTION Hardware.GetCostsSlaSog;
go

CREATE FUNCTION [Hardware].[GetCostsSlaSog](
    @approved bit,
    @cnt dbo.ListID readonly,
    @wg dbo.ListID readonly,
    @av dbo.ListID readonly,
    @dur dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc dbo.ListID readonly,
    @pro dbo.ListID readonly
)
RETURNS TABLE 
AS
RETURN 
(
    with cte as (
        select    
               m.Id

             --SLA

             , m.CountryId
             , m.Country
             , m.CurrencyId
             , m.Currency
             , m.ExchangeRate

             , m.WgId
             , m.Wg
             , wg.Description as WgDescription
             , m.SogId
             , m.Sog

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

             , m.AvailabilityFee
             , m.TaxAndDutiesW
             , m.TaxAndDutiesOow
             , m.Reinsurance
             , m.ProActive
             , m.ServiceSupportCost
             , m.MaterialW
             , m.MaterialOow
             , m.FieldServiceCost
             , m.Logistic
             , m.OtherDirect
             , coalesce(m.LocalServiceStandardWarrantyManual, m.LocalServiceStandardWarranty) as LocalServiceStandardWarranty
             , m.Credits

             , ib.InstalledBaseCountryNorm

             , (sum(m.ServiceTCResult * ib.InstalledBaseCountryNorm)                               over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_x_tc 
             , (sum(case when m.ServiceTCResult <> 0 then ib.InstalledBaseCountryNorm end)          over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_by_tc

             , (sum(m.ServiceTP_Released * ib.InstalledBaseCountryNorm)                      over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_x_tp_Released
             , (sum(case when m.ServiceTP_Released <> 0 then ib.InstalledBaseCountryNorm end) over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_by_tp_Released

             , (sum(m.ServiceTPResult * ib.InstalledBaseCountryNorm)                               over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_x_tp
             , (sum(case when m.ServiceTPResult <> 0 then ib.InstalledBaseCountryNorm end)          over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_by_tp

             , (max(m.ReleaseDate)                                                           over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as ReleaseDate

             , m.ListPrice
             , m.DealerDiscount
             , m.DealerPrice

        from Hardware.GetCosts(@approved, @cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, null, null) m
        join InputAtoms.Wg wg on wg.id = m.WgId and wg.DeactivatedDateTime is null
        left join Hardware.GetInstallBaseOverSog(@approved, @cnt) ib on ib.Country = m.CountryId and ib.Wg = m.WgId
    )
    select    
            m.Id

            --SLA

            , m.CountryId
            , m.Country
            , m.CurrencyId
            , m.Currency
            , m.ExchangeRate

            , m.WgId
            , m.Wg
            , m.WgDescription
            , m.SogId
            , m.Sog

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

            , m.AvailabilityFee
            , m.TaxAndDutiesW
            , m.TaxAndDutiesOow
            , m.Reinsurance
            , m.ProActive
            , m.ServiceSupportCost
            , m.MaterialW
            , m.MaterialOow
            , m.FieldServiceCost
            , m.Logistic
            , m.OtherDirect
            , m.LocalServiceStandardWarranty
            , m.Credits

            , case when m.sum_ib_x_tc <> 0 and m.sum_ib_by_tc <> 0 then m.sum_ib_x_tc / m.sum_ib_by_tc else 0 end as ServiceTcSog
            , case when m.sum_ib_x_tp <> 0 and m.sum_ib_by_tp <> 0 then m.sum_ib_x_tp / m.sum_ib_by_tp else 0 end as ServiceTpSog
            , case when m.sum_ib_x_tp_Released <> 0 and m.sum_ib_by_tp_Released <> 0 then m.sum_ib_x_tp_Released / m.sum_ib_by_tp_Released 
                   when m.ReleaseDate is not null then 0 end as ServiceTpSog_Released

            , m.ReleaseDate

            , m.ListPrice
            , m.DealerDiscount
            , m.DealerPrice  

    from cte m
)
go

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
         , m.ServiceTP_Released

         , m.ReleaseDate
         , m.ChangeUserName
         , m.ChangeUserEmail

       from CostCte6 m
)
go

IF OBJECT_ID('Hardware.SpReleaseCosts') IS NOT NULL
  DROP PROCEDURE Hardware.SpReleaseCosts;
go

CREATE PROCEDURE [Hardware].[SpReleaseCosts]
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
    
    declare @now datetime = getdate();

    SELECT   
              case when costs.Year >= 1 and costs.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / costs.Year, costs.ServiceTP1) end * costs.ExchangeRate as TP1_Released
            , case when costs.Year >= 2 and costs.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / costs.Year, costs.ServiceTP2) end * costs.ExchangeRate as TP2_Released
            , case when costs.Year >= 3 and costs.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / costs.Year, costs.ServiceTP3) end * costs.ExchangeRate as TP3_Released
            , case when costs.Year >= 4 and costs.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / costs.Year, costs.ServiceTP4) end * costs.ExchangeRate as TP4_Released
            , case when costs.Year >= 5 and costs.IsProlongation = 0 then  COALESCE(costs.ServiceTPManual / costs.Year, costs.ServiceTP5) end * costs.ExchangeRate as TP5_Released
            , case when costs.IsProlongation = 1                     then  COALESCE(costs.ServiceTPManual, costs.ServiceTP1P)             end * costs.ExchangeRate as TP1P_Released

            , COALESCE(costs.ServiceTPManual, costs.ServiceTP) * costs.ExchangeRate as TP_Released

            , costs.*
    INTO #temp 
	FROM Hardware.GetReleaseCosts(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, 0, 100) costs
	WHERE (not exists(select 1 from @portfolioIds) or costs.Id in (select Id from @portfolioIds))   
	--TODO: @portfolioIds case to be fixed in a future release 

    UPDATE mc
    SET   [ServiceTP1_Released]  = TP1_Released
        , [ServiceTP2_Released]  = TP2_Released
        , [ServiceTP3_Released]  = TP3_Released
        , [ServiceTP4_Released]  = TP4_Released
        , [ServiceTP5_Released]  = TP5_Released
        , [ServiceTP1P_Released] = TP1P_Released
        , [ServiceTP_Released]   = TP_Released
    
        , [ChangeUserId] = @usr
        , [ReleaseDate] = @now

    FROM [Hardware].[ManualCost] mc
    JOIN #temp costs on mc.PortfolioId = costs.Id
    where costs.ServiceTPManual is not null or costs.ServiceTP is not null

	INSERT INTO [Hardware].[ManualCost] 
				([PortfolioId], 
				[ChangeUserId], 
                [ReleaseDate],
				[ServiceTP1_Released], [ServiceTP2_Released], [ServiceTP3_Released], [ServiceTP4_Released], [ServiceTP5_Released], [ServiceTP1P_Released], ServiceTP_Released)
	SELECT    costs.Id
            , @usr
            , @now
            , TP1_Released
            , TP2_Released
            , TP3_Released
            , TP4_Released
            , TP5_Released
            , TP1P_Released
            , TP_Released
    FROM [Hardware].[ManualCost] mc
    RIGHT JOIN #temp costs on mc.PortfolioId = costs.Id
    where mc.PortfolioId is null and (costs.ServiceTPManual is not null or costs.ServiceTP is not null)

    DROP table #temp
   
END
GO

if OBJECT_ID('Hardware.SpUpdateStandardWarrantyManualCost') is not null
    drop procedure Hardware.SpUpdateStandardWarrantyManualCost;
go

IF type_id('Hardware.StdwCost') IS NOT NULL
    DROP TYPE Hardware.StdwCost;
go

CREATE TYPE Hardware.StdwCost AS TABLE(
    [Country]          nvarchar(255) NOT NULL,
    [Wg]               nvarchar(255) NOT NULL,
    [StandardWarranty] float         NULL
)
GO

CREATE PROCEDURE [Hardware].[SpUpdateStandardWarrantyManualCost]
    @usr          int, 
    @cost         Hardware.StdwCost readonly
AS
BEGIN

    SET NOCOUNT ON;

    declare @now datetime = GETDATE();

    select cnt.Id as CountryId, wg.Id as WgId, max(c.StandardWarranty) as StandardWarranty
    into #temp
    from @cost c 
    join InputAtoms.Country cnt on UPPER(cnt.Name) = UPPER(c.Country) and cnt.CanOverrideTransferCostAndPrice = 1
    join InputAtoms.Wg wg on UPPER(wg.Name) = UPPER(c.Wg)
    group by cnt.Id, wg.Id;

    update stdw set StandardWarranty = c.StandardWarranty, ChangeUserId = @usr, ChangeDate = @now
    from Hardware.StandardWarrantyManualCost stdw 
    join #temp c on c.CountryId = stdw.CountryId and c.WgId = stdw.WgId;

    insert into Hardware.StandardWarrantyManualCost(CountryId, WgId, StandardWarranty, ChangeUserId, ChangeDate)
    select c.CountryId, c.WgId, c.StandardWarranty, @usr, @now
    from #temp c
    left join Hardware.StandardWarrantyManualCost stdw on stdw.CountryId = c.CountryId and stdw.WgId = c.WgId
    where stdw.Id is null;

    DROP table #temp;

END
go
