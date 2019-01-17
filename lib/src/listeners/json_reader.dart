abstract class JsonReader<T> {
  void handleString(String value);

  void handleNumber(num value);

  void handleBool(bool value);

  void handleNull();

  void objectStart();

  void propertyName();

  void propertyValue();

  void objectEnd();

  void arrayStart();

  void arrayElement();

  void arrayEnd();

  T get result;
}
