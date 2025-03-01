import 'package:car_api/bloc/block.dart';
import 'package:car_api/constants.dart';
import 'package:car_api/crud/model_car_crud.dart';
import 'package:car_api/models/model_car.dart';
import 'package:car_api/models/req_res.dart';
import 'package:car_api/widget/drawer_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_paginator/number_paginator.dart';

class CarModelsForm extends StatefulWidget {
  const CarModelsForm({Key? key}) : super(key: key);

  @override
  _CarModelsFormState createState() => _CarModelsFormState();
}

class _CarModelsFormState extends State<CarModelsForm> {
  int _currentPage = 0; // Переменная для хранения текущей страницы
  UniqueKey _paginatorKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    Widget central =
        context.read<DataCubit>().getModelCarRequestRes.message.isEmpty
            ? CircularProgressIndicator(
                color: Colors.blue,
              )
            : Center(
                child: GetCentralWidget(
                    context.read<DataCubit>().getModelCarRequestRes),
              );

    if (context.read<DataCubit>().getModelCarRequestRes.status == 0) {
      ModelCarCrud.getModelCar('1', context.read<DataCubit>().getYearFilter,
              context.read<DataCubit>().getMakesIdFilter)
          .then(
        (value) {
          print(value);
          context.read<DataCubit>().setModelCarRequestRes(value);

          central =
              GetCentralWidget(context.read<DataCubit>().getModelCarRequestRes);

          setState(() {});
        },
      );
    }

    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                print('on_press');
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu_rounded),
            );
          },
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          'Car Models',
          style: txt30,
        ),
        // -----------  Actions start  -----------------
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) {
              if (item == 0) {
                String yearr = context.read<DataCubit>().getYearFilter;
                print(yearr);
                int h2 = 0;
                Navigator.pushNamed(context, '/YearFilterForm',
                        arguments: yearr)
                    .then((value) {
                  if (value != null) {
                    context.read<DataCubit>().setYearFilter(value.toString());

                    ModelCarCrud.getModelCar(
                            '1',
                            context.read<DataCubit>().getYearFilter,
                            context.read<DataCubit>().getMakesIdFilter)
                        .then((val) {
                      context.read<DataCubit>().setModelCarRequestRes(val);

                      setState(() {
                        _currentPage = 0;
                        _paginatorKey = UniqueKey();

                        int g5 = 5;
                      });
                    });
                  }
                });
              } else if (item == 1) {
                //  MakesIdFilter
                print('MakesIdFilter');
                Navigator.pushNamed(context, '/MakesIdFilter',
                        arguments: context.read<DataCubit>().getMakesIdFilter)
                    .then((values) {
                  if (values != null && values.toString().trim().isNotEmpty) {
                    if (values != null) {
                      context
                          .read<DataCubit>()
                          .setMakesIdFilter(values.toString());

                      ModelCarCrud.getModelCar(
                              '1',
                              context.read<DataCubit>().getYearFilter,
                              context.read<DataCubit>().getMakesIdFilter)
                          .then((val) {
                        context.read<DataCubit>().setModelCarRequestRes(val);

                        int h3 = 3;
                        setState(() {
                          _currentPage = 0;
                          _paginatorKey = UniqueKey();
                        });
                      });
                    }
                  }
                  print(values);
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Year'),
                    ],
                  )),
              PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.car_repair_sharp,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Makes'),
                    ],
                  )),
            ],
          ),
        ],

        // -----------  Actions end  -----------------
      ),
      drawer: DrawerMenu(),

      body: BlocBuilder<DataCubit, Keeper>(builder: (context, state) {
        return Center(
          child: central,
        );
      }),
      bottomNavigationBar: Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        child: NumberPaginator(
          key: _paginatorKey,
          initialPage: _currentPage,
          // by default, the paginator shows numbers as center content
          numberPages:
              context.read<DataCubit>().getModelCarRequestRes.pages_total,
          onPageChange: (int index) {
            setState(() {
              _currentPage = index; // Обновление текущей страницы
              ModelCarCrud.getModelCar(
                      (index + 1).toString(),
                      context.read<DataCubit>().getYearFilter,
                      context.read<DataCubit>().getMakesIdFilter)
                  .then(
                (value) {
                  print(value);

                  setState(() {
                    context.read<DataCubit>().setModelCarRequestRes(value);

                    central = GetCentralWidget(
                        context.read<DataCubit>().getModelCarRequestRes);
                  });
                },
              );
              print('indes = $index');
            });
          },
        ),
      ),
    );
  }

  //------  GetCentralWidget ----------------------------
  Widget GetCentralWidget(ReqRes<ModelCar> result) {
    Widget central = Text(
      'No Data',
      style: txt15,
    );

    if (result.list.isEmpty) {
      if (result.status == 200) {
        central = Text(
          'No Data',
          style: txt15,
        );
      } else {
        central = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No Data'),
            Text(
              result.message,
              style: txt15,
            ),
          ],
        );
      }
    } else {
      central = ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          color: Colors.black,
          thickness: 1,
        ),
        itemCount: result.list.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Text(
                  '${result.list[index].id}',
                  style: txt15,
                ),
              ),
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              '${result.list[index].name}',
              style: txt20,
            ),
            subtitle: Text(
              '${result.list[index].make_name}',
              style: txt15,
            ),
          );
        },
      );
    }
    return central;
  }
}
