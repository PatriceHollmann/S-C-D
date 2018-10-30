﻿import { Button, Column, Container, Grid, NumberColumn, Toolbar } from "@extjs/ext-react";
import * as React from "react";
import { buildMvcUrl } from "../Common/Services/Ajax";
import { CalcCostProps } from "./Components/CalcCostProps";
import { HwCostFilter } from "./Components/HwCostFilter";
import { HwCostFilterModel } from "./Model/HwCostFilterModel";

export class HwCostView extends React.Component<CalcCostProps, any> {

    private grid: Grid;

    private filter: HwCostFilter;

    private store: Ext.data.IStore = Ext.create('Ext.data.Store', {
        pageSize: 25,
        autoLoad: true,

        proxy: {
            type: 'ajax',
            api: {
                read: buildMvcUrl('calc', 'gethwcost'),
                update: buildMvcUrl('calc', 'savehwcost')
            },
            writer: {
                type: 'json',
                writeAllFields: true,
                allowSingle: false,
                idProperty: "id"
            },
            reader: {
                type: 'json',
                rootProperty: 'items',
                totalProperty: 'total'
            }
        },
        listeners: {
            update: (store, record, operation, modifiedFieldNames, details, eOpts) => {
                const changed = this.store.getUpdatedRecords().length;
                this.toggleToolbar(changed == 0);
            }
        }
    });

    public state = {
        disableSaveButton: true,
        disableCancelButton: true
    };

    public constructor(props: CalcCostProps) {
        super(props);
        this.init();
    }

    public render() {

        const canEdit = this.canEdit();

        let fieldServiceCost: string = 'fieldServiceCost';
        let serviceSupport: string = 'serviceSupport';
        let logistic: string = 'logistic';
        let availabilityFee: string = 'availabilityFee';
        let hddRetention: string = 'hddRetention';
        let reinsurance: string = 'reinsurance';
        let taxAndDutiesW: string = 'taxAndDutiesW';
        let taxAndDutiesOow: string = 'taxAndDutiesOow';
        let materialW: string = 'materialW';
        let materialOow: string = 'materialOow';
        let proActive: string = 'proActive';
        let serviceTC: string = 'serviceTC';
        let serviceTCManual: string = 'serviceTCManual';
        let serviceTP: string = 'serviceTP';
        let serviceTPManual: string = 'serviceTPManual';
        let listPrice: string = 'listPrice';
        let dealerDiscount: string = 'dealerDiscount';
        let dealerPrice: string = 'dealerPrice';
        let otherDirect: string = 'otherDirect';
        let localServiceStandardWarranty: string = 'localServiceStandardWarranty';
        let credits: string = 'credits';

        if (this.props.approved) {
            fieldServiceCost = 'fieldServiceCost_Approved';
            serviceSupport = 'serviceSupport_Approved';
            logistic = 'logistic_Approved';
            availabilityFee = 'availabilityFee_Approved';
            hddRetention = 'hddRetention_Approved';
            reinsurance = 'reinsurance_Approved';
            taxAndDutiesW = 'taxAndDutiesW_Approved';
            taxAndDutiesOow = 'taxAndDutiesOow_Approved';
            materialW = 'materialW_Approved';
            materialOow = 'materialOow_Approved';
            proActive = 'proActive_Approved';
            serviceTC = 'serviceTC_Approved';
            serviceTCManual = 'serviceTCManual_Approved';
            serviceTP = 'serviceTP_Approved';
            serviceTPManual = 'serviceTPManual_Approved';
            listPrice = 'listPrice_Approved';
            dealerDiscount = 'dealerDiscount_Approved';
            dealerPrice = 'dealerPrice_Approved';
            otherDirect = 'otherDirect_Approved';
            localServiceStandardWarranty = 'localServiceStandardWarranty_Approved';
            credits = 'credits_Approved';
        }

        return (
            <Container layout="fit">

                <HwCostFilter ref="filter" docked="right" onSearch={this.onSearch} />

                <Grid
                    ref="grid"
                    store={this.store}
                    width="100%"
                    platformConfig={this.pluginConf()}>

                    { /*dependencies*/}

                    <Column
                        isHeaderGroup={true}
                        text="Dependencies"
                        dataIndex=""
                        cls="calc-cost-result-green"
                        defaults={{ align: 'center', minWidth: 100, flex: 1, cls: "x-text-el-wrap" }}>

                        <Column text="Country" dataIndex="country" />
                        <Column text="WG(Asset)" dataIndex="wg" />
                        <Column text="Availability" dataIndex="availability" />
                        <Column text="Duration" dataIndex="duration" />
                        <Column text="Reaction type" dataIndex="reactionType" />
                        <Column text="Reaction time" dataIndex="reactionTime" />
                        <Column text="Service location" dataIndex="serviceLocation" />

                    </Column>

                    { /*cost block results*/}

                    <Column
                        isHeaderGroup={true}
                        text="Cost block results"
                        dataIndex=""
                        cls="calc-cost-result-blue"
                        defaults={{ align: 'center', minWidth: 100, flex: 1, cls: "x-text-el-wrap" }}>

                        <NumberColumn text="Field service cost" dataIndex={fieldServiceCost} />
                        <NumberColumn text="Service support cost" dataIndex={serviceSupport} />
                        <NumberColumn text="Logistic cost" dataIndex={logistic} />
                        <NumberColumn text="Availability fee" dataIndex={availabilityFee} />
                        <NumberColumn text="HDD retention" dataIndex={hddRetention} />
                        <NumberColumn text="Reinsurance" dataIndex={reinsurance} />
                        <NumberColumn text="Tax &amp; Duties iW period" dataIndex={taxAndDutiesW} />
                        <NumberColumn text="Tax &amp; Duties OOW period" dataIndex={taxAndDutiesOow} />
                        <NumberColumn text="Material cost iW period" dataIndex={materialW} />
                        <NumberColumn text="Material cost OOW period" dataIndex={materialOow} />
                        <NumberColumn text="Pro active" dataIndex={proActive} />

                    </Column>

                    { /*Resulting costs*/}

                    <Column
                        isHeaderGroup={true}
                        text="Resulting costs"
                        dataIndex=""
                        cls="calc-cost-result-yellow"
                        defaults={{ align: 'center', minWidth: 100, flex: 1, cls: "x-text-el-wrap" }}>

                        <NumberColumn text="Service TC(calc)" dataIndex={serviceTC} />
                        <NumberColumn text="Service TC(manual)" dataIndex={serviceTCManual} editable={canEdit} />

                        <NumberColumn text="Service TP(calc)" dataIndex={serviceTP} />
                        <NumberColumn text="Service TP(manual)" dataIndex={serviceTPManual} editable={canEdit} />

                        <NumberColumn text="List price" dataIndex={listPrice} editable={canEdit} />
                        <NumberColumn text="Dealer discount" dataIndex={dealerDiscount} editable={canEdit} />
                        <NumberColumn text="Dealer price" dataIndex={dealerPrice} />

                        <NumberColumn text="Other direct cost" dataIndex={otherDirect} />
                        <NumberColumn text="Local service standard warranty" dataIndex={localServiceStandardWarranty} />
                        <NumberColumn text="Credits" dataIndex={credits} />

                    </Column>

                </Grid>

                {this.toolbar()}

            </Container>
        );
    }

    public componentDidMount() {
        this.grid = this.refs.grid as Grid;
        this.filter = this.refs.filter as HwCostFilter;
    }

    private init() {
        this.onSearch = this.onSearch.bind(this);
        this.onBeforeLoad = this.onBeforeLoad.bind(this);
        this.cancelChanges = this.cancelChanges.bind(this);
        this.saveRecords = this.saveRecords.bind(this);

        this.store.on('beforeload', this.onBeforeLoad);
    }

    private toggleToolbar(disable: boolean) {
        this.setState({ disableSaveButton: disable, disableCancelButton: disable });
    }

    private cancelChanges() {
        this.store.rejectChanges();
        this.toggleToolbar(true);
    }

    private saveRecords() {
        this.store.sync({
            scope: this,

            success: function (batch, options) {
                //TODO: show successfull message box
                this.setState({
                    disableSaveButton: true,
                    disableCancelButton: true
                });
                this.store.load();
            },

            failure: (batch, options) => {
                //TODO: show error
                this.store.rejectChanges();
            }
        });

    }

    private onSearch(filter: HwCostFilterModel) {
        this.reload();
    }

    private reload() {
        this.store.load();
    }

    private onBeforeLoad(s, operation) {
        let filter = this.filter.getModel();
        let params = Ext.apply({}, operation.getParams(), filter);
        operation.setParams(params);
    }

    private pluginConf(): any {

        let cfg: any = {
            desktop: {
                plugins: {
                    gridpagingtoolbar: true
                }
            },
            '!desktop': {
                plugins: {
                    gridpagingtoolbar: true
                }
            }
        };

        if (this.canEdit()) {
            cfg['desktop'].plugins['gridcellediting'] = true;
            cfg['!desktop'].plugins['grideditable'] = true;
        }

        return cfg;
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