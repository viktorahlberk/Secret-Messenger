class Message {
  Message(
    this.key,
    this.sender,
    this.timestamp,
    this.content,
    this.messageType,
    this.readed,
  );
  String key;
  String sender;
  int timestamp;
  String content;
  String messageType;
  bool readed;
}
