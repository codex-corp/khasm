import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/restaurant.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart' as sett;
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/map_controller.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';
import 'package:geolocator/geolocator.dart' as geo;

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;

  HomeWidget({Key key, this.parentScaffoldKey, this.routeArgument,}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  Restaurant currentRestaurant;
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  Address currentAddress;
  Set<Polyline> polylines = new Set();
  CameraPosition cameraPosition;
  geo.Position res;
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

  MapsUtil mapsUtil = new MapsUtil();
  Future<bool> getLocationPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {}
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {}
    }

    _locationData = await location.getLocation();
    print(_locationData);
    setState(() {
      res = geo.Position(
          latitude: _locationData.latitude, longitude: _locationData.longitude);

      //  currentAddress.longitude=res.longitude;

    });

    getCurrentLocation();
    getRestaurantLocation();
    getDirectionSteps();
    goCurrentLocation();

  }

  Completer<GoogleMapController> mapController = Completer();
  _HomeWidgetState() : super(HomeController()) {
    _con = controller;

  }
  void getRestaurantsOfArea() async {
    setState(() {
      topRestaurants = <Restaurant>[];
      Address areaAddress = Address.fromJSON({"latitude": cameraPosition.target.latitude, "longitude": cameraPosition.target.longitude});
      if (cameraPosition != null) {
        listenForNearRestaurants(currentAddress, areaAddress);
      } else {
        listenForNearRestaurants(currentAddress, currentAddress);
      }
    });
  }
  void listenForNearRestaurants(Address myLocation, Address areaLocation) async {
    final Stream<Restaurant> stream = await getNearRestaurants(myLocation, areaLocation);
    stream.listen((Restaurant _restaurant) {
      setState(() {
        topRestaurants.add(_restaurant);
      });
      Helper.getMarker(_restaurant.toMap()).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    }, onError: (a) {}, onDone: () {});
  }

  void getCurrentLocation() async {
    try {
      currentAddress = sett.deliveryAddress.value;
      setState(() {
        if (currentAddress.isUnknown()) {
          cameraPosition = CameraPosition(
            target: LatLng(40, 3),
            zoom: 4,
          );
        } else {
          cameraPosition = CameraPosition(
            target: LatLng(res.latitude, res.longitude),
            zoom: 14.4746,
          );
        }
      });
      if (!currentAddress.isUnknown()) {
        Helper.getMyPositionMarker(res.latitude, res.longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  void getRestaurantLocation() async {
    try {
      currentAddress = await sett.getCurrentLocation();
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(double.parse(res.latitude.toString()), double.parse(res.longitude.toString())),
          zoom: 14.4746,
        );
      });
      Helper.getMyPositionMarker(res.latitude, res.longitude).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }
  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;

    sett.setCurrentLocation().then((_currentAddress) {
      setState(() {
        sett.deliveryAddress.value = _currentAddress;
        currentAddress = _currentAddress;
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentAddress.latitude, _currentAddress.longitude),
        zoom: 14.4746,
      )));
    });
  }

  void getDirectionSteps() async {
    // currentAddress = await sett.getCurrentLocation();
    //
    //  getLocationPermission();
    print(res.latitude.toString());
    mapsUtil
        .get("origin=" +
        res.latitude.toString() +
        "," +
        res.longitude.toString() +
        "&destination=" +
        res.latitude.toString() +
        "," +
        res.longitude.toString() +
        "&key=${sett.setting.value?.googleMapsKey}")
        .then((dynamic res) {
      if (res != null) {
        List<LatLng> _latLng = res as List<LatLng>;
        _latLng?.insert(0, new LatLng(res.latitude, res.longitude));
        setState(() {
          polylines.add(new Polyline(
              visible: true, polylineId: new PolylineId(currentAddress.hashCode.toString()), points: _latLng, color: config.Colors().mainColor(0.8), width: 6));
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getLocationPermission();
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
    print(currentUser.value.isActive.toString());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {




    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              // value.appName ?? S.of(context).home,
              S.of(context).home ?? S.of(context).home,
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        /*actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],*/
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: currentUser.value.isActive==true?
          currentUser.value.isEnded==false?  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(settingsRepo.setting.value.homeSections.length, (index) {
              String _homeSection = settingsRepo.setting.value.homeSections.elementAt(index);
              switch (_homeSection) {
                case 'slider':
                  return Column(children: <Widget>[
                    HomeSliderWidget(slides: _con.slides),

                    Padding(padding:EdgeInsets.all(10),child:
                    Container(child:
                    Column(children: <Widget>[


                      Container(height: 250,child:  Stack(
//        fit: StackFit.expand,
                        alignment: AlignmentDirectional.bottomStart,
                        children: <Widget>[
                          cameraPosition == null
                              ? CircularLoadingWidget(height: 0)
                              : GoogleMap(
                            mapToolbarEnabled: false,
                            mapType: MapType.normal,
                            initialCameraPosition: cameraPosition,
                            markers: Set.from(allMarkers),
                            onMapCreated: (GoogleMapController controller) {
                              mapController.complete(controller);
                            },
                            onCameraMove: (CameraPosition cameraPosition) {
                              cameraPosition = cameraPosition;
                            },
                            onCameraIdle: () {
                              getRestaurantsOfArea();
                            },
                            polylines: polylines,
                          ),

                        ],
                      ),
                      ),
                      Padding(padding:EdgeInsets.all(10),child:Row(children: <Widget>[Text(
                          S.of(context).nearby_services+
                              ' :',style:TextStyle(fontWeight: FontWeight.bold))],)),
                      CardsCarouselWidget(
                        restaurantsList: topRestaurants,
                        heroTag: 'map_restaurants',
                      ),],))),
                  ],)

                  ;
                case 'search':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      onClickFilter: (event) {
                        widget.parentScaffoldKey.currentState.openEndDrawer();
                      },
                    ),
                  );
                case 'top_restaurants_heading':
                  return Padding(
                    padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                S.of(context).top_restaurants,
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (currentUser.value.apiToken == null) {
                                  _con.requestForCurrentLocation(context);
                                } else {
                                  var bottomSheetController = widget.parentScaffoldKey.currentState.showBottomSheet(
                                        (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                    ),
                                  );
                                  bottomSheetController.closed.then((value) {
                                    _con.refreshHome();
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: settingsRepo.deliveryAddress.value?.address == null
                                      ? Theme.of(context).focusColor.withOpacity(0.1)
                                      : Theme.of(context).accentColor,
                                ),
                                child: Text(
                                  S.of(context).delivery,
                                  style: TextStyle(
                                      color:
                                      settingsRepo.deliveryAddress.value?.address == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(width: 7),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  settingsRepo.deliveryAddress.value?.address = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: settingsRepo.deliveryAddress.value?.address != null
                                      ? Theme.of(context).focusColor.withOpacity(0.1)
                                      : Theme.of(context).accentColor,
                                ),
                                child: Text(
                                  S.of(context).pickup,
                                  style: TextStyle(
                                      color:
                                      settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (settingsRepo.deliveryAddress.value?.address != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              S.of(context).near_to + " " + (settingsRepo.deliveryAddress.value?.address),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                      ],
                    ),
                  );
                case 'top_restaurants':
                  return CardsCarouselWidget(restaurantsList: _con.topRestaurants, heroTag: 'home_top_restaurants',con: context);
                case 'trending_week_heading':
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).trending_this_week,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  );
                case 'trending_week':
                  return FoodsCarouselWidget(foodsList: _con.trendingFoods, heroTag: 'home_food_carousel');
                case 'categories_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.category,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).food_categories,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'categories':
                  return CategoriesCarouselWidget(
                    categories: _con.categories,
                  );
                case 'popular_heading':
                  return _con.popularRestaurants.length==0?Visibility(visible:false,child:Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).most_popular,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  )):
                  Visibility(visible:true,child:Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).most_popular,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ));
                case 'popular':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridWidget(
                      restaurantsList: _con.popularRestaurants,
                      heroTag: 'home_restaurants',
                    ),
                  );
                case 'recent_reviews_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      leading: Icon(
                        Icons.recent_actors,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).recent_reviews,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'recent_reviews':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsListWidget(reviewsList: _con.recentReviews),
                  );
                default:
                  return SizedBox(height: 0);
              }
            }),
          ):


          Column(children: <Widget>[

          StickyHeader(header:
            Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).accentColor,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(5),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  S.of(context).subscription_ended_msg,
                  style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                ),
              ),
            ),
              content:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: List.generate(settingsRepo.setting.value.homeSections.length, (index) {
                  String _homeSection = settingsRepo.setting.value.homeSections.elementAt(index);
                  switch (_homeSection) {
                    case 'slider':
                      return Column(children: <Widget>[
                        HomeSliderWidget(slides: _con.slides),

                        Padding(padding:EdgeInsets.all(10),child:
                        Container(child:
                        Column(children: <Widget>[


                          Container(height: 250,child:  Stack(
//        fit: StackFit.expand,
                            alignment: AlignmentDirectional.bottomStart,
                            children: <Widget>[
                              cameraPosition == null
                                  ? CircularLoadingWidget(height: 0)
                                  : GoogleMap(
                                mapToolbarEnabled: false,
                                mapType: MapType.normal,
                                initialCameraPosition: cameraPosition,
                                markers: Set.from(allMarkers),
                                onMapCreated: (GoogleMapController controller) {
                                  mapController.complete(controller);
                                },
                                onCameraMove: (CameraPosition cameraPosition) {
                                  cameraPosition = cameraPosition;
                                },
                                onCameraIdle: () {
                                  getRestaurantsOfArea();
                                },
                                polylines: polylines,
                              ),

                            ],
                          ),
                          ),
                          Padding(padding:EdgeInsets.all(10),child:Row(children: <Widget>[Text(
                              S.of(context).nearby_services+
                                  ' :',style:TextStyle(fontWeight: FontWeight.bold))],)),
                          CardsCarouselWidget(
                            restaurantsList: topRestaurants,
                            heroTag: 'map_restaurants',
                          ),],))),
                      ],)

                      ;
                    case 'search':
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SearchBarWidget(
                          onClickFilter: (event) {
                            widget.parentScaffoldKey.currentState.openEndDrawer();
                          },
                        ),
                      );
                    case 'top_restaurants_heading':
                      return Padding(
                        padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    S.of(context).top_restaurants,
                                    style: Theme.of(context).textTheme.headline4,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (currentUser.value.apiToken == null) {
                                      _con.requestForCurrentLocation(context);
                                    } else {
                                      var bottomSheetController = widget.parentScaffoldKey.currentState.showBottomSheet(
                                            (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                        ),
                                      );
                                      bottomSheetController.closed.then((value) {
                                        _con.refreshHome();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: settingsRepo.deliveryAddress.value?.address == null
                                          ? Theme.of(context).focusColor.withOpacity(0.1)
                                          : Theme.of(context).accentColor,
                                    ),
                                    child: Text(
                                      S.of(context).delivery,
                                      style: TextStyle(
                                          color:
                                          settingsRepo.deliveryAddress.value?.address == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 7),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      settingsRepo.deliveryAddress.value?.address = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: settingsRepo.deliveryAddress.value?.address != null
                                          ? Theme.of(context).focusColor.withOpacity(0.1)
                                          : Theme.of(context).accentColor,
                                    ),
                                    child: Text(
                                      S.of(context).pickup,
                                      style: TextStyle(
                                          color:
                                          settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (settingsRepo.deliveryAddress.value?.address != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  S.of(context).near_to + " " + (settingsRepo.deliveryAddress.value?.address),
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                          ],
                        ),
                      );
                    case 'top_restaurants':
                      return CardsCarouselWidget(restaurantsList: _con.topRestaurants, heroTag: 'home_top_restaurants',con: context);
                    case 'trending_week_heading':
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        leading: Icon(
                          Icons.trending_up,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).trending_this_week,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        subtitle: Text(
                          S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      );
                    case 'trending_week':
                      return FoodsCarouselWidget(foodsList: _con.trendingFoods, heroTag: 'home_food_carousel');
                    case 'categories_heading':
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            Icons.category,
                            color: Theme.of(context).hintColor,
                          ),
                          title: Text(
                            S.of(context).food_categories,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      );
                    case 'categories':
                      return CategoriesCarouselWidget(
                        categories: _con.categories,
                      );
                    case 'popular_heading':
                      return _con.popularRestaurants.length==0?Visibility(visible:false,child:Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            Icons.trending_up,
                            color: Theme.of(context).hintColor,
                          ),
                          title: Text(
                            S.of(context).most_popular,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      )):
                      Visibility(visible:true,child:Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            Icons.trending_up,
                            color: Theme.of(context).hintColor,
                          ),
                          title: Text(
                            S.of(context).most_popular,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      ));
                    case 'popular':
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridWidget(
                          restaurantsList: _con.popularRestaurants,
                          heroTag: 'home_restaurants',
                        ),
                      );
                    case 'recent_reviews_heading':
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                          leading: Icon(
                            Icons.recent_actors,
                            color: Theme.of(context).hintColor,
                          ),
                          title: Text(
                            S.of(context).recent_reviews,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      );
                    case 'recent_reviews':
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ReviewsListWidget(reviewsList: _con.recentReviews),
                      );
                    default:
                      return SizedBox(height: 0);
                  }
                }),
              ),),
          ],):
          currentUser.value.isEnded==true?
          Column(children: <Widget>[

            StickyHeader(header:  Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).canvasColor,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(5),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  S.of(context).account_not_active_msg,
                  style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                ),
              )
            ),content:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: List.generate(settingsRepo.setting.value.homeSections.length, (index) {
                String _homeSection = settingsRepo.setting.value.homeSections.elementAt(index);
                switch (_homeSection) {
                  case 'slider':
                    return Column(children: <Widget>[
                      HomeSliderWidget(slides: _con.slides),

                      Padding(padding:EdgeInsets.all(10),child:
                      Container(child:
                      Column(children: <Widget>[


                        Container(height: 250,child:  Stack(
//        fit: StackFit.expand,
                          alignment: AlignmentDirectional.bottomStart,
                          children: <Widget>[
                            cameraPosition == null
                                ? CircularLoadingWidget(height: 0)
                                : GoogleMap(
                              mapToolbarEnabled: false,
                              mapType: MapType.normal,
                              initialCameraPosition: cameraPosition,
                              markers: Set.from(allMarkers),
                              onMapCreated: (GoogleMapController controller) {
                                mapController.complete(controller);
                              },
                              onCameraMove: (CameraPosition cameraPosition) {
                                cameraPosition = cameraPosition;
                              },
                              onCameraIdle: () {
                                getRestaurantsOfArea();
                              },
                              polylines: polylines,
                            ),

                          ],
                        ),
                        ),
                        Padding(padding:EdgeInsets.all(10),child:Row(children: <Widget>[Text(
                            S.of(context).nearby_services+
                                ' :',style:TextStyle(fontWeight: FontWeight.bold))],)),
                        CardsCarouselWidget(
                          restaurantsList: topRestaurants,
                          heroTag: 'map_restaurants',
                        ),],))),
                    ],)

                    ;
                  case 'search':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SearchBarWidget(
                        onClickFilter: (event) {
                          widget.parentScaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                    );
                  case 'top_restaurants_heading':
                    return Padding(
                      padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  S.of(context).top_restaurants,
                                  style: Theme.of(context).textTheme.headline4,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (currentUser.value.apiToken == null) {
                                    _con.requestForCurrentLocation(context);
                                  } else {
                                    var bottomSheetController = widget.parentScaffoldKey.currentState.showBottomSheet(
                                          (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                      ),
                                    );
                                    bottomSheetController.closed.then((value) {
                                      _con.refreshHome();
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    color: settingsRepo.deliveryAddress.value?.address == null
                                        ? Theme.of(context).focusColor.withOpacity(0.1)
                                        : Theme.of(context).accentColor,
                                  ),
                                  child: Text(
                                    S.of(context).delivery,
                                    style: TextStyle(
                                        color:
                                        settingsRepo.deliveryAddress.value?.address == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              SizedBox(width: 7),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    settingsRepo.deliveryAddress.value?.address = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    color: settingsRepo.deliveryAddress.value?.address != null
                                        ? Theme.of(context).focusColor.withOpacity(0.1)
                                        : Theme.of(context).accentColor,
                                  ),
                                  child: Text(
                                    S.of(context).pickup,
                                    style: TextStyle(
                                        color:
                                        settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (settingsRepo.deliveryAddress.value?.address != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                S.of(context).near_to + " " + (settingsRepo.deliveryAddress.value?.address),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                        ],
                      ),
                    );
                  case 'top_restaurants':
                    return CardsCarouselWidget(
                        restaurantsList: _con.topRestaurants,
                        heroTag: 'home_top_restaurants',con: context);
                  case 'trending_week_heading':
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).trending_this_week,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                        S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  case 'trending_week':
                    return FoodsCarouselWidget(foodsList: _con.trendingFoods, heroTag: 'home_food_carousel');
                  case 'categories_heading':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.category,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).food_categories,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    );
                  case 'categories':
                    return CategoriesCarouselWidget(
                      categories: _con.categories,
                    );
                  case 'popular_heading':
                    return _con.popularRestaurants.length==0?Visibility(visible:false,child:Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.trending_up,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).most_popular,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    )):
                    Visibility(visible:true,child:Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.trending_up,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).most_popular,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ));
                  case 'popular':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridWidget(
                        restaurantsList: _con.popularRestaurants,
                        heroTag: 'home_restaurants',
                      ),
                    );
                  case 'recent_reviews_heading':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        leading: Icon(
                          Icons.recent_actors,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).recent_reviews,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    );
                  case 'recent_reviews':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ReviewsListWidget(reviewsList: _con.recentReviews),
                    );
                  default:
                    return SizedBox(height: 0);
                }
              }),
            ),),


          ],):


          Column(children: <Widget>[

            StickyHeader(header:  Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).accentColor,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(5),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  S.of(context).subscription_ended_msg,
                  style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                ),
              ),
            ),content:     StickyHeader(header:  Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).unselectedWidgetColor,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(5),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  S.of(context).account_not_active_msg,
                  style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                ),
              )
            ),content:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: List.generate(settingsRepo.setting.value.homeSections.length, (index) {
                String _homeSection = settingsRepo.setting.value.homeSections.elementAt(index);
                switch (_homeSection) {
                  case 'slider':
                    return Column(children: <Widget>[
                      HomeSliderWidget(slides: _con.slides),

                      Padding(padding:EdgeInsets.all(10),child:
                      Container(child:
                      Column(children: <Widget>[


                        Container(height: 250,child:  Stack(
//        fit: StackFit.expand,
                          alignment: AlignmentDirectional.bottomStart,
                          children: <Widget>[
                            cameraPosition == null
                                ? CircularLoadingWidget(height: 0)
                                : GoogleMap(
                              mapToolbarEnabled: false,
                              mapType: MapType.normal,
                              initialCameraPosition: cameraPosition,
                              markers: Set.from(allMarkers),
                              onMapCreated: (GoogleMapController controller) {
                                mapController.complete(controller);
                              },
                              onCameraMove: (CameraPosition cameraPosition) {
                                cameraPosition = cameraPosition;
                              },
                              onCameraIdle: () {
                                getRestaurantsOfArea();
                              },
                              polylines: polylines,
                            ),

                          ],
                        ),
                        ),
                        Padding(padding:EdgeInsets.all(10),child:Row(children: <Widget>[Text(
                            S.of(context).nearby_services+
                                ' :',style:TextStyle(fontWeight: FontWeight.bold))],)),
                        CardsCarouselWidget(
                          restaurantsList: topRestaurants,
                          heroTag: 'map_restaurants',
                        ),],))),
                    ],)

                    ;
                  case 'search':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SearchBarWidget(
                        onClickFilter: (event) {
                          widget.parentScaffoldKey.currentState.openEndDrawer();
                        },
                      ),
                    );
                  case 'top_restaurants_heading':
                    return Padding(
                      padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  S.of(context).top_restaurants,
                                  style: Theme.of(context).textTheme.headline4,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (currentUser.value.apiToken == null) {
                                    _con.requestForCurrentLocation(context);
                                  } else {
                                    var bottomSheetController = widget.parentScaffoldKey.currentState.showBottomSheet(
                                          (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                      ),
                                    );
                                    bottomSheetController.closed.then((value) {
                                      _con.refreshHome();
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    color: settingsRepo.deliveryAddress.value?.address == null
                                        ? Theme.of(context).focusColor.withOpacity(0.1)
                                        : Theme.of(context).accentColor,
                                  ),
                                  child: Text(
                                    S.of(context).delivery,
                                    style: TextStyle(
                                        color:
                                        settingsRepo.deliveryAddress.value?.address == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              SizedBox(width: 7),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    settingsRepo.deliveryAddress.value?.address = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    color: settingsRepo.deliveryAddress.value?.address != null
                                        ? Theme.of(context).focusColor.withOpacity(0.1)
                                        : Theme.of(context).accentColor,
                                  ),
                                  child: Text(
                                    S.of(context).pickup,
                                    style: TextStyle(
                                        color:
                                        settingsRepo.deliveryAddress.value?.address != null ? Theme.of(context).hintColor : Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (settingsRepo.deliveryAddress.value?.address != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                S.of(context).near_to + " " + (settingsRepo.deliveryAddress.value?.address),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                        ],
                      ),
                    );
                  case 'top_restaurants':
                    return CardsCarouselWidget(restaurantsList: _con.topRestaurants, heroTag: 'home_top_restaurants',con: context);
                  case 'trending_week_heading':
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).trending_this_week,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                        S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  case 'trending_week':
                    return FoodsCarouselWidget(foodsList: _con.trendingFoods, heroTag: 'home_food_carousel');
                  case 'categories_heading':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.category,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).food_categories,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    );
                  case 'categories':
                    return CategoriesCarouselWidget(
                      categories: _con.categories,
                    );
                  case 'popular_heading':
                    return _con.popularRestaurants.length==0?Visibility(visible:false,child:Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.trending_up,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).most_popular,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    )):
                    Visibility(visible:true,child:Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.trending_up,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).most_popular,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ));
                  case 'popular':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridWidget(
                        restaurantsList: _con.popularRestaurants,
                        heroTag: 'home_restaurants',
                      ),
                    );
                  case 'recent_reviews_heading':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        leading: Icon(
                          Icons.recent_actors,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          S.of(context).recent_reviews,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    );
                  case 'recent_reviews':
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ReviewsListWidget(reviewsList: _con.recentReviews),
                    );
                  default:
                    return SizedBox(height: 0);
                }
              }),
            ),),),


          ],),
        ),
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
      setState(() {print(
          scanResult.rawContent);
      scanResult = result;});
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        //  format: BarcodeFormat.unknown,
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