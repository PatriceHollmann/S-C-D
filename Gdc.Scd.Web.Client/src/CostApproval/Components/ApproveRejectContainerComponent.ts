import { connect } from "react-redux";
import { ApproveRejectActions, ApproveRejectComponent } from "./ApproveRejectComponent";
import { CommonState } from "../../Layout/States/AppStates";
import * as CostApprovalService from "../Services/CostApprovalService"
import { ApproveRejectContainerProps } from "./ApproveRejectContainerProps";
import { handleRequest } from "../../Common/Helpers/RequestHelper";

export const ApproveRejectContainerComponent = 
    connect<{}, ApproveRejectActions, ApproveRejectContainerProps, CommonState>(
        null,
        (dispatch, { bundleId, onHandled }) => {
            const handlePromise = (promise: Promise<any>) => handleRequest(
                promise.then(() => onHandled && onHandled())
            );

            return  {
                onApprove: () => handlePromise(CostApprovalService.approve(bundleId)),
                onSendBackToRequestor: message => handlePromise(CostApprovalService.reject(bundleId, message))
            }
        }
    )(ApproveRejectComponent)