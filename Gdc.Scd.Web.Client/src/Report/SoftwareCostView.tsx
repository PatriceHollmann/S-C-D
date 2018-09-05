﻿import { Column, Container, Grid } from "@extjs/ext-react";
import * as React from "react";
import { SwCalcFilter } from "./Components/SwCalcFilter";
import { SwCalcFilterModel } from "./Model/SwCalcFilterModel";
import { IReportService } from "./Services/IReportService";
import { ReportFactory } from "./Services/ReportFactory";

export class SoftwareCostView extends React.Component<any, any> {

    private grid: Grid;

    private filter: SwCalcFilter;

    private srv: IReportService;

    public constructor(props: any) {
        super(props);
        this.init();
    }

    public render() {

        return (
            <Container layout="fit">

                <SwCalcFilter ref="filter" docked="right" onSearch={this.onSearch} />

                <Grid ref="grid" store={this.state.denied} width="100%" plugins={['pagingtoolbar']}>
                    <Column flex="1" text="Country" dataIndex="country" />
                    <Column flex="1" text="SOG(Asset)" dataIndex="wg" />
                    <Column flex="1" text="Availability" dataIndex="availability" />
                    <Column flex="1" text="Year" dataIndex="duration" />
                </Grid>

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

    private onSearch(filter: SwCalcFilterModel) {
        this.reload();
    }

    private reload() {
        let filter = this.filter.getModel();
    }

}