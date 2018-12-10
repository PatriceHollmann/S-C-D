import { buildMvcUrl, get, post } from "../../Common/Services/Ajax";
import { TableViewInfo, QualityGateResultSet } from "../States/TableViewState";
import { TableViewRecord } from "../States/TableViewRecord";
import { CostElementIdentifier } from "../../Common/States/CostElementIdentifier";
import { Model } from "../../Common/States/ExtStates";
import { ApprovalOption } from "../../QualityGate/States/ApprovalOption";

const TABLE_VIEW_CONTROLLER_NAME = 'TableView';

export const buildGetRecordsUrl = () => buildMvcUrl(TABLE_VIEW_CONTROLLER_NAME, 'GetRecords')

export const getTableViewInfo = () => get<TableViewInfo>(TABLE_VIEW_CONTROLLER_NAME, 'GetTableViewInfo')

export const updateRecords = (records: TableViewRecord[], approvalOption: ApprovalOption) => 
    post<TableViewRecord[], QualityGateResultSet>(TABLE_VIEW_CONTROLLER_NAME, 'UpdateRecords', records, approvalOption)

export const buildGetHistoryUrl = (costElementId: CostElementIdentifier, coordinates: { [key: string]: number }) => 
    buildMvcUrl(TABLE_VIEW_CONTROLLER_NAME, 'GetHistory', { ...costElementId, ...coordinates });