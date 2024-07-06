class AnimalInfoModel {
  String? animalIdentification;
  BasicInformation? basicInformation;

  AnimalInfoModel({this.animalIdentification, this.basicInformation});

  AnimalInfoModel.fromJson(Map<String, dynamic> json) {
    animalIdentification = json['animalIdentification'];
    basicInformation = json['basicInformation'] != null ? new BasicInformation.fromJson(json['basicInformation']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['animalIdentification'] = this.animalIdentification;
    if (this.basicInformation != null) {
      data['basicInformation'] = this.basicInformation!.toJson();
    }
    return data;
  }
}

class BasicInformation {
  String? commonName;
  String? scientificName;
  Classification? classification;
  String? physicalDescription;
  String? habitat;
  List<String>? geographicDistribution;
  String? behavior;
  String? diet;
  int? rarity;
  String? type;
  String? conservationStatus;
  List<String>? interestingFacts;

  BasicInformation({this.commonName, this.scientificName, this.classification, this.physicalDescription, this.habitat, this.geographicDistribution, this.behavior, this.diet, this.rarity, this.conservationStatus, this.interestingFacts});

  BasicInformation.fromJson(Map<String, dynamic> json) {
    commonName = json['commonName'];
    scientificName = json['scientificName'];
    classification = json['classification'] != null ? new Classification.fromJson(json['classification']) : null;
    physicalDescription = json['physicalDescription'];
    habitat = json['habitat'];
    geographicDistribution = json['geographicDistribution'].cast<String>();
    behavior = json['behavior'];
    diet = json['diet'];
    rarity = json['rarity'];
    conservationStatus = json['conservationStatus'];
    interestingFacts = json['interestingFacts'].cast<String>();
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['commonName'] = this.commonName;
    data['scientificName'] = this.scientificName;
    if (this.classification != null) {
      data['classification'] = this.classification!.toJson();
    }
    data['physicalDescription'] = this.physicalDescription;
    data['habitat'] = this.habitat;
    data['geographicDistribution'] = this.geographicDistribution;
    data['behavior'] = this.behavior;
    data['diet'] = this.diet;
    data['rarity'] = this.rarity;
    data['conservationStatus'] = this.conservationStatus;
    data['interestingFacts'] = this.interestingFacts;
    data['type'] = this.type;
    return data;
  }
}

class Classification {
  String? kingdom;
  String? phylum;
  String? animalClass;
  String? order;
  String? family;
  String? genus;
  String? species;

  Classification({this.kingdom, this.phylum, this.animalClass, this.order, this.family, this.genus, this.species});

  Classification.fromJson(Map<String, dynamic> json) {
  kingdom = json['kingdom'];
  phylum = json['phylum'];
  animalClass = json['class'];
  order = json['order'];
  family = json['family'];
  genus = json['genus'];
  species = json['species'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['kingdom'] = this.kingdom;
  data['phylum'] = this.phylum;
  data['class'] = this.animalClass;
  data['order'] = this.order;
  data['family'] = this.family;
  data['genus'] = this.genus;
  data['species'] = this.species;
  return data;
  }
}
