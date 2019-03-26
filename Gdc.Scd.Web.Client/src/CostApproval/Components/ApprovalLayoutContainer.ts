import { connectAdvanced } from "react-redux";
import { CommonState } from "../../Layout/States/AppStates";
import { Dispatch } from "redux";
import { handleRequest } from "../../Common/Helpers/RequestHelper";
import { COST_APPROVAL_PAGE } from "../Constants/CostApprovalConstants";
import { BundleListLayoutProps } from "../../Approval/Components/BundleListLayout";
import { buildBundleFilter } from "../../Approval/Helpers/FilterHelper";
import { getBundles } from "../../Approval/Services/ApprovalService";
import { loadBundles } from "../../Approval/Actions/BundleListActions";
import { ApprovalLayout } from "./ApprovalLayout";

export const ApprovalLayoutContainer = connectAdvanced<CommonState, BundleListLayoutProps, {}>(
    dispatch => ({ pages: { costApproval } }) => ({
        bundles: costApproval.bundles,
        onRefresh: () => {
            const filter = buildBundleFilter(costApproval.filter);

            handleRequest(
                getBundles(filter).then(bundles => {
                    dispatch(loadBundles(COST_APPROVAL_PAGE, bundles))
                })
            );
        }
    })
)(ApprovalLayout)