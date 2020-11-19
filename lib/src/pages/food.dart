import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:food_delivery_app/rating_dialog.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
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

class _FoodWidgetState extends StateMVC<FoodWidget> {
  FoodController _con;
  ScanResult scanResult;

  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];


  _FoodWidgetState() : super(FoodController()) {
    _con = controller;
  }




  @override
  void initState() {
 //   cameraAndMicrophonePermissionsGranted();
    _con.listenForFood(foodId: widget.routeArgument.id);
    _con.listenForCart();
    _con.listenForFavorite(foodId: widget.routeArgument.id);
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var contentList = <Widget>[
      if (scanResult != null)
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("Result Type"),
                subtitle: Text(scanResult.type?.toString() ?? ""),
              ),
              ListTile(
                title: Text("Raw Content"),
                subtitle: Text(scanResult.rawContent ?? ""),
              ),
              ListTile(
                title: Text("Format"),
                subtitle: Text(scanResult.format?.toString() ?? ""),
              ),
              ListTile(
                title: Text("Format note"),
                subtitle: Text(scanResult.formatNote ?? ""),
              ),
            ],
          ),
        ),
      ListTile(
        title: Text("Camera selection"),
        dense: true,
        enabled: false,
      ),
      RadioListTile(
        onChanged: (v) => setState(() => _selectedCamera = -1),
        value: -1,
        title: Text("Default camera"),
        groupValue: _selectedCamera,
      ),
    ];

    for (var i = 0; i < _numberOfCameras; i++) {
      contentList.add(RadioListTile(
        onChanged: (v) => setState(() => _selectedCamera = i),
        value: i,
        title: Text("Camera ${i + 1}"),
        groupValue: _selectedCamera,
      ));
    }

    contentList.addAll([
      ListTile(
        title: Text("Button Texts"),
        dense: true,
        enabled: false,
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Flash On",
          ),
          controller: _flashOnController,
        ),
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Flash Off",
          ),
          controller: _flashOffController,
        ),
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Cancel",
          ),
          controller: _cancelController,
        ),
      ),
    ]);

    if (Platform.isAndroid) {
      contentList.addAll([
        ListTile(
          title: Text("Android specific options"),
          dense: true,
          enabled: false,
        ),
        ListTile(
          title:
          Text("Aspect tolerance (${_aspectTolerance.toStringAsFixed(2)})"),
          subtitle: Slider(
            min: -1.0,
            max: 1.0,
            value: _aspectTolerance,
            onChanged: (value) {
              setState(() {
                _aspectTolerance = value;
              });
            },
          ),
        ),
        CheckboxListTile(
          title: Text("Use autofocus"),
          value: _useAutoFocus,
          onChanged: (checked) {
            setState(() {
              _useAutoFocus = checked;
            });
          },
        )
      ]);
    }

    contentList.addAll([
      ListTile(
        title: Text("Other options"),
        dense: true,
        enabled: false,
      ),
      CheckboxListTile(
        title: Text("Start with flash"),
        value: _autoEnableFlash,
        onChanged: (checked) {
          setState(() {
            _autoEnableFlash = checked;
          });
        },
      )
    ]);

    contentList.addAll([
      ListTile(
        title: Text("Barcode formats"),
        dense: true,
        enabled: false,
      ),
      ListTile(
        trailing: Checkbox(
          tristate: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: selectedFormats.length == _possibleFormats.length
              ? true
              : selectedFormats.length == 0 ? false : null,
          onChanged: (checked) {
            setState(() {
              selectedFormats = [
                if (checked ?? false) ..._possibleFormats,
              ];
            });
          },
        ),
        dense: true,
        enabled: false,
        title: Text("Detect barcode formats"),
        subtitle: Text(
          'If all are unselected, all possible platform formats will be used',
        ),
      ),
    ]);

    contentList.addAll(_possibleFormats.map(
          (format) => CheckboxListTile(
        value: selectedFormats.contains(format),
        onChanged: (i) {
          setState(() => selectedFormats.contains(format)
              ? selectedFormats.remove(format)
              : selectedFormats.add(format));
        },
        title: Text(format.toString()),
      ),
    ));
    return Scaffold(
      key: _con.scaffoldKey,
      body: _con.food == null || _con.food?.image == null
          ? CircularLoadingWidget(height: 500)
          : RefreshIndicator(
              onRefresh: _con.refreshFood,
              child:_con.food.isClosed==true?


              Stack(
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
                          backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                          expandedHeight: 300,
                          elevation: 0,
                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Hero(
                              tag: widget.routeArgument.heroTag ?? '' + _con.food.id,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _con.food.image.url,
                                placeholder: (context, url) => Image.asset(
                                  'assets/img/loading.gif',
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Wrap(
                              runSpacing: 8,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _con.food?.name ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          Text(
                                            _con.food?.restaurant?.name ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Helper.getPrice(
                                            _con.food.price,
                                            context,
                                            style: Theme.of(context).textTheme.headline2,
                                          ),
                                          _con.food.discountPrice > 0
                                              ? Helper.getPrice(_con.food.discountPrice, context,
                                                  style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(decoration: TextDecoration.lineThrough)))
                                              : SizedBox(height: 0),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Divider(height: 20),
                                Helper.applyHtml(context, _con.food.description, style: TextStyle(fontSize: 12)),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  leading: Icon(
                                    Icons.add_circle,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).extras,
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                  subtitle: Text(
                                    S.of(context).select_extras_to_add_them_on_the_food,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ),
                                _con.food.extraGroups == null
                                    ? CircularLoadingWidget(height: 100)
                                    : ListView.separated(
                                        padding: EdgeInsets.all(0),
                                        itemBuilder: (context, extraGroupIndex) {
                                          var extraGroup = _con.food.extraGroups.elementAt(extraGroupIndex);
                                          return Wrap(
                                            children: <Widget>[
                                              ListTile(
                                                dense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                                leading: Icon(
                                                  Icons.add_circle_outline,
                                                  color: Theme.of(context).hintColor,
                                                ),
                                                title: Text(
                                                  extraGroup.name,
                                                  style: Theme.of(context).textTheme.subtitle1,
                                                ),
                                              ),
                                              ListView.separated(
                                                padding: EdgeInsets.all(0),
                                                itemBuilder: (context, extraIndex) {
                                                  return ExtraItemWidget(
                                                    extra: _con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).elementAt(extraIndex),
                                                    onChanged: _con.calculateTotal,
                                                  );
                                                },
                                                separatorBuilder: (context, index) {
                                                  return SizedBox(height: 20);
                                                },
                                                itemCount: _con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).length,
                                                primary: false,
                                                shrinkWrap: true,
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return SizedBox(height: 20);
                                        },
                                        itemCount: _con.food.extraGroups.length,
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
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
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
                                            _con.removeFromFavorite(_con.favorite);
                                          },
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          color: Theme.of(context).primaryColor,
                                          shape: StadiumBorder(),
                                          borderSide: BorderSide(color: Theme.of(context).accentColor),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Theme.of(context).accentColor,
                                          ))
                                      : FlatButton(
                                          onPressed: () {
                                            if (currentUser.value.apiToken == null) {
                                              Navigator.of(context).pushNamed("/Login");
                                            } else {
                                              _con.addToFavorite(_con.food);
                                            }
                                          },
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          color: Theme.of(context).accentColor,
                                          shape: StadiumBorder(),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Theme.of(context).primaryColor,
                                          )),
                                ),
                                SizedBox(width: 10),
                                Stack(
                                  fit: StackFit.loose,
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width - 190,
                                      child: FlatButton(
                                        onPressed: () {

                                        },
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        color: Theme.of(context).backgroundColor,
                                        shape: StadiumBorder(),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Text(
                                           'Purchase',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(color: Theme.of(context).primaryColor),
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: FlatButton(
                                      onPressed: scan,
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      color: Theme.of(context).accentColor,
                                      shape: StadiumBorder(),
                                      child: Icon(
                                        Icons.camera,
                                        color: Theme.of(context).primaryColor,
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
              ):   StickyHeader(header:
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).accentColor,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(5),
                child: Text(
                  _con.food.msgUsag.toString(),
                  style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                ),
              ),
                content:   Stack(
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
                            backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                            expandedHeight: 300,
                            elevation: 0,
                            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.parallax,
                              background: Hero(
                                tag: widget.routeArgument.heroTag ?? '' + _con.food.id,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: _con.food.image.url,
                                  placeholder: (context, url) => Image.asset(
                                    'assets/img/loading.gif',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Wrap(
                                runSpacing: 8,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _con.food?.name ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: Theme.of(context).textTheme.headline3,
                                            ),
                                            Text(
                                              _con.food?.restaurant?.name ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: Theme.of(context).textTheme.bodyText2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Helper.getPrice(
                                              _con.food.price,
                                              context,
                                              style: Theme.of(context).textTheme.headline2,
                                            ),
                                            _con.food.discountPrice > 0
                                                ? Helper.getPrice(_con.food.discountPrice, context,
                                                style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(decoration: TextDecoration.lineThrough)))
                                                : SizedBox(height: 0),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  Divider(height: 20),
                                  Helper.applyHtml(context, _con.food.description, style: TextStyle(fontSize: 12)),
                                  ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    leading: Icon(
                                      Icons.add_circle,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    title: Text(
                                      S.of(context).extras,
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                    subtitle: Text(
                                      S.of(context).select_extras_to_add_them_on_the_food,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  _con.food.extraGroups == null
                                      ? CircularLoadingWidget(height: 100)
                                      : ListView.separated(
                                    padding: EdgeInsets.all(0),
                                    itemBuilder: (context, extraGroupIndex) {
                                      var extraGroup = _con.food.extraGroups.elementAt(extraGroupIndex);
                                      return Wrap(
                                        children: <Widget>[
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                                            leading: Icon(
                                              Icons.add_circle_outline,
                                              color: Theme.of(context).hintColor,
                                            ),
                                            title: Text(
                                              extraGroup.name,
                                              style: Theme.of(context).textTheme.subtitle1,
                                            ),
                                          ),
                                          ListView.separated(
                                            padding: EdgeInsets.all(0),
                                            itemBuilder: (context, extraIndex) {
                                              return ExtraItemWidget(
                                                extra: _con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).elementAt(extraIndex),
                                                onChanged: _con.calculateTotal,
                                              );
                                            },
                                            separatorBuilder: (context, index) {
                                              return SizedBox(height: 20);
                                            },
                                            itemCount: _con.food.extras.where((extra) => extra.extraGroupId == extraGroup.id).length,
                                            primary: false,
                                            shrinkWrap: true,
                                          ),
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: 20);
                                    },
                                    itemCount: _con.food.extraGroups.length,
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
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                            boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
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
                                          _con.removeFromFavorite(_con.favorite);
                                        },
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        color: Theme.of(context).primaryColor,
                                        shape: StadiumBorder(),
                                        borderSide: BorderSide(color: Theme.of(context).accentColor),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Theme.of(context).accentColor,
                                        ))
                                        : FlatButton(
                                        onPressed: () {
                                          if (currentUser.value.apiToken == null) {
                                            Navigator.of(context).pushNamed("/Login");
                                          } else {
                                            _con.addToFavorite(_con.food);
                                          }
                                        },
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        color: Theme.of(context).accentColor,
                                        shape: StadiumBorder(),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                  ),
                                  SizedBox(width: 10),
                                  Stack(
                                    fit: StackFit.loose,
                                    alignment: AlignmentDirectional.centerEnd,
                                    children: <Widget>[
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width - 190,
                                        child: FlatButton(
                                          onPressed: () {

                                          },
                                          padding: EdgeInsets.symmetric(vertical: 14),
                                          color: Theme.of(context).backgroundColor,
                                          shape: StadiumBorder(),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            child: Text(
                                              'Purchase',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(color: Theme.of(context).primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: FlatButton(
                                        onPressed: scan,
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        color: Theme.of(context).accentColor,
                                        shape: StadiumBorder(),
                                        child: Icon(
                                          Icons.camera,
                                          color: Theme.of(context).primaryColor,
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
                ),),
            ),
    );
  }


  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": _cancelController.text,
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

}
