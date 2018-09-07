export const API_URL = '/scd/api/'; 
//export declare var API_URL: any;

export enum Methods {
    Get = 'GET',
    Post = 'POST',
    Put = 'PUT',
    Delete = 'DELETE'
}

const request = (url: string, method: Methods, params = null, options = {}) => {
    if (params != null) {
        url = Ext.urlAppend(url, Ext.urlEncode(params, true));
    }

    return new Promise<any>((resolve, reject) => {
        Ext.Ajax.request({
            url,
            method,
            success: response => resolve(response),
            failure: response => reject(response),
            ...options
        });
    })
}

const requestMvc = (
    controller: string, 
    action: string, 
    method: Methods, 
    params = null, 
    options = {}
) => {
    const url = `${API_URL}${controller}/${action}`;

    return request(url, method, params, options);
}

export const get = <T=any>(controller: string, action: string, params = null) => {
    return requestMvc(controller, action, Methods.Get, params).then<T>(resp => JSON.parse(resp.responseText));
}

export const post = <T>(controller: string, action: string, data: T, params = null) => {
    return requestMvc(controller, action, Methods.Post, params, { jsonData: data });
}

export const put = <T>(controller: string, action: string, data: T, params = null) => {
    return requestMvc(controller, action, Methods.Put, params, { jsonData: data });
}

export const deleteItem = (controller: string, action: string, params = null) => {
    return requestMvc(controller, action, Methods.Delete, params);
}

export const buildMvcUrl = (controller: string, action: string, params?: { [key: string]: any }) => {
    let url = `${API_URL}${controller}/${action}`;

    if (params) {
        const urlParams = Ext.urlEncode(params, true);

        url = Ext.urlAppend(url, urlParams);
    }

    return url;
}   