// 詳細評語頁面
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

//flag
bool dataLoadedFlag = false;

//資料庫data
List<String> resultAllMsg = []; //server 回傳的所有data，包含斷語。
String cropFace_points_string = ""; //全臉點圖String
Uint8List basicImgByte = Uint8List(10); //全臉點圖

class DetailResult extends StatefulWidget {
  const DetailResult({Key? key}) : super(key: key);

  @override
  _DetailResultState createState() => _DetailResultState();
}

class _DetailResultState extends State<DetailResult>
    with AutomaticKeepAliveClientMixin {
  bool firstGetResult_detail_flag = true;
  String account = '';
  //此頁面要用到之data

  String resultDetailMsg = '';
  //detail文字架構
  List<String> allDetailTitle = []; //allDetailTitle : 臉型、下巴型、脣型......
  List<String> allDetailTextOfTitle = []; //allDetailTitle的內文
  String detialResultText = ''; //斷語文本

  @override
  bool get wantKeepAlive => true;

  void getAllData() async {
    if (!firstGetResult_detail_flag) return;
    print('loading msg at detail');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    account = prefs.getString('account') ?? '';
    allDetailTitle = prefs.getStringList('allDetailTitle') ?? [];
    allDetailTextOfTitle = prefs.getStringList('allDetailTextOfTitle') ?? [];

    //擷取cropFace_points_string
    cropFace_points_string = prefs.getString('cropFace_points_string') ?? '';
    basicImgByte = base64Decode(
        cropFace_points_string); //將cropFace_points_string轉成byte，才能渲染於頁面
    dataLoadedFlag = true;

    if (firstGetResult_detail_flag) {
      if (mounted) {
        firstGetResult_detail_flag = false;
        setState(() {});
      } else {
        Future.delayed(const Duration(milliseconds: 100), getAllData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //初始化 firstGetResult_detail_flag 為true
    // bool firstGetResult_detail_flag = widget.firstGetResult_detail_flag;//初始化 firstGetResult_detail_flag 為true

    double screenWidth = MediaQuery.of(context).size.width; //抓取螢幕寬度
    double screenHeight = MediaQuery.of(context).size.height; //抓取螢幕高度

    // if(firstGetResult_detail_flag){
    //   getAllData();
    // }
    getAllData();
    // print(firstGetResult_detail_flag);

    return Scaffold(
        body: (dataLoadedFlag == false)
            ? Container()
            : Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black,
                width: screenWidth,
                height: screenHeight,
                child: Column(
                  children: [
                    //切割圖
                    Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Image.memory(
                              (basicImgByte),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        )),

                    Expanded(
                        flex: 1,
                        child: Text(
                          '長按斷語以複製到剪貼簿',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        )),
                    // //詳細內容
                    // Expanded(
                    //     flex: 5,
                    //     child: ListView.builder(
                    //         padding: new EdgeInsets.only(top: 10, bottom: 10),
                    //         itemBuilder: (context, index) => Container(
                    //                 child: Column(
                    //               children: [
                    //                 Container(
                    //                   width: screenWidth,
                    //                   child: Text(
                    //                     allDetailTitle[index].trim(),
                    //                     textAlign: TextAlign.start,
                    //                     style: TextStyle(
                    //                         color: Colors.yellow[300], fontSize: 25),
                    //                   ),
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 0,
                    //                 ),
                    //                 Container(
                    //                   width: screenWidth,
                    //                   child: Text(
                    //                     allDetailTextOfTitle[index].trim(),
                    //                     textAlign: TextAlign.start,
                    //                     style: const TextStyle(
                    //                         color: Colors.white, fontSize: 20),
                    //                   ),
                    //                 ),
                    //                 const SizedBox(

                    //                   height: 15,
                    //                 ),
                    //               ],
                    //             )),
                    //         itemCount: allDetailTitle.length)),
                    //詳細內容
                    Expanded(
                        flex: 6,
                        child: GestureDetector(
                            onLongPress: () {
                              print('已長按斷語，將斷語複製到剪貼簿');
                              for (int i = 0; i < allDetailTitle.length; i++) {
                                detialResultText +=
                                    '${allDetailTitle[i]}\n${allDetailTextOfTitle[i]}\n';
                              }
                              Clipboard.setData(
                                  ClipboardData(text: detialResultText));

                              setState(() {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      const AlertDialog(
                                    title: Text('斷語已複製剪貼簿'),
                                  ),
                                );
                              });
                            },
                            child: ListView.builder(
                                padding:
                                    new EdgeInsets.only(top: 10, bottom: 10),
                                itemBuilder: (context, index) => Container(
                                        child: Column(
                                      children: [
                                        Container(
                                          width: screenWidth,
                                          child: Text(
                                            allDetailTitle[index].trim(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: Colors.yellow[300],
                                                fontSize: 25),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 0,
                                        ),
                                        Container(
                                          width: screenWidth,
                                          child: Text(
                                            allDetailTextOfTitle[index].trim(),
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    )),
                                itemCount: allDetailTitle.length))),

                    //繼續按鈕
                  ],
                ),

                //繼續按鈕
              ));
  }
}
