import { Action } from 'redux';
import { asyncAction, AsyncAction } from "../../Common/Actions/AsyncAction";
import * as service from "../Services/CostApprovalService";
import { ItemSelectedAction, ItemsSelectedAction } from "../../Common/Actions/CommonActions";
import { openPage, pageInit, loadMetaData } from '../../Layout/Actions/AppActions';

export const COST_APPROVAL_PAGE = "costApproval";
export const COST_APPROVAL_SELECT_APPLICATION = "COST_APPROVAL_SELECT_APPLICATIONS";
export const COST_APPROVAL_SELECT_COST_BLOCKS = "COST_APPROVAL_SELECT_COST_BLOCKS";
export const COST_APPROVAL_SELECT_COST_ELEMENTS = "COST_APPROVAL_SELECT_COST_ELEMENTS";
export const COST_APPROVAL_SELECT_PERIOD = "COST_APPROVAL_SELECT_PERIOD";

export interface SelectPeriodAction extends Action<string>{
    startDate: string;
    endDate: string;
}

export const selectApplication = (applicationId: string) => <ItemSelectedAction>{
    type: COST_APPROVAL_SELECT_APPLICATION,
    selectedItemId: applicationId
}

export const selectCostBlocks = (selectedCostBlockIds: string[]) => <ItemsSelectedAction>{
    type: COST_APPROVAL_SELECT_COST_BLOCKS,
    selectedItemIds: selectedCostBlockIds
}

export const selectCostElements = (selectedCostElementIds: string[]) => <ItemsSelectedAction>{
    type: COST_APPROVAL_SELECT_COST_ELEMENTS,
    selectedItemIds: selectedCostElementIds
}

export const selectTimePeriod = (startDate: string, endDate: string) => <SelectPeriodAction>{
    type: COST_APPROVAL_SELECT_PERIOD,
    startDate: startDate,
    endDate: endDate
}

export const init = () => asyncAction(
    dispatch => {
        dispatch(openPage(COST_APPROVAL_PAGE, 'Cost Elements Approval'));
        service.getCostApprovalFilterData().then(
            data => {
                //TODO: remove
                console.log(data);
                dispatch(pageInit(COST_APPROVAL_PAGE, data));
                dispatch(loadMetaData(data));
            } 
        );
        error => dispatch(error(error))
    }
)



