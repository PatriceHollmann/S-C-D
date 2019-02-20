﻿import { Button, CheckBoxField, Container, Panel, PanelProps } from "@extjs/ext-react";
import * as React from "react";
import { CountryField } from "../../Dict/Components/CountryField";
import { DictField } from "../../Dict/Components/DictField";
import { ReactionTimeField } from "../../Dict/Components/ReactionTimeField";
import { ReactionTypeField } from "../../Dict/Components/ReactionTypeField";
import { ServiceLocationField } from "../../Dict/Components/ServiceLocationField";
import { AvailabilityFeeFilterModel } from "./AvailabilityFeeFilterModel";
import { NamedId, SortableNamedId } from "../../Common/States/CommonStates";

export interface FilterPanelProps extends PanelProps {
    onSearch(filter: AvailabilityFeeFilterModel): void;
}

export class FilterPanel extends React.Component<FilterPanelProps, any> {

    private country: DictField<NamedId>;

    private reacttype: DictField<NamedId>;

    private reacttime: DictField<NamedId>;

    private srvloc: DictField<SortableNamedId>;

    private isApplicable: CheckBoxField;

    public constructor(props: any) {
        super(props);
        this.init();
    }

    public render() {
        return (
            <Panel title="Filter By" {...this.props} margin="0 0 5px 0" padding="4px 20px 7px 20px">

                <Container margin="10px 0"
                    defaults={{
                        maxWidth: '200px',
                        valueField: 'id',
                        displayField: 'name',
                        queryMode: 'local',
                        clearable: 'true'
                    }}
                >

                    <CountryField ref={x => this.country = x} label="Country:"/>
                    <ReactionTypeField ref={x => this.reacttype = x} label="Reaction type:" />
                    <ReactionTimeField ref={x => this.reacttime = x} label="Reaction time:" />
                    <ServiceLocationField ref={x => this.srvloc = x} label="Service location:" />

                </Container>

                <Container layout={{ type: 'vbox', align: 'left' }} defaults={{ padding: '3px 0' }}>
                    <CheckBoxField ref={x => this.isApplicable = x} boxLabel="Is Applicable" />
                </Container>

                <Button text="Search" ui="action" minWidth="85px" handler={this.onSearch} margin="20px auto" />

            </Panel>
        );
    }

    public getModel(): AvailabilityFeeFilterModel {
        return {
            country: this.country.getSelected(),
            reactionType: this.reacttype.getSelected(),
            reactionTime: this.reacttime.getSelected(),
            serviceLocation: this.srvloc.getSelected(),

            isApplicable: this.getChecked(this.isApplicable)
        };
    }

    private init() {
        this.onSearch = this.onSearch.bind(this);
    }

    private onSearch() {
        let handler = this.props.onSearch;
        if (handler) {
            handler(this.getModel());
        }
    }

    private setPortfolio(val: boolean) {
        this.setState({ isPortfolio: val });
    }

    private getChecked(cb: CheckBoxField): boolean {
        return (cb as any).getChecked();
    }
}