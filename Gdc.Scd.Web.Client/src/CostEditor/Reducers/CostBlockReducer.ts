import { Reducer, Action } from "redux";
import { CostBlockState, CostElementState, InputLevelState, CheckItem, EditItem, DataLoadingState, CostBlockEditState } from "../States/CostBlockStates";
import { CostEditorState } from "../States/CostEditorStates";
import { 
    COST_EDITOR_PAGE, 
    COST_EDITOR_SELECT_APPLICATION, 
    COST_EDITOR_SELECT_COST_BLOCK 
} from "../Actions/CostEditorActions";
import { ItemSelectedAction } from "../../Common/Actions/CommonActions";
import { 
    COST_BLOCK_INPUT_SELECT_REGIONS, 
    COST_BLOCK_INPUT_SELECT_COST_ELEMENT,
    RegionSelectedAction, 
    CostElementAction, 
    CostBlockAction, 
    FilterSelectionChangedAction,
    COST_BLOCK_INPUT_SELECTION_CHANGE_COST_ELEMENT_FILTER,
    CostElementFilterSelectionChangedAction,
    COST_BLOCK_INPUT_RESET_COST_ELEMENT_FILTER,
    COST_BLOCK_INPUT_SELECT_INPUT_LEVEL,
    InputLevelAction,
    InputLevelFilterSelectionChangedAction,
    COST_BLOCK_INPUT_SELECTION_CHANGE_INPUT_LEVEL_FILTER,
    COST_BLOCK_INPUT_RESET_INPUT_LEVEL_FILTER,
    InputLevelFilterLoadedAction,
    COST_BLOCK_INPUT_LOAD_INPUT_LEVEL_FILTER,
    COST_BLOCK_INPUT_LOAD_EDIT_ITEMS,
    EditItemsAction,
    COST_BLOCK_INPUT_CLEAR_EDIT_ITEMS,
    ItemEditedAction,
    COST_BLOCK_INPUT_EDIT_ITEM,
    COST_BLOCK_INPUT_SAVE_EDIT_ITEMS,
    COST_BLOCK_INPUT_APPLY_FILTERS,
    COST_BLOCK_INPUT_LOAD_COST_ELEMENT_DATA,
    CostElementDataLoadedAction,
    SaveEditItemsAction,
    COST_BLOCK_INPUT_RESET_ERRORS,
 } from "../Actions/CostBlockActions";
import { mapIf } from "../../Common/Helpers/CommonHelpers";
import { changeSelecitonFilterItem, resetFilter, loadFilter } from "./FilterReducer";
import { PageInitAction, APP_PAGE_INIT } from "../../Layout/Actions/AppActions";
import { CostBlockMeta, InputType, FieldType, CostMetaData } from "../../Common/States/CostMetaStates";

const getVisibleCostBlockIds = (costBlockMetas: CostBlockMeta[], selectedApplicationId: string) => {
    return costBlockMetas.filter(costBlockMeta => costBlockMeta.applicationIds.includes(selectedApplicationId))
                         .map(costBlockMeta => costBlockMeta.id);
}

const clearCostBlockFilters  = (costBlock: CostBlockState, clearSelected: boolean = false) => {
    const result: CostBlockState = {
        ...costBlock,
        costElement: {
            ...costBlock.costElement,
            list: costBlock.costElement.list.map(costElement => ({
                ...costElement,
                filter: null,
                inputLevel: {
                    ...costElement.inputLevel,
                    list: costElement.inputLevel.list.map(inputLevel => ({
                        ...inputLevel,
                        filter: null
                    })),
                    selectedItemId: clearSelected ? null : costElement.inputLevel.selectedItemId,
                }
            }))
        }
    };

    if (clearSelected) {
        result.costElement.selectedItemId = null;
    }

    return result;
}

const getVisibleCostElementIds = (costBlock: CostBlockMeta) => {
    var costElements = costBlock.costElements.filter(
        costElement => 
            costElement.inputType === InputType.Manually || 
            costElement.inputType === InputType.ManuallyAutomaticly
    )

    return costElements.map(costElement => costElement.id);
}

const initSuccess: Reducer<CostEditorState, PageInitAction<CostMetaData>> = (state, action) => {
    const { costBlocks: costBlockMetas } = action.data;

    const visibleCostBlockIds = getVisibleCostBlockIds(costBlockMetas, state.selectedApplicationId);

    return action.pageId === COST_EDITOR_PAGE 
        ? {
            ...state,
            costBlocks: costBlockMetas.map(costBlockMeta => (<CostBlockState>{
                costBlockId: costBlockMeta.id,
                selectedRegionId: null,
                costElement: {
                    selectedItemId: null,
                    list: costBlockMeta.costElements.map(costElementMeta => (<CostElementState>{
                        costElementId: costElementMeta.id,
                        inputLevel: {
                            selectedItemId: null,
                            list: costElementMeta.inputLevels.map(inputLevel => (<InputLevelState>{
                                inputLevelId: inputLevel.id
                            }))
                        },
                        dataLoadingState: DataLoadingState.None
                    }))
                },
                visibleCostElementIds: getVisibleCostElementIds(costBlockMeta),
                edit: {
                    originalItems: null,
                    editedItems: [],
                    isFiltersApplied: true,
                    appliedFilter: {
                        costElementsItemIds: new Set<string>(),
                        inputLevelItemIds: new Set<string>()
                    },
                    saveErrors: []
                }
            })),
            visibleCostBlockIds,
            selectedCostBlockId: visibleCostBlockIds[0]
        } 
        : state;
}

const selectApplication: Reducer<CostEditorState, ItemSelectedAction> = (state, action) => {
    const visibleCostBlockIds = getVisibleCostBlockIds(
        Array.from(state.costBlockMetas.values()), 
        action.selectedItemId);

    const selectedCostBlockId = visibleCostBlockIds.includes(state.selectedCostBlockId)
        ? state.selectedCostBlockId
        : visibleCostBlockIds[0];

    return {
        ...state,
        costBlocks: state.costBlocks.map(costBlock => clearCostBlockFilters(costBlock, true)),
        visibleCostBlockIds,
        selectedCostBlockId,
    }
}

const buildCostBlockChanger = <TAction extends CostBlockAction>(
    changeFn: ((costBlock: CostBlockState, action: TAction, state: CostEditorState) => CostBlockState)
) => 
        (state: CostEditorState, action: Action<string>) => {
            const costBlockAction = <TAction>action;

            return <CostEditorState>{
                ...state,
                costBlocks: mapIf(
                    state.costBlocks, 
                    costBlock => costBlock.costBlockId === costBlockAction.costBlockId,
                    costBlock => changeFn(costBlock, costBlockAction, state) 
                )
            }
        }

const buildCostElementListItemChanger = <TAction extends CostElementAction>(
    costElementFn: ((costElement: CostElementState, action: TAction) => CostElementState)
) => 
    buildCostBlockChanger<TAction>(
        (costBlock, action) => ({
            ...costBlock,
            costElement: {
                ...costBlock.costElement,
                list: mapIf(
                    costBlock.costElement.list,
                    costElement => costElement.costElementId === action.costElementId,
                    costElement => costElementFn(costElement, action)
                )
            }
        })
    )

const buildInputLevelFilterChanger = <TAction extends InputLevelAction>(
    inputLevelFn: ((costElement: InputLevelState, action: TAction) => InputLevelState)
) => 
    buildCostElementListItemChanger<TAction>(
        (costElement, action) => ({
            ...costElement,
            inputLevel: {
                ...costElement.inputLevel,
                list: mapIf(
                    costElement.inputLevel.list, 
                    item => item.inputLevelId === action.inputLevelId, 
                    item => inputLevelFn(item, action)
                )
            }
        })
    )

const selectRegion = buildCostBlockChanger<RegionSelectedAction>(
    (costBlock, action) => ({
        ...clearCostBlockFilters(costBlock), 
        costElement: {
            ...costBlock.costElement,
            list: costBlock.costElement.list.map(
                costElement => 
                    costElement.costElementId === action.costElementId 
                        ? {
                            ...costElement,
                            region: {
                                ...costElement.region,
                                selectedItemId: action.regionId
                            }
                        }
                        : costElement
            )
        }
    })
)

const selectCostElement = buildCostBlockChanger<CostElementAction>(
    (costBlock, { costElementId }, state) => (<CostBlockState>{
        ...costBlock, 
        costElement: {
            ...costBlock.costElement,
            selectedItemId: costElementId,
            list: costBlock.costElement.list.map(item => {
                if (item.costElementId === costElementId && !item.dataLoadingState) {
                    const costBlockMeta = state.costBlockMetas.get(costBlock.costBlockId);
                    const costElementMeta = costBlockMeta.costElements.find(item => item.id === costElementId);
                    const isDataLoading = 
                        costElementMeta.regionInput || 
                        costElementMeta.dependency || 
                        costElementMeta.typeOptions && costElementMeta.typeOptions.Type === FieldType.Reference;

                    item = {
                        ...item,
                        dataLoadingState: isDataLoading ? DataLoadingState.Wait : DataLoadingState.None
                    }
                }

                return item;
            })
        }
    })
)

const changeSelectionCostElementFilter = buildCostElementListItemChanger<CostElementFilterSelectionChangedAction>(
    (costElement, action) => ({
        ...costElement,
        filter: changeSelecitonFilterItem(costElement.filter, action)
    })
)

const resetCostElementFilter = buildCostElementListItemChanger<CostElementAction>(
    costElement => ({
        ...costElement,
        filter: resetFilter(costElement.filter)
    })
)

const selectInputLevel = buildCostElementListItemChanger<InputLevelAction>(
    (costElement, action) => ({
        ...costElement,
        inputLevel: {
            ...costElement.inputLevel,
            selectedItemId: action.inputLevelId
        }
    })
)

const changeSelectionInputLevelFilter = buildInputLevelFilterChanger<InputLevelFilterSelectionChangedAction>(
    (inputLevel, action) => ({
        ...inputLevel, 
        filter: changeSelecitonFilterItem(inputLevel.filter, action)
    })
)

const resetInputLevelFilter = buildInputLevelFilterChanger(
    inputLevel => ({
        ...inputLevel,
        filter: resetFilter(inputLevel.filter)
    })
)

const loadCostElementData = buildCostElementListItemChanger<CostElementDataLoadedAction>(
    (costElement, { costElementData }) => ({
        ...costElement,
        dataLoadingState: DataLoadingState.Loaded,
        region: {
            ...costElement.region,
            list: costElementData.regions && costElementData.regions.sort((region1, region2) => region1.name.localeCompare(region2.name)),
            selectedItemId: costElementData.regions && costElementData.regions[0].id
        },
        filter: loadFilter(costElementData.filters),
        referenceValues: costElementData.referenceValues
    })
)

const loadLevelInputFilter = buildInputLevelFilterChanger<InputLevelFilterLoadedAction>(
    (inputLevel, action) => ({
        ...inputLevel,
        filter: loadFilter(action.filterItems)
    })
)

const loadEditItems = buildCostBlockChanger<EditItemsAction>(
    (costBlock, action) => ({
        ...costBlock,
        edit: {
            ...costBlock.edit,
            editedItems: [],
            originalItems: action.editItems
        }
    })
)

const clearEditItems = buildCostBlockChanger(
    costblock => ({
        ...costblock,
        edit: {
            ...costblock.edit,
            editedItems: []
        }
    })
)

const editItem = buildCostBlockChanger<ItemEditedAction>(
    (costBlock, action) => {
        const editedItems = costBlock.edit.editedItems;
        const editedItem = <EditItem>{
            ...action.item,
            valueCount: 1
        };

        return {
            ...costBlock,
            edit: {
                ...costBlock.edit,
                editedItems: editedItems.filter(item => item.id !== action.item.id)
                                        .concat(editedItem)
            }
        }
    }
)

const saveEditItems = buildCostBlockChanger<SaveEditItemsAction>(
    (costBlock, action) => {
        const edit: CostBlockEditState = action.qualityGateResult.hasErrors
            ? {
                ...costBlock.edit,
                saveErrors: action.qualityGateResult.errors
            }
            : {
                ...costBlock.edit,
                editedItems: [],
                originalItems: costBlock.edit.originalItems.map(
                    origItem => 
                        costBlock.edit.editedItems.find(editedItem => editedItem.id === origItem.id) || 
                        origItem
                ),
                saveErrors: []
            };

        return {
            ...costBlock,
            edit
        };
    }
)

const checkedFilterItemsSet = (filterItems: CheckItem[]) => {
    const ids = filterItems && filterItems.filter(item => item.isChecked).map(item => item.id);

    return new Set<string>(ids);
}

const applyFilters = buildCostBlockChanger(
    costBlock => {
        const { costElement } = costBlock;
        
        const selectedCostElement = 
            costElement.list.find(item => item.costElementId === costElement.selectedItemId);

        const selectInputLevel = 
            selectedCostElement.inputLevel.list.find(item => item.inputLevelId === selectedCostElement.inputLevel.selectedItemId);

        return <CostBlockState>{ 
            ...costBlock,
            edit: {
                ...costBlock.edit,
                appliedFilter: {
                    ...costBlock.edit.editedItems,
                    costElementsItemIds: checkedFilterItemsSet(selectedCostElement.filter),
                    inputLevelItemIds: checkedFilterItemsSet(selectInputLevel.filter)
                }
            }
        }
    }
)

const resetErrors = buildCostBlockChanger(
    costBlock => ({
        ...costBlock,
        edit: {
            ...costBlock.edit,
            saveErrors: []
        }
    })
)

export const costBlockReducer: Reducer<CostEditorState, Action<string>> = (state, action) => {
    switch(action.type) {
        case APP_PAGE_INIT:
            return initSuccess(state, <PageInitAction<CostMetaData>>action)
        
        case COST_EDITOR_SELECT_APPLICATION:
            return selectApplication(state, <ItemSelectedAction>action)

        case COST_BLOCK_INPUT_LOAD_COST_ELEMENT_DATA:
            return loadCostElementData(state, action);

        case COST_BLOCK_INPUT_SELECT_REGIONS: 
            return selectRegion(state, action)

        case COST_BLOCK_INPUT_SELECT_COST_ELEMENT:
            return selectCostElement(state, action)

        case COST_BLOCK_INPUT_SELECTION_CHANGE_COST_ELEMENT_FILTER: 
            return changeSelectionCostElementFilter(state, action)

        case COST_BLOCK_INPUT_RESET_COST_ELEMENT_FILTER:
            return resetCostElementFilter(state, action)
            
        case COST_BLOCK_INPUT_SELECT_INPUT_LEVEL:
            return selectInputLevel(state, action)

        case COST_BLOCK_INPUT_SELECTION_CHANGE_INPUT_LEVEL_FILTER:
            return changeSelectionInputLevelFilter(state, action)

        case COST_BLOCK_INPUT_RESET_INPUT_LEVEL_FILTER:
            return resetInputLevelFilter(state, action);

        case COST_BLOCK_INPUT_LOAD_INPUT_LEVEL_FILTER:
            return loadLevelInputFilter(state, action)

        case COST_BLOCK_INPUT_LOAD_EDIT_ITEMS:
            return loadEditItems(state, action)

        case COST_BLOCK_INPUT_CLEAR_EDIT_ITEMS:
            return clearEditItems(state, action)

        case COST_BLOCK_INPUT_EDIT_ITEM:
            return editItem(state, action)

        case COST_BLOCK_INPUT_SAVE_EDIT_ITEMS:
            return saveEditItems(state, action)

        case COST_BLOCK_INPUT_APPLY_FILTERS:
            return applyFilters(state, action)

        case COST_BLOCK_INPUT_RESET_ERRORS:
            return resetErrors(state, action);

        default:
            return state;
    }
}