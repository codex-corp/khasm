import '../../generated/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class FoodItemWidget extends StatelessWidget {
  final String heroTag;
  final Food food;

  const FoodItemWidget({Key key, this.food, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
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
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      imageUrl: food.image.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    currentUser.value.apiToken == null
                        ? Visibility(
                            visible: true,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(40, 45, 10, 10),
                              child: Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : Visibility(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(40, 45, 10, 10),
                              child: Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                            ),
                            visible: false,
                          ),
                  ],
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
                        Row(
                          children: Helper.getStarsList(food.getRate()),
                        ),
                        Text(
                          food.extras.map((e) => e.name).toList().join(', '),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Helper.getPrice(
                        food.price,
                        context,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      food.discountPrice > 0
                          ? Helper.getPrice(food.discountPrice, context,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .merge(TextStyle(
                                      decoration: TextDecoration.lineThrough)))
                          : SizedBox(height: 0),
                      food.rede == 1
                          ? Visibility(
                              visible: true,
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
                                              color: Colors.white,
                                            ),
                                            Padding(
                                                child: Text(
                                                  food.smileA,
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
