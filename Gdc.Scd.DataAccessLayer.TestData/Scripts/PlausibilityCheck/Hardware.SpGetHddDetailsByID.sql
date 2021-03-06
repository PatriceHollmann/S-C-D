if OBJECT_ID('Hardware.SpGetHddDetailsByID') is not null
    drop procedure [Hardware].SpGetHddDetailsByID;
go

create procedure [Hardware].SpGetHddDetailsByID(
    @approved       bit , 
    @id             bigint
)
as
begin

    declare @tbl table (
          Mandatory       bit default(1)
        , CostBlock       nvarchar(64)
        , CostElement     nvarchar(64)
        , Value           nvarchar(64)
        , Dependency      nvarchar(64)
        , Level           nvarchar(64)
        , [order]         int identity
    );

    declare @central nvarchar(64) = 'Central';

    declare @mat float;
    declare @fr1 float; 
    declare @fr2 float; 
    declare @fr3 float; 
    declare @fr4 float; 
    declare @fr5 float; 

    select * into #tmp
    from Hardware.HddRetention 
    where Wg = @id and Year in (select id from Dependencies.Year where IsProlongation = 0 and Value <= 5)

    --====================================================

    select top(1) @mat = case when @approved = 0 then HddMaterialCost else HddMaterialCost_Approved end from #tmp;

    select  @fr1 = case when @approved = 0 then HddFr else HddFr_Approved end from #tmp where Year = 1;

    select  @fr2 = case when @approved = 0 then HddFr else HddFr_Approved end from #tmp where Year = 2;

    select  @fr3 = case when @approved = 0 then HddFr else HddFr_Approved end from #tmp where Year = 3;

    select  @fr4 = case when @approved = 0 then HddFr else HddFr_Approved end from #tmp where Year = 4;

    select  @fr5 = case when @approved = 0 then HddFr else HddFr_Approved end from #tmp where Year = 5;

    insert into @tbl values 
              (1, 'Hdd retention', 'HDD Material Cost', FORMAT(@mat, ''), null, @central)
            , (1, 'Hdd retention', 'HDD FR', cast(@fr1 as nvarchar(64)) + ' %', '1st year', @central)
            , (1, 'Hdd retention', 'HDD FR', cast(@fr2 as nvarchar(64)) + ' %', '2nd year', @central)
            , (1, 'Hdd retention', 'HDD FR', cast(@fr3 as nvarchar(64)) + ' %', '3rd year', @central)
            , (1, 'Hdd retention', 'HDD FR', cast(@fr4 as nvarchar(64)) + ' %', '4th year', @central)
            , (1, 'Hdd retention', 'HDD FR', cast(@fr5 as nvarchar(64)) + ' %', '5th year', @central)

    --##########################################

    drop table #tmp;

    select CostBlock, CostElement, Dependency, Level, Value, Mandatory
    from @tbl order by [order];

end
go

exec Hardware.SpGetHddDetailsByID 0, 102;

