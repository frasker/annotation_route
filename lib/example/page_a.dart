import 'package:annotation_route/route.dart';

@ARoute(url: 'myapp://pagea')
class A {
  @Autowired(name: 'haha', defaultValue: 33)
  final int a;
  String b;

  A({this.a});
}
