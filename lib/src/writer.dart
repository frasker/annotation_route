import 'dart:math';

import 'package:mustache4dart/mustache4dart.dart';
import 'collector.dart';
import 'page_config_map_util.dart';
import 'tpl.dart';

class Writer {
  Collector collector;
  Writer(this.collector);

  String instanceCreated() {
    return instanceCreatedTpl;
  }

  String instanceFromClazz() {
    final StringBuffer buffer = new StringBuffer();
    buffer..writeln('switch(clazz) {');
    final Map<String, bool> mappedClazz = <String, bool>{};
    final Function writeClazzCase = (Map<String, dynamic> config) {
      final dynamic clazz = config[wK('clazz')];
      if (mappedClazz[clazz] == null) {
        mappedClazz[clazz] = true;
      } else {
        return;
      }
      String tmp = "${clazz}".toLowerCase();
      buffer.writeln("case ${clazz}: \n");
          final String key = '${clazz}';
          List<Map<String, dynamic>> map = collector.paramsMap[wK(key)];
          if((map?.length??0) == 0) {
            buffer.writeln("${clazz} ${tmp} = ${clazz}();");
          } else {
            buffer.writeln("${clazz} ${tmp} = ${clazz}(");
            if(map != null) {
              map.forEach((params){
                if(params != null) {
                  params.forEach((key, value){
                    final dynamic name = value['name'];
                    final dynamic defaultValue = value['defaultValue'];
                    if(defaultValue!=null && !(defaultValue is Symbol)) {
                      if(defaultValue is String) {
                        buffer.writeln("${key} :option[${wK(name)}]??\"${defaultValue.toString()}\",");
                      } else if(defaultValue is int) {
                        buffer.writeln("${key} :int.tryParse(option[${wK(name)}])??${defaultValue.toString()},");
                      } else if(defaultValue is double) {
                        buffer.writeln("${key} :double.tryParse(option[${wK(name)}])??${defaultValue.toString()},");
                      } else {
                        buffer.writeln("${key} :option[${wK(name)}]??${defaultValue.toString()},");
                      }
                    }else {
                      buffer.writeln("${key} :option[${wK(name)}],");
                    }
                  });
                }
              });
            }
            buffer.writeln(");");
          }
      buffer.writeln("return ${tmp};");
    };

    collector.routerMap
        .forEach((String url, List<Map<String, dynamic>> configList) {
      configList.forEach(writeClazzCase);
    });
    buffer..writeln('default:return null;')..writeln('}');
    return buffer.toString();
  }

  String write() {
    final List<Map<String, String>> refs = <Map<String, String>>[];
    final Function addRef = (String path) {
      refs.add(<String, String>{'path': path});
    };
    collector.importList.forEach(addRef);
    return render(clazzTpl, <String, dynamic>{
      'refs': refs,
      'instanceCreated': instanceCreated(),
      'instanceFromClazz': instanceFromClazz(),
      'routerMap': collector.routerMap.toString()
    });
  }
}
