import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_build_number/simple_build_number.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => BuildNumberBloc(BuildNumberRepository())
        ..add(BuildNumberArgumentsLoadEvent()),
      lazy: false,
      child: MaterialApp(
        title: 'simple_build_number',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Simple build number example'),
          ),
          body: Center(
            child: BlocBuilder<BuildNumberBloc, BuildNumberState>(builder:
                (BuildContext context, BuildNumberState buildNumberState) {
              if (buildNumberState is BuildNumberLoadedState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'state - version',
                    ),
                    Text(
                      '${describeEnum(buildNumberState.state)} - ${buildNumberState.version}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                );
              }
              return Center(
                child: Text('Loading build number...'),
              );
            }),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }
}
