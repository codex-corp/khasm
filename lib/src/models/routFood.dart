class RouteArgumentFood {
  String id;
  String heroTag;
  dynamic param;
  String rede;
  String smiA;

  RouteArgumentFood({this.id, this.heroTag, this.param,this.rede,this.smiA});

  @override
  String toString() {
    return '{id: $id, heroTag:${heroTag.toString()}}';
  }
}
