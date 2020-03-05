import 'package:annotation_route/route.dart';

@ARoute(url: 'myapp://pagea')
class A {
  @Autowired(name: 'haha')
  int a;
  String b;
}
