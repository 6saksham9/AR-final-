import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class MultipleAugmentedImagesPage extends StatefulWidget {
  @override
  _MultipleAugmentedImagesPageState createState() =>
      _MultipleAugmentedImagesPageState();
}

class _MultipleAugmentedImagesPageState
    extends State<MultipleAugmentedImagesPage> {
  ArCoreController? arCoreController;
  Map<String, ArCoreAugmentedImage> augmentedImagesMap = Map();
  Map<String, Uint8List> bytesMap = Map();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AR IMAGE'),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          type: ArCoreViewType.AUGMENTEDIMAGES,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    arCoreController?.onTrackingImage = _handleOnTrackingImage;
    loadSphere();
    loadMultipleImage();
  }

  void loadSphere() async {
    final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');
    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      textureBytes: textureBytes.buffer.asUint8List(),
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1, // Adjust the radius as needed
    );
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0.0, 0.0, -1.0), // Adjust the position as needed
    );

    arCoreController?.addArCoreNode(node);
  }

  final imageUrl1 =
      'https://fastly.picsum.photos/id/237/200/300.jpg?hmac=TmmQSbShHz9CdQm0NkEjx1Dyh_Y984R9LpNrpvH2D_U';

  loadMultipleImage() async {
    print('load tracked');

    final ByteData bytes1 =
        await rootBundle.load('assets/earth_augmented_image.jpg');
    final ByteData bytes2 = await rootBundle.load('assets/prova_texture.png');
    final bytesFromNetwork1 = await _getBytesFromNetwork(imageUrl1);

    final ByteData bytes3 = await rootBundle.load('assets/umano_digitale.png');
    bytesMap["earth_augmented_image"] = bytes1.buffer.asUint8List();
    bytesMap["prova_texture"] = bytes2.buffer.asUint8List();
    bytesMap["umano_digitale"] = bytes3.buffer.asUint8List();
    bytesMap['test'] = bytesFromNetwork1;
    arCoreController?.loadMultipleAugmentedImage(bytesMap: bytesMap);

    print('load tracked completed');
  }

  Future<Uint8List> _getBytesFromNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image from network');
    }
  }

  _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
    print('image tracked');
    if (!augmentedImagesMap.containsKey(augmentedImage.name)) {
      print(augmentedImage.name);
      print(augmentedImage.index);

      augmentedImagesMap[augmentedImage.name] = augmentedImage;
      switch (augmentedImage.name) {
        case "earth_augmented_image":
          _addSphere(augmentedImage);
          break;
        case "prova_texture":
          _addCube(augmentedImage);
          break;
        case "umano_digitale":
          _addCylindre(augmentedImage);
          break;

        case 'test':
          _addSphere(augmentedImage);
          break;
      }
    }
  }

  // loadMultipleImage() async {
  //   print('load tracked');
  //   final ByteData bytes1 =
  //       await rootBundle.load('assets/earth_augmented_image.jpg');
  //   final ByteData bytes2 = await rootBundle.load('assets/prova_texture.png');
  //   final ByteData bytes3 = await rootBundle.load('assets/umano_digitale.png');
  //   bytesMap["earth_augmented_image"] = bytes1.buffer.asUint8List();
  //   bytesMap["prova_texture"] = bytes2.buffer.asUint8List();
  //   bytesMap["umano_digitale"] = bytes3.buffer.asUint8List();

  //   arCoreController?.loadMultipleAugmentedImage(bytesMap: bytesMap);
  // }

  // _handleOnTrackingImage(ArCoreAugmentedImage augmentedImage) {
  //   print('image tracked');
  //   if (!augmentedImagesMap.containsKey(augmentedImage.name)) {
  //     augmentedImagesMap[augmentedImage.name] = augmentedImage;
  //     switch (augmentedImage.name) {
  //       case "earth_augmented_image":
  //         _addSphere(augmentedImage);
  //         break;
  //       case "prova_texture":
  //         _addCube(augmentedImage);
  //         break;
  //       case "umano_digitale":
  //         _addCylindre(augmentedImage);
  //         break;
  //     }
  //   }
  // }

  // Future _addSphere(ArCoreAugmentedImage augmentedImage) async {
  //   print('calling sphere');
  //   final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');
  //
  //   final material = ArCoreMaterial(
  //     color: Color.fromARGB(120, 66, 134, 244),
  //     textureBytes: textureBytes.buffer.asUint8List(),
  //   );
  //   final sphere = ArCoreSphere(
  //     materials: [material],
  //     radius: augmentedImage.extentX / 2,
  //   );
  //   final node = ArCoreNode(
  //     shape: sphere,
  //   );
  //
  //   // final moon = ArCoreNode(
  //   //  children: [
  //   //    ArCoreReferenceNode(
  //   //      name: 'MyModel',
  //   //      objectUrl: 'https://mhappstorage.blob.core.windows.net/monkhubhr/section/soldier1/soldier.glb',
  //   //    ),
  //   //  ],
  //   //   position: vector.Vector3(0.2, 0, 0),
  //   //   rotation: vector.Vector4(0, 0, 0, 0),
  //   // );
  //
  //   arCoreController?.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  // }
  Future _addSphere(ArCoreAugmentedImage augmentedImage) async {
    print('url called');
    // final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');
    //
    // final material = ArCoreMaterial(
    //   color: Color.fromARGB(120, 66, 134, 244),
    //   textureBytes: textureBytes.buffer.asUint8List(),
    // );
    // final sphere = ArCoreSphere(
    //   materials: [material],
    //   radius: augmentedImage.extentX / 2,
    // );
    // final node = ArCoreNode(
    //   shape: sphere,
    // );

    final moon = ArCoreReferenceNode(
      name: 'MyModel',
      objectUrl:
          'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb',
      scale: vector.Vector3(0.1, 0.1, 0.1),
    );

    arCoreController?.addArCoreNodeToAugmentedImage(moon, augmentedImage.index);
  }

  void _addCube(ArCoreAugmentedImage augmentedImage) {
    double size = augmentedImage.extentX / 2;
    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(size, size, size),
    );
    final node = ArCoreNode(
      shape: cube,
    );
    arCoreController?.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  void _addCylindre(ArCoreAugmentedImage augmentedImage) {
    final material = ArCoreMaterial(
      color: Colors.red,
      reflectance: 1.0,
    );
    final cylindre = ArCoreCylinder(
      materials: [material],
      radius: augmentedImage.extentX / 2,
      height: augmentedImage.extentX / 3,
    );
    final node = ArCoreNode(
      shape: cylindre,
    );
    arCoreController?.addArCoreNodeToAugmentedImage(node, augmentedImage.index);
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}
