import { Reducer, Action } from "redux";
import { BundleListState } from "../States/BundleListState";
import { COST_APPROVAL_LOAD_BUNDLES } from "../Actions/BundleListActions";
import { CommonAction } from "../../Common/Actions/CommonActions";

export const bundleListReducer: Reducer<BundleListState, Action<string>> = (state = { bundles: [] }, action) => {
    switch(action.type){
        case COST_APPROVAL_LOAD_BUNDLES:
            return {
                ...state,
                bundles: (<CommonAction>action).data
            };

        default:
            return state;
    }
}