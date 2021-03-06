import { connect } from "react-redux";
import { QualityGateToolbarActions } from "../../QualityGate/Components/QualityGateToolbar";
import { CommonState } from "../../Layout/States/AppStates";
import { QualtityGateTab, QualtityGateSetView } from "./QualtityGateSetView";
import { getCostBlock, getCostElement } from "../../Common/Helpers/MetaHelper";
import { resetQualityCheckResult } from "../Actions/TableViewActions";
import { QualityGateSetWindow, QualityGateSetWindowProps } from "./QualityGateSetWindow";

export const QualtityGateSetWindowContainer =
    connect<QualityGateSetWindowProps, QualityGateToolbarActions, QualityGateSetWindowProps, CommonState>(
        ({ app: { appMetaData }, pages: { tableView } }, { position }) => {
            const { qualityGateResultSet } = tableView;
            const tabs: QualtityGateTab[] = [];

            if (qualityGateResultSet && qualityGateResultSet.hasErrors) {
                for (const item of qualityGateResultSet.items) {
                    if (item.qualityGateResult.hasErrors) {
                        const { applicationId, costBlockId, costElementId } = item.costElementIdentifier;
                        const costBlock = getCostBlock(appMetaData, costBlockId);
                        const costElement = getCostElement(costBlock, costElementId);

                        tabs.push(<QualtityGateTab>{
                            key: `${applicationId}_${costBlockId}_${costElementId}`,
                            title: costElement.name,
                            costElement,
                            errors: item.qualityGateResult.errors
                        });
                    }
                }
            }

            return <QualityGateSetWindowProps>{
                tabs,
                position
            }
        },
        (dispatch, ownProps) => ({
            onSave: ownProps.onSave,
            onCancel: () => dispatch(resetQualityCheckResult())
        })
    )(QualityGateSetWindow)