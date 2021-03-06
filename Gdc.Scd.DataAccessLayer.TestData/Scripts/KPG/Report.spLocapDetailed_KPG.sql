if object_id('Report.spLocapDetailed_KPG') is not null
    drop procedure Report.spLocapDetailed_KPG;
go

create procedure Report.spLocapDetailed_KPG(
    @country nvarchar(64)
)
as
BEGIN

    declare @cnt            bigint = (select id from InputAtoms.Country where UPPER(name) = UPPER(@country));
    declare @wg             dbo.ListID ;

    declare @tbl table (
            Id                             bigint
          , Fsp                            nvarchar(255)
          , WgDescription                  nvarchar(255)
          , Wg                             nvarchar(255)
          , SogDescription                 nvarchar(255)
          , ServiceLevel                   nvarchar(255)
          , Duration                       nvarchar(255)
          , ServiceLocation                nvarchar(255)
          , Availability                   nvarchar(255)
          , ReactionTime                   nvarchar(255)
          , ReactionType                   nvarchar(255)
          , ProActiveSla                   nvarchar(255)
          , ServicePeriod                  nvarchar(255)
          , Sog                            nvarchar(255)
          , PLA                            nvarchar(255)
          , Country                        nvarchar(255)
          , StdWarranty                    nvarchar(255)
          , StdWarrantyLocation            nvarchar(255)
          
          , ServiceTC                      float
          , ServiceTP_Approved             float
          , ServiceTP_Released             float
          , ReleaseDate                    datetime
          , FieldServiceCost               float
          , ServiceSupportCost             float
          , MaterialOow                    float
          , MaterialW                      float
          , TaxAndDutiesW                  float
          , LogisticW                      float
          , LogisticOow                    float
          , Reinsurance                    float
          , ReinsuranceOow                 float
          , OtherDirect                    float
          , Credits                        float
          , LocalServiceStandardWarranty   float
          
          , Currency                       nvarchar(255)
          , ServiceType                    nvarchar(255)  
    );

    insert into @tbl
    exec Report.spLocapDetailedApproved @cnt, @wg, null, null, null, null, null, null, null;

    select * from @tbl

END
go

