import { Action } from 'redux';
import { asyncAction, AsyncAction } from "../../Common/Actions/AsyncAction";
import * as service from "../Services/CostApprovalService";
import { ItemSelectedAction } from "../../Common/Actions/CommonActions";
import { pageInit, loadAppData } from '../../Layout/Actions/AppActions';
import { ElementWithParent } from '../../Common/States/CommonStates';

export const COST_APPROVAL_SELECT_APPLICATION = "COST_APPROVAL_SELECT_APPLICATIONS";
export const COST_APPROVAL_CHECK_COST_BLOCK = "COST_APPROVAL_CHECK_COST_BLOCK";
export const COST_APPROVAL_CHECK_COST_ELEMENT = "COST_APPROVAL_CHECK_COST_ELEMENT";
export const COST_APPROVAL_UNCHECK_COST_BLOCK = "COST_APPROVAL_UNCHECK_COST_BLOCK";
export const COST_APPROVAL_UNCHECK_COST_ELEMENT = "COST_APPROVAL_UNCHECK_COST_ELEMENT";
export const COST_APPROVAL_SELECT_START_DATE = "COST_APPROVAL_SELECT_START_DATE";
export const COST_APPROVAL_SELECT_END_DATE = "COST_APPROVAL_SELECT_END_DATE";
export const COST_APPROVAL_ON_INIT = "COST_APPROVAL_ON_INIT";

