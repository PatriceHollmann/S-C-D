if OBJECT_ID('Archive.spGetSwProActiveCosts') is not null
    drop procedure Archive.spGetSwProActiveCosts;
go

create procedure Archive.spGetSwProActiveCosts
AS
BEGIN

    SET NOCOUNT ON;

    declare @cnt dbo.ListID ;
    declare @digit dbo.ListID ;
    declare @av dbo.ListID ;
    declare @year dbo.ListID ;

    select    c.Name as Country               
            , sog.Name as Sog                   
            , d.Name as SwDigit               

            , av.Name as Availability
            , y.Name as Year
            , pro.ExternalName as ProactiveSla

            , m.ProActive

    FROM SoftwareSolution.GetProActiveCosts(1, @cnt, @digit, @av, @year, null, null) m
    JOIN InputAtoms.Country c on c.id = m.Country
    join InputAtoms.SwDigit d on d.Id = m.SwDigit
    join InputAtoms.Sog sog on sog.Id = d.SogId
    left join Dependencies.Availability av on av.Id = m.AvailabilityId
    left join Dependencies.Year y on y.Id = m.DurationId
    left join Dependencies.ProActiveSla pro on pro.Id = m.ProactiveSlaId

    order by m.Country, m.SwDigit, m.AvailabilityId, m.DurationId, m.ProactiveSlaId;


END