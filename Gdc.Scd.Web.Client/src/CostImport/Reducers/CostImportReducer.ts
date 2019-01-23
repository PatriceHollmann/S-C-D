import { Reducer, Action } from "redux";
import { CostImportState, FileData } from "../States/CostImportState";
import { COST_IMPORT_SELECT_APPLICATION, COST_IMPORT_SELECT_COST_BLOCK, COST_IMPORT_SELECT_COST_ELEMENT, COST_IMPORT_LOAD_COST_ELEMENT_DATA, COST_IMPORT_LOAD_IMPORT_STATUS, COST_IMPORT_SELECT_DEPENDENCY_ITEM, COST_IMPORT_SELECT_FILE, COST_IMPORT_SELECT_REGION, COST_IMPORT_LOAD_FILE_DATA, COST_IMPORT_LOAD_QUALITY_GATE_ERRORS } from "../Actions/CostImportActions";
import { ItemSelectedAction, CommonAction } from "../../Common/Actions/CommonActions";
import { CostElementData } from "../../Common/States/CostElementData";
import { SelectList, NamedId } from "../../Common/States/CommonStates";
import { BundleDetailGroup } from "../../QualityGate/States/QualityGateResult";

const reset = () => ({
    dependencyItems: <SelectList<NamedId<number>, number>>{
        list: [],
        selectedItemId: null
    },
    regions: <SelectList<NamedId<number>, number>>{
        list: [],
        selectedItemId: null
    },
    status: [],
    file: <FileData>{
        name: null,
        base64Data: null
    }
})

const defaultState = () => (<CostImportState>{
    ...reset(),
    applicationId: null,
    costBlockId: null,
    costElementId: null,
})

const selectApplication: Reducer<CostImportState, ItemSelectedAction> = (state, action) => ({
    ...state,
    ...reset(),
    applicationId: action.selectedItemId,
    costBlockId: null,
    costElementId: null,
})

const selectCostBlock: Reducer<CostImportState, ItemSelectedAction> = (state, action) => ({
    ...state,
    ...reset(),
    costBlockId: action.selectedItemId,
    costElementId: null,
})

const selectCostElement: Reducer<CostImportState, ItemSelectedAction> = (state, action) => ({
    ...state,
    ...reset(),
     costElementId: action.selectedItemId
})

const selectDependencyItem: Reducer<CostImportState, ItemSelectedAction<number>> = (state, action) => ({
    ...state,
    dependencyItems: {
        ...state.dependencyItems,
        selectedItemId: action.selectedItemId
    }
}) 

const selectRegion: Reducer<CostImportState, ItemSelectedAction<number>> = (state, action) => ({
    ...state,
    regions: {
        ...state.dependencyItems,
        selectedItemId: action.selectedItemId
    }
}) 

const loadCostElementData: Reducer<CostImportState, CommonAction<CostElementData>> = (state, { data: { dependencyItems, regions } }) => ({
    ...state,
    dependencyItems: {
        ...state.dependencyItems,
        list: dependencyItems
    },
    regions: {
        ...state.regions,
        list: regions
    }
}) 

const loadImportStatus: Reducer<CostImportState, CommonAction<string[]>> = (state, action) => ({
    ...state,
    status: action.data
}) 

const selectFile: Reducer<CostImportState, ItemSelectedAction> = (state, action) => ({
    ...state,
    file: {
        ...state.file,
        name: action.selectedItemId,
        base64Data: null
    }
})

const loadFileData: Reducer<CostImportState, CommonAction<string>> = (state, action) => ({
    ...state,
    file: {
        ...state.file,
        base64Data: action.data
    }
})

const loadQualityGatErrors: Reducer<CostImportState, CommonAction<BundleDetailGroup[]>> = (state, action) => ({
    ...state,
    qualityGateErrors: action.data
})

export const costImportReducer: Reducer<CostImportState, Action<string>> = (state = defaultState(), action) => {
    switch (action.type) {
        case COST_IMPORT_SELECT_APPLICATION:
            return selectApplication(state, <ItemSelectedAction>action);
        
        case COST_IMPORT_SELECT_COST_BLOCK:
            return selectCostBlock(state, <ItemSelectedAction>action);

        case COST_IMPORT_SELECT_COST_ELEMENT:
            return selectCostElement(state, <ItemSelectedAction>action);

        case COST_IMPORT_SELECT_DEPENDENCY_ITEM:
            return selectDependencyItem(state, <ItemSelectedAction<number>>action);

        case COST_IMPORT_SELECT_REGION:
            return selectRegion(state, <ItemSelectedAction<number>>action);

        case COST_IMPORT_LOAD_COST_ELEMENT_DATA:
            return loadCostElementData(state, <CommonAction<CostElementData>>action);

        case COST_IMPORT_LOAD_IMPORT_STATUS:
            return loadImportStatus(state, <CommonAction<string[]>>action);

        case COST_IMPORT_SELECT_FILE:
            return selectFile(state, <ItemSelectedAction>action);

        case COST_IMPORT_LOAD_FILE_DATA:
            return loadFileData(state, <CommonAction<string>>action);

        case COST_IMPORT_LOAD_QUALITY_GATE_ERRORS:
            return loadQualityGatErrors(state, <CommonAction<BundleDetailGroup[]>>action);

        default:
            return state;
    }
}