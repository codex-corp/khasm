import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/cuisionController.dart';
import 'package:food_delivery_app/src/controllers/user_controller.dart';
import 'package:food_delivery_app/src/elements/CardWidget.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/serviceList.dart';
import 'package:food_delivery_app/src/repository/serviceRepository.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../pages/cardCuision.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../elements/FoodGridItemWidget.dart';
import '../elements/FoodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ServiceCuision extends StatefulWidget {
  final RouteArgument routeArgument;

  ServiceCuision({Key key, this.routeArgument}) : super(key: key);

  @override
  _ServiceCuision createState() => _ServiceCuision();
}

class _ServiceCuision extends StateMVC<ServiceCuision> {
  // TODO add layout in configuration file
  String layout = 'grid';

  //
  List<Restaurant> res;
  ServiceList ser;
  UserController _conu;

  CuisionController _con;

  _ServiceCuision() : super(CuisionController()) {
    _con = controller;
  }
  getValueString() async {
   // _con.listenForresturantByCuison(id: widget.routeArgument.id);
    final Stream<ServiceList> stream = await getResturantByCCuision( widget.routeArgument.id);
    stream.listen((ServiceList _food) {
      setState(() {
        ser=_food;
        res=_food.restaurant;
      });
    }, onError: (a) {

    }, onDone: () {
      setState(() {
       // ser=_food;
      //  res1=res;
      });
    });

  }
  @override
  void initState() {
    _conu = new UserController();
res= new List<Restaurant>();

getValueString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(context),
      endDrawer: FilterWidget(onFilter: (filter) {
        Navigator.of(context).pushReplacementNamed('/Category',
            arguments: RouteArgument(id: widget.routeArgument.id));
      }),
      appBar: AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String mobile = prefs.getString('phoneM');
              String code = prefs.getString('codeC');
              String tok = prefs.getString('tok');

              _conu.loginUpdatae(mobile, tok, code, '2');

              _con.scaffoldKey?.currentState?.openDrawer();
            }),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).cuision_restaurants,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 0)),
        ),
        /* actions: <Widget>[
          _con.loadCart
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.5, vertical: 15),
                  child: SizedBox(
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],*/
      ),
      body: ser == null
          ? CircularLoadingWidget(height: 500)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Container(
                        child: res != null
                            ? ClipRRect(
                                child: CachedNetworkImage(
                                  // height: 10,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl: ser.image,
                                  placeholder: (context, url) => Image.asset(
                                    'assets/img/loading.gif',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 10,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              )
                            : ClipRRect(
                                child: Image.asset(
                                  'assets/img/loading.gif',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 10,
                                ),
                              ),
                        height: 50,
                        width: 50,
                      ),
                      title: Text(
                        ser?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  res.isEmpty
                      ? CircularLoadingWidget(height: 288)
                      :Column(children: [Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0),
                      title: Text(
                        S.of(context).restaurants_results,
                        style:
                        Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                    ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount:
                      res.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                '/Details',
                                arguments: RouteArgument(
                                  id: res
                                      .elementAt(index)
                                      .id,
                                  // heroTag: 'search',
                                ));
                          },
                          child:cardCuision(restaurant: res.elementAt(index),),
                        );
                      },
                    )],),

                  /*_con.ServiceLists.isEmpty
                ? CircularLoadingWidget(height: 500)
                : Offstage(
              offstage: this.layout != 'grid',
              child: GridView.count(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
                padding: EdgeInsets.symmetric(horizontal: 20),
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
                // Generate 100 widgets that display their index in the List.
                children: List.generate(_con.ServiceLists.length, (index) {
                  return FoodGridItemWidget(
                      heroTag: 'category_grid',
                      food: _con.ServiceLists.elementAt(index),
                      onPressed: () {
                        if (currentUser.value.apiToken == null) {
                          Navigator.of(context).pushNamed('/Login');
                        } else {
                          if (_con.isSameRestaurants(_con.ServiceLists.elementAt(index))) {
                            _con.addToCart(_con.foods.elementAt(index));
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AddToCartAlertDialogWidget(
                                    oldFood: _con.carts.elementAt(0)?.food,
                                    newFood: _con.foods.elementAt(index),
                                    onPressed: (food, {reset: true}) {
                                      return _con.addToCart(_con.foods.elementAt(index), reset: true);
                                    });
                              },
                            );
                          }
                        }
                      });
                }),
              ),
            )*/
                ],
              ),
            ),
    );
  }
}
