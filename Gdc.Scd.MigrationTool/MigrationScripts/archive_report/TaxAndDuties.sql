select  c.Name as Country
      , c.Region
      , c.ClusterRegion

      , tax.TaxAndDuties_Approved as Tax

from Hardware.TaxAndDuties tax
join Archive.GetCountries() c on c.id = tax.Country

where tax.DeactivatedDateTime is null

order by c.Name
