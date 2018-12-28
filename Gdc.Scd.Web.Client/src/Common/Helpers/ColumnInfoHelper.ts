import { CostBlockMeta, CostMetaData, InputLevelMeta, FieldType, InputType } from "../States/CostMetaStates";
import { ColumnInfo, ColumnType } from "../States/ColumnInfo";
import { NamedId } from "../States/CommonStates";
import { getDependency, findMeta, getSortedInputLevels } from "./MetaHelper";
import { FieldInfo } from "../States/FieldInfo";
import { Model } from "../States/ExtStates";

export const getDependecyColumnFromCostBlock = (costBlock: CostBlockMeta, costElementId: string) => {
    const dependency = getDependency(costBlock, costElementId);

    return buildNameColumnInfo(dependency);
}

export const getDependecyColumnFromMeta = (meta: CostMetaData, costBlockId: string, costElementId: string) => {
    const costBlock = findMeta(meta.costBlocks, costBlockId);

    return getDependecyColumnFromCostBlock(costBlock, costElementId);
}

export const getInputLevelColumns = (costBlock: CostBlockMeta, costElementId: string) => {
    const costElement = findMeta(costBlock.costElements, costElementId);

    return getSortedInputLevels(costElement).map(buildNameColumnInfo);
}   

export const buildNameColumnInfo = (metaItem: NamedId) => (<ColumnInfo>{
    title: metaItem.name,
    dataIndex: `${metaItem.id}Name`,
    type: ColumnType.Text
})

export interface CostElementColumnOption<T=any> {
    title: string,
    dataIndex: string
    type: FieldType,
    inputType: InputType
    references?: NamedId<number>[]
    mappingFn?(data: T): any
    editMappingFn?(data: Model<T>, dataIndex: string)
    getCountFn?(data: Model<T>): number
}

export const buildCostElementColumn = <T=any>(option: CostElementColumnOption<T>) => {
    let columnType: ColumnType;
    let referenceItems: Map<number, NamedId<number>>;
    let formatFn: (value, record?: Model<T>) => any;

    const { title, type, dataIndex, inputType, references = [] } = option;
    const readonly = inputType == InputType.AutomaticallyReadonly || inputType == InputType.Automatically;

    switch (type) {
        case FieldType.Double:
            columnType = ColumnType.Numeric;
            break;

        case FieldType.Flag:
            columnType = ColumnType.Reference;
            formatFn = (value: number) => {
                let result: string;

                switch(value) {
                    case 0:
                        return 'false';
                    case 1:
                        return 'true';
                    default:
                        return value;
                }
            }

            referenceItems = new Map<number, NamedId<number>>();
            referenceItems.set(0, { id: 0, name: 'false' });
            referenceItems.set(1, { id: 1, name: 'true' });
            break;

        case FieldType.Reference:
            columnType = ColumnType.Reference;
            referenceItems = new Map<number, NamedId<number>>();

            references.forEach(item => referenceItems.set(item.id, item));
            break;

        case FieldType.Percent:
            columnType = ColumnType.Numeric;
            formatFn = value => Ext.util.Format.number(value, '0.##%');
            break;
    }

    const { mappingFn, editMappingFn, getCountFn } = option;

    return <ColumnInfo<T>>{
        title,
        dataIndex,
        isEditable: !readonly,
        type: columnType,
        referenceItems,
        mappingFn,
        editMappingFn,
        rendererFn: rendererFnBuilder(formatFn)
    };

    function rendererFnBuilder(formatFn = value => value) {
        return (value, record: Model<T>) => {
            const count = getCountFn(record);

            return count == 1 ? formatFn(value) : `(${count} values)`;
        }
    }
}