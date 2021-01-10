import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/src/controllers/reviews_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/rating_dialog.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:toast/toast.dart';
import '../../generated/l10n.dart';
import '../controllers/food_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/ExtraItemWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

// ignore: must_be_immutable
class FoodWidget extends StatefulWidget {
  RouteArgument routeArgument;

  FoodWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _FoodWidgetState createState() {
    return _FoodWidgetState();
  }
}

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class _FoodWidgetState extends StateMVC<FoodWidget> {
  FoodController _con;
  ReviewsController _conR;

  _FoodWidgetState() : super(FoodController()) {
    _con = controller;
  }
  String userId;
  getValueString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

  }
  @override
  void initState() {
    getValueString();
    //   cameraAndMicrophonePermissionsGranted();
    _con.listenForFood(foodId: widget.routeArgument.id);
    _con.listenForCart();
    _con.listenForFavorite(foodId: widget.routeArgument.id);
    _conR=new ReviewsController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: _con.food == null || _con.food?.image == null
          ? CircularLoadingWidget(height: 500)
          : RefreshIndicator(
        onRefresh: _con.refreshFood,
        child: _con.food.isClosed == false
            ? Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 125),
              padding: EdgeInsets.only(bottom: 15),
              child: CustomScrollView(
                primary: true,
                shrinkWrap: false,
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Theme.of(context)
                        .accentColor
                        .withOpacity(0.9),
                    expandedHeight: 300,
                    elevation: 0,
                    iconTheme: IconThemeData(
                        color: Theme.of(context).primaryColor),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Hero(
                        tag: widget.routeArgument.heroTag ??
                            '' + _con.food.id,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: _con.food.image.url,
                          placeholder: (context, url) =>
                              Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                              ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Wrap(
                        runSpacing: 8,
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _con.food?.name ?? '',
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3,
                                    ),
                                    Text(
                                      _con.food?.restaurant?.name ??
                                          '',
                                      overflow:
                                      TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Helper.getPrice(
                                      _con.food.price,
                                      context,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2,
                                    ),
                                    _con.food.discountPrice > 0
                                        ? Helper.getPrice(
                                        _con.food.discountPrice,
                                        context,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .merge(TextStyle(
                                            decoration:
                                            TextDecoration
                                                .lineThrough)))
                                        : SizedBox(height: 0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 20),
                          Helper.applyHtml(
                              context, _con.food.description,
                              style: TextStyle(fontSize: 12)),
                          ListTile(
                            dense: true,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10),
                            leading: Icon(
                              Icons.add_circle,
                              color: Theme.of(context).hintColor,
                            ),
                            title: Text(
                              S.of(context).extras,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1,
                            ),
                            subtitle: Text(
                              S
                                  .of(context)
                                  .select_extras_to_add_them_on_the_food,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ),
                          _con.food.extraGroups == null
                              ? CircularLoadingWidget(height: 100)
                              : ListView.separated(
                            padding: EdgeInsets.all(0),
                            itemBuilder:
                                (context, extraGroupIndex) {
                              var extraGroup = _con
                                  .food.extraGroups
                                  .elementAt(extraGroupIndex);
                              return Wrap(
                                children: <Widget>[
                                  ListTile(
                                    dense: true,
                                    contentPadding:
                                    EdgeInsets.symmetric(
                                        vertical: 0),
                                    leading: Icon(
                                      Icons
                                          .add_circle_outline,
                                      color: Theme.of(context)
                                          .hintColor,
                                    ),
                                    title: Text(
                                      extraGroup.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1,
                                    ),
                                  ),
                                  ListView.separated(
                                    padding:
                                    EdgeInsets.all(0),
                                    itemBuilder: (context,
                                        extraIndex) {
                                      return ExtraItemWidget(
                                        extra: _con
                                            .food.extras
                                            .where((extra) =>
                                        extra
                                            .extraGroupId ==
                                            extraGroup.id)
                                            .elementAt(
                                            extraIndex),
                                        onChanged: _con
                                            .calculateTotal,
                                      );
                                    },
                                    separatorBuilder:
                                        (context, index) {
                                      return SizedBox(
                                          height: 20);
                                    },
                                    itemCount: _con
                                        .food.extras
                                        .where((extra) =>
                                    extra
                                        .extraGroupId ==
                                        extraGroup.id)
                                        .length,
                                    primary: false,
                                    shrinkWrap: true,
                                  ),
                                ],
                              );
                            },
                            separatorBuilder:
                                (context, index) {
                              return SizedBox(height: 20);
                            },
                            itemCount:
                            _con.food.extraGroups.length,
                            primary: false,
                            shrinkWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 100,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .focusColor
                              .withOpacity(0.15),
                          offset: Offset(0, -2),
                          blurRadius: 5.0)
                    ]),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _con.favorite?.id != null
                                ? OutlineButton(
                                onPressed: () {
                                  _con.removeFromFavorite(
                                      _con.favorite);
                                },
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                color: Theme.of(context)
                                    .primaryColor,
                                shape: StadiumBorder(),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .accentColor),
                                child: Icon(
                                  Icons.favorite,
                                  color: Theme.of(context)
                                      .accentColor,
                                ))
                                : FlatButton(
                                onPressed: () {
                                  if (currentUser
                                      .value.apiToken ==
                                      null) {
                                    Navigator.of(context)
                                        .pushNamed("/Login");
                                  } else {
                                    _con.addToFavorite(
                                        _con.food);
                                  }
                                },
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                color: Theme.of(context)
                                    .accentColor,
                                shape: StadiumBorder(),
                                child: Icon(
                                  Icons.favorite,
                                  color: Theme.of(context)
                                      .primaryColor,
                                )),
                          ),
                          SizedBox(width: 10),
                          Stack(
                            fit: StackFit.loose,
                            alignment:
                            AlignmentDirectional.centerEnd,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context)
                                    .size
                                    .width -
                                    190,
                                child: FlatButton(
                                  onPressed: () {},
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14),
                                  color: Theme.of(context)
                                      .backgroundColor,
                                  shape: StadiumBorder(),
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Purchase',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: FlatButton(
                                onPressed: () {
                                    if (currentUser
                                        .value.apiToken ==
                                        null) {
                                      Navigator.of(context)
                                          .pushNamed("/Login");
                                    } else {
                                      Navigator.of(context)
                                          .push(new MaterialPageRoute<
                                          String>(
                                          builder: (context) =>
                                              scanA(widget
                                                  .routeArgument
                                                  .id)))
                                          .then((String value) {
                                         print('tedttttttttttttttt');
                                        String smil =
                                            'has been added ' +
                                                _con.food.smileA +
                                                ' for you';
                                        print(value);
                                    if(value!=null){
                                      Fluttertoast.showToast(
                                          msg: smil);
                                      showDialog(
                                          context: context,
                                          child: Dialog(
                                            shape: BeveledRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(
                                                    Radius
                                                        .circular(
                                                        10))),
                                            child: RatingDialog(_con.food.id,_conR,userId),
                                          ));
                                    }
                                      });
                                    }

                                },
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                color:
                                Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Icon(
                                  Icons.camera,
                                  color: Theme.of(context)
                                      .primaryColor,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
            : Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 125),
              padding: EdgeInsets.only(bottom: 15),
              child: CustomScrollView(
                primary: true,
                shrinkWrap: false,
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Theme.of(context)
                        .accentColor
                        .withOpacity(0.9),
                    expandedHeight: 300,
                    elevation: 0,
                    iconTheme: IconThemeData(
                        color: Theme.of(context).primaryColor),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Hero(
                        tag: widget.routeArgument.heroTag ??
                            '' + _con.food.id,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: _con.food.image.url,
                          placeholder: (context, url) =>
                              Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                              ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(

                    child: Column(
                      children: [
                        Container(
                          width:
                          MediaQuery.of(context).size.width,
                          height: 50,
                          child: Padding(child: Text(
                            _con.food.msgUsag,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,color: Colors.white),
                          ),padding: EdgeInsets.all(10),),
                          color: Colors.red,
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),child:  Wrap(
                          runSpacing: 8,
                          children: [
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Text(
                                        _con.food?.name ?? '',
                                        overflow: TextOverflow
                                            .ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                      Text(
                                        _con.food?.restaurant
                                            ?.name ??
                                            '',
                                        overflow: TextOverflow
                                            .ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Helper.getPrice(
                                        _con.food.price,
                                        context,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      _con.food.discountPrice >
                                          0
                                          ? Helper.getPrice(
                                          _con.food
                                              .discountPrice,
                                          context,
                                          style: Theme.of(
                                              context)
                                              .textTheme
                                              .bodyText2
                                              .merge(TextStyle(
                                              decoration:
                                              TextDecoration
                                                  .lineThrough)))
                                          : SizedBox(height: 0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 20),
                            Helper.applyHtml(
                                context, _con.food.description,
                                style: TextStyle(fontSize: 12)),
                            ListTile(
                              dense: true,
                              contentPadding:
                              EdgeInsets.symmetric(
                                  vertical: 10),
                              leading: Icon(
                                Icons.add_circle,
                                color:
                                Theme.of(context).hintColor,
                              ),
                              title: Text(
                                S.of(context).extras,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1,
                              ),
                              subtitle: Text(
                                S
                                    .of(context)
                                    .select_extras_to_add_them_on_the_food,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption,
                              ),
                            ),
                            _con.food.extraGroups == null
                                ? CircularLoadingWidget(
                                height: 100)
                                : ListView.separated(
                              padding: EdgeInsets.all(0),
                              itemBuilder: (context,
                                  extraGroupIndex) {
                                var extraGroup = _con
                                    .food.extraGroups
                                    .elementAt(
                                    extraGroupIndex);
                                return Wrap(
                                  children: <Widget>[
                                    ListTile(
                                      dense: true,
                                      contentPadding:
                                      EdgeInsets
                                          .symmetric(
                                          vertical:
                                          0),
                                      leading: Icon(
                                        Icons
                                            .add_circle_outline,
                                        color: Theme.of(
                                            context)
                                            .hintColor,
                                      ),
                                      title: Text(
                                        extraGroup.name,
                                        style: Theme.of(
                                            context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ),
                                    ListView.separated(
                                      padding:
                                      EdgeInsets.all(
                                          0),
                                      itemBuilder:
                                          (context,
                                          extraIndex) {
                                        return ExtraItemWidget(
                                          extra: _con
                                              .food.extras
                                              .where((extra) =>
                                          extra
                                              .extraGroupId ==
                                              extraGroup
                                                  .id)
                                              .elementAt(
                                              extraIndex),
                                          onChanged: _con
                                              .calculateTotal,
                                        );
                                      },
                                      separatorBuilder:
                                          (context,
                                          index) {
                                        return SizedBox(
                                            height: 20);
                                      },
                                      itemCount: _con
                                          .food.extras
                                          .where((extra) =>
                                      extra
                                          .extraGroupId ==
                                          extraGroup
                                              .id)
                                          .length,
                                      primary: false,
                                      shrinkWrap: true,
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder:
                                  (context, index) {
                                return SizedBox(
                                    height: 20);
                              },
                              itemCount: _con.food
                                  .extraGroups.length,
                              primary: false,
                              shrinkWrap: true,
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 100,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .focusColor
                              .withOpacity(0.15),
                          offset: Offset(0, -2),
                          blurRadius: 5.0)
                    ]),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _con.favorite?.id != null
                                ? OutlineButton(
                                onPressed: () {
                                  _con.removeFromFavorite(
                                      _con.favorite);
                                },
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                color: Theme.of(context)
                                    .primaryColor,
                                shape: StadiumBorder(),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .accentColor),
                                child: Icon(
                                  Icons.favorite,
                                  color: Theme.of(context)
                                      .accentColor,
                                ))
                                : FlatButton(
                                onPressed: () {
                                  if (currentUser
                                      .value.apiToken ==
                                      null) {
                                    Navigator.of(context)
                                        .pushNamed("/Login");
                                  } else {
                                    _con.addToFavorite(
                                        _con.food);
                                  }
                                },
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                color: Theme.of(context)
                                    .accentColor,
                                shape: StadiumBorder(),
                                child: Icon(
                                  Icons.favorite,
                                  color: Theme.of(context)
                                      .primaryColor,
                                )),
                          ),
                          SizedBox(width: 10),
                          Stack(
                            fit: StackFit.loose,
                            alignment:
                            AlignmentDirectional.centerEnd,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context)
                                    .size
                                    .width -
                                    190,
                                child: FlatButton(
                                  onPressed: () {},
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14),
                                  color: Theme.of(context)
                                      .backgroundColor,
                                  shape: StadiumBorder(),
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Purchase',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: FlatButton(
                                onPressed: () {
                                  if (currentUser
                                      .value.apiToken ==
                                      null) {
                                    Navigator.of(context)
                                        .pushNamed("/Login");
                                  } else {
                                    Navigator.of(context)
                                        .push(new MaterialPageRoute<
                                        String>(
                                        builder: (context) =>
                                            scanA(widget
                                                .routeArgument
                                                .id)))
                                        .then((String value) {
                                      String smil =
                                          'has been added ' +
                                              _con.food.smileA +
                                              ' for you';
                                     if(value!=null){
                                       Fluttertoast.showToast(
                                           msg: smil);
                                       showDialog(
                                           context: context,
                                           child: Dialog(
                                             shape: BeveledRectangleBorder(
                                                 borderRadius:
                                                 BorderRadius.all(
                                                     Radius
                                                         .circular(
                                                         10))),
                                             child: RatingDialog(_con.food.id,_conR,userId),
                                           ));
                                     }
                                    });
                                  }

                                },
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                color:
                                Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Icon(
                                  Icons.camera,
                                  color: Theme.of(context)
                                      .primaryColor,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class scanA extends StatefulWidget {
  final String idfood;

  scanA(this.idfood);

  @override
  _scanA createState() => _scanA();
}

class _scanA extends StateMVC<scanA> {
  var qrText = '';
  var flashState = flashOn;
  var cameraState = frontCamera;
  QRViewController controllert;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('This is the result of scan: $qrText'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: RaisedButton(
                          onPressed: () {
                            if (controllert != null) {
                              controllert.toggleFlash();
                              if (_isFlashOn(flashState)) {
                                setState(() {
                                  flashState = flashOff;
                                });
                              } else {
                                setState(() {
                                  flashState = flashOn;
                                });
                              }
                            }
                          },
                          child:
                          Text(flashState, style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: RaisedButton(
                          onPressed: () {
                            if (controllert != null) {
                              controllert.flipCamera();
                              if (_isBackCamera(cameraState)) {
                                setState(() {
                                  cameraState = frontCamera;
                                });
                              } else {
                                setState(() {
                                  cameraState = backCamera;
                                });
                              }
                            }
                          },
                          child:
                          Text(cameraState, style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: RaisedButton(
                          onPressed: () {
                            controllert?.pauseCamera();
                          },
                          child: Text('pause', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: RaisedButton(
                          onPressed: () {
                            controllert?.resumeCamera();
                          },
                          child: Text('resume', style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controllert = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        controllert.dispose();

        //    Navigator.of(context).pop(qrText);
        /* SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/Food');
        });*/
        Navigator.of(context).pop(qrText);
        Navigator.of(context).pushNamed('/Food',
            arguments: RouteArgument(
                id: widget.idfood, heroTag: 'home_food_carousel'));

        /* showDialog(
            context: context,
            child: Dialog(
              shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              child: RatingDialog('1'),
            ));
        Fluttertoast.showToast(msg:qrText.toString());*/
        //    Navigator.pop(context, true);
      });
    });
  }

  @override
  void dispose() {
    controllert.dispose();

    super.dispose();
  }
}
