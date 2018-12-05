import * as React from "react";
import { Container } from "@extjs/ext-react";
import { FilterBundleContainer } from "./FilterBundlesContainer";
import { ApprovalBundleListContainerComponent } from "./ApprovalBundleListContainerComponent";
import { ApprovalBundle } from "../States/ApprovalBundle";
import { ApprovalBundleState } from "../States/ApprovalBundleState";
import { Action } from "redux";

export abstract class BaseBundleLayout extends React.Component{
    public render(){
        const pageName = this.getPageName();
        const approvalState = this.getApprovalBundleState();
        const title = this.getTitle();
        const isCheckColumnsVisible = this.isCheckColumnsVisible();

        return (
            <Container
                layout={{
                    type: "hbox",
                    pack: "space-between"
                }}>
                <ApprovalBundleListContainerComponent 
                    flex={2}
                    buildChildrenBundleItem={this.buildChildrenBundleItem}
                    buildReloadBundlesAction={this.buildReloadBundlesAction}
                    approvalBundleState={approvalState}
                    pageName={pageName}
                    title={title}
                    isCheckColumnsVisible={isCheckColumnsVisible}
                />
                <FilterBundleContainer 
                    pageName={pageName} 
                    approvalBundleState={approvalState}
                    buildReloadBundlesAction={this.buildReloadBundlesAction}
                />
            </Container>
        );
    }

    protected abstract buildChildrenBundleItem(bundle: ApprovalBundle, onHandled: () => void): any

    protected abstract buildReloadBundlesAction(pageName: string, approvalBundleState: ApprovalBundleState): Action<string>

    protected abstract getApprovalBundleState(): ApprovalBundleState

    protected abstract getPageName(): string

    protected abstract getTitle(): string

    protected abstract isCheckColumnsVisible(): boolean
}

export default BaseBundleLayout;