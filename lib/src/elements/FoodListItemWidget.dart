import 'package:food_delivery_app/src/repository/user_repository.dart';

import '../../generated/l10n.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class FoodListItemWidget extends StatelessWidget {
  String heroTag;
  Food food;
  String catId;

  FoodListItemWidget({Key key, this.heroTag, this.food, this.catId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        if (food.rede == 1) {
          if (currentUser.value.totals == "null") {
            showDialog(context: context, builder: (_) => showdd(context));
          } else {
            if (int.parse(currentUser.value.totals) >= int.parse(food.smileb)) {
            } else {
              showDialog(context: context, builder: (_) => showdd(context));
            }
          }
        } else {
          Navigator.of(context).pushNamed('/FoodCat',
              arguments: new RouteArgument(
                  heroTag: this.heroTag, id: this.food.id, param: this.catId));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + food.id,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                      image: NetworkImage(food.image.thumb), fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          food.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          food.restaurant.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        food.rede == 1
                            ? Visibility(
                                visible: true,
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFFFB24D),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.emoji_emotions_rounded,
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                  child: Text(
                                                    food.smileb,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  padding: EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0))
                                            ],
                                          ),
                                          Padding(
                                              child: Text(S.of(context).buy,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              padding: EdgeInsets.all(5))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Visibility(
                                visible: false,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFFFB24D),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.emoji_emotions_rounded,
                                                color: Color(0xFFFFB24D),
                                              ),
                                              Text('food.smileb')
                                            ],
                                          ),
                                          Padding(
                                            child: Text(
                                              S.of(context).buy,
                                            ),
                                            padding: EdgeInsets.all(3),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Helper.getPrice(food.price, context,
                      style: Theme.of(context).textTheme.headline4),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showdd(BuildContext context) {
    return AlertDialog(
      // contentPadding: EdgeInsets.zero,
      //insetPadding:  EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      //actionsPadding:  EdgeInsets.zero,
      //  buttonPadding:  EdgeInsets.zero,
      //  titlePadding:  EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(15, 15, 15, 25),
                  child: Text(
                    S.of(context).sorry,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: Colors.orange.withOpacity(0.2),
                                width: 1))),
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(S.of(context).yes,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))),
                        ),
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}