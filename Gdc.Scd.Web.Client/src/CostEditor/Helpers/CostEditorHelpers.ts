import { CostEditorState } from "../States/CostEditorStates";
import { Action } from "redux";
import { asyncAction } from "../../Common/Actions/AsyncAction";
import { Dispatch } from "react-redux";
import { CommonState } from "../../Layout/States/AppStates";
import { UsingInfo, CostBlockMeta, CostMetaData } from "../../Common/States/CostMetaStates";
import { SelectList } from "../../Common/States/CommonStates";
import { CostBlockState, CostElementState, InputLevelState, CheckItem } from "../States/CostBlockStates";
import { Context } from "../../Common/States/Context";

export const findApplication = (state: CostEditorState, applicationId = state.applications.selectedItemId) => 
    state.applications.list.find(app => app.id == applicationId)

export const findCostBlock = (costBlocks: SelectList<CostBlockState>, costBlockId = costBlocks.selectedItemId) => 
    costBlocks.list.find(costBlock => costBlock.costBlockId == costBlockId)

export const findCostElement = (costElements: SelectList<CostElementState>, costElementId = costElements.selectedItemId) => 
    costElements.list.find(costElement => costElement.costElementId == costElementId)

export const findInputLevel = (inputLevels: SelectList<InputLevelState>, inputLevelId = inputLevels.selectedItemId) =>
    inputLevels.list.find(inputLevel => inputLevel.inputLevelId == inputLevelId)

export const findCostBlockByState = (state: CostEditorState, applicationId?: string, costBlockId?: string) => {
    const { costBlocks } = findApplication(state, applicationId);

    return findCostBlock(costBlocks, costBlockId)
}

export const findCostElementByState = (state: CostEditorState, applicationId?: string, costBlockId?: string, costElementId?: string) => {
    const { costElements } = findCostBlockByState(state, applicationId, costBlockId);

    if (costElementId == null) {
        costElementId = costElements.selectedItemId;
    }

    return findCostElement(costElements, costElementId);
}

export const findInputeLevelByState = (state: CostEditorState, applicationId?: string, costBlockId?: string, costElementId?: string, inputeLevelId?: string) => {
    const { inputLevels } = findCostElementByState(state, applicationId, costBlockId, costElementId);

    return findInputLevel(inputLevels, inputeLevelId);
}

export const getCheckedItemIds = (items: CheckItem[]) => {
    let ids: number[] = [];

    items && items.forEach(item => item.isChecked && ids.push(item.id));

    return ids;
}

export const buildCostEditorContext = (state: CostEditorState) => {
    const { id: applicationId, costBlocks } = findApplication(state);
    const costBlock = findCostBlock(costBlocks);
    const { costBlockId, costElements } = costBlock;

    let costElementFilterIds: number[] = null;
    let inputLevelFilterIds: number[] = null;
    let inputLevelId: string = null;
    let regionInputId: number = null;

    if (costElements.selectedItemId == null) {
        costElementFilterIds = [];
        inputLevelFilterIds = [];
    } else {
        const selectedCostElement = findCostElement(costElements);

        regionInputId = selectedCostElement.region && selectedCostElement.region.selectedItemId;
        inputLevelId = selectedCostElement.inputLevels.selectedItemId;
        costElementFilterIds = getCheckedItemIds(selectedCostElement.filter);

        const inputLevel = findInputLevel(selectedCostElement.inputLevels);

        if (inputLevel) {
            inputLevelFilterIds = getCheckedItemIds(inputLevel.filter);
        } else {
            inputLevelFilterIds = [];
        }
    }

    return <Context>{
        applicationId,
        costBlockId,
        regionInputId,
        costElementId: costElements.selectedItemId,
        inputLevelId,
        costElementFilterIds,
        inputLevelFilterIds
    }
}

export const filterCostEditorItems = <T extends UsingInfo>(items: T[]) => items.filter(item => item.usingInfo.isUsingCostEditor);