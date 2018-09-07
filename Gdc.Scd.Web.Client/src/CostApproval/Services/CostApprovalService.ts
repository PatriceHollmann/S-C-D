import { BundleFilterStates } from "../States/BundleFilterStates"
import { NamedId } from "../../Common/States/CommonStates";
import { get, post, buildMvcUrl } from "../../Common/Services/Ajax";
import { CostMetaData } from "../../Common/States/CostMetaStates";
import { ApprovalBundle } from "../States/ApprovalBundle";
import { BundleFilter } from "../States/BundleFilter";
import { ApprovalBundleState } from "../States/ApprovalBundleState";

export const CONTROLLER_NAME = 'CostBlockHistory';

export const getCostApprovalFilterData = () => get<CostMetaData>('CostEditor', 'GetCostEditorData');

export const approve = (historyId: number) => post(CONTROLLER_NAME, 'Approve', null, { historyId });

export const reject = (historyId: number, message: string) => post(CONTROLLER_NAME, 'Reject', null, { historyId, message });

export const getBundles = (filter: BundleFilter, state: ApprovalBundleState) => get<ApprovalBundle[]>(CONTROLLER_NAME, 'GetApprovalBundles', { ...filter, state });

export const buildGetApproveBundleDetailUrl = (
    bundleId: number, 
    historyValueId?: number, 
    costBlockFilter?: { [key: string]: number[] }
) => {
    const params: any = {
        costBlockHistoryId: bundleId, 
        historyValueId
    };

    if (costBlockFilter) {
        params.costBlockFilter = JSON.stringify(costBlockFilter);
    }

    return buildMvcUrl(CONTROLLER_NAME, 'GetApproveBundleDetail', params);
}
