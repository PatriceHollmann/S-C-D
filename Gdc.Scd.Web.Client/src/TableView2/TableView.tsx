﻿import { Container } from "@extjs/ext-react";
import * as React from "react";
import { handleRequest } from "../Common/Helpers/RequestHelper";
import { CostMetaData } from "../Common/States/CostMetaStates";
import { StoreOperation } from "../Common/States/ExtStates";
import { TableViewRecord } from "../TableView/States/TableViewRecord";
import { QualityGateResultSet, TableViewInfo } from "../TableView/States/TableViewState";
import { TableViewErrorDialog } from "./Components/TableViewErrorDialog";
import { TableViewGrid } from "./Components/TableViewGrid";
import { TableViewGridHelper } from "./Helpers/TableViewGridHelper";
import { ITableViewService } from "./Services/ITableViewService";
import { TableViewFactory } from "./Services/TableViewFactory";

export interface TableViewState {
    meta: CostMetaData;
    schema: TableViewInfo
}

export class TableView extends React.Component<any, TableViewState> {

    private grid: TableViewGrid;

    private dlg: TableViewErrorDialog;

    private srv: ITableViewService;

    private editRecords: Array<TableViewRecord>;

    public state: TableViewState;

    public constructor(props: any) {
        super(props);
        this.init();
    }

    public render() {

        let el = null;

        if (this.state) {

            let meta = this.state.meta;
            let schema = this.state.schema;
            let url = this.srv.getUrl();

            if (meta && schema) {
                el = <Container layout="fit">
                    <TableViewGrid
                        {...TableViewGridHelper.buildGridProps(url, schema, meta)}
                        ref={x => this.grid = x}
                        onApprove={this.onSaveAndApprove}
                        onCancel={this.onCancel}
                        onSave={this.onSave}
                        onUpdateRecord={this.onUpdateRecord}
                        onUpdateRecordSet={this.onUpdateRecordSet}
                    />
                    <TableViewErrorDialog ref={x => this.dlg = x} title="Quality gate errors" onForceSave={this.onForceSave} onCancel={this.onCancel} />
                </Container>;
            }
        }

        return el;
    }

    public componentDidMount() {
        Promise.all([
            this.srv.getMeta(),
            this.srv.getSchema()
        ]).then(x => this.setState({
            meta: x[0],
            schema: x[1]
        }));
    }

    private init() {
        this.srv = TableViewFactory.getTableViewService();
        //
        this.reset();
        this.onCancel = this.onCancel.bind(this);
        this.onForceSave = this.onForceSave.bind(this);
        this.onSave = this.onSave.bind(this);
        this.onSaveAndApprove = this.onSaveAndApprove.bind(this);
        this.onUpdateRecord = this.onUpdateRecord.bind(this);
        this.onUpdateRecordSet = this.onUpdateRecordSet.bind(this);
    }


    private onCancel() {
        this.reset();
    }

    private onForceSave(msg: string) {
        console.log('onForceSave()', msg);
    }

    private onSave() {
        this.save(false);
    }

    private onSaveAndApprove() {
        this.save(true);
    }

    private onUpdateRecord(store, record, operation, modifiedFieldNames) {
        if (operation === StoreOperation.Edit) {
            const [dataIndex] = modifiedFieldNames;
            const countDataIndex = TableViewGridHelper.buildCountDataIndex(dataIndex);

            if (record.get(countDataIndex) == 0) {
                record.data[countDataIndex] = 1;
            }
        }
    }

    private onUpdateRecordSet(records, operation, dataIndex) {
        if (operation === StoreOperation.Edit) {
            this.editRecords = TableViewGridHelper.refreshEditRecords(this.editRecords, records.map(rec => rec.data), dataIndex);
        }
    }

    private reset() {
        this.editRecords = [];
    }

    private save(isApproving: boolean) {
        let p = this.srv.updateRecords(this.editRecords, { isApproving: isApproving })
            .then(x => {
                if (x.hasErrors) {
                    this.showQualityError(x);
                }
                else {
                    //dispatch(resetQualityCheckResult());
                    //dispatch(resetChanges());
                }
            })

        handleRequest(p);
    }

    private showQualityError(err: QualityGateResultSet) {
        this.dlg.setModel(err);
        this.dlg.show();
    }

}