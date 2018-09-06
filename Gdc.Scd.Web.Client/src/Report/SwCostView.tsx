﻿import { Button, Column, Container, Grid, NumberColumn, Toolbar } from "@extjs/ext-react";
import * as React from "react";
import { CalcCostProps } from "./Components/CalcCostProps";
import { SwCalcFilter } from "./Components/SwCalcFilter";
import { SwCalcFilterModel } from "./Model/SwCalcFilterModel";
import { IReportService } from "./Services/IReportService";
import { ReportFactory } from "./Services/ReportFactory";

export class SwCostView extends React.Component<CalcCostProps, any> {

    private grid: Grid;

    private filter: SwCalcFilter;

    private srv: IReportService;

    public constructor(props: CalcCostProps) {
        super(props);
        this.init();
    }

    public render() {

        return (
            <Container layout="fit">

                <SwCalcFilter ref="filter" docked="right" onSearch={this.onSearch} />

                <Grid ref="grid" store={this.state.denied} width="100%" plugins={['pagingtoolbar']}>

                    { /*dependencies*/}

                    <Column
                        flex="1"
                        isHeaderGroup={true}
                        text="Dependencies"
                        dataIndex="none"
                        cls="calc-cost-result-green"
                        defaults={{ align: 'center', minWidth: 100, flex: 1, cls: "x-text-el-wrap" }}>

                        <Column text="Country" dataIndex="country" />
                        <Column text="SOG(Asset)" dataIndex="wg" />
                        <Column text="Availability" dataIndex="availability" />
                        <Column text="Year" dataIndex="duration" />

                    </Column>

                    { /*Resulting costs*/}

                    <Column
                        flex="2"
                        isHeaderGroup={true}
                        text="Resulting costs"
                        dataIndex="none"
                        cls="calc-cost-result-blue"
                        defaults={{ align: 'center', minWidth: 100, flex: 1, cls: "x-text-el-wrap" }}>

                        <NumberColumn text="Service support cost" dataIndex="serviceSupport" />
                        <NumberColumn text="Reinsurance" dataIndex="reinsurance" />
                        <NumberColumn text="Transer price" dataIndex="transferPrice" />

                        <NumberColumn flex="1" text="Maintenance list price(calc)" dataIndex="maintenanceListPrice" />
                        <NumberColumn flex="1" text="Maintenance list price(manual)" dataIndex="maintenanceListPriceManual" />

                        <NumberColumn flex="1" text="Dealer reference price(calc)" dataIndex="dealerPrice" />
                        <NumberColumn flex="1" text="Dealer reference price(manual)" dataIndex="dealerPriceManual" />

                    </Column>

                </Grid>

                {this.toolbar()}

            </Container>
        );
    }

    public componentDidMount() {
        this.grid = this.refs.grid as Grid;
        this.filter = this.refs.filter as SwCalcFilter;
        //
        this.reload();
    }

    private init() {
        this.srv = ReportFactory.getReportService();
        this.onSearch = this.onSearch.bind(this);
        //
        this.state = {
            allowed: [],
            denied: []
        };
    }

    private cancelChanges() {
        console.log('cancelChanges()');
    }

    private saveRecords() {
        console.log('saveRecords()');
    }

    private onSearch(filter: SwCalcFilterModel) {
        this.reload();
    }

    private reload() {
        let filter = this.filter.getModel();
    }

    private canEdit() {
        return !this.props.approved;
    }

    private toolbar() {
        if (this.canEdit()) {
            return (
                <Toolbar docked="bottom">
                    <Button
                        text="Cancel"
                        flex={1}
                        iconCls="x-fa fa-trash"
                        handler={this.cancelChanges}
                        disabled={this.state.disableCancelButton}
                    />
                    <Button
                        text="Save"
                        flex={1}
                        iconCls="x-fa fa-save"
                        handler={this.saveRecords}
                        disabled={this.state.disableSaveButton}
                    />
                </Toolbar>
            );
        }
    }
}