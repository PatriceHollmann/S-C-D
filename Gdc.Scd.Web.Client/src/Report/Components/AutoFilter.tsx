﻿import { Button, Container, NumberField, Panel, PanelProps, TextField } from "@extjs/ext-react";
import * as React from "react";
import { AutoFilterModel } from "../Model/AutoFilterModel";
import { AutoFilterType } from "../Model/AutoFilterType";
import { AvailabilityField } from "./AvailabilityField";
import { CountryField } from "./CountryField";
import { CountryGroupField } from "./CountryGroupField";
import { DurationField } from "./DurationField";
import { ReactionTimeField } from "./ReactionTimeField";
import { ReactionTypeField } from "./ReactionTypeField";
import { ServiceLocationField } from "./ServiceLocationField";
import { SogField } from "./SogField";
import { WgField } from "./WgField";
import { YearField } from "./YearField";

export interface AutoFilterPanelProps extends PanelProps {
    filter: AutoFilterModel[];
    onSearch(filter: any): void;
}

export class AutoFilter extends React.Component<AutoFilterPanelProps, any> {

    public constructor(props: any) {
        super(props);
        this.init();
    }

    public render() {
        var filter = this.props.filter || [];

        return (
            <Panel {...this.props} margin="0 0 5px 0" padding="4px 20px 7px 20px">

                <Container
                    ref="fields"
                    margin="10px 0"
                    defaults={{
                        maxWidth: '200px',
                        clearable: 'true'
                    }}>

                    {filter.map(this.CreateField)}

                </Container>

                <Button text="Search" ui="action" width="85px" handler={this.onSearch} margin="20px auto" />

            </Panel>
        );
    }

    private CreateField(model: AutoFilterModel, index: number): JSX.Element {
        switch (model.type) {

            case AutoFilterType.NUMBER:
                return (<NumberField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.WG:
                return (<WgField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.SOG:
                return (<SogField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.COUNTRY:
                return (<CountryField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.COUNTRYGROUP:
                return (<CountryGroupField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.AVAILABILITY:
                return (<AvailabilityField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.DURATION:
                return (<DurationField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.YEAR:
                return (<YearField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.REACTIONTIME:
                return (<ReactionTimeField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.REACTIONTYPE:
                return (<ReactionTypeField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.SERVICELOCATION:
                return (<ServiceLocationField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);

            case AutoFilterType.TEXT:
            default:
                return (<TextField key={index} ref={model.name} name={model.name} label={model.text} value={model.value} />);
        }
    }

    public getModel(): any {
        let result = {};
        let filter = this.props.filter;

        if (filter) {
            for (let i = 0, item; item = filter[i]; i++) {

                let f = this.refs[item.name] as any;

                if (f.getValue()) {
                    result[item.name] = f.getValue();
                }
            }
        }

        return result;
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
}