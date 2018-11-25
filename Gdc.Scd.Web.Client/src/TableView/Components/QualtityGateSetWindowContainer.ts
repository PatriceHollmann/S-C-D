import { connect } from "react-redux";
import { QualityGateToolbarActions } from "../../QualityGate/Components/QualityGateToolbar";
import { CommonState } from "../../Layout/States/AppStates";
import { QualtityGateTab, QualtityGateSetView } from "./QualtityGateSetView";
import { getCostBlock, getCostElement } from "../../Common/Helpers/MetaHelper";
import { saveTableViewToServer, resetQualityCheckResult } from "../Actions/TableViewActions";
import { QualityGateSetWindow, QualityGateSetWindowProps } from "./QualityGateSetWindow";

export const QualtityGateSetWindowContainer =
    connect<QualityGateSetWindowProps, QualityGateToolbarActions, QualityGateSetWindowProps, CommonState>(
        ({ app: { appMetaData }, pages: { tableView } }, { position }) => {
            const { qualityGateResultSet, info: { recordInfo } } = tableView;

            const tabs: QualtityGateTab[] = [];

            if (qualityGateResultSet && qualityGateResultSet.hasErros) {
                for (const item of qualityGateResultSet.items) {
                    if (item.qualityGateResult.hasErrors) {
                        const { applicationId, costBlockId, costElementId } = item.costElementIdentifier;
                        
                        const fieldInfos = recordInfo.data.filter(
                            fieldInfo => 
                                fieldInfo.applicationId == applicationId &&
                                fieldInfo.metaId == costBlockId &&
                                fieldInfo.fieldName == costElementId
                        );

                        const costBlock = getCostBlock(appMetaData, costBlockId);
                        const costElement = getCostElement(costBlock, costElementId);

                        tabs.push(...fieldInfos.map(fieldInfo => <QualtityGateTab>{
                            key: `${applicationId}_${costBlockId}_${costElementId}`,
                            title: `${costBlock.name} ${costElement.name}`,
                            costElement,
                            errors: item.qualityGateResult.errors
                        }));
                    }
                }
            }

            return <QualityGateSetWindowProps>{
                tabs,
                position
            }
        },
        dispatch => ({
            onSave: explanationMessage => saveTableViewToServer({ 
                hasQualityGateErrors: true, 
                isApproving: true,
                qualityGateErrorExplanation: explanationMessage
            }),
            onCancel: () => dispatch(resetQualityCheckResult())
        })
    )(QualityGateSetWindow)