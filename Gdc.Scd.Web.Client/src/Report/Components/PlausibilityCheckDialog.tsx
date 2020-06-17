﻿import { Dialog } from "@extjs/ext-react";
import * as React from "react";
import { Accordion } from "../../Common/Components/Accordion";
import { handleRequest } from "../../Common/Helpers/RequestHelper";
import { getFromUri } from "../../Common/Services/Ajax";

export interface PlausibilityCheckProps {

}

export class PlausibilityCheckDialog extends React.Component<PlausibilityCheckProps, any> {

    public state: any = {
        onlyMissing: false
    };

    public componentDidMount() {
        let p = getFromUri('http://localhost:11167/scd/Content/fake/service-tc.json').then(x => this.setState({ data: x }));
        handleRequest(p);
    }

    public render() {

        let d = this.state.data;

        if (!d) {
            return null;
        }

        return <Dialog
            displayed={true}
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

            <h1 className="plausi-box wide">
                <span className="plausi-box-left">{d.name}</span>
                <span className="plausi-box-right no-wrap">{this.priceStr(d.value, d.exchangeRate, d.currency)}</span>
            </h1>

            <div className="plausi-box wide">
                <div className="plausi-box-left">
                    <p>
                        <span className="sla">
                            {d.fsp}:&nbsp;
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

        </Dialog>;
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

        let sdata = this.state.data;
        let title = <div className="plausi-box">
            <div className="plausi-box-left">{d.name}</div>
            <div className="plausi-box-right plausi-box-right2">{this.priceStr(d.value, sdata.exchangeRate, sdata.currency)}</div>
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