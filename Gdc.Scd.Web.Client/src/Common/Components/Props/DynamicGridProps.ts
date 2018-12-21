import { ColumnInfo } from "../../States/ColumnInfo";
import { Model } from "../../States/ExtStates";
import { SaveToolbar } from "../SaveToolbar";
import { DynamicGrid } from "../DynamicGrid";

export interface DynamicGridActions {
    init?()
    onSelectionChange?(grid, records: Model[], selecting: boolean, selectionInfo)
    onCancel?()
    onSave?()
}

export interface DynamicGridProps extends DynamicGridActions {
    columns: ColumnInfo[]
    id?: string
    minHeight?: number
    minWidth?: number
    height?: string
    width?: string
    flex?: number
    isScrollable?: boolean
}

export interface ToolbarDynamicGridProps extends DynamicGridProps {
    getSaveToolbar?(hasChanges: boolean, ref: (toolbar: SaveToolbar) => void, grid: DynamicGrid)
}