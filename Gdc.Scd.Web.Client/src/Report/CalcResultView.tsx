﻿import { Container, TabPanel } from "@extjs/ext-react";
import * as React from "react";
import { HwCostView } from "./HwCostView";
import { SwCostView } from "./SwCostView";

export class CalcResultView extends React.Component<any, any> {

    public render() {

        return (
            <Container layout="vbox">

                <TabPanel flex="1" tabBar={{ layout: { pack: 'left' } }}>

                    <Container title="Hardware<br>service costs" layout="fit">
                        <HwCostView />
                    </Container>

                    <Container title="Hardware<br>service costs<br>(approved)" layout="fit">
                        <HwCostView approved={true} />
                    </Container>

                    <Container title="Software &amp; Solution<br>service costs" layout="fit">
                        <SwCostView />
                    </Container>

                    <Container title="Software &amp; Solution<br>service costs<br>(approved)" layout="fit">
                        <SwCostView approved={true} />
                    </Container>

                </TabPanel>

            </Container>
        );
    }
}