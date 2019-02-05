import 'package:flutter/material.dart';
import '../model/psData.dart';
import 'package:uuid/uuid.dart';
import '../store/index.dart';
import '../route/index.dart';
import '../utils/date_utils.dart';

class VerificationMsg {
  VerificationMsg({this.isSuccess = false, this.msg = ''});

  bool isSuccess;
  String msg;
}

class Detail extends StatefulWidget {
  Detail({Key key, this.title, this.index, this.isNew = false})
      : super(key: key);

  final String title;
  final bool isNew;
  final int index;

  @override
  DetailState createState() => new DetailState();
}

class DetailState extends State<Detail> {
  bool canShow = false;
  bool isEditor = false;
  Uuid uuid = new Uuid();
  PsItem item;
  GState state;

  TextEditingController _passwordController;
  TextEditingController _accountController;
  VerificationMsg verPassword = new VerificationMsg(isSuccess: true, msg: '');
  TextEditingController _titleController;
  VerificationMsg verTitle = new VerificationMsg(isSuccess: true, msg: '');
  VerificationMsg verAccount = new VerificationMsg(isSuccess: true, msg: '');

  // 保存
  void save(BuildContext context) {
    item.modifyDate = new DateTime.now();
    if (widget.isNew) {
      item.createDate = item.modifyDate;
      state?.addPsItem(item);
      state?.savePsData()?.then((file) {
        print('Successfully saved：${file.path}');
        Application.router.pop(context);
      })?.catchError((error) {
        print('Save failed：$error');
      });
    } else {
      print(item.createDate.toString());
      state?.modifyPsItem(index: widget.index, item: item);
      state?.savePsData()?.then((file) {
        print('Successfully saved：${file.path}');
        Application.router.pop(context);
      })?.catchError((error) {
        print('Save failed：$error');
      });
    }
  }

  void setEditor(BuildContext context) {
    if (isEditor == false) {
      setState(() {
        isEditor = true;
      });
    } else if (isEditor == true &&
        verificationPassword(item.password) &&
        verificationTitle(item.title)) {
      isEditor = false;
      save(context);
    }
  }

  @override
  void initState() {
    state = GState.of(context);
    isEditor = widget.isNew;
    if (widget.isNew) {

      DateTime dt = new DateTime.now();
      item = new PsItem(
          id: uuid.v1(),
          title: '',
          account: '',
          password: '',
          createDate: dt,
          modifyDate: dt);
    } else {
      int index = widget.index;
      String id = state.data.list[index].id;
      String title = state.data.list[index].title;
      String account = state.data.list[index].account;
      String password = state.data.list[index].password;
      int status = state.data.list[index].status;
      DateTime createDate = state.data.list[index].createDate;
      DateTime modifyDate = state.data.list[index].modifyDate;
      item = new PsItem(
          id: id,
          title: title,
          account: account,
          password: password,
          status: status,
          createDate: createDate,
          modifyDate: modifyDate);
    }
    setController();
    super.initState();

  }


  bool verificationPassword(String str) {
    if (str.isEmpty) {
      print(str.isEmpty);

      setState(() {
        verPassword?.isSuccess = false;
        verPassword?.msg = 'Can not be empty';
      });
      return false;
    } else if (!str.contains(RegExp(r'^[0-9a-zA-Z]*$'))) {
      setState(() {
        verPassword?.isSuccess = false;
        verPassword?.msg = 'Only alphanumeric and special symbols can be entered';
      });
      return false;
    }
    setState(() {
      verPassword?.isSuccess = true;
      verPassword?.msg = '';
    });
    return true;
  }


  bool verificationTitle(String str) {
    if (str.isEmpty) {
      setState(() {
        verTitle?.isSuccess = false;
        verTitle?.msg = 'Can not be empty';
      });
      return false;
    }
    setState(() {
      verTitle?.isSuccess = true;
      verTitle?.msg = '';
    });
    return true;
  }

  // 验证账号
  bool verificationAccount(String str) {
    print(str.indexOf(new RegExp(r'^[0-9]*$')));
    if (str.isEmpty) {
      // 判断是否为空
      setState(() {
        verAccount?.isSuccess = false;
        verAccount?.msg = 'You may forget your account, remember it.';
      });
      return false;
    } else if (str.indexOf('@') >= 0 &&
        str.indexOf(new RegExp(
                r'^\w+((.\w+)|(-\w+))@[A-Za-z0-9]+((.|-)[A-Za-z0-9]+).[A-Za-z0-9]+$')) !=
            0) {
      setState(() {
        verAccount?.isSuccess = false;
        verAccount?.msg = 'It may not be an email address';
      });
      return false;
    } else if (str.indexOf(new RegExp(r'^[0-9]*$')) >= 0 &&
        str.indexOf(new RegExp(
                r'^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\d{8}$')) ==
            -1) {
      setState(() {
        verAccount?.isSuccess = false;
        verAccount?.msg = 'It may not be a mobile phone number';
      });
      return false;
    }
    setState(() {
      verAccount?.isSuccess = true;
      verAccount?.msg = '';
    });
    return true;
  }

  void setController() {
    _titleController = new TextEditingController(text: item.title);
    _titleController.addListener(() {
      item.title = _titleController.text;
      verificationTitle(item.title);
    });

    _accountController = new TextEditingController(text: item.account);
    _accountController.addListener(() {
      item.account = _accountController.text;
      verificationAccount(item.account);
    });

    _passwordController = new TextEditingController(text: item.password);
    _passwordController.addListener(() {
      item.password = _passwordController.text;
      verificationPassword(item.password);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          enabled: isEditor,
          controller: _titleController,
          textAlign: TextAlign.center,
          autocorrect: false,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          decoration: InputDecoration(
            hintText: 'Please fill in the title here',
            hintStyle: TextStyle(color: Color(0xffa2bdd2), fontSize: 18.0),
            border: InputBorder.none,
            enabledBorder: isEditor
                ? UnderlineInputBorder(
                    borderSide: BorderSide(
                    color: verTitle.isSuccess ? Colors.white30 : Colors.red,
                  ))
                : InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: verTitle.isSuccess ? Colors.white : Colors.red,
              ),
            ),
            contentPadding: EdgeInsets.only(bottom: 5.0),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(isEditor == true ? Icons.done : Icons.edit),
            onPressed: () {
              setEditor(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                ),
                child: Text(
                  item.modifyDate != null
                      ? toDateTimeStringZH(
                          datetime: item.modifyDate,
                          formatString: 'yyyyMMdd hh:mm')
                      : '',
                  style: TextStyle(
                    fontSize: 14.0,
                    height: 1.2,
                    color: Color(0xff8d989c),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20.0,
                        // bottom: 20.0,
                      ),
                      child: TextField(
                        enabled: isEditor,
                        controller: _accountController,
                        // obscureText: !canShow,
                        decoration: InputDecoration(
                          labelText: 'Account number (optional)',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                            height: 1.0,
                            color: verAccount.isSuccess ? null : Colors.orange,
                          ),
                          hintText: 'xxx@163.com',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            height: 1.0,
                            color: Color(0xff999999),
                          ),
                          errorText:
                              verAccount.msg.isNotEmpty ? verAccount.msg : null,
                          errorStyle: TextStyle(
                            color: Colors.orange,
                          ),
                          border: OutlineInputBorder(),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.orange,
                          )),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.orange,
                          )),
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20.0,
                        bottom: 40.0,
                      ),
                      child: TextField(
                        enabled: isEditor,
                        controller: _passwordController,
                        obscureText: !canShow,
                        style: TextStyle(
                          fontSize: 14.0,
                          height: 1.0,
                          color: Color(0xff333333),
                        ),
                        decoration: InputDecoration(
                            labelText: 'password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintText: 'Please fill in the password',
                            hintStyle: TextStyle(
                              color: Colors.cyan,
                              height: 1.0,
                              fontSize: 14.0,
                            ),
                            errorText: verPassword.msg.isNotEmpty
                                ? verPassword.msg
                                : null,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(10.0),
                            suffixIcon: Offstage(
                              offstage: !isEditor,
                              child: IconButton(
                                icon: Icon(
                                  canShow == true
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: canShow == true
                                      ? Colors.blue
                                      : Color(0xff999999),
                                ),
                                onPressed: () {
                                  setState(() {
                                    canShow = !canShow;
                                  });
                                },
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                ),
                child: Text(
                  'Creation time：${item.createDate != null ? toDateTimeStringZH(datetime: item.createDate, formatString: 'yyyyMMdd hh:mm') : ''}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.0,
                    height: 1.2,
                    color: Color(0xffb6b6b6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          canShow == true ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            canShow = !canShow;
          });
        },
      ),
    );
  }
}
