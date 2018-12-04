import { NamedId, SelectList } from "../../Common/States/CommonStates";
import { BundleDetailGroup } from "../../QualityGate/States/QualityGateResult";


export interface EditItem extends NamedId {
    value: number
    valueCount: number
}

export interface CheckItem extends NamedId {
    isChecked: boolean
}

export interface Filter {
    filter: CheckItem[]
}

export interface CostElementState extends Filter {
    costElementId: string
    inputLevels: SelectList<InputLevelState>
    region: SelectList<NamedId>
    isDataLoaded: boolean
    referenceValues: NamedId<number>[]
}

export interface InputLevelState extends Filter {
    inputLevelId: string
    isFilterLoaded: boolean
}

export interface CostElementData {
    regions: NamedId[] 
    filters: NamedId[] 
    referenceValues: NamedId<number>[] 
}

export interface CostBlockEditState {
    originalItems: EditItem[],
    editedItems: EditItem[]
    appliedFilter: {
        inputLevelItemIds: Set<string>
        costElementsItemIds: Set<string>
    }
    saveErrors: BundleDetailGroup[]
}

export interface CostBlockState {
    costBlockId: string
    costElements: SelectList<CostElementState>
    edit: CostBlockEditState
}
