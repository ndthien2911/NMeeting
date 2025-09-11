import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PageVersion extends StatefulWidget {
  final String appstoreUrl;

  PageVersion({Key? key, required this.appstoreUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageVersionState();
  }
}

class _PageVersionState extends State<PageVersion> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    final _paddingTop = _mediaQuery.size.height * 0.2;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: _paddingTop, bottom: 25),
              child: Image(
                image: AssetImage('lib/assets/images/version-error.png'),
                fit: BoxFit.fill,
                width: 250,
                height: 250,
              ),
            ),
            Text(
              'Phiên bản hiện tại đã cũ, vui lòng bấm vào bên dưới để cài đặt phiên bản mới.',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(50, 20, 50, 0),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 29, 40, 238),
                    Color.fromARGB(255, 16, 113, 230)
                  ],
                ),
              ),
              child: MaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                minWidth: 300,
                height: 50,
                child: Text(
                  'Đến kho ứng dụng',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (await canLaunch(widget.appstoreUrl)) {
                    await launch(widget.appstoreUrl);
                  } else {
                    throw 'Could not launch $widget.appstoreUrl';
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
