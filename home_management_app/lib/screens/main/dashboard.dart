import 'package:flutter/material.dart';
import 'package:home_management_app/screens/main/widgets/income.widget.dart';
import 'package:home_management_app/screens/main/widgets/outcome.widget.dart';

import 'widgets/bartchart.sample.dart';
import 'widgets/chart.sample.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
              children:[
                Expanded(
                    child: IncomeWidget()),
                Expanded(
                    child: OutcomeWidget()),
              ]
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: ChartSampleWidget(),
            )
          ),
          /*Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: LineChartSample2(),
            ),
          ),*/
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: BarChartSample2(),
            ),
          )
        ],
      ),
    );
  }
}