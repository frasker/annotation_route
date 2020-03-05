import 'package:annotation_route/route.dart';
import 'router.route.internal.dart';

@ARouteRoot()
class Router {
  ARouterInternal internal = ARouterInternalImpl();
  dynamic getPage(String url, Map<String, dynamic> params) {
    return internal.findPage(ARouteOption(url, params), params);
  }
}
