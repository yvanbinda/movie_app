import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/Api/apicall.dart';
import 'package:movie_app/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> trendinglist = [];

  Future<void> trendlisthome() async {
    var trendingweekresponse = await http.get(Uri.parse(trendingweekurl));
    if (trendingweekresponse.statusCode == 200) {
      var tempdata = jsonDecode(trendingweekresponse.body);
      var trendingweekjson = tempdata['results'];
      for (var i = 0; i < trendingweekjson.length; i++){
        trendinglist.add({
          'id' : trendingweekjson[i]['id'],
          'poster_path': trendingweekjson[i]['poster_path'],
          'vote_average': trendingweekjson[i]['vote_average'],
          'media_type': trendingweekjson[i]['media_type'],
          'indexno': i,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers:[
        SliverAppBar(
          centerTitle: true,
          toolbarHeight: 60,
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.height * 0.5,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: FutureBuilder(
                future: trendlisthome(), builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done){
                    return CarouselSlider(
                      options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 2),
                        height: MediaQuery.of(context).size.height,
                      ),

                      items: trendinglist.map((i){
                        return Builder(builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              print("presses");
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.3),
                                    BlendMode.darken,
                                  ),
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                      'https://image.tmdb.org/t/p/w500${i['poster_path']}'
                                    )),
                              ),
                            ),
                          );
                        },);
                    }).toList(),
                    );

                  }else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                    );
                  }
                },),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Trending 🔥" + "🔥",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 20.sp
                ),
              ),
              SizedBox(width: 5.w,),
            ],
          ),
        ),
        SliverList(delegate: SliverChildListDelegate([
          Center(
            child: Text("Sample text"),
          )
        ]))
      ]
    );
  }
}
