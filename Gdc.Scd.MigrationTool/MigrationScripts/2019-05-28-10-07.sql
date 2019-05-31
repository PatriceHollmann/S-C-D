ALTER TABLE [Hardware].[InstallBase]
ADD [InstalledBase1stLevel_Approved] float null
go

ALTER TRIGGER [Hardware].[InstallBaseUpdated]
ON [Hardware].[InstallBase]
After INSERT, UPDATE
AS BEGIN

    with cte as (
        select  ib.*

              , sum(case when c.InstallbaseGroup is null then null else ib.InstalledBaseCountry end) over(partition by c.InstallbaseGroup, ib.Wg) as InstalledBase1stLevel_Calc

              , sum(case when c.InstallbaseGroup is null then null else ib.InstalledBaseCountry_Approved end) over(partition by c.InstallbaseGroup, ib.Wg) as InstalledBase1stLevel_Calc_Approved

        from Hardware.InstallBase ib 
        join InputAtoms.Country c on c.Id = ib.Country
        JOIN InputAtoms.Wg wg on wg.id = ib.Wg

        where ib.DeactivatedDateTime is null  and wg.DeactivatedDateTime is null
    )
    update c 
        set   InstalledBase1stLevel = coalesce(InstalledBase1stLevel_Calc, InstalledBaseCountry)
            , InstalledBase1stLevel_Approved = coalesce(InstalledBase1stLevel_Calc_Approved, InstalledBaseCountry_Approved)
    from cte c;

    with ibCte as (
        select    
                  ib.*
                , pla.ClusterPlaId

                , (sum(ib.InstalledBase1stLevel) over(partition by ib.Country)) as sum_ib_cnt
                , (sum(ib.InstalledBase1stLevel_Approved) over(partition by ib.Country)) as sum_ib_cnt_Approved

                , (sum(ib.InstalledBaseCountry) over(partition by ib.Country, pla.ClusterPlaId)) as sum_ib_cnt_clusterPLA
                , (sum(ib.InstalledBaseCountry_Approved) over(partition by ib.Country, pla.ClusterPlaId)) as sum_ib_cnt_clusterPLA_Approved

                , (sum(ib.InstalledBaseCountry) over(partition by c.ClusterRegionId, cpla.Id)) as sum_ib_cnt_clusterRegion
                , (sum(ib.InstalledBaseCountry_Approved) over(partition by c.ClusterRegionId, cpla.Id)) as sum_ib_cnt_clusterRegion_Approved

        from Hardware.InstallBase ib
        JOIN InputAtoms.Country c on c.id = ib.Country
        JOIN InputAtoms.Wg wg on wg.id = ib.Wg
        JOIN InputAtoms.Pla pla on pla.id = wg.PlaId
        JOIN InputAtoms.ClusterPla cpla on cpla.Id = pla.ClusterPlaId

        where ib.DeactivatedDateTime is null and wg.DeactivatedDateTime is null
    )
    UPDATE ssc
            SET   ssc.TotalIb                          = ib.sum_ib_cnt
                , ssc.TotalIb_Approved                 = ib.sum_ib_cnt_Approved
                , ssc.TotalIbClusterPla                = ib.sum_ib_cnt_clusterPLA
                , ssc.TotalIbClusterPla_Approved       = ib.sum_ib_cnt_clusterPLA_Approved
                , ssc.TotalIbClusterPlaRegion          = ib.sum_ib_cnt_clusterRegion
                , ssc.TotalIbClusterPlaRegion_Approved = ib.sum_ib_cnt_clusterRegion_Approved
    from Hardware.ServiceSupportCost ssc
    join ibCte ib on ib.Country = ssc.Country and ib.ClusterPlaId = ssc.ClusterPla

END
go

update Hardware.InstallBase set InstalledBaseCountry = InstalledBaseCountry where id < 100
go