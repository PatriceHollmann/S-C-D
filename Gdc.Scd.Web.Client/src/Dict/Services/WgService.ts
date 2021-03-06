﻿import { CacheDomainService } from "../../Common/Services/CacheDomainService";
import { NamedId } from "../../Common/States/CommonStates";

export class WgService extends CacheDomainService<NamedId> {
    constructor() {
        super('wg');
    }

    public allWithMultivendor(): Promise<NamedId[]> {
        return this.getFromUrlAll<NamedId>('multivendor');
    }

    public standard(): Promise<NamedId[]> {
        return this.getFromUrlAll<NamedId>('standard');
    }

    public hardware(): Promise<NamedId[]> {
        return this.getFromUrlAll<NamedId>('hardware');
    }
}
