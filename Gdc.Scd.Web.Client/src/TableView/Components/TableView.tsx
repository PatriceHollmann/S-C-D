import * as React from "react";
import { Container, Toolbar, Button } from "@extjs/ext-react";
import { TableViewGridContainer } from "./TableViewGridContainer";
import { HistoryButtonView } from "../../History/Components/HistoryButtonView";
import { Model } from "../../Common/States/ExtStates";
import { TableViewRecord } from "../States/TableViewRecord";
import { RouteComponentProps } from "react-router";
import { QualtityGateSetEditWindowContainer } from "./QualtityGateSetEditWindowContainer";

export interface TableViewActions {
    onExportToExcelClick?()
    onImportFromExcelClick?()
}

export interface TableViewProps extends RouteComponentProps, TableViewActions {
    buildHistotyDataLoadUrl(selection: Model<TableViewRecord>[], selectedDataIndex: string): string
}

export interface TableViewState {
    selection: Model<TableViewRecord>[]
    selectedDataIndex: string
    isEnableHistoryButton: boolean
}

export class TableView extends React.Component<TableViewProps, TableViewState> {
    constructor(props) {
        super(props)

        this.state = {
            selection: [],
            selectedDataIndex: null,
            isEnableHistoryButton: false
        };
    }

    public render() {
        const { selection, selectedDataIndex, isEnableHistoryButton } = this.state;
        const { buildHistotyDataLoadUrl } = this.props;

        return (
            <Container layout="fit">
                <Toolbar docked="top">
                    <HistoryButtonView  
                        isEnabled={isEnableHistoryButton}
                        flex={1}
                        windowPosition={{
                            top: '300',
                            left: '25%'
                        }}
                        buidHistoryUrl={() => buildHistotyDataLoadUrl && buildHistotyDataLoadUrl(selection, selectedDataIndex)}
                    />
                    <Button text="Export to Excel" flex={1} handler={this.onExportToExcel}/>
                    <Button text="Import from excel" flex={1} handler={this.onImportFromExcel}/>
                    <QualtityGateSetEditWindowContainer position={{ top: '25%', left: '25%'}}/>
                </Toolbar>

                <TableViewGridContainer {...this.props} onSelectionChange={this.onSelectionChange} />
            </Container>
        );
    }

    protected onSelectionChange = (grid, records: Model<TableViewRecord>[], selecting: boolean, selectionInfo) => {
        const { startCell } = selectionInfo;

         if (startCell) {
            const column = selectionInfo.startCell.column;
            const dataIndex = column.getDataIndex();

            this.setState({
                selection: records,
                selectedDataIndex: dataIndex,
                isEnableHistoryButton: dataIndex in records[0].data.data
            });
         } 
         else {
            this.setState({
                selection: [],
                selectedDataIndex: null,
                isEnableHistoryButton: false
            });
         }
    }

    private onExportToExcel = () => {
        const { onExportToExcelClick } = this.props;

        onExportToExcelClick && onExportToExcelClick();
    } 

    private onImportFromExcel = () => {
        const { onImportFromExcelClick } = this.props;

        onImportFromExcelClick && onImportFromExcelClick();
    }
}