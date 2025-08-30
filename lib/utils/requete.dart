import 'dart:convert';
import 'package:get/get.dart' as g;
import 'package:http/http.dart' as http;

class Requete extends g.GetConnect {
  static String url = "http://192.168.11.106:8080";
  Future<http.Response> getE(String path) async {
    var response = await http.get(Uri.parse("$url/$path"));
    return response;
  }

  Future<http.Response> getEe(String path, String token) async {
    var response = await http.get(
      Uri.parse("$url/$path"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    return response;
  }

  Future<http.Response> postE(String path, var e) async {
    var response = await http.post(
      Uri.parse("$url/$path"),
      body: json.encode(e),
      headers: {"Accept": "*/*", "Content-Type": "application/json"},
    );
    //
    //var response = await post("$url/$path", e,
    // headers: {"Content-Type": "application/json"},
    //  headers: {"Accept": "*/*", "Content-Type": "application/json"});
    return response;
  }

  Future<http.Response> putE(String path, Map e) async {
    //print(await http.read(Uri.https('$url/$path', 'foobar.txt')));
    print('e: $e');

    var response = await http.put(
      Uri.parse("$url/$path"),
      headers: {"Accept": "*/*", "Content-Type": "application/json"},
      body: json.encode(e),
    );
    return response;
  }

  Future<http.Response> deleteE(String path) async {
    //var url = Uri.parse("${Connexion.lien}$path");
    var response = await http.delete(Uri.parse("$url/$path"));
    //print(await http.read(Uri.https('example.com', 'foobar.txt')));
    return response;
  }
}
