if OBJECT_ID('[Report].[spLocapDetailed_Full_KPG]') is not null
    drop procedure [Report].[spLocapDetailed_Full_KPG];
GO

CREATE procedure [Report].[spLocapDetailed_Full_KPG]
as
BEGIN

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

    declare @wg dbo.ListID ;
    declare @cnt bigint;
    declare @rownum int = 1;

    SELECT ROW_NUMBER() over(order by cnt.Id) as rownum, cnt.Id
    INTO #Temp_Cnt
    FROM InputAtoms.Country cnt
    where cnt.IsMaster = 1

    while 1 = 1
    begin

        set @cnt = (select Id from #Temp_Cnt where rownum = @rownum);
        set @rownum = @rownum + 1;

        if @cnt is null break;

        insert into @tbl exec Report.spLocapDetailedApproved @cnt, @wg, null, null, null, null, null, null, null;

    end;

    drop table  #Temp_Cnt;

    select * from @tbl;

END

