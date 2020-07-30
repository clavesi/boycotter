class Brands {
  String name;
  String product;
  bool logo;
  List<String> warnings;
  List<String> sources;

  Brands(this.name, this.product, this.logo, this.warnings, this.sources);

  Brands.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    product = json['product'];
    logo = json['logo'];
    warnings = List<String>.from(json['warnings']);
    sources = List<String>.from(json['sources']);
  }
}
