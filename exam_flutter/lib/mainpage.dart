import 'package:exam_flutter/writeArticle.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<String> displayedPosts = [];
  List<String> displayedPostId = [];
  int currentPage = 0;
  final int postsPerPage = 9;
  bool isLoading = false;
  bool hasMore = true;
  String temperature = '';
  String humidity = '';

  @override
  void initState() {
    super.initState();
    _getWeather();
    _loadMorePosts();
  }

  Future<void> _getWeather() async {
    try {
      String dayValue = DateTime.now().toString();
      String year = dayValue.substring(0, 4);
      String month = dayValue.substring(5, 7);
      String day = dayValue.substring(8, 10);
      String today = year + month + day;
      String time = DateTime.now().toString();
      String hour = time.substring(11, 13);
      String minute = time.substring(14, 15);
      minute += '0';
      String now = hour + minute; 
      String url = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=%2B8aTLhoKPaPMuDqlPKRrcEEonjDzS0WkW4EX4Yw3sCC7AGKM%2FmTHQRYjTfhLEamD%2FtG40moxUbI3jPFLVQ%2FwnA%3D%3D&pageNo=1&numOfRows=10&dataType=JSON&base_date=";
      url += today;
      url += '&base_time=';
      url += now;
      url += '&nx=67&ny=100';
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        setState(() {
          temperature = response.data['response']['body']['items']['item'][3]['obsrValue'].toString();
          humidity = response.data['response']['body']['items']['item'][1]['obsrValue'].toString();
        });
        print('Temperature: $temperature, Humidity: $humidity');
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (error) {
      print('Error fetching weather: $error');
    }
  }

  Future<void> _loadMorePosts() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await Dio().get(
        'http://localhost:8080/posts',
        queryParameters: {
          'page': currentPage,
          'size': postsPerPage,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> newPosts = response.data['content'];
        List<String> newPostTitles = newPosts.map((post) => post['title'].toString()).toList();
        List<String> newPostId = newPosts.map((post) => post['id'].toString()).toList();

        setState(() {
          displayedPosts.addAll(newPostTitles);
          displayedPostId.addAll(newPostId);
          currentPage++;
          isLoading = false;
          hasMore = newPosts.length == postsPerPage;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void writeArticle() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WriteArticle(id: "-1", temperature: "", humidity: "")));
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
      ),
      body: Column(
        children: [
          if (screenWidth > 600)
            Row(
              children: [
                const SizedBox(width: 100),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TestPage()));
                  },
                  child: const Text('logo', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 100),
                Text(
                  '기온 : $temperature  습도 : $humidity', 
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 100),
                TextButton(
                  onPressed: writeArticle,
                  child: const Text('글작성'),
                ),
                const SizedBox(width: 10),
                const Text('로그인'),
                const SizedBox(width: 10),
                const Text('로그아웃'),
                const SizedBox(width: 10),
              ],
            )
          else
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TestPage()));
                  },
                  child: const Text('logo', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Text(
                  '기온 : $temperature, 습도 : $humidity', 
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: writeArticle,
                  child: const Text('글작성'),
                ),
                const SizedBox(width: 10),
                const Text('로그인'),
                const SizedBox(width: 10),
                const Text('로그아웃'),
                const SizedBox(width: 10),
              ],
            ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading && 
                    hasMore && 
                    scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  _loadMorePosts();
                  return true;
                }
                return false;
              },
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 3 : 1,
                ),
                itemCount: displayedPosts.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < displayedPosts.length) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WriteArticle(id: displayedPostId[index], temperature: temperature, humidity: humidity)));
                      },
                      child: Card(
                        child: Center(
                          child: Text(displayedPosts[index]),
                        ),
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
