import 'package:anidex/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onboarding/onboarding.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currIndex = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Onboarding(
          startIndex: 0,
          onPageChanges:(netDragDistance,pagesLength,currentIndex, slideDirection){
            currIndex = currentIndex;
          },
            buildFooter:(context, netDragDistance, pagesLength, currentIndex, setIndex, slideDirection){
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0,right: 40),
                      child: Indicator(painter: CirclePainter(
                          showAllActiveIndicators: true,
                          netDragPercent: 0, pagesLength: 3, currentPageIndex: currIndex, slideDirection: SlideDirection.right_to_left)),
                    );
            },
          buildHeader:(context, netDragDistance, pagesLength, currentIndex, setIndex, slideDirection){
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return LoginScreen();
                        }));
                      },
                      child: Text("Skip>",style: GoogleFonts.poppins(fontSize: 16),)),
                )
              ],
            );
          },
          swipeableBody: [
            PageOne(imagePath: 'assets/observe.png', title: 'Observe', description: 'Get outside, observe an animal, click a clear picture.',width: 177,height: 280,
            ),
            PageOne(imagePath: 'assets/owl.png', title: 'Learn', description: 'Anidex will automatically identify the animal and provide detailed insights.',width: 300,height: 280
            ),
            PageOne(imagePath: 'assets/interact.png', title: 'Interact', description: 'Interact with animals through an AI powered chat feature..',width: 300,height: 280
            ),
          ],
        ),
      )
      );
  }
}


class PageOne extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final double height;
  final double width;
  const PageOne({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.width,
    required this.height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            imagePath,
            height: height,
            width: width,
          ),
        ),
        SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w200,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
