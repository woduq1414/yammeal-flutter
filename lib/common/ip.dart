class Host {

  static const String herokuAddress = 'http://meal-backend.herokuapp.com/api';
  static const String localAddress = "http://192.168.21.1:5000/api";
  static const String vultrAddress = "https://yammeal.com/api";
}

String currentHost = Host.localAddress;