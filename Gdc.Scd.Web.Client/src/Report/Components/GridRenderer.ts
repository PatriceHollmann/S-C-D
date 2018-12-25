﻿const N_A = 'N/A';

export function stringRenderer(val, row) {
    return isEmpty(val) ? N_A : val;
}

export function moneyRenderer(value: any, row: any): string {
    return isEmpty(value) ? N_A : Ext.util.Format.number(value, '0.00') + ' EUR';
}

export function percentRenderer(value: any, row: any): string {
    return isEmpty(value) ? N_A : Ext.util.Format.number(value, '0.000') + '%';
}

export function yearRenderer(val: number, row) {
    if (isEmpty(val) || val <= 0) {
        return N_A;
    }

    if (val === 1) {
        return val + ' Year';
    }
    else {
        return val + ' Years';
    }
}

function isEmpty(val: any) {
    return val === null || val === undefined || val === '';
}