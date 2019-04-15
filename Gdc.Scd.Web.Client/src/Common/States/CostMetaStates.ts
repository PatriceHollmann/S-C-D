import { NamedId } from "./CommonStates";

export interface UsingInfo {
    usingInfo: {
        isUsingCostEditor: boolean
        isUsingTableView: boolean
        isUsingCostImport: boolean
    }
}

export interface CostElementMeta extends NamedId, UsingInfo {
    dependency: NamedId
    description: string
    inputLevels: InputLevelMeta[]
    regionInput: NamedId
    typeOptions: {
        Type: FieldType
    }
    inputType: InputType
}

export interface CostBlockMeta extends NamedId, UsingInfo {
    applicationIds: string[]
    costElements: CostElementMeta[]
}

export interface InputLevelMeta extends NamedId {
    levelNumer: number
    hasFilter: boolean
    filterName
    hide: boolean
}

export enum FieldType {
    Reference = "Reference",
    Double = "Double",
    Flag = "Flag",
    Percent = "Percent",
    CountryCurrencyCost = "CountryCurrencyCost"
}

export enum InputType {
    Manually = 0,
    Automatically = 1,
    Reference = 2,
    ManuallyAutomatically = 3,
    AutomaticallyReadonly = 4
}

export interface ApplicationMeta extends NamedId, UsingInfo {

}

export interface CostMetaData {
    applications: ApplicationMeta[]
    costBlocks: CostBlockMeta[]
}

