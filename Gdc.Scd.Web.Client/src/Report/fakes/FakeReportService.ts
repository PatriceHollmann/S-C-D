import { DataInfo } from "../../Common/States/CommonStates";
import { AutoGridModel } from "../Model/AutogridModel";
import { HwCostFilterModel } from "../Model/HwCostFilterModel";
import { HwCostListModel } from "../Model/HwCostListModel";
import { ReportModel } from "../Model/ReportModel";
import { IReportService } from "../Services/IReportService";
import { fakeHwCost } from "./FakeHwCost";
import { fakeReportList } from "./FakeReportList";
import { fakeSchema } from "./FakeSchema";

export class FakeReportService implements IReportService {
    public getSchema(): Promise<AutoGridModel> {
        return this.fromResult(fakeSchema);
    }

    getSchemaByName(name: string): Promise<AutoGridModel> {
        return this.getSchema();
    }

    public getHwCost(filter: HwCostFilterModel): Promise<DataInfo<HwCostListModel>> {
        return this.fromResult({ items: fakeHwCost, total: fakeHwCost.length * 5 });
    }

    public getReports(): Promise<DataInfo<ReportModel>> {
        return this.fromResult({ items: fakeReportList, total: fakeReportList.length });
    }

    private fromResult<T>(value: T): Promise<T> {
        return Promise.resolve(value);
    }
}
