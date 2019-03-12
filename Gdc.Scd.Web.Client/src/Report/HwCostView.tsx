﻿import { Button, Column, Container, Grid, NumberColumn, Panel, Toolbar, CheckColumn } from "@extjs/ext-react";
import * as React from "react";
import { ExtMsgHelper } from "../Common/Helpers/ExtMsgHelper";
import { handleRequest } from "../Common/Helpers/RequestHelper";
import { buildMvcUrl, post } from "../Common/Services/Ajax";
import { Country } from "../Dict/Model/Country";
import { UserCountryService } from "../Dict/Services/UserCountryService";
import { CalcCostProps } from "./Components/CalcCostProps";
import { emptyRenderer, IRenderer, localMoneyRendererFactory, localToEuroMoneyRendererFactory, percentRenderer, yearRenderer } from "./Components/GridRenderer";
import { HwCostFilter } from "./Components/HwCostFilter";
import { HwReleasePanel } from "./Components/HwReleasePanel";
import { CurrencyType } from "./Model/CurrencyType";
import { HwCostFilterModel } from "./Model/HwCostFilterModel";
import { ExportService } from "./Services/ExportService";

const localMoneyRenderer = localMoneyRendererFactory('Currency');
const euroMoneyRenderer = localToEuroMoneyRendererFactory('ExchangeRate');
const SELECTED_FIELD = 'selected';

export class HwCostView extends React.Component<CalcCostProps, any> {

    private grid: Grid & any;

    private filter: HwCostFilter;

    private store = Ext.create('Ext.data.Store', {

        fields: [
            'Id', SELECTED_FIELD, 'ListPrice', 'DealerDiscount', 'ChangeUserName', 'ChangeUserEmail',
            {
                name: 'DealerPriceCalc',
                calculate: function (d) {
                    let result: any;
                    if (d && d.ListPrice) {
                        result = d.ListPrice;
                        if (d.DealerDiscount) {
                            result = result - (result * d.DealerDiscount / 100);
                        }
                    }
                    return result;
                }
            },
            {
                name: 'ChangeUserCalc',
                calculate: function (d) {
                    let result: string = '';
                    if (d) {
                        if (d.ChangeUserName) {
                            result += d.ChangeUserName;
                        }
                        if (d.ChangeUserEmail) {
                            result += '[' + d.ChangeUserEmail + ']';
                        }
                    }
                    return result;
                }
            }
        ],

        pageSize: 25,
        autoLoad: false,

        proxy: {
            type: 'ajax',
            api: {
                read: buildMvcUrl('calc', 'gethwcost')
            },
            actionMethods: {
                read: 'POST'
            },
            reader: {
                type: 'json',
                rootProperty: 'items',
                idProperty: "Id",
                totalProperty: 'total'
            },
            paramsAsJson: true
        },
        listeners: {
            update: (store, record, operation, modifiedFieldNames, details) => {
                const changed = this.store.getUpdatedRecords().length;
                if (modifiedFieldNames && modifiedFieldNames.length > 0 && modifiedFieldNames[0] == SELECTED_FIELD) {
                    this.onCheckChange();
                }
                else {
                    this.toggleToolbar(changed == 0);
                }                              
            }
        }
    });

    public state = {
        disableSaveButton: true,
        disableCancelButton: true,
        selectedCountry: null,
        showInLocalCurrency: true,
        hideReleaseButton: true,
        userCanEdit: false
    };

    public constructor(props: CalcCostProps) {
        super(props);
        this.init();
    }

    public render() {
        let canEditTC: boolean = false;
        let canEditListPrice: boolean = false;
        let moneyRndr: IRenderer;

        if (this.state.showInLocalCurrency) {

            //allow manual edit in LOCAL CURRENCY mode only for well view!!!

            canEditTC = this.canEditTC();
            canEditListPrice = this.canEditListPrice();
            //
            moneyRndr = localMoneyRenderer;
        }
        else {
            moneyRndr = euroMoneyRenderer;
        }
     
        return (
            <Container layout="fit">

                <Panel {...this.props} docked="right" scrollable={true} >
                    <HwCostFilter
                        ref={x => this.filter = x}
                        onSearch={this.onSearch}
                        onChange={this.onFilterChange}
                        onDownload={this.onDownload}
                        checkAccess={!this.props.approved} />

                    <HwReleasePanel
                        onApprove={this.releaseCosts}
                        checkAccess={!this.props.approved}
                        hidden={this.state.hideReleaseButton}
                        disabled={!this.state.disableSaveButton}/>
                </Panel>

                <Grid
                    ref={x => this.grid = x}
                    store={this.store}
                    width="100%"
                    platformConfig={this.pluginConf()}
                >

                    { /*dependencies*/}

                    <Column
                        isHeaderGroup={true}
                        text="Dependencies"
                        dataIndex=""
                        cls="calc-cost-result-green"
                        defaults={{ align: 'center', minWidth: 50, flex: 1, cls: "x-text-el-wrap" }}>

                        <CheckColumn dataIndex={SELECTED_FIELD} sortable={false} flex="0.2" hidden={!this.approved()}/>
                        <Column text="Country" dataIndex="Country" />
                        <Column text="WG(Asset)" dataIndex="Wg" />
                        <Column text="Availability" dataIndex="Availability" />
                        <Column text="Duration" dataIndex="Duration" />
                        <Column text="Reaction type" dataIndex="ReactionType" />
                        <Column text="Reaction time" dataIndex="ReactionTime" />
                        <Column text="Service location" dataIndex="ServiceLocation" />
                        <Column text="ProActive SLA" dataIndex="ProActiveSla" />
                        <Column text="Standard warranty duration" dataIndex="StdWarranty" renderer={yearRenderer} flex="0.5" />
                        <Column text="Standard Warranty Service Location" dataIndex="StdWarrantyLocation" />

                    </Column>

                    { /*Resulting costs*/}

                    <Column
                        isHeaderGroup={true}
                        text="Resulting costs"
                        dataIndex=""
                        cls="calc-cost-result-yellow"
                        defaults={{ align: 'center', minWidth: 100, flex: 1, cls: "x-text-el-wrap", renderer: moneyRndr }}>

                        <NumberColumn text="Service TC(calc)" dataIndex="ServiceTC" />
                        <NumberColumn text="Service TC(manual)" dataIndex="ServiceTCManual" editable={canEditTC && this.state.userCanEdit} />
                        <NumberColumn text="Service TP(calc)" dataIndex="ServiceTP" />
                        <NumberColumn text="Service TP(manual)" dataIndex="ServiceTPManual" editable={canEditTC && this.state.userCanEdit} />
                        <NumberColumn text="Service TP(released)" dataIndex="ServiceTP_Released" />

                        <NumberColumn text="List price" dataIndex="ListPrice" editable={canEditListPrice && this.state.userCanEdit} />
                        <NumberColumn text="Dealer discount in %" dataIndex="DealerDiscount" editable={canEditListPrice && this.state.userCanEdit} renderer={percentRenderer} />
                        <NumberColumn text="Dealer price" dataIndex="DealerPriceCalc" />

                        <Column flex="2" minWidth="250" text="Change user" dataIndex="ChangeUserCalc" renderer={emptyRenderer} />

                        <NumberColumn text="Other direct cost" dataIndex="OtherDirect" />
                        <NumberColumn text="Local service standard warranty" dataIndex="LocalServiceStandardWarranty" />
                        <NumberColumn text="Credits" dataIndex="Credits" />

                    </Column>

                    {/*cost block results*/}

                    <Column
                        isHeaderGroup={true}
                        text="Cost block results"
                        dataIndex=""
                        cls="calc-cost-result-blue"
                        defaults={{ align: 'center', minWidth: 100, flex: 1, cls: "x-text-el-wrap", renderer: moneyRndr }}>

                        <NumberColumn text="Field service cost" dataIndex="FieldServiceCost" />
                        <NumberColumn text="Service support cost" dataIndex="ServiceSupportCost" />
                        <NumberColumn text="Logistic cost" dataIndex="Logistic" />
                        <NumberColumn text="Availability fee" dataIndex="AvailabilityFee" />
                        <NumberColumn text="Reinsurance" dataIndex="Reinsurance" />
                        <NumberColumn text="Tax &amp; Duties iW period" dataIndex="TaxAndDutiesW" />
                        <NumberColumn text="Tax &amp; Duties OOW period" dataIndex="TaxAndDutiesOow" />
                        <NumberColumn text="Material cost iW period" dataIndex="MaterialW" />
                        <NumberColumn text="Material cost OOW period" dataIndex="MaterialOow" />
                        <NumberColumn text="ProActive" dataIndex="ProActive" />

                    </Column>

                </Grid>

                {this.toolbar()}

            </Container>
        );
    }

    private init() {
        this.onSearch = this.onSearch.bind(this);
        this.onFilterChange = this.onFilterChange.bind(this);
        this.onDownload = this.onDownload.bind(this);
        this.cancelChanges = this.cancelChanges.bind(this);
        this.saveRecords = this.saveRecords.bind(this);
        this.releaseCosts = this.releaseCosts.bind(this);

        this.store.on('beforeload', this.onBeforeLoad, this);
    }

    private toggleToolbar(disable: boolean) {
        this.setState({ disableSaveButton: disable, disableCancelButton: disable });
    }

    private cancelChanges() {
        this.store.rejectChanges();
        this.toggleToolbar(true);
    }

    private saveRecords() {
        let recs = this.store.getModifiedRecords().map(x => x.getData());
        let cnt = this.state.selectedCountry;

        if (recs && cnt) {
            let me = this;
            let p = post('calc', 'savehwcost', { items: recs, countryId: cnt.id }).then(() => {
                me.reset();
                me.reload();
            });
            handleRequest(p);
        }
    }

    private releaseCosts() {
        let recs = this.getSelectedRows();
        let cnt = this.state.selectedCountry;

        if (cnt) {
            if (recs && recs.length > 0) {
                recs = this.store.getData().items.filter(x => recs.includes(x.data.Id)).map(x => x.data);
            }
            else {
                recs = this.store.getData().items.map(x => x.data);
            }
        }

        ExtMsgHelper.confirm('Release', `Do you want to approve for release ${recs.length} record(s)?`, () => {
            let me = this;
            let p = post('calc', 'releasehwcost', { items: recs, countryId: cnt.id }).then(() => {
                me.reset();
                me.reload();
            });
            handleRequest(p);
        });


    }

    private onSearch(filter: HwCostFilterModel) {
        this.reload();
    }

    private onDownload(filter: HwCostFilterModel & any) {
        filter = filter || {};
        filter.local = filter.currency;
        ExportService.Download('HW-CALC-RESULT', this.props.approved, filter);
    }

    private onFilterChange(filter: HwCostFilterModel) {
        this.setState({ showInLocalCurrency: filter.currency === CurrencyType.Local });
        this.grid.refresh();
    }

    private reload() {
        this.store.load();
    }

    private onBeforeLoad(s, operation) {
        this.reset();

        let filter = this.filter.getModel() as any;
        filter.approved = this.props.approved;
        operation.setParams(filter);

        const srv = new UserCountryService();
        let cntId = 0;
        if (this.state && this.state.selectedCountry) {
            cntId = this.state.selectedCountry.id;
            srv.isCountryUser(cntId).then(x => {
                this.setState({
                    hideReleaseButton: !this.props.approved || !x || !this.state.disableSaveButton,
                    userCanEdit: x
                });

            })
        };
    }

    private pluginConf(): any {
        let cfg: any = {
            'desktop': {
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

        if (this.approved()) {
            cfg['!desktop'].plugins.grideditable = true;
            const desktop = cfg['desktop'];
            desktop.plugins.gridcellediting = true;
            desktop.plugins.selectionreplicator = true;
            desktop.selectable = {
                cells: true,
                rows: true,
                columns: false,
                drag: true,
                extensible: 'y'
            };
        }

        return cfg;
    }

    private approved() {
        return this.props.approved;
    }

    private canEdit(): boolean {
        return this.state.userCanEdit && (this.canEditListPrice() || this.canEditTC());
    }

    private canEditListPrice(): boolean {
        let result: boolean = this.approved();
        if (result) {
            const cnt: Country = this.state.selectedCountry;
            result = cnt && cnt.canStoreListAndDealerPrices;
        }
        return result;
    }

    private canEditTC(): boolean {
        let result: boolean = this.approved();
        if (result) {
            const cnt: Country = this.state.selectedCountry;
            result = cnt && cnt.canOverrideTransferCostAndPrice;
        }
        return result;
    }

    private toolbar() {
        if (this.canEdit()) {
            return <Toolbar docked="top">
                <Button
                    text="Cancel"
                    iconCls="x-fa fa-trash"
                    handler={this.cancelChanges}
                    disabled={this.state.disableCancelButton}
                />
                <Button
                    text="Save"
                    iconCls="x-fa fa-save"
                    handler={this.saveRecords}
                    disabled={this.state.disableSaveButton}
                />
            </Toolbar>;
        }
    }

    private reset() {
        this.setState({
            disableCancelButton: true,
            disableSaveButton: true,
            selectedCountry: this.filter.getCountry()
        });
    }

    private getSelectedRows(): string[] {
        return this.store.getData().items.filter(record => record.data[SELECTED_FIELD] == true).map(record => record.data.Id)
    }

    private onCheckChange = () => {
        this.grid.select(this.store.getData().items.filter(record => record.data[SELECTED_FIELD] == true));
    }
}
