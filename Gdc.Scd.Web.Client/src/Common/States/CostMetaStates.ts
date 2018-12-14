import { NamedId } from "./CommonStates";

export interface UsingInfo {
    isUsingCostEditor: boolean
    isUsingTableView: boolean
}

export interface CostElementMeta extends NamedId, UsingInfo {
    dependency: NamedId
    description: string
    inputLevels: InputLevelMeta[]
    regionInput: NamedId
    typeOptions: {
        Type: FieldType
    }
}

export interface CostBlockMeta extends NamedId {
    applicationIds: string[]
    costElements: CostElementMeta[]
    isUsingCostEditor: boolean
    isUsingTableView: boolean
}

export interface InputLevelMeta extends NamedId {
    levelNumer: number
    hasFilter: boolean
    filterName
}

export enum FieldType {
    Reference = "Reference",
    Double = "Double",
    Flag = "Flag",
    Percent = "Percent"
}

export interface ApplicationMeta extends NamedId, UsingInfo {

}

export interface CostMetaData {
    applications: ApplicationMeta[]
    costBlocks: CostBlockMeta[]
}

