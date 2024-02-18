import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

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
  ui.Image? image;
  ByteData? imageBytes;
  bool isChoose = false;
  bool isOK = false;
  int statuscode = 0;
  XFile? file ;
  String encodedString = '';

  final url =
      'https://api.online-ijara.uz/web/v1/public/files/upload/category/photos';

  pickImage() async {
    final ImagePicker imagepicker = ImagePicker();
    var pickedFile = await imagepicker.pickImage(source: ImageSource.gallery);


    if (pickedFile == null) {
      pickImage();
    }

    print('image picked');
    setState(() {
      imagePath = pickedFile!.path;
      file = pickedFile;
    });
    return imagePath;
  }

   imageToBase64String(XFile file) async {
    String imagePath = file.path;
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();
    String base64String = base64.encode(imageBytes);
    print('image encoded to string');
    print(base64String);
    setState(() {
      encodedString = base64String;
    });

  }



 base64StringToImage(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      print('string converted to image');
      setState(() {
        image =  frameInfo.image;
      });
     

    } catch (error) {
      print('Error converting base64 string to image: $error');
      return null;
    }
  }
  sendConvertedImageToServer(String url, ByteData imageBytes)async{
    final url = 'https://your-server/upload-image';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['description'] = 'My awesome image'; // Optional additional fields

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes.buffer.asUint8List(),
        // Replace with actual image type
      ),
    );

    final response = await request.send();
    print(response.statusCode);
  }


  sendImageToServer(String url, String imagePath) async {
    final imageFile = File(imagePath);

    final request = http.MultipartRequest('POST', Uri.parse(url));

    final imageMultipartFile =
        await http.MultipartFile.fromPath('file', imagePath);
    request.files.add(imageMultipartFile);

    final response = await request.send();
    if (response.statusCode == 200) {
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
            ElevatedButton(onPressed: ()async{
              imagePath = pickImage();
            }, child: Text('Pick image')),
            ElevatedButton(onPressed: (){
              sendImageToServer(url, imagePath);
              print(imagePath);
            }, child: Text('Post image')),
            ElevatedButton(onPressed: (){
            imageToBase64String(file!);
            }, child: Text('Convert image to string')),
            ElevatedButton(onPressed: ()async{
              base64StringToImage(encodedString);
               imageBytes =await  image?.toByteData(format: ui.ImageByteFormat.png);


            }, child: Text('Convert string to image')),
            ElevatedButton(onPressed: ()async{
             await  sendConvertedImageToServer(url, imageBytes!);
            }, child: Text('Post converted image')),
          ],
        ),
      ),
    );
  }
}
