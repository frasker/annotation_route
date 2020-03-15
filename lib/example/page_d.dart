import 'package:annotation_route/route.dart';

@ARoute(alias: [
  ARouteAlias(url: 'myapp://paged', params: {'parama': 'd'})
])
class D {
  int a;
  @Autowired(name: 'b', defaultValue: 2.34)
  final double b;

  D({this.b});
}
