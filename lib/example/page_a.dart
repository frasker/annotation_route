import 'package:annotation_route/route.dart';

@ARoute(url: 'myapp://pagea')
class A {
  @Autowired(name: 'haha')
  final int a;
  String b;

  A({this.a});
}
