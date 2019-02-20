import { Action } from "redux";

export interface PageAction extends Action<string> {
    pageName: string
}

export interface ItemSelectedAction<T=string> extends Action<string> {
    selectedItemId: T;
}

export interface MultiItemSelectedAction extends Action<string> {
    selectedItemIds: string[];
}

export interface PageItemSelectedAction<T=string> extends ItemSelectedAction<T>, PageAction {

}

export interface PageMultiItemSelectedAction extends MultiItemSelectedAction, PageAction {

}

export interface CommonAction<T = any> extends Action<string> {
    data: T;
}

export interface PageCommonAction<T = any> extends CommonAction<T>, PageAction {
    
}
