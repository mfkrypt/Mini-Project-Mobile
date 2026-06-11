String normalizeFloorPlanAssetPath(String? value) {
  final path = value?.trim().replaceAll('\\', '/');
  if (path == null || path.isEmpty) {
    return 'lib/image/Easy_book_logo.png';
  }

  final flutterAssetIndex = path.lastIndexOf('/flutter_assets/');
  if (flutterAssetIndex >= 0) {
    return path.substring(flutterAssetIndex + '/flutter_assets/'.length);
  }

  final imageDirIndex = path.lastIndexOf('/lib/image/');
  if (imageDirIndex >= 0) {
    return path.substring(imageDirIndex + 1);
  }

  final imgsDirIndex = path.lastIndexOf('/imgs/');
  if (imgsDirIndex >= 0) {
    return path.substring(imgsDirIndex + 1);
  }

  if (path.startsWith('lib/image/') || path.startsWith('imgs/')) {
    return path;
  }

  final fileName = path.split('/').last;
  if (fileName.toLowerCase() == 'easy_book_logo.png') {
    return 'lib/image/$fileName';
  }

  return 'imgs/$fileName';
}
