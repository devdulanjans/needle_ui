import '../auth_controller.dart';

String imagePathSetter({String? requestingImageType, String? imageSize = "FULL", String? imageName, String? setUserId}){
  String s3BucketUrl = "https://ms3-needle.blr1.cdn.digitaloceanspaces.com";
  var userId = setUserId != null ? setUserId:1; //: await getUserId();
  var imageS3BucketUrl = "${s3BucketUrl}/${userId}/${requestingImageType}/${imageSize}/${imageName}"; //https://ms3-needle.blr1.cdn.digitaloceanspaces.com/2/PAGEPOST/FULL/20250128211933.jpg
  return imageS3BucketUrl;
}