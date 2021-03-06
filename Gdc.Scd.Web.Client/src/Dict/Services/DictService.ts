import { NamedId, SortableNamedId } from "../../Common/States/CommonStates";
import { AvailabilityService } from "../../Dict/Services/AvailabilityService";
import { CountryService } from "../../Dict/Services/CountryService";
import { DurationService } from "../../Dict/Services/DurationService";
import { ReactionTimeService } from "../../Dict/Services/ReactionTimeService";
import { ReactionTypeService } from "../../Dict/Services/ReactionTypeService";
import { ServiceLocationService } from "../../Dict/Services/ServiceLocationService";
import { WgService } from "../../Dict/Services/WgService";
import { Country } from "../Model/Country";
import { CountryGroupService } from "./CountryGroupService";
import { CountryManagementService } from "./CountryManagementService";
import { CurrencyService } from "./CurrencyService";
import { IDictService } from "./IDictService";
import { PlaService } from "./PlaService";
import { ProActiveService } from "./ProActiveService";
import { RoleService } from "./RoleService";
import { SogService } from "./SogService";
import { SwDigitService } from "./SwDigitService";
import { UserCountryService } from "./UserCountryService";
import { YearService } from "./YearService";
import { RegionService } from "./RegionService";

export class DictService implements IDictService {
    public getCountries(): Promise<NamedId<string>[]> {
        return new CountryManagementService().getCountryNames();
    }

    public getMasterCountries(cache: boolean): Promise<Country[]> {
        const srv = new CountryService();
        return cache ? srv.getAll() : srv.loadAll();
    }

    public getMasterCountriesNames(): Promise<NamedId<string>[]> {
        const srv = new CountryService();
        return srv.getAllNames();
    }

    public getUserCountries(cache: boolean): Promise<Country[]> {
        const srv = new UserCountryService();
        return cache ? srv.getAll() : srv.loadAll();
    }

    public getUserCountryNames(): Promise<NamedId[]> {
        const srv = new UserCountryService();
        return srv.getAllNames();
    }

    public getCountryGroups(): Promise<NamedId<string>[]> {
        return new CountryGroupService().getAll();
    }

    public getCountryGroupDigits(): Promise<NamedId<string>[]> {
        return new CountryGroupService().getDigit();
    }

    public getRegions(): Promise<NamedId<string>[]> {
        return new RegionService().getAll();
    }

    public getCountryGroupLuts(): Promise<NamedId<string>[]> {
        return new CountryGroupService().getLut();
    }

    public getCountryGroupIsoCode(): Promise<NamedId<string>[]> {
        return new CountryManagementService().getIsoCodes();
    }

    public getCountryQualityGroup(): Promise<NamedId<string>[]> {
        return new CountryManagementService().getQualityGroups();
    }

    public getCurrencies(): Promise<NamedId<string>[]> {
        return new CurrencyService().getAll();
    }

    public getWG(): Promise<NamedId<string>[]> {
        return new WgService().getAll();
    }

    public getWgWithMultivendor(): Promise<NamedId<string>[]> {
        return new WgService().allWithMultivendor();
    }

    public getWgWithSog(): Promise<NamedId<string>[]> {
        return new WgService().getAll().then(x => x.filter((y: any) => !!y.sogId));
    }

    public getStandardWg(): Promise<NamedId<string>[]> {
        return new WgService().standard();
    }

    public getHardwareWg(): Promise<NamedId<string>[]> {
        return new WgService().hardware();
    }

    public getPla(): Promise<NamedId<string>[]> {
        return new PlaService().getAll();
    }

    public getSog(): Promise<NamedId<string>[]> {
        return new SogService().getAll();
    }

    public getSwDigit(): Promise<NamedId<string>[]> {
        return new SwDigitService().getAll();
    }

    getSwDigitSog(): Promise<NamedId<string>[]> {
        return new SwDigitService().sog();
    }

    public getAvailabilityTypes(): Promise<NamedId<string>[]> {
        return new AvailabilityService().getAll();
    }

    public getDurationTypes(): Promise<NamedId<string>[]> {
        return new DurationService().getAll();
    }

    public getYears(): Promise<NamedId<string>[]> {
        return new YearService().getAll();
    }

    public getReactionTypes(): Promise<NamedId<string>[]> {
        return new ReactionTypeService().getAll();
    }

    public getReactionTimeTypes(): Promise<NamedId<string>[]> {
        return new ReactionTimeService().getAll();
    }

    public getServiceLocationTypes(): Promise<SortableNamedId<string>[]> {
        return new ServiceLocationService().getAll();
    }

    public getProActive(): Promise<NamedId<string>[]> {
        return new ProActiveService().getAll();
    }

    public getRoles(): Promise<NamedId<string>[]> {
        return new RoleService().getAll();
    }
}
