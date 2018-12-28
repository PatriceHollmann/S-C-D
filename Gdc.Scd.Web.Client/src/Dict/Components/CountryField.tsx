﻿import { DictField } from "./DictField";
import { Country } from "../Model/Country";

export class CountryField extends DictField {
    public getItems() {
        return this.srv.getMasterCountries(this.canCache());
    }

    public getSelectedModel(): Country {
        return super.getSelectedModel() as Country;
    }
}