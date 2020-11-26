import 'package:flutter/cupertino.dart';
import '../../generated/l10n.dart';
import 'package:flutter/material.dart';
import '../elements/SearchBarWidget.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';

class SubscriptionWidget extends StatefulWidget {
  @override
  _SubscriptionWidget createState() => _SubscriptionWidget();
}

class _SubscriptionWidget extends State<SubscriptionWidget> {
  User sibItem;
  GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    // sibItem = new User();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).sub,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new GestureDetector(
            child: Padding(
              child: Text('Packages'),
              padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
            ),
            onTap: () {
              Navigator.of(scaffoldKey.currentContext)
                  .pushReplacementNamed('/category');
            },
          ),
        ],
      ),
      body: currentUser.value.apiToken != null
          ? SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.subscriptions,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).your_sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      //  mainAxisAlignment: MainAxisAlignment.start,

                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            currentUser.value.subS.name,
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Row(
                              children: [
                                //    Icon(Icons.merge_type,color: Theme.of(context).accentColor),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Text(S.of(context).type + ' : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Text(currentUser.value.subS.subType)
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                            child: Row(
                              children: [
                                // Icon(Icons.merge_type,color: Theme.of(context).accentColor),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Text(
                                    S.of(context).startd + ' : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(currentUser.value.subS.startD)
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                            child: Row(
                              children: [
                                // Icon(Icons.merge_type,color: Theme.of(context).accentColor),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Text(
                                    S.of(context).endD + ' : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(currentUser.value.subS.endD)
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                            child: Row(
                              children: [
                                // Icon(Icons.merge_type,color: Theme.of(context).accentColor),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Text(
                                    S.of(context).statusS + ' : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                currentUser.value.isActive == true
                                    ? Text(
                                        S.of(context).active,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                      )
                                    : currentUser.value.isEnded == true
                                        ? Text(
                                            S.of(context).ended,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          )
                                        : currentUser.value.isTrail == true
                                            ? Text(
                                                S.of(context).trail,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange),
                                              )
                                            : Text('')
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }
}
