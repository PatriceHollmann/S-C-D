import { LocalDynamicGrid, LocalDynamicGridProps } from "./LocalDynamicGrid";

export interface ApiUrls {
    read: string
    update?: string
    create?: string
    destroy?: string
}

export interface AjaxDynamicGridProps<T=any> extends LocalDynamicGridProps<T> {
    apiUrls: ApiUrls
}

export class AjaxDynamicGrid<T=any> extends LocalDynamicGrid<T, AjaxDynamicGridProps<T>> {
    private apiUrls: ApiUrls

    // public componentWillReceiveProps(nextProps: AjaxDynamicGridProps<T>) {
    //     //super.componentWillReceiveProps(nextProps);
        
    //     const { apiUrls } = nextProps;

    //     if (this.apiUrls != apiUrls ||
    //         this.apiUrls.read != apiUrls.read ||
    //         this.apiUrls.update != apiUrls.update ||
    //         this.apiUrls.create != apiUrls.create ||
    //         this.apiUrls.destroy != apiUrls.destroy) {
    //         this.apiUrls = apiUrls;

    //         this.init(nextProps);
    //     }
    // }

    protected buildDataStore(props: AjaxDynamicGridProps<T>) {
        const { columns, apiUrls } = props;

        return Ext.create('Ext.data.Store', {
            fields: this.buildDataStoreFields(columns),
            autoLoad: true,
            pageSize: 0,
            proxy: {
                type: 'ajax',
                api: apiUrls,
                reader: { 
                    type: 'json',
                },
                writer: {
                    type: 'json',
                    writeAllFields: true,
                    allowSingle: false
                }
            }
        });
    }
}