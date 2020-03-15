import 'dart:convert' hide JsonDecoder;

import 'package:analyzer/dart/element/element.dart';
import 'package:annotation_route/route.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'page_config_map_util.dart';

const TypeChecker autowiredChecker = TypeChecker.fromRuntime(Autowired);

class Collector {
  Collector();
  Map<String, List<Map<String, dynamic>>> routerMap =
      <String, List<Map<String, dynamic>>>{};

  Map<String, List<Map<String, dynamic>>> paramsMap =
  <String, List<Map<String, dynamic>>>{};

  List<String> importList = <String>[];

  Map<String, DartObject> toStringDartObjectMap(
      Map<DartObject, DartObject> map) {
    return map.map((DartObject k, DartObject v) {
      return MapEntry<String, DartObject>(k.toStringValue(), v);
    });
  }

  Map<String, String> toStringStringMap(Map<DartObject, DartObject> map) {
    return map.map((DartObject k, DartObject v) {
      return MapEntry<String, String>(k.toStringValue(), v.toStringValue());
    });
  }

  void collect(
      ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    final String className = element.name;
    final String url = annotation.peek('url')?.stringValue;
    if (url != null) {
      addEntryFromPageConfig(annotation, className);
    }
    final ConstantReader alias = annotation.peek('alias');
    if (alias != null) {
      final List<DartObject> aliasList = alias.listValue;
      final Function addEntry = (DartObject one) {
        final ConstantReader oneObj = ConstantReader(one);
        addEntryFromPageConfig(oneObj, className);
      };
      aliasList.forEach(addEntry);
    }

    if (buildStep.inputId.path.contains('lib/')) {
      print(buildStep.inputId.path);
      importClazz(
          "package:${buildStep.inputId.package}/${buildStep.inputId.path.replaceFirst('lib/', '')}");
    } else {
      importClazz("${buildStep.inputId.path}");
    }
    for (FieldElement field in (element as ClassElement).fields) {
      final autowiredAnnotation = autowiredChecker.firstAnnotationOf(field);
      if(autowiredAnnotation != null) {
        final autowired = ConstantReader(autowiredAnnotation);
        var name = autowired.peek('name')?.stringValue??field.name;
        var defaultValue = autowired.peek('defaultValue')?.literalValue;
        addParamFromPageConfig(className, name, defaultValue, field);
      }
    }
  }

  void addParam(String key, Map<String, dynamic> value) {
    List<Map<String, dynamic>> list = paramsMap[key];
    if (null == list) {
      list = <Map<String, dynamic>>[];
      paramsMap[key] = list;
    }
    list.add(value);
  }

  void addParamFromPageConfig(String className, String annotationName, dynamic defaultValue, FieldElement element) {
    if (annotationName != null) {
      final Map<String, dynamic> map = <String, dynamic>{element.name: {
        'name': annotationName,
        'defaultValue': defaultValue
      }};
      if (map != null) {
        addParam("'${className}'", map);
      }
    }
  }

  void addEntryFromPageConfig(ConstantReader reader, String className) {
    final String url = reader.peek('url')?.stringValue;
    if (url != null) {
      final Map<String, dynamic> map =
          genPageConfigFromConstantReader(reader, className);
      if (map != null) {
        addEntry("'${url}'", map);
      }
    }
  }

  Map<String, dynamic> genPageConfigFromConstantReader(
      ConstantReader reader, String className) {
    final ConstantReader params = reader.peek('params');
    final Map<String, dynamic> map = <String, dynamic>{wK('clazz'): className};
    if (params != null) {
      final Map<String, String> paramsMap = toStringStringMap(params.mapValue);
      map[wK('params')] = "${wK(json.encode(paramsMap))}";
    }
    return map;
  }

  void addEntry(String key, Map<String, dynamic> value) {
    List<Map<String, dynamic>> list = routerMap[key];
    if (null == list) {
      list = <Map<String, dynamic>>[];
      routerMap[key] = list;
    }
    list.add(value);
  }

  void importClazz(String path) {
    importList.add(path);
  }
}
