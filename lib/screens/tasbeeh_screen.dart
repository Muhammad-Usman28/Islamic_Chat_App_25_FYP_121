import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int? n = 0;
  //  Method for containing record of Tasbeeh Count
  Future<void> updateTasbeehCount(
      String userId, String ayatId, String tasbeeh, int newValue) async {
    final tasbeehRef = FirebaseFirestore.instance
        .collection('users_tasbeeh')
        .doc(userId)
        .collection('tasbeehs')
        .doc(ayatId);

    await tasbeehRef.set({
      'tasbeeh': tasbeeh,
      'value': newValue,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    double? height = MediaQuery.of(context).size.height;
    double? width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff292E49),
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFADB5BD)),
          title: Text(
            "Dhikar Counter",
            style: GoogleFonts.roboto(
              fontSize: 22,
              color: Color(0xFFADB5BD),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff536976),
                Color(0xff292E49),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Tasbeeh')
                .snapshots()
                .map((snapshot) {
              return snapshot.docs
                  .map((doc) => {
                        'id': doc.id,
                        'tasbeeh': doc['tasbeeh'],
                        'translation': doc['translation'],
                      })
                  .toList();
            }),
            builder: (context, ayatSnapshot) {
              if (ayatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final ayatList = ayatSnapshot.data ?? [];

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users_tasbeeh')
                    .doc("${FirebaseAuth.instance.currentUser!.email}")
                    .collection('tasbeehs')
                    .snapshots()
                    .map((snapshot) {
                  return snapshot.docs
                      .map((doc) => {
                            'id': doc.id,
                            'tasbeeh': doc['tasbeeh'],
                            'value': doc['value'],
                          })
                      .toList();
                }),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final userTasbeehs = userSnapshot.data ?? [];

                  return ListView.builder(
                    itemCount: ayatList.length,
                    itemBuilder: (context, index) {
                      final ayat = ayatList[index];
                      final userTasbeeh = userTasbeehs.firstWhere(
                          (tasbeeh) => tasbeeh['id'] == ayat['id'],
                          orElse: () => {'value': 0});

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(20),
                              height: height * 0.21,
                              width: width * 0.85,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xffBBD2C5).withValues(alpha: 0.8),
                                    Color(0xff536976).withValues(alpha: 0.8),
                                    Color(0xff292E49).withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset(0,
                                        5), // Subtle shadow below the container
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        ayat['tasbeeh'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.5),
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.015,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: width * 0.1,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.remove),
                                          color: Colors.white,
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed: () {
                                            if (userTasbeeh['value'] > 0) {
                                              updateTasbeehCount(
                                                "${FirebaseAuth.instance.currentUser!.email}",
                                                ayat['id'],
                                                ayat['tasbeeh'],
                                                userTasbeeh['value'] - 1,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.4,
                                        child: Center(
                                          child: Text(
                                            'Count: ${userTasbeeh['value']}',
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.4),
                                                  offset: Offset(1, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.05,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.add),
                                          color: Colors.white,
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed: () {
                                            updateTasbeehCount(
                                              "${FirebaseAuth.instance.currentUser!.email}",
                                              ayat['id'],
                                              ayat['tasbeeh'],
                                              userTasbeeh['value'] + 1,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      updateTasbeehCount(
                                        "${FirebaseAuth.instance.currentUser!.email}",
                                        ayat['id'],
                                        ayat['tasbeeh'],
                                        0, // Reset value
                                      );
                                    },
                                    child: Container(
                                      height: height * 0.05,
                                      width: width * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Color(0xffBBD2C5)
                                            .withValues(alpha: 0.8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Reset",
                                          style: GoogleFonts.roboto(
                                            color: Color(0xff292E49),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
