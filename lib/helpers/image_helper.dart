import 'dart:convert';
import 'dart:io';

Future<String> imageToBase64(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);
  return 'data:image/jpeg;base64,$base64Image';
}
