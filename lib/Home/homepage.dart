import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/Api/apicall.dart';
import 'package:movie_app/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

import '../movieType/movies.dart';
import '../movieType/tvseries.dart';
import '../movieType/upcoming.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin{
  List<Map<String, dynamic>> trendinglist = [];
  int uval = 1;

  Future<void> trendlisthome() async {
    if (uval == 1){
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
    }else {
      var trendingdayresponse = await http.get(Uri.parse(trendingdayurl));
      if (trendingdayresponse.statusCode == 200) {
        var tempdata = jsonDecode(trendingdayresponse.body);
        var trendingdayjson = tempdata['results'];
        for (var i = 0; i < trendingdayjson.length; i++){
          trendinglist.add({
            'id' : trendingdayjson[i]['id'],
            'poster_path': trendingdayjson[i]['poster_path'],
            'vote_average': trendingdayjson[i]['vote_average'],
            'media_type': trendingdayjson[i]['media_type'],
            'indexno': i,
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length:3, vsync: this);

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
              Text("Trending" + "🔥",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 20.sp
                ),
              ),
              SizedBox(width: 1.w,),
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: DropdownButton(
                    dropdownColor: Colors.black54,
                      icon: Icon(Icons.arrow_downward_sharp, color: Colors.yellow,),
                      autofocus: true,
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                      items: [
                        DropdownMenuItem(
                            child: Text(
                              'Weekly',
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                    color: Colors.white,
                                fontSize: 16.sp
                              ),
                            ),
                          value: 1,
                        ),
                        DropdownMenuItem(
                            child: Text(
                              'Daily',
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                    color: Colors.white,
                                fontSize: 16.sp
                              ),
                            ),
                          value: 2,
                        ),
                      ],
                      onChanged: (value) {
                      setState(() {
                        trendinglist.clear();
                        uval = int.parse(value.toString());
                      });
                      },
                    value: uval,
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
              Material(
                color: Colors.black,
                child: Column(
                  children: [
                    Text("Sample text", style: TextStyle(color: Colors.white),),
                    Container(
                      height: 6.h,
                      child: TabBar(
                          physics: BouncingScrollPhysics(),
                          labelPadding: EdgeInsets.symmetric(horizontal: 5.w),
                          labelColor: Colors.white,
                          isScrollable: true,
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.yellow.withOpacity(0.4),
                          ),
                          tabs: [
                            Tab(child: Text("Tv Series")),
                            Tab(child: Text("Movies")),
                            Tab(child: Text("Upcoming")),
                          ]),
                    ),
                    Container(
                      child: TabBarView(
                        controller: _tabController,
                          children: [
                            TvSeries(),
                            Movies(),
                            Upcoming(),
                          ]
                      ),
                    ),
                  ],
                ),
              )
        ]))
      ]
    );
  }
}
