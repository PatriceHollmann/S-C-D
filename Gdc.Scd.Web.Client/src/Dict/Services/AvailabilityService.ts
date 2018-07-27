﻿import { DomainService } from "../../Common/Services/DomainService";
import { NamedId } from "../../Common/States/CommonStates";

export class AvailabilityService extends DomainService<NamedId> {
    constructor() {
        super('availability');
    }
}