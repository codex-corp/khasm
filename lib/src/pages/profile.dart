import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/user_controller.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/DrawerWidget.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/ProfileAvatarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/user_repository.dart';

class ProfileWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;
  ProfileWidget({Key key, this.parentScaffoldKey, this.routeArgument,}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends StateMVC<ProfileWidget> {
  ProfileController _con;
  UserController _conu;

  _ProfileWidgetState() : super(ProfileController()) {
    _con = controller;
  }
@override
  void initState() {
  _conu=new UserController();

  // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // key: _con.scaffoldKey,
      drawer: DrawerWidget(context),
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).primaryColor),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String mobile = prefs.getString('phoneM');
            String code=   prefs.getString('codeC');
            String tok=   prefs.getString('tok');

            _conu.loginUpdatae(mobile,tok,code,'2');

            _con.scaffoldKey?.currentState?.openDrawer();}
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).profile,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3, color: Theme.of(context).primaryColor)),
        ),

        actions: <Widget>[
          GestureDetector(child: Padding(padding:EdgeInsets.fromLTRB(10, 0, 10, 0),child:Icon(Icons.settings,color:Colors.white)),
          onTap:(){
            Navigator.of(context).pushNamed('/Settings');
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) =>  SettingsWidget(),
              ),
            );

          })
        ],
      ),
      body: currentUser.value.apiToken == null
          ? PermissionDeniedWidget()
          : SingleChildScrollView(
//              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: <Widget>[
                  ProfileAvatarWidget(user: currentUser.value),
                  Wrap(
                    runSpacing: 2,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child:  ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              leading: Icon(
                                Icons.tag_faces,
                                color: Theme.of(context).accentColor,
                              ),
                              title: Text(
                                '10',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child:  ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                              leading: Icon(
                                Icons.save,
                                color: Theme.of(context).accentColor,
                              ),
                              title: Text(
                                '450',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          )                        ],
                      ),

                      Divider(height: 20),




                    ],
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).about,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      currentUser.value?.bio ?? "",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),

                 /* ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.shopping_basket,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).recent_orders,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  _con.recentOrders.isEmpty
                      ? EmptyOrdersWidget()
                      : ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: false,
                          itemCount: _con.recentOrders.length,
                          itemBuilder: (context, index) {
                            var _order = _con.recentOrders.elementAt(index);
                            return OrderItemWidget(expanded: index == 0 ? true : false, order: _order);
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 20);
                          },
                        ),*/
                ],
              ),
            ),
    );
  }
}
