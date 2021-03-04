import 'package:food_delivery_app/src/repository/user_repository.dart';

import '../../generated/l10n.dart';
import 'package:flutter/material.dart';

import '../models/food.dart';
import '../models/route_argument.dart';

class FoodGridItemWidget extends StatefulWidget {
  final String heroTag;
  final Food food;
  final VoidCallback onPressed;
String catId;
  FoodGridItemWidget({Key key, this.heroTag, this.food, this.onPressed,this.catId}) : super(key: key);

  @override
  _FoodGridItemWidgetState createState() => _FoodGridItemWidgetState();
}

class _FoodGridItemWidgetState extends State<FoodGridItemWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      onTap: () {

        if(widget.food.rede==1){
          if(currentUser.value.totals=="null"){
            showDialog(context: context, builder: (_) => showdd(context));

          }else{
            if(int.parse(currentUser.value.totals)>= int.parse(widget.food.smileb)){

            }else{
              showDialog(context: context, builder: (_) => showdd(context));
            }
          }

        }
        else{
          Navigator.of(context).pushNamed('/FoodCat', arguments: new RouteArgument(heroTag: this.widget.heroTag, id: this.widget.food.id,param: this.widget.catId));

        }


      },
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: widget.heroTag + widget.food.id,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(this.widget.food.image.thumb), fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                widget.food.name,
                style: Theme.of(context).textTheme.bodyText1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                widget.food.restaurant.name,
                style: Theme.of(context).textTheme.caption,
                overflow: TextOverflow.ellipsis,
              ),
              widget.food.rede == 1
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
                                    widget.food.smileb,
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
        /*  Container(
            margin: EdgeInsets.all(10),
            width: 40,
            height: 40,
            child: FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                widget.onPressed();
              },
              child: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              color: Theme.of(context).accentColor.withOpacity(0.9),
              shape: StadiumBorder(),
            ),
          ),*/
        ],
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
                                color: Colors.orange
                                    .withOpacity(0.2),
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
