import { Filter, CostBlockState, InputLevelState, CheckItem } from "../States/CostBlockStates";
import { NamedId } from "../../Common/States/CommonStates";
import { CostEditorState } from "../States/CostEditorStates";
import { CostBlockTab, CostEditorProps, CostEditorActions, CostEditorView } from "./CostEditorView";
import { connect } from "react-redux";
import { selectApplication, } from "../Actions/CostEditorActions";
import { 
    selectRegionWithReloading, 
    getDataByCostElementSelection, 
    loadEditItemsByContext, 
    getFilterItemsByInputLevelSelection, 
    changeSelectionCostElementFilter, 
    changeSelectionInputLevelFilter, 
    resetCostElementFilter, 
    resetInputLevelFilter, 
    clearEditItems, 
    editItem, 
    saveEditItemsToServer, 
    applyFiltersWithReloading,
    selectCostBlock, 
} 
from "../Actions/CostBlockActions";
import { SelectListFilter, RegionProps, CostElementProps } from "./CostBlocksView";
import { EditGridToolProps } from "./EditGridTool";
import { CommonState } from "../../Layout/States/AppStates";
import { InputLevelMeta, CostBlockMeta, FieldType } from "../../Common/States/CostMetaStates";
import { filterCostEditorItems, findCostBlock, findApplication } from "../Helpers/CostEditorHelpers";
import { findMeta } from "../../Common/Helpers/MetaHelper";

const isSetContainsAllCheckedItems = (set: Set<string>, filterObj: Filter) => {
    let result = true;

    if (filterObj && filterObj.filter) {
        const checkedItems = filterObj.filter.filter(item => item.isChecked);

        result = checkedItems.length == set.size && checkedItems.every(item => set.has(item.id))
    } 

    return result
}

const buildInputLevel = (
    costBlock: CostBlockState, 
    selectedInputLevel: InputLevelState,
    selectedInputLevelMeta: InputLevelMeta,
    inputLevelMetas: InputLevelMeta[],
    isEnableList: boolean
 ) => {
    let filter: CheckItem[];
    let filterName: string;
    let selectedInputLevelId: string = null;
    let isVisibleFilter: boolean;
    
    // if (selectedInputLevel) {
    //     isVisibleFilter = selectedInputLevel.filter && selectedInputLevel.filter.length > 0;
    //     if (isVisibleFilter) {
    //         const prevLevelNumber = selectedInputLevelMeta.levelNumer - 1;
    //         const prevInputLevelMeta = inputLevelMetas.find(item => item.levelNumer === prevLevelNumber);
            
    //         filterName = prevInputLevelMeta.name;
    //         filter = selectedInputLevel.filter;
    //     }

    //     selectedInputLevelId = selectedInputLevel.inputLevelId;
    // }

    if (selectedInputLevel) {
        if (selectedInputLevelMeta.hasFilter) {
            isVisibleFilter = true;
            filterName = selectedInputLevelMeta.filterName;
            filter = selectedInputLevel.filter;
        }

        selectedInputLevelId = selectedInputLevel.inputLevelId;
    }

    return <SelectListFilter>{
        id: `${costBlock.costBlockId}_${costBlock.costElements.selectedItemId}`,
        filter,
        filterName,
        isVisibleFilter,
        isEnableList: isEnableList,
        selectList: {
            selectedItemId: selectedInputLevelId,
            list: inputLevelMetas
        }
    }
};

const costBlockTabMap = (
    applicationId: string,
    costBlock: CostBlockState, 
    costBlockMeta: CostBlockMeta
): CostBlockTab => {
    const { edit } = costBlock;

    let regionProps: RegionProps;
    let inputLevel: SelectListFilter;
    let editProps: EditGridToolProps;
    let selectedInputLevelMeta: InputLevelMeta;
    let selectedInputLevel: InputLevelState;
    
    const hasChanges = edit.editedItems && edit.editedItems.length > 0;
    const isEnableList = !hasChanges;

    const costElementProps = <CostElementProps>{
        id: costBlock.costBlockId,
        selectList: {
            selectedItemId: costBlock.costElements.selectedItemId,
            // // // list: costBlockMeta.costElements.filter(
            // // //     costElement => costBlock.visibleCostElementIds.includes(costElement.id))
            // list: costBlockMeta.costElements.filter(
            //     costElement => 
            //         costElement.inputType === InputType.Manually || 
            //         costElement.inputType === InputType.ManuallyAutomaticly
            // )
            list: filterCostEditorItems(costBlockMeta.costElements)
        },
        isEnableList,
        isVisibleFilter: false,
    }

    if (costBlock.costElements.selectedItemId != null) {
        const selectedCostElement = 
            costBlock.costElements.list.find(
                item => item.costElementId === costBlock.costElements.selectedItemId);

        const selectedCostElementMeta = 
            costBlockMeta.costElements.find(
                item => item.id === costBlock.costElements.selectedItemId);

        if (selectedCostElement.inputLevels.selectedItemId != null) {
            selectedInputLevelMeta = 
                selectedCostElementMeta.inputLevels.find(inputLevel => inputLevel.id === selectedCostElement.inputLevels.selectedItemId);

            selectedInputLevel = 
                selectedCostElement.inputLevels.list.find(item => item.inputLevelId === selectedCostElement.inputLevels.selectedItemId);

            editProps = {
                editGrid: {
                    nameColumnTitle: selectedInputLevelMeta.name,
                    valueColumn: {
                        title: selectedCostElementMeta.name,
                        type: selectedCostElementMeta.typeOptions ? selectedCostElementMeta.typeOptions.Type : FieldType.Double,
                        selectedItems: selectedCostElement.referenceValues
                    },
                    items: edit.originalItems && edit.originalItems.map(originalItem => ({
                        ...edit.editedItems.find(editedItem => editedItem.id === originalItem.id) || originalItem
                    }))
                },
                applicationId,
                costBlockId: costBlock.costBlockId,
                qualityGateErrors: costBlock.edit.saveErrors,
                isEnableClear: hasChanges,
                isEnableSave: hasChanges,
                isEnableApplyFilters: !isSetContainsAllCheckedItems(edit.appliedFilter.costElementsItemIds, selectedCostElement) ||
                                      !isSetContainsAllCheckedItems(edit.appliedFilter.inputLevelItemIds, selectedInputLevel) 
            }
        }

        inputLevel = buildInputLevel(
            costBlock, 
            selectedInputLevel, 
            selectedInputLevelMeta, 
            selectedCostElementMeta.inputLevels, 
            isEnableList);

        if (selectedCostElementMeta.regionInput){
            regionProps = {
                name: selectedCostElementMeta.regionInput.name,
                selectedList: selectedCostElement.region,
                isEnabled: !hasChanges
            }
        }

        costElementProps.filter = selectedCostElement.filter;
        costElementProps.filterName = selectedCostElementMeta.dependency && selectedCostElementMeta.dependency.name;
        costElementProps.description = selectedCostElementMeta.description;
        costElementProps.isVisibleFilter = selectedCostElement.filter && selectedCostElement.filter.length > 0;
    }

    return {
        id: costBlock.costBlockId,
        name: costBlockMeta.name,
        costBlock: {
            region: regionProps,
            costElement: costElementProps,
            inputLevel: inputLevel,
            edit: editProps
        }
    }
}

export const CostEditorContainer = connect<CostEditorProps,CostEditorActions,{},CommonState>(
    state => {
        // const { 
        //     //applications, 
        //     selectedApplicationId,
        //     //visibleCostBlockIds,
        //     selectedCostBlockId,
        //     costBlocks,
        //     //costBlockMetas,
        //     dataLossInfo,
        // } = state.pages.costEditor;

        
        const { applications, dataLossInfo } = state.pages.costEditor;
        const { costBlocks } = findApplication(state.pages.costEditor);
        const { applications: applicationMetas, costBlocks: costBlockMetas } = state.app.appMetaData;

        return {
            application: {
                selectedItemId: applications.selectedItemId,
                list: <NamedId[]>filterCostEditorItems(applicationMetas)
                //list: applications && Array.from(applications.values())
            },
            isDataLossWarningDisplayed: dataLossInfo.isWarningDisplayed,
            costBlocks: {
                selectedItemId: costBlocks.selectedItemId,
                // list: costBlocks && 
                //     //   //costBlocks.filter(costBlock => visibleCostBlockIds.includes(costBlock.costBlockId))
                //     //   costBlocks.filter(costBlock => findMeta(costBlockMetas, costBlock.costBlockId).applicationIds.includes(selectedApplicationId))
                //     //             .map(costBlock => 
                //     //                 costBlockTabMap(
                //     //                     costBlock, 
                //     //                     costBlockMetas.get(costBlock.costBlockId)))
                // list: costBlocks.list.map(costBlock => ({ state: costBlock, meta: findMeta(costBlockMetas, costBlock.costBlockId) }))
                //                      .filter(costBlockInfo => costBlockInfo.meta.applicationIds.includes(applications.selectedItemId))
                //                      .map(costBlockInfo => costBlockTabMap(costBlockInfo.state, costBlockInfo.meta))   
                list: costBlocks.list.map(costBlock => {
                    let costBlockTab: CostBlockTab;

                    const costBlockMeta = findMeta(costBlockMetas, costBlock.costBlockId);

                    return costBlocks.selectedItemId == costBlock.costBlockId 
                        ? costBlockTabMap(applications.selectedItemId, costBlock, costBlockMeta)
                        : <CostBlockTab>{
                            id: costBlockMeta.id,
                            name: costBlockMeta.name
                        }
                })     
            }
        } as CostEditorProps;
    },
    dispatch => ({
        //onApplicationSelected: applicationId => dispatch(selectApplicationLosseDataCheck(applicationId)),
        onApplicationSelected: applicationId => dispatch(selectApplication(applicationId)),
        onCostBlockSelected: (applicationId, costBlockId) => dispatch(selectCostBlock(applicationId, costBlockId)),
        // onLoseChanges: () => dispatch(loseChanges()),
        // onCancelDataLose: () => dispatch(hideDataLoseWarning()),
        tabActions: {
            onRegionSelected: (regionId, costBlockId, applicationId) => {
                dispatch(selectRegionWithReloading(applicationId, costBlockId, regionId));
            },
            onCostElementSelected: (applicationId, costBlockId, costElementId) => {
                dispatch(getDataByCostElementSelection(applicationId, costBlockId, costElementId));
                dispatch(loadEditItemsByContext());
            },
            onInputLevelSelected: (applicationId, costBlockId, costElementId, inputLevelId) => {
                dispatch(getFilterItemsByInputLevelSelection(applicationId, costBlockId, costElementId, inputLevelId));
                dispatch(loadEditItemsByContext());
            },
            onCostElementFilterSelectionChanged: (applicationId, costBlockId, costElementId, filterItemId, isSelected) => {
                dispatch(changeSelectionCostElementFilter(applicationId, costBlockId, costElementId, filterItemId, isSelected));
            },
            onInputLevelFilterSelectionChanged: (applicationId, costBlockId, costElementId, inputLevelId, filterItemId, isSelected) => {
                dispatch(changeSelectionInputLevelFilter(applicationId, costBlockId, costElementId, inputLevelId, filterItemId, isSelected));
            },
            onCostElementFilterReseted: (applicationId, costBlockId, costElementId) => {
                dispatch(resetCostElementFilter(applicationId, costBlockId, costElementId));
            },
            onInputLevelFilterReseted: (applicationId, costBlockId, costElementId, inputLevelId) => {
                dispatch(resetInputLevelFilter(applicationId, costBlockId, costElementId, inputLevelId))
            },
            onEditItemsCleared: (applicationId, costBlockId) => dispatch(clearEditItems(applicationId, costBlockId)),
            onItemEdited: (applicationId, costBlockId, item) => dispatch(editItem(applicationId, costBlockId, item)),
            onEditItemsSaving: (applicationId, costBlockId, forApproval) => dispatch(
                saveEditItemsToServer(applicationId, costBlockId, { isApproving: forApproval })
            ),
            onApplyFilters: (applicationId, costBlockId) => dispatch(applyFiltersWithReloading(applicationId, costBlockId))
        }
    })
)(CostEditorView);