import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mbf/constants/Theme.dart';

import 'package:mbf/widgets/drawer-tile.dart';
import 'package:mbf/_pages/home.page.dart';
import 'package:mbf/_pages/profile.page.dart';

class NowDrawer extends StatelessWidget {
  final String currentPage;
  const NowDrawer({Key? key, required this.currentPage}) : super(key: key);

  _launchURL() async {
    const url = 'https://creative-tim.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
          color: Theme.of(context).primaryColor,
          child: Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24.0, right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Image.asset("assets/imgs/now-logo.png"),
                          ],
                        ),
                      ),
                    )),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: EdgeInsets.only(top: 36, left: 8, right: 16),
                    children: [
                      DrawerTile(
                          icon: FontAwesomeIcons.dharmachakra,
                          onTap: () {
                              Navigator.pushNamed(context, '/blood-requests');
                          },
                          iconColor: Theme.of(context).primaryColor,
                          title: "Blood Requests",
                      ),
                      DrawerTile(
                          icon: FontAwesomeIcons.newspaper,
                          onTap: () {
                              Navigator.pushReplacementNamed(context, '/blood-requests/new');
                          },
                          iconColor: Theme.of(context).primaryColor,
                          title: "New Blood Request",
                      ),
                      DrawerTile(
                        icon: FontAwesomeIcons.user,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/donors');
                        },
                        iconColor: Theme.of(context).primaryColor,
                        title: "Donors",
                      ),
                      DrawerTile(
                          icon: FontAwesomeIcons.gear,
                          onTap: () {
                              Navigator.pushReplacementNamed(context, '/settings');
                          },
                          iconColor: NowUIColors.success,
                          title: "Settings",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      padding: EdgeInsets.only(left: 8, right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                              height: 4,
                              thickness: 0,
                              color: NowUIColors.white.withOpacity(0.8)),
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 16.0, left: 16, bottom: 8),
                            child: Text("DOCUMENTATION",
                                style: TextStyle(
                                  color: NowUIColors.white.withOpacity(0.8),
                                  fontSize: 13,
                                )),
                          ),
                          DrawerTile(
                              icon: FontAwesomeIcons.satellite,
                              onTap: _launchURL,
                              iconColor: NowUIColors.muted,
                              title: "Getting Started",
                              isSelected:
                              currentPage == "Getting started" ? true : false),
                        ],
                      )),
                ),
              ]
          ),
        )
    );
  }
}
