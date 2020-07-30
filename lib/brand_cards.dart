import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';

import 'brands.dart';

class BrandCards extends StatefulWidget {
  @override
  _BrandCardsState createState() => _BrandCardsState();
}

// TODO use auto_size_text more

class _BrandCardsState extends State<BrandCards> {
  // Two lists, one of every brand
  List<Brands> _brands = List<Brands>();
  // and one that showcases all the ones that meet the searchbar text
  List<Brands> _displayBrands = List<Brands>();
  List<String> _hasLogo = List<String>();
  Icon _searchIcon = Icon(Icons.search);
  bool _loadingCards = true;
  Widget _appBarTitle = Text('Boycotter');

  // Fetch and load JSON information
  Future<List<Brands>> fetchBrands() async {
    var url =
        'https://raw.githubusercontent.com/clavesi/brandsJSON/master/brands.json';
    var response = await http.get(url);

    var brands = List<Brands>();

    if (response.statusCode == 200) {
      var brandsJson = json.decode(response.body);
      for (var brandJson in brandsJson) {
        brands.add(Brands.fromJson(brandJson));
        if (Brands.fromJson(brandJson).logo) {
          _hasLogo.add(Brands.fromJson(brandJson).name);
        }
      }
    }
    return brands;
  }

  @override
  void initState() {
    fetchBrands().then((value) {
      setState(() {
        _brands.addAll(value);
        _displayBrands = _brands;
        _loadingCards = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCards) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      appBar: _buildSearchbar(context),
      body: Container(
        child: ListView.builder(
          itemCount: _displayBrands.length,
          itemBuilder: (BuildContext context, int index) =>
              buildBrandCard(context, index),
        ),
      ),
    );
  }

  // Custom AppBar to allow for search functionality
  _buildSearchbar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  // Open and close search
  _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = Icon(Icons.close);
        // You can still type without clicking on the searchbar, but it
        // shouldn't be that big of a deal.
        _appBarTitle = TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
          onChanged: (text) {
            text = text.toLowerCase();
            setState(() {
              _displayBrands = _brands.where((brand) {
                var brandName = removeDiacritics(brand.name.toLowerCase());
                return brandName.contains(text);
              }).toList();
            });
          },
        );
      } else {
        _searchIcon = Icon(Icons.search);
        _appBarTitle = Text('Boycotter');
        _displayBrands = _brands;
      }
    });
  }

  // Card widget that's fillable
  Widget buildBrandCard(BuildContext context, int index) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          height: 125,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _expandBrand(_displayBrands[index]),
                ),
              );
            },
            child: Card(
              elevation: 8,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 125,
                    child: _getLogo(_displayBrands[index].name),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 143,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: AutoSizeText(
                            _displayBrands[index].name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            presetFontSizes: [30, 20, 14],
                            maxFontSize: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // :smile
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: AutoSizeText(
                            _displayBrands[index].product,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                            presetFontSizes: [20, 16, 12],
                            maxFontSize: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: _getWarnings(_displayBrands[index], 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getLogo(String name) {
    if (_hasLogo.contains(name)) {
      return Image(
          image: AssetImage(
              'assets/logos/${name.toLowerCase().replaceAll(" ", "")}.png'));
    } else {
      return Image(image: AssetImage('assets/logos/nologo.png'));
    }
  }

  _getWarnings(Brands brand, double size) {
    final List<Widget> warnIcons = <Widget>[];
    for (var warning in brand.warnings) {
      String icon =
          'assets/icons/${warning.toLowerCase().replaceAll(" ", "")}.png';
      warnIcons.add(Container(
        width: size,
        height: size,
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Image(image: AssetImage(icon)),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: warnIcons,
    );
  }

  _expandBrand(Brands brand) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(brand.name),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: _getLogo(brand.name),
                ),
                Text(
                  brand.name,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  brand.product,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                _getWarnings(brand, 55),
                _getSources(brand.sources),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getSources(List<String> brand) {
    var sourcesList = <Widget>[];

    for (var source in brand) {
      sourcesList.add(_buildExpanded(source));
    }

    return GridView.count(
      physics: ScrollPhysics(),
      crossAxisCount: 2,
      shrinkWrap: true,
      children: List.generate(
        sourcesList.length,
        (index) => sourcesList[index],
      ),
    );
  }

  _getSourceData(String source) async {
    var data = await extract(source);
    return data;
  }

  _getSourceName(String url) {
    String name;

    // Cut off useless bits of the url
    int beginUrl = url.indexOf('://');
    int checkForWWW = url.indexOf('www.');
    List<String> domains = ['.gov', '.org', '.com'];
    int domainLevel;
    for (var domain in domains) {
      if (url.contains(domain)) {
        domainLevel = domains.indexOf(domain);
      }
    }
    int topLevelDomain = url.indexOf(domains[domainLevel]);
    checkForWWW == -1
        ? name = url.substring(beginUrl + 3, topLevelDomain)
        : name = url.substring(checkForWWW + 4, topLevelDomain);

    return name.toUpperCase();
  }

  _buildExpanded(String source) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        child: InkWell(
          onTap: () async {
            if (await canLaunch(source)) {
              await launch(source);
            } else {
              throw 'Could not launch $source';
            }
          },
          child: FutureBuilder(
            future: _getSourceData(source),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Card(
                  elevation: 8,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        // TODO if no image, insert template for one of their warnings
                        child: Image.network(
                          snapshot.data.image,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: AutoSizeText(
                            snapshot.data.title,
                            style: TextStyle(fontSize: 100),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: AutoSizeText(
                            _getSourceName(snapshot.data.url),
                            style: TextStyle(fontSize: 100),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
