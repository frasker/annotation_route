import 'package:annotation_route/route.dart';

@ARoute(url: 'myapp://pageb', params: {'parama': 'b'})
class B {
  int a;
  @Autowired(name: 'e')
  String b;
}
