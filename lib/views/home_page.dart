import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String imagePath = '';
  bool isChoose = false;
  bool isOK = false;
  int statuscode = 0;
  final url = 'https://api.online-ijara.uz/web/v1/public/files/upload/category/photos';



  pickImage()async{
    final ImagePicker imagepicker = ImagePicker();
    var pickedFile = await imagepicker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      imagePath = pickedFile.path;
      setState(() {
        isChoose = true;
      });
    }

  }
  sendImageToServer(String url, String imagePath)async{
    final imageFile = File(imagePath);

    final request = http.MultipartRequest('POST', Uri.parse(url));


    final imageMultipartFile = await http.MultipartFile.fromPath('file', imagePath);
    request.files.add(imageMultipartFile);

    


    final response = await request.send();
    if(response.statusCode==200){
      setState(() {
        isOK = true;
      });
      statuscode = response.statusCode;
    }

    print('${response.statusCode}');

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Sending post request'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isOK?Text('Image send succesfully, status code 200'):Text('Status code is:$statuscode'),
            SizedBox(height: 30),
            isChoose?Container(
              width: 200,
              height: 100,
              child: Image.file(File(imagePath),fit: BoxFit.cover,),
            ):Container(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: ()async{
                pickImage();
              },
              child: Text('Pick image'),
            ),
            ElevatedButton(
              onPressed: ()async{
                sendImageToServer(url, imagePath);
              },
              child: Text('Post image'),
            ),
          ],
        ),
      ),
    );
  }
}
