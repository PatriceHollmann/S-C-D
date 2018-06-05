import { CostElementInputState, CostElementInputDto } from "../States/CostElementState";
import { CostBlockInputState, EditItem } from "../States/CostBlock";
import { NamedId } from "../../Common/States/NamedId";

export interface Context {
    applicationId: string
    scopeId: string
    countryId: string
    costBlockId: string
    costElementId: string
    inputLevelId: string
    costElementFilterIds: string[],
    inputLevelFilterIds: string[]
}

export const getCostElementInput = () => Promise.resolve(<CostElementInputDto>{
    applications: [
        { id: 'hardware', name: 'Hardware' },
        { id: 'software', name: 'Software' }
    ],
    scopes: [
        { id: 'central', name: 'Central cost elements' },
        { id: 'local', name: 'Local cost elements' }
    ],
    countries: [
        { id: 'Algeria', name: 'Algeria' },
        { id: 'Austria', name: 'Austria' },
        { id: 'Balkans', name: 'Balkans' },
        { id: 'Belgium', name: 'Belgium' },
        { id: 'CIS & Russia', name: 'CIS & Russia' },
        { id: 'Czech Republic', name: 'Czech Republic' },
        { id: 'Denmark', name: 'Denmark' },
        { id: 'Egypt', name: 'Egypt' },
        { id: 'Finland', name: 'Finland' },
        { id: 'France', name: 'France' },
        { id: 'Germany', name: 'Germany' },
        { id: 'Greece', name: 'Greece' },
        { id: 'Hungary', name: 'Hungary' },
        { id: 'India', name: 'India' },
        { id: 'Italy', name: 'Italy' },
        { id: 'Luxembourg', name: 'Luxembourg' },
        { id: 'Middle East', name: 'Middle East' },
        { id: 'Morocco', name: 'Morocco' },
        { id: 'Netherlands', name: 'Netherlands' },
        { id: 'Norway', name: 'Norway' },
        { id: 'Poland', name: 'Poland' },
        { id: 'Portugal', name: 'Portugal' },
        { id: 'South Africa', name: 'South Africa' },
        { id: 'Spain', name: 'Spain' },
        { id: 'Sweden', name: 'Sweden' },
        { id: 'Switzerland', name: 'Switzerland' },
        { id: 'Tunisia', name: 'Tunisia' },
        { id: 'Turkey', name: 'Turkey' },
        { id: 'UK & Ireland', name: 'UK & Ireland' },
    ],
    costBlockMetas: [
        { 
            id: 'fieldservice', 
            name: 'Field Service', 
            applicationIds: ['hardware'],
            costElements: [
                { 
                    id: 'traveltime', 
                    name: 'Travel Time',
                    scopeId: 'local',
                    description: 'Travel Time description',
                    dependency: null
                },
                { 
                    id: 'onsitehourlyrate', 
                    name: 'Onsite Hourly Rate',
                    scopeId: 'local',
                    description: 'Onsite Hourly Rate description',
                    dependency: {
                        id: 'rolecode',
                        name: 'RoleCode (Code)'
                    }
                },
                { 
                    id: 'labourflatfee', 
                    name: 'Labour Flat Fee',
                    scopeId: 'local',
                    description: 'Labour Flat Fee description',
                    dependency: {
                        id: 'servicelocation',
                        name: 'ServiceLocation (Code)'
                    }
                },
                { 
                    id: 'travelcost', 
                    name: 'Travel Cost',
                    scopeId: 'local',
                    description: 'Travel Cost description',
                    dependency: null
                },
                { 
                    id: 'repairtime', 
                    name: 'Repair Time',
                    scopeId: 'central',
                    description: 'Repair Time description',
                    dependency: null
                },
            ]
        },
        { 
            id: 'servicesupportcost', 
            name: 'Service Support Cost', 
            applicationIds: ['hardware', 'software'],
            costElements: [
                { 
                    id: '1stlevelsupportcostscountry', 
                    name: '1st Level Support Costs Country',
                    scopeId: 'local',
                    description: '1st Level Support Costs Country description',
                    dependency: null
                },
                { 
                    id: '2ndlevelsupportcostsplanonemia', 
                    name: '2nd Level Support Costs PLAnon EMEIA',
                    scopeId: 'local',
                    description: '2nd Level Support Costs PLAnon EMEIA description',
                    dependency: null
                },
                { 
                    id: '2ndLevelSupportCostsPLA', 
                    name: '2nd Level Support Costs PLA',
                    scopeId: 'central',
                    description: '2nd Level Support Costs PLA description',
                    dependency: null
                }
            ]
        },
        { 
            id: 'logisticscost', 
            name: 'Logistics Cost', 
            applicationIds: ['hardware'],
            costElements: [
                { 
                    id: 'standardhandlingincountry', 
                    name: 'Standard Handling In Country',
                    scopeId: 'local',
                    description: 'Standard Handling In Country description',
                    dependency: {
                        id: 'reactiontime',
                        name: 'ReactionTime (Code)'
                    }
                },
                { 
                    id: 'highavailabilityhandlingincountry', 
                    name: 'High Availability Handling In Country',
                    scopeId: 'local',
                    description: 'High Availability Handling In Country description',
                    dependency: {
                        id: 'reactiontime',
                        name: 'ReactionTime (Code)'
                    }
                },
                { 
                    id: 'standarddelivery', 
                    name: 'Standard Delivery',
                    scopeId: 'local',
                    description: 'Standard Delivery description',
                    dependency: {
                        id: 'reactiontime',
                        name: 'ReactionTime (Code)'
                    }
                },
                { 
                    id: 'expressdelivery', 
                    name: 'Express Delivery',
                    scopeId: 'local',
                    description: 'Express Delivery description',
                    dependency: {
                        id: 'reactiontime',
                        name: 'ReactionTime (Code)'
                    }
                },
                { 
                    id: 'taxandduties', 
                    name: 'Tax And Duties',
                    scopeId: 'central',
                    description: 'Tax And Duties description',
                    dependency: null
                },
            ]
        },
    ],
    inputLevels: [
        { id: 'country',  name: 'Country' },
        { id: 'pla',  name: 'PLA' },
        { id: 'sog',  name: 'SOG' },
        { id: 'wgr',  name: 'WGR' },
    ]
})

export const getCostElementFilterItems = (costBlockId: string, costElementId: string) => {
    const filterItems: NamedId[] = [];

    for (let i = 0; i < costElementId.length; i++) {
        filterItems.push({
            id: i.toString(),
            name: `${costElementId} ${i}`
        })
    }

    return Promise.resolve(filterItems)
}

export const getLevelInputFilterItems = (costBlockId: string, inputLevelId: string) => {
    const filterItems: NamedId[] = [];

    for (let i = 0; i < inputLevelId.length; i++) {
        filterItems.push({
            id: i.toString(),
            name: `${inputLevelId} ${i}`
        })
    }

    return Promise.resolve(filterItems)
}

export const getEditItems = (context: Context) => {
    const editItems: EditItem[] = [];
    const {
        applicationId,
        scopeId,
        countryId,
        costElementId,
        costBlockId,
        inputLevelId
    } = context;

    const editItemCount = 
        applicationId.length + 
        scopeId.length + 
        countryId.length + 
        costBlockId.length +
        costElementId.length +
        inputLevelId.length;

    for (let i = 0; i < editItemCount; i++) {
        editItems.push({
            id: i.toString(),
            name: `test${i}`,
            value: i * editItemCount
        });
    }

    return Promise.resolve(editItems);
}