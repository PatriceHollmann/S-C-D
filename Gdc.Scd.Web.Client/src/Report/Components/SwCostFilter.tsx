﻿import { Button, Container, Panel, PanelProps, SearchField } from "@extjs/ext-react";
import * as React from "react";
import { AvailabilityField } from "../../Dict/Components/AvailabilityField";
import { SwCostFilterModel } from "../Model/SwCostFilterModel";
import { NamedId } from "../../Common/States/CommonStates";
import { DictFactory } from "../../Dict/Services/DictFactory";
import { IDictService } from "../../Dict/Services/IDictService";
import { MultiSelect } from "../../Dict/Components/MultiSelect";
import { MultiSelectField } from "../../Dict/Components/MultiSelectField";
import { FspRadioField } from "./FspRadioField";

Ext.require('Ext.panel.Collapser');

const SELECT_MAX_HEIGHT: string = '200px';

export interface FilterPanelProps extends PanelProps {
    onSearch(filter: SwCostFilterModel): void;
    onDownload(filter: SwCostFilterModel): void;
}

export class SwCostFilter extends React.Component<FilterPanelProps, any> {

    private fsp: SearchField & any;

    private hasFsp: FspRadioField;

    private digit: MultiSelect;

    private avail: MultiSelect;

    private duration: MultiSelect;

    private dictSrv: IDictService;

    public constructor(props: any) {
        super(props);
        this.init();
    }

    public render() {
        let multiProps = {
            width: '200px',
            maxHeight: SELECT_MAX_HEIGHT,
            title: "",
            hideCheckbox: true
        };
        let panelProps = {
            width: '300px',
            collapsible: {
                direction: 'top',
                dynamic: true,
                collapsed: true
            },
            userCls: 'multiselect-filter',
            margin: "0 0 2px 0"
        };

        return (
            <Panel {...this.props} margin="0 0 5px 0" padding="4px 20px 7px 20px" layout={{ type: 'vbox', align: 'left' }}>

                <Container margin="10px 0"
                    defaults={{
                        maxWidth: '200px',
                        valueField: 'id',
                        displayField: 'name',
                        queryMode: 'local',
                        clearable: 'true'
                    }}
                >

                    <SearchField ref={x => this.fsp = x} label="FSP" placeholder="Search by FSP..." />
                    <FspRadioField ref={x => this.hasFsp = x} />
                    <MultiSelectField ref={x => this.digit = x} {...multiProps} store={this.dictSrv.getSwDigit} label='SW digit' />
                    <Panel title='Availability'
                        {...panelProps}>
                        <MultiSelect ref={x => this.avail = x} {...multiProps} store={this.dictSrv.getAvailabilityTypes} />
                    </Panel>
                    <Panel title='Duration'
                        {...panelProps}>
                        <MultiSelect ref={x => this.duration = x} {...multiProps} store={this.dictSrv.getDurationTypes} />
                    </Panel>

                </Container>

                <Button text="Search" ui="action" minWidth="85px" handler={this.onSearch} margin="5px 20px" />

                <Button text="Download" ui="action" minWidth="85px" iconCls="x-fa fa-download" handler={this.onDownload} margin="5px 20px" />

            </Panel>
        );
    }

    public getModel(): SwCostFilterModel {
        return {
            digit: this.digit.getSelectedKeysOrNull(),
            availability: this.avail.getSelectedKeysOrNull(),
            duration: this.duration.getSelectedKeysOrNull(),
            fsp: this.fsp.getValue(),
            hasFsp: this.hasFsp.getValue()
        }
    }

    private init() {
        this.dictSrv = DictFactory.getDictService();
        this.onSearch = this.onSearch.bind(this);
        this.onDownload = this.onDownload.bind(this);
    }

    private onSearch() {
        let handler = this.props.onSearch;
        if (handler) {
            handler(this.getModel());
        }
    }

    private onDownload() {
        let handler = this.props.onDownload;
        if (handler) {
            handler(this.getModel());
        }
    }
}