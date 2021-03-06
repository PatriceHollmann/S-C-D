﻿import { Dialog } from "@extjs/ext-react";
import * as React from "react";
import { handleRequest } from "../../Common/Helpers/RequestHelper";
import { get, getFromUri } from "../../Common/Services/Ajax";
import { priceStr } from "./PlausibilityCheckHwDialog";

export class PlausibilityCheckHddDialog extends React.Component<any, any> {

    private wnd: Dialog & any;

    public state: any = {
        onlyMissing: false,
        model: null
    };

    public show(id: number, approved: boolean) {
        this.setModel(null);
        let p = get('hdd', 'details', { id, approved }).then(this.onLoad);
        handleRequest(p);
    }

    public render() {
        let m = this.state.model;
        return <Dialog
            ref={this.wndRef}
            displayed={false}
            closable
            closeAction="hide"
            draggable={false}
            minWidth="650px"
            maxWidth="1400px"
            width="75%"
            height="90%"
            title="Plausibility check"
            scrollable={true}
        >
            {m && this.renderBody(m)}
        </Dialog>;
    }

    private wndRef = x => {
        this.wnd = x;
    }

    private setModel(m) {
        this.setState({ onlyMissing: false, model: m });
    }

    private onLoad = (x) => {
        this.setModel(x);
        this.wnd.show();
    }

    private renderBody(d) {
        return <div>
            <h1 className="plausi-box wide">
                <span className="plausi-box-left">{d.name}</span>
                <span className="plausi-box-right no-wrap">{priceStr(d.value)}</span>
            </h1>

            <div className="plausi-box wide">
                <div className="plausi-box-left">
                    <p>
                        <span className="sla">
                            {d.wg},&nbsp;
                            {d.sog}
                        </span>
                    </p>
                </div>
            </div>

            <a className="lnk underline" onClick={this.onShowMissing}>
                {this.state.onlyMissing ? 'Show all elements' : 'Show missing elements only'}
            </a>
            <br />

            {this.renderBlocks(d.costBlocks)}
        </div>;
    }

    private renderBlocks = (items: Array<any>) => {

        if (!items) {
            return null;
        }

        return this.renderElements(items[0].costElements);
    }

    private renderElements = (elems: Array<any>) => {
        if (elems) {
            return <table className="plausi-tbl">
                <thead>
                    <tr>
                        <th></th>
                        <th className="w40">Cost element</th>
                        <th className="w20">Value</th>
                        <th className="w20">Dependency</th>
                        <th>Level</th>
                    </tr>
                </thead>
                <tbody>
                    {elems.map(this.renderElementRow)}
                </tbody>
            </table>;
        }
    }

    private renderElementRow = (d, i) => {

        let cls;

        if (this.state.onlyMissing && d.value) {
            cls = 'hidden';
        }

        if (d.mandatory && !d.value) {
            cls = 'missing';
        }

        let mandatory;
        if (d.mandatory) {
            mandatory = '*';
        }

        return <tr key={i} className={cls}>
            <td>{mandatory}</td>
            <td>{d.name}</td>
            <td>{d.value}</td>
            <td>{d.dependency}</td>
            <td>{d.level}</td>
        </tr>;
    }

    private onShowMissing = () => {
        let missing = !this.state.onlyMissing;
        this.setState({ onlyMissing: missing });
    }
}