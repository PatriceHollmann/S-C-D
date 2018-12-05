import * as React from "react";
import { HistoryValuesGridViewProps, HistoryValuesGridView } from "./HistoryValuesGridView";
import { Dialog } from "@extjs/ext-react";
import { Position } from "../../Common/States/ExtStates"

export interface HistoryWindowViewActions {
    onClose?()
}

export interface HistoryWindowViewProps extends HistoryValuesGridViewProps, HistoryWindowViewActions {
    isVisible: boolean,
    position?: Position
}

export class HistoryWindowView extends React.Component<HistoryWindowViewProps> {
    public render() {
        const { isVisible, onClose, position = {}, dataLoadUrl } = this.props;

        return (
            <Dialog 
                displayed={isVisible} 
                title="History" 
                closable 
                maximizable
                resizable={{
                    dynamic: true,
                    edges: 'all'
                }}
                minHeight="600"
                minWidth="700"
                onClose={onClose}
                layout="fit"
                {...position}
            >
                <HistoryValuesGridView dataLoadUrl={dataLoadUrl} />
            </Dialog>
        );
    }
}