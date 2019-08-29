declare var APP_URL: any;
export const API_URL=APP_URL+'/api/';

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

const responseParse = (resp: { responseText: string }) => 
    resp.responseText == null || resp.responseText == "" 
        ? null 
        : JSON.parse(resp.responseText);

export const get = <T=any>(controller: string, action: string, params = null) => {
    return requestMvc(controller, action, Methods.Get, params).then<T>(responseParse);
}

export const getFromUri = <T=any>(url: string) => {
    return request(url, Methods.Get).then<T>(responseParse);
}

export const post = <TData, TResult=any>(controller: string, action: string, data: TData, params = null) => {
    return requestMvc(controller, action, Methods.Post, params, { jsonData: data }).then<TResult>(responseParse);
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

export const buildComponentUrl = (componentPath: string) => {
    let url = `${APP_URL}${componentPath}`;

    return url;
}   

export const downloadFile = <TData>(controller: string, action: string, data?: TData, params?: { [key: string]: any }) => {
    const FORM_ID = 'downloadFileForm';
    
    let input;
    let form = document.getElementById(FORM_ID) as any;
    
    if (form) {
        input = form.elements.data;
    } else {
        form = document.createElement('form');
        form.setAttribute('id', FORM_ID);

        document.body.appendChild(form);

        input = document.createElement('input');
        input.setAttribute('type', 'hidden');
        input.setAttribute('name', 'data');

        form.appendChild(input);
    }

    input.setAttribute('value', data == null ? undefined : JSON.stringify(data));

    form.setAttribute('method', 'post');
    form.setAttribute('action', buildMvcUrl(controller, action, params));
    
    form.submit();
}