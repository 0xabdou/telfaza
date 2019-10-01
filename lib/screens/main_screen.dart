import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telfaza/components/movies_row.dart';
import 'package:telfaza/screens/profile_screen.dart';
import 'package:telfaza/services/auth_service.dart';
import 'package:telfaza/services/db_service.dart';
import 'package:telfaza/services/tmdb_api.dart';
import 'package:telfaza/serach_movie.dart';
import 'package:telfaza/style.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DBService _dbService;

  Future<User> _userFuture;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dbService = Provider.of<DBService>(context);
    _userFuture = _dbService.currentUser();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final appBar = AppBar();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _Drawer(future: _userFuture),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: 8.0,
              left: 8.0,
              right: 8.0,
            ),
            child: ListView(
              children: [
                SizedBox(
                  height: appBar.preferredSize.height,
                ),
                MoviesRow(
                  type: PageType.popular,
                ),
                MoviesRow(
                  type: PageType.topRated,
                ),
                MoviesRow(
                  type: PageType.nowPlaying,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  //BlocProvider.of<MoviesBloc>(context).inRefresh.add(null);
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              title: Image.asset(
                'assets/images/TLFZ.png',
                height: 30.0,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: SearchMovie(context),
                    );
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  final Future<User> future;

  const _Drawer({this.future});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: kPrimaryColor,
        child: Column(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                FutureBuilder<User>(
                  future: future,
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return _DrawerHeader(user: snapshot.data);
                    }
                    return DrawerHeader(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
                Divider(
                  color: Colors.white70,
                  height: 1,
                ),
                _DrawerItem(
                  label: 'Profile',
                  icon: Icons.person,
                  onTap: () {
                    _launchProfile(context);
                  },
                ),
                _DrawerItem(
                  label: 'Favorites',
                  icon: Icons.favorite_border,
                  onTap: () {
                    Navigator.pop(context);
                    Scaffold.of(context).hideCurrentSnackBar();
                    _snackIt('Not implemented yet', context);
                  },
                ),
                _DrawerItem(
                  label: 'Watch later',
                  icon: Icons.watch_later,
                  onTap: () {
                    Navigator.pop(context);
                    Scaffold.of(context).hideCurrentSnackBar();
                    _snackIt('Not implemented yet', context);
                  },
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            _DrawerItem(
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<AuthService>(context).signOut();
              },
              label: 'Log out',
              icon: Icons.clear,
            )
          ],
        ),
      ),
    );
  }

  void _snackIt(String msg, BuildContext context) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: Text(msg),
    ));
  }

  void _launchProfile(BuildContext context) async {
    Navigator.pop(context);
    final User user = await future;
    if (user != null)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
      );
  }
}

class _DrawerHeader extends StatelessWidget {
  final User user;

  const _DrawerHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: CircleAvatar(
              radius: 26.0,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl ?? ''),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? '',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  '@${user.username ?? ''}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function onTap;

  const _DrawerItem({this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onTap,
      splashColor: Colors.white70,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
            ),
            SizedBox(
              width: 8.0,
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
