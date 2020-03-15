import 'package:annotation_route/route.dart';

@ARoute(url: 'myapp://pageb', params: {'parama': 'b'})
class B {
  int a;
  @Autowired(name: 'e', defaultValue: "傻叉")
  final String b;

  B({this.b});
}
