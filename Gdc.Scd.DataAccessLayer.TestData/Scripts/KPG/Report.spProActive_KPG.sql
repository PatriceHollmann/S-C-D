if OBJECT_ID('[Report].[spProActive_KPG]') is not null
    drop procedure [Report].[spProActive_KPG];
go

create procedure [Report].[spProActive_KPG](
    @country nvarchar(64)
)
as
BEGIN

    declare @cnt            bigint = (select id from InputAtoms.Country where UPPER(name) = UPPER(@country));

    declare @tbl table (
          rownum             int  
        , Id                 bigint
        , Country            nvarchar(255)
        , CountryGroup       nvarchar(255)
        , Fsp                nvarchar(255)
        , Wg                 nvarchar(255)
        , Pla                nvarchar(255)
        , ServiceLocation    nvarchar(255)
        , ReactionTime       nvarchar(255)
        , ReactionType       nvarchar(255)
        , Availability       nvarchar(255)
        , ProActiveSla       nvarchar(255)
        , Duration           nvarchar(255)
        , ReActive           float
        , ProActive          float
        , ServiceTP          float
        , Currency           nvarchar(255)
        , Sog                nvarchar(255)
        , SogDescription     nvarchar(255)
        , FspDescription     nvarchar(255)
    );

    insert into  @tbl 
    exec Report.spProActive @cnt, null, null, null, null, null, null, null, null, null;

    select 
            Country         
          , CountryGroup    
          , Fsp             
          , Wg              
          , PLA
          , ServiceLocation 
          , ReactionTime    
          , ReactionType    
          , Availability    
          , ProActiveSla    
          , Duration        
          , ReActive        
          , ProActive       
          , ServiceTP       
          , Currency        
          , Sog             
          , SogDescription  
          , FspDescription  
    
    from  @tbl;

END
go
