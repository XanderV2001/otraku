/*
Replaces _ with [blank_space] and makes each word
start with an upper case letter and continue with
lower case ones.
*/
import 'package:flutter/foundation.dart';

String clarifyEnum(String str) {
  return str.splitMapJoin(
    '_',
    onMatch: (_) => ' ',
    onNonMatch: (s) => s[0] + s.substring(1).toLowerCase(),
  );
}

/*
Transforms a string into enum. The string must be
as if it was acquired through "describeEnum()" (from the
foundation package) and the values must be the enum
values ex. "MyEnum.values"
*/
T stringToEnum<T>(String str, List<T> values) {
  return values.firstWhere((v) => describeEnum(v) == str, orElse: () => null);
}
