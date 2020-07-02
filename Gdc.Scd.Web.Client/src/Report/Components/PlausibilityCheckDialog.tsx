﻿import { Dialog } from "@extjs/ext-react";
import * as React from "react";
import { Accordion } from "../../Common/Components/Accordion";
import { handleRequest } from "../../Common/Helpers/RequestHelper";
import { get } from "../../Common/Services/Ajax";

export interface PlausibilityCheckProps {

}

export class PlausibilityCheckDialog extends React.Component<PlausibilityCheckProps, any> {

    private wnd: Dialog & any;

    public state: any = {
        onlyMissing: false,
        model: null
    };

    public show(id: number, what: string) {
        this.setModel(null);
        let p = get('calc', 'details', { id, what }).then(this.onLoad);
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
                <span className="plausi-box-right no-wrap">{this.priceStr(d.value, d.exchangeRate, d.currency)}</span>
            </h1>

            <div className="plausi-box wide">
                <div className="plausi-box-left">
                    <p>
                        <span className="sla">
                            {d.fsp ? d.fsp + ': ' : ''}
                            {d.country},&nbsp;
                            {d.wg},&nbsp;
                            {d.availability},&nbsp;
                            {d.duration},&nbsp;
                            {d.reactionTime === 'none' && d.reactionType === 'none' ? 'no Reaction' : d.reactionTime + ' ' + d.reactionType},&nbsp;
                            {d.serviceLocation},&nbsp;
                            {d.stdWarranty} {d.stdWarranty > 1 ? 'years' : 'year'} STDW
                        </span>
                        <br />
                        {d.proActiveSla === 'none' ? 'no Proactive SLA' : d.proActiveSla}
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

        if (items.length > 1) {
            return items.map(this.renderBlock);
        }

        return this.renderElements(items[0].costElements);
    }

    private renderBlock = (d, i) => {

        let cls = this.state.onlyMissing && d.value ? 'plausi-accordion hidden' : 'plausi-accordion';

        if (!d.value) {
            cls += ' missing';
        }

        let smodel = this.state.model;
        let title = <div className="plausi-box">
            <div className="plausi-box-left">{d.name}</div>
            <div className="plausi-box-right plausi-box-right2">{this.priceStr(d.value, smodel.exchangeRate, smodel.currency)}</div>
        </div>;

        return <div className={cls} key={i}>
            <Accordion title={title}>
                {this.renderElements(d.costElements)}
            </Accordion>
        </div>
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

    private priceStr(value, exchangeRate, currency): string {
        let result: string;
        if (value) {
            result = this.asMoney((value / exchangeRate), currency);
            if (currency !== 'EUR') {
                result += ' (' + this.asMoney(value, 'EUR') + ')';
            }
        }
        else {
            result = 'N/A';
        }
        return result;
    }

    private asMoney(value: number, cur: string): string {
        return typeof value === 'number' ? Ext.util.Format.number(value, '0.00') + ' ' + cur : '';
    }
}