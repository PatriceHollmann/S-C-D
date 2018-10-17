import { CostEditorState } from "../../CostEditor/States/CostEditorStates";
import { CostMetaData } from "../../Common/States/CostMetaStates";
import { ApprovalCostElementsLayoutState } from "../../CostApproval/States/ApprovalCostElementsLayoutState";
import { OwnApprovalCostElementsLayoutState } from "../../CostApproval/States/OwnApprovalCostElementsLayoutState";
import { TableViewState } from "../../TableView/States/TableViewState";
import { NamedId } from "../../Common/States/CommonStates";

export interface Role {
    name: string
    isGlobal: boolean
    country: NamedId
    permissions: string[]
}

export interface AppState {
    currentPage: {
        id: string
        title: string
    }
    appMetaData: CostMetaData
    userRoles: Role[]
}

export interface AppData {
    meta: CostMetaData
    userRoles: Role[]
}

export interface CommonState {
    app: AppState
    pages: {
        costEditor: CostEditorState,
        costApproval: ApprovalCostElementsLayoutState,
        ownCostApproval: OwnApprovalCostElementsLayoutState,
        tableView: TableViewState
    }
}