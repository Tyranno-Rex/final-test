import 'dart:ui';

import 'package:exam_flutter/mainpage.dart';
import 'package:exam_flutter/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';


class WriteArticle extends StatefulWidget {
  final String id;
  final String temperature;
  final String humidity;
  const WriteArticle({super.key, required this.id, required this.temperature, required this.humidity});
  
  @override
  State<WriteArticle> createState() => _WriteArticleState();
}

class _WriteArticleState extends State<WriteArticle> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  
  @override
  void initState() {
    if (widget.id != "-1") {
      fetchArticle(widget.id);
    }
  }

  void fetchArticle(id) {
    Dio dio = Dio();
    if (id == "-1") {
      return;
    }
    dio.get('http://localhost:8080/getPost', 
      queryParameters: {
        'id': id,
      },
    ).then((response) {
      print(response);
      Map<String, dynamic> article = jsonDecode(response.toString());
      titleController.text = article['title'];
      contentController.text = article['content'];
    }).catchError((error) {
      print(error);
    });
  }

  void writeArticle(title, content) {
    Dio dio = Dio();


    if (widget.id == "-1") {
      dio.post('http://localhost:8080/posts', 
        data: {
          'title': title,
          'content': content,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      ).then((response) {
        print(response);
      }).catchError((error) {
        print(error);
      });
    }
    else {
      dio.put('http://localhost:8080/posts', 
        data: {
          'id': widget.id,
          'title': title,
          'content': content,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      ).then((response) {
        print(response);
      }).catchError((error) {
        print(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row (
              children: [
                const SizedBox(width: 100,),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TestPage()));
                  },
                  child: const Text('logo', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 100,),
                Text(
                  '기온 : ${widget.temperature}, 습도 : ${widget.humidity}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 100,),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WriteArticle(id: "-1", temperature: widget.temperature, humidity: widget.humidity)));
                  },
                  child: const Text('글작성'),
                ),
                const SizedBox(width: 10,),
                TextButton(
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                  },
                  child: const Text('로그인'),
                ),
                const SizedBox(width: 10,),
                TextButton(
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const Logout()));
                  },
                  child: const Text('로그아웃'),
                ),
              ],
            ),
            // 선 추가
            const SizedBox(height: 10),
            const Divider(
              height: 20,
              thickness: 5,
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            const Text(
              '글쓰기',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 500, // 원하는 너비
              height: 50, // 원하는 높이 (여기서 높이를 조정)
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '제목',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 500, // 원하는 너비
              height: 500, // 원하는 높이 (여기서 높이를 조정)
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '내용',
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15), // 내부 여백 조정
                ),
                maxLines: null, // 텍스트 필드가 여러 줄을 지원하도록 설정
              ),
            ),


            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                writeArticle(titleController.text, contentController.text);
                titleController.clear();
                contentController.clear();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TestPage()));
              },
              child: const Text('글쓰기'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TestPage()));
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (widget.id == "-1") {
                  return;
                }
                Dio dio = Dio();
                dio.delete('http://localhost:8080/posts', 
                  queryParameters: {
                    'id': widget.id,
                  },
                ).then((response) {
                  print(response);
                }).catchError((error) {
                  print(error);
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TestPage()));
              },
              child: const Text('삭제'),
            ),

          ],
        ),
      ),
    );
  }
}