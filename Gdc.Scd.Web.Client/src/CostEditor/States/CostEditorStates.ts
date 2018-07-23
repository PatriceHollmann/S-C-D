import { CostBlockState } from "./CostBlockStates";
import { Action } from "redux";
import { NamedId } from "../../Common/States/CommonStates";

export interface CostElementMeta extends NamedId {
    dependency: NamedId
    description: string
    inputLevels: InputLevelMeta[]
    regionInput: NamedId
    inputType: InputType
    typeOptions: {
        Type: FieldType
    }
}

export interface CostBlockMeta extends NamedId {
    applicationIds: string[]
    costElements: CostElementMeta[]
}

export interface CostEditortData {
    applications: NamedId[]
    costBlocks: CostBlockMeta[]
}

export interface InputLevelMeta extends NamedId {
    levelNumer: number
    isFilterLoading: boolean
}

export enum InputType {
    Manually = 0,
    Automatically = 1,
    Reference = 2,
    ManuallyAutomaticly = 3
}

export enum FieldType {
    Reference = "Reference",
    Double = "Double"
}

export interface CostEditorState {
    applications: Map<string, NamedId>
    costBlockMetas: Map<string, CostBlockMeta>
    selectedApplicationId: string
    costBlocks: CostBlockState[]
    visibleCostBlockIds: string[]
    selectedCostBlockId: string
    dataLossInfo: {
        isWarningDisplayed: boolean
        action: Action<string>
    }
}