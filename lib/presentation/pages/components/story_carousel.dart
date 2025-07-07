import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_brain/presentation/pages/webview_page.dart';

class StoryCarousel extends StatelessWidget {
  StoryCarousel({super.key});
  
  final List<String> titles = [
    "The Villainess",
    "Hide and Seek",
    "In for the Win",
    "Assassination on the Kill",
    "The Minotaur"
  ];
  
  final List<String> urls = [
    "https://www.wattpad.com/story/213054919-the-villainess-who-has-reborn-five-times",
    "https://www.wattpad.com/story/60315847-hide-and-seek",
    "https://www.wattpad.com/story/342242335-in-for-the-win",
    "https://www.wattpad.com/story/52663953-assassination-on-the-kill",
    "https://www.wattpad.com/story/160748487-the-minotaur"
  ];

  final List<String> genres = [
    "Fantasy",
    "Horror",
    "Romance",
    "Adventure",
    "Thriller"
  ];

  final List<String> authors = [
    "butterfly_effect",
    "Ms_Horrendous",
    "readzwithjuliette",
    "Angelgirl4ever02",
    "AdeAlaoOluwaferanmiA"
  ];

  final List<String> imagePaths = [
    "assets/sampul/theVillains.jpg",
    "assets/sampul/HideAndSeek.jpg",
    "assets/sampul/InForTheWin.jpg",
    "assets/sampul/AssassinationOnTheKill.jpg",
    "assets/sampul/TheMinotaur.jpg"
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Get.to(WebViewScreen(url: urls[index]));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(imagePaths[index]), // Menggunakan path gambar dari list
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    titles[index], // Menampilkan judul cerita dari list
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authors[index], // Menampilkan penulis cerita dari list
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
