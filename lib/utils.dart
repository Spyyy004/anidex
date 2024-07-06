import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color(0xFF173EA5);

final buttonStyles = OutlinedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  side: BorderSide(color: Color(0xFF173EA5)),
  backgroundColor: Color(0xFF173EA5),
);

final gemini = Gemini.instance;

const prompt = """Objective: Identify the animal in the provided image and return detailed information in a Pokedex style. If there is no animal in the image, return a message as 'Invalid Image. No animal found'. Response must be in JSON format.

JSON Structure:
{
  "animalIdentification": "identified_animal",
  "basicInformation": {
    "commonName": "NA",
    "scientificName": "NA",
    "classification": {
      "kingdom": "NA",
      "phylum": "NA",
      "class": "NA",
      "order": "NA",
      "family": "NA",
      "genus": "NA",
      "species": "NA"
    },
    "physicalDescription": "NA",
    "habitat": "NA",
    "geographicDistribution": ["NA"],
    "behavior": "NA",
    "diet": "NA",
    "rarity": "NA",
    "type":"water or land or air"
    "conservationStatus": "NA",
    "interestingFacts": ["NA"]
  }
}

Guidelines:
1. Always return the response in the above JSON format.
2. If an animal is found, fill in the fields with the relevant information.
3. If no animal is found, use "NA" for all fields.
4. Decide the rarity of the animals very carefully.Here is some help to decide rarity
1-3: Species that are widespread and have large populations.
4-5: Species that are regularly encountered but may not be as widespread as abundant species.
6-8: Species that are less frequently encountered but still present in certain habitats.
9-10: Species that have small populations or limited distributions.

Example Response:
{
  "animalIdentification": "Bald Eagle",
  "basicInformation": {
    "commonName": "Bald Eagle",
    "scientificName": "Haliaeetus leucocephalus",
    "classification": {
      "kingdom": "Animalia",
      "phylum": "Chordata",
      "class": "Aves",
      "order": "Accipitriformes",
      "family": "Accipitridae",
      "genus": "Haliaeetus",
      "species": "H. leucocephalus"
    },
    "type": "water"
    "physicalDescription": "Large raptor with white head and tail feathers, yellow beak, and dark brown body and wings.",
    "habitat": "Near large bodies of open water with abundant fish.",
    "geographicDistribution": ["North America"],
    "behavior": "Solitary or in pairs, known for their powerful flight.",
    "diet": "Primarily fish, also small mammals and carrion.",
    "rarity": 4,
    "conservationStatus": "Least Concern",
    "interestingFacts": [
      "National bird of the United States.",
      "Can live up to 20-30 years in the wild."
    ]
  }
}
""";

TextStyle headerStyles = GoogleFonts.mPlusCodeLatin(
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 40)
);

TextStyle subHeaderStyles = GoogleFonts.mPlusCodeLatin(
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 32)
);

TextStyle subHeaderNormalStyles = GoogleFonts.mPlusCodeLatin(
    textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 32)
);

TextStyle header3Styles = GoogleFonts.mPlusCodeLatin(
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)
);

TextStyle header3NormalStyles = GoogleFonts.poppins(
    textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 24)
);

TextStyle titleStyles = GoogleFonts.poppins(
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
);

TextStyle regularTitleStyles = GoogleFonts.poppins(
    textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)
);

TextStyle labelStyles = GoogleFonts.poppins(
    textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 20)
);

TextStyle subtitleStyles = GoogleFonts.poppins(
    textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)
);

TextStyle boldSubtitleStyles = GoogleFonts.poppins(
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
);