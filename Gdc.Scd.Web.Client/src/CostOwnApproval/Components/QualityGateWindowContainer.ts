import { connect } from "react-redux";
import { QualityGateErrorContainerProps } from "../../QualityGate/Components/QualityGateErrorContainer";
import { CommonState } from "../../Layout/States/AppStates";
import { resetQualityGateErrors } from "../Actions/QualityGateActions";
import { handleRequest } from "../../Common/Helpers/RequestHelper";
import { QualityGateErrorWindow } from "../../QualityGate/Components/QualityGateErrorWindow";
import { QualityGateToolbarActions } from "../../QualityGate/Components/QualityGateToolbar";
import { sendForApproval } from "../../Approval/Services/ApprovalService";

export interface QualityGateWindowContainerProps extends QualityGateErrorContainerProps {
    bundleId: number
}

export const QualityGateWindowContainer = 
    connect<QualityGateErrorContainerProps, QualityGateToolbarActions, QualityGateWindowContainerProps, CommonState>(
        ({ pages }, props) => ({
            ...props,
            errors: pages.ownCostApproval.qualityGateErrors
        }),
        (dispatch, { bundleId, onSave, onCancel }) => ({
            onSave: explanationMessage => {
                dispatch(resetQualityGateErrors());
                
                handleRequest(
                    sendForApproval(bundleId, explanationMessage).then(() => onSave && onSave(explanationMessage))
                );
            },
            onCancel: () => {
                dispatch(resetQualityGateErrors());
                onCancel && onCancel();
            }
        })
    )(QualityGateErrorWindow)