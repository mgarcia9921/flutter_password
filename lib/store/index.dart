import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../model/psData.dart';

class Io {
  static String _localPath = '';
  static File _file;

  static Future<String> get localPath {
    if (_localPath.isNotEmpty) {
      return Future<String>(() =>_localPath);
    } else {
      return getApplicationDocumentsDirectory().then((dir) {
        _localPath = dir.path;
        return _localPath;
      });
    }
  }

  static Future<File> get file {
    if (_file != null) {
      return Future<File>(() => _file);
    } else {
      return localPath.then((path) {
        _file = File('$path/data.json');
        return _file;
      }).catchError((e) {
        return null;
      });
    }
  }

  static Future<String> readData () {
    return file.then((file) {
      return file.readAsString().then((String data) {
        return data;
      }).catchError((e) {
        return e;
      });
    });
  }

  static Future<File> writeData(String jsonString) {
    return file.then((File file) {
      return file.writeAsString(jsonString);
    }); 
  }
}

class GState extends Model {
  PsData _data;
  PsData get data => _data;

  GState() {
    _data = new PsData(id: '0', account: 'plusli', list: []);
    loadData();
  }

  void loadData() {
    Io.readData().then((String jsonStr) {
      Map<String, dynamic> jsonMap = json.decode(jsonStr);
      PsData data = new PsData.fromJson(jsonMap);
      setData(data);
    }).catchError((error){
      print('File read failed:$error');
    });
  }

  void setData(PsData data){
    _data = data;
    notifyListeners();
  }

  Future<File> savePsData() {
    Map<String, dynamic> mapData = _data.toJson();
    String jsonStr = json.encode(mapData);
    return Io.writeData(jsonStr);
  }

  void addPsItem(PsItem item) {
    _data.list.add(item);
  }

  void modifyPsItem({int index, PsItem item}){
    _data.list[index] = item;
  }

  void delPsItem({int index}) {
    _data.list.removeAt(index);
    notifyListeners();
  }

  void starItem({int index,int status}) {
    data.list[index].status = status;
    notifyListeners();
  }

  static GState of(BuildContext context){
    return ScopedModel.of<GState>(context);
  }
}
