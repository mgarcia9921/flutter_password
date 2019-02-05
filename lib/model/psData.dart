import 'package:json_annotation/json_annotation.dart';

part 'psData.g.dart';

@JsonSerializable(nullable: false)
class PsItem {
	String id;
	String title;
  String account;
	String password;
	int status;
	DateTime createDate;
	DateTime modifyDate;
	PsItem({this.id, this.account, this.title, String password, int status, this.createDate, this.modifyDate})
      :this.status = status == null ? 0 : status,
       this.password = password == null ? '' : password;
	factory PsItem.fromJson(Map<String, dynamic> json) => _$PsItemFromJson(json);
	Map<String, dynamic> toJson() => _$PsItemToJson(this);
}


@JsonSerializable(nullable: false)
class PsData {
	String account;
	String id;
	List<PsItem> list;
	PsData({this.account,this.id,this.list});
	factory PsData.fromJson(Map<String, dynamic> json) => _$PsDataFromJson(json);
	Map<String, dynamic> toJson() => _$PsDataToJson(this);
}