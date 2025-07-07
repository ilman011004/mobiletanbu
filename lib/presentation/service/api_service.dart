import 'package:get/get.dart';

class ApiService extends GetConnect {
  Future<Response> getBestSellerListNames() async {
    const apiKey = 'ba2JAYrIZmG54KxxBiMvK57oVWtrNGBu';
    const url =
        'https://api.nytimes.com/svc/books/v3/lists/names.json?api-key=$apiKey';
    return get(url);
  }
}
